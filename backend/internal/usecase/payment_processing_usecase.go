package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// PaymentProcessingUsecase implements domain.PaymentProcessingUseCase with real Stripe integration.
type PaymentProcessingUsecase struct {
	paymentRepo  domain.RidePaymentRepository
	stripeClient domain.StripeClient
	rideRepo     domain.RideRepository
	userRepo     domain.UserRepository
	earningsRepo domain.EarningsRepository
	txManager    domain.TransactionManager
}

// NewPaymentProcessingUsecase creates a new payment processing usecase.
func NewPaymentProcessingUsecase(
	paymentRepo domain.RidePaymentRepository,
	stripeClient domain.StripeClient,
	rideRepo domain.RideRepository,
	userRepo domain.UserRepository,
	earningsRepo domain.EarningsRepository,
	txManager domain.TransactionManager,
) *PaymentProcessingUsecase {
	return &PaymentProcessingUsecase{
		paymentRepo:  paymentRepo,
		stripeClient: stripeClient,
		rideRepo:     rideRepo,
		userRepo:     userRepo,
		earningsRepo: earningsRepo,
		txManager:    txManager,
	}
}

// ProcessPayment charges the passenger's card for a completed ride.
// This is the public entry point for the auto-charge flow triggered on ride completion.
func (uc *PaymentProcessingUsecase) ProcessPayment(ctx context.Context, passengerID uuid.UUID, rideID uuid.UUID, paymentToken string, idempotencyKey string) (*domain.Payment, error) {
	err := uc.ChargeRide(ctx, passengerID, rideID, paymentToken, idempotencyKey)
	if err != nil {
		return nil, err
	}
	return uc.paymentRepo.GetByRideID(ctx, rideID)
}

// ChargeRide performs the actual charge flow:
// 1. Look up the ride to get the fare amount
// 2. Charge via Stripe
// 3. Create payment record
// 4. If successful, create driver earnings record
func (uc *PaymentProcessingUsecase) ChargeRide(ctx context.Context, passengerID uuid.UUID, rideID uuid.UUID, paymentMethodID string, idempotencyKey string) error {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return err
	}

	// Ownership: only the ride's passenger may pay for it (M2).
	if ride.PassengerID != passengerID {
		return domain.ErrForbidden
	}
	// Idempotency: if a payment already exists, do not charge again (M2).
	if existing, err := uc.paymentRepo.GetByRideID(ctx, rideID); err == nil && existing != nil {
		return nil
	}

	// Determine charge amount.
	amount := ride.EstimatedFare
	if ride.ActualFare != nil && *ride.ActualFare > 0 {
		amount = ride.ActualFare
	}
	if amount == nil || *amount <= 0 {
		return fmt.Errorf("ride %s has no valid fare amount", rideID)
	}

	// Charge via Stripe.
	result, err := uc.stripeClient.ChargePaymentMethod(ctx, paymentMethodID, *amount, "USD", idempotencyKey)
	if err != nil {
		return fmt.Errorf("stripe charge failed: %w", err)
	}

	// Build payment record.
	now := time.Now()
	payment := &domain.Payment{
		ID:             uuid.New(),
		RideID:         rideID,
		PassengerID:    passengerID,
		Method:         domain.PaymentMethodCard,
		Amount:         *amount,
		Currency:       "USD",
		CreatedAt:      now,
		IdempotencyKey: &idempotencyKey,
	}

	if result.Success {
		payment.Status = domain.PaymentStatusCompleted
		payment.StripeChargeID = &result.ChargeID
		payment.GatewayTransactionID = &result.ChargeID
		payment.ProcessedAt = &now
	} else {
		payment.Status = domain.PaymentStatusFailed
		payment.FailureReason = &result.FailureReason
	}

	// Wrap in transaction for atomicity.
	err = uc.txManager.WithTransaction(ctx, func(ctx context.Context) error {
		// Persist payment record.
		if err := uc.paymentRepo.Create(ctx, payment); err != nil {
			return fmt.Errorf("failed to create payment record: %w", err)
		}

		// If charge succeeded, create driver earnings record.
		if result.Success && ride.DriverID != nil {
			driverID := *ride.DriverID
			earnings := &domain.DriverEarnings{
				ID:          uuid.New(),
				DriverID:    driverID,
				RideID:      rideID,
				FareAmount:  *amount,
				TipAmount:   0,
				TotalAmount: *amount,
				Currency:    "USD",
				CompletedAt: now,
			}
			if err := uc.earningsRepo.Create(ctx, earnings); err != nil {
				return fmt.Errorf("failed to create earnings record: %w", err)
			}
		}
		return nil
	})

	if err != nil {
		return err
	}

	if !result.Success {
		return domain.ErrPaymentFailed
	}

	return nil
}

// GetReceipt returns the payment receipt for a ride.
func (uc *PaymentProcessingUsecase) GetReceipt(ctx context.Context, userID uuid.UUID, rideID uuid.UUID) (*domain.Payment, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	// Only the passenger or assigned driver may view the receipt.
	if ride.PassengerID != userID && (ride.DriverID == nil || *ride.DriverID != userID) {
		return nil, domain.ErrForbidden
	}
	return uc.paymentRepo.GetByRideID(ctx, rideID)
}
