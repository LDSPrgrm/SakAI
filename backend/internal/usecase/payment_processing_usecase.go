package usecase

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// StripeClient defines the interface for interacting with Stripe's API.
// This allows mocking in tests and swapping providers later.
type StripeClient interface {
	// Charge creates a payment intent and returns the transaction ID or an error.
	Charge(ctx context.Context, amountCents int64, currency string, paymentMethodToken string, idempotencyKey string) (transactionID string, err error)
}

type paymentProcessingUseCase struct {
	paymentRepo domain.RidePaymentRepository
	rideRepo    domain.RideRepository
	stripe      StripeClient
}

// NewPaymentProcessingUseCase creates a new domain.PaymentProcessingUseCase.
func NewPaymentProcessingUseCase(
	paymentRepo domain.RidePaymentRepository,
	rideRepo domain.RideRepository,
	stripe StripeClient,
) domain.PaymentProcessingUseCase {
	return &paymentProcessingUseCase{
		paymentRepo: paymentRepo,
		rideRepo:    rideRepo,
		stripe:      stripe,
	}
}

func (uc *paymentProcessingUseCase) ProcessPayment(ctx context.Context, passengerID uuid.UUID, rideID uuid.UUID, paymentToken string, idempotencyKey string) (*domain.Payment, error) {
	// Verify ride exists and belongs to passenger.
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.PassengerID != passengerID {
		return nil, domain.ErrForbidden
	}

	// Guard: ride must be completed before payment.
	if ride.Status != domain.RideStatusCompleted {
		return nil, domain.ErrRideNotCompleted
	}

	// Check if payment already exists for this ride (idempotency).
	existingPayment, err := uc.paymentRepo.GetByRideID(ctx, rideID)
	if err == nil && existingPayment != nil {
		if existingPayment.Status == domain.PaymentStatusCompleted {
			// Already paid — return existing payment (idempotent).
			return existingPayment, nil
		}
		// Payment exists but not completed — allow retry (e.g., failed -> retry).
	} else if err != nil && err != domain.ErrNotFound {
		return nil, err
	}

	// Calculate amount in cents for Stripe.
	amountCents := int64(ride.Fare * 100)
	currency := "USD" // TODO: make configurable per region.

	// Process charge via Stripe.
	transactionID, err := uc.stripe.Charge(ctx, amountCents, currency, paymentToken, idempotencyKey)
	if err != nil {
		// Record failed payment.
		now := time.Now()
		failureReason := fmt.Sprintf("Stripe charge failed: %v", err)
		payment := &domain.Payment{
			ID:            uuid.New(),
			RideID:        rideID,
			Amount:        ride.Fare,
			Currency:      currency,
			Method:        domain.PaymentMethodCard,
			Status:        domain.PaymentStatusFailed,
			FailureReason: &failureReason,
			CreatedAt:     now,
		}
		if createErr := uc.paymentRepo.Create(ctx, payment); createErr != nil {
			return nil, createErr
		}
		return payment, domain.ErrPaymentFailed
	}

	// Record successful payment.
	now := time.Now()
	gatewayResp, _ := json.Marshal(map[string]string{
		"stripe_intent_id": transactionID,
		"status":           "succeeded",
	})
	gatewayRespStr := string(gatewayResp)

	payment := &domain.Payment{
		ID:                   uuid.New(),
		RideID:               rideID,
		Amount:               ride.Fare,
		Currency:             currency,
		Method:               domain.PaymentMethodCard,
		Status:               domain.PaymentStatusCompleted,
		GatewayTransactionID: &transactionID,
		GatewayResponse:      &gatewayRespStr,
		ProcessedAt:          &now,
		CreatedAt:            now,
	}

	if err := uc.paymentRepo.Create(ctx, payment); err != nil {
		return nil, err
	}
	return payment, nil
}

func (uc *paymentProcessingUseCase) GetReceipt(ctx context.Context, userID uuid.UUID, rideID uuid.UUID) (*domain.Payment, error) {
	// Verify user has access to this ride (passenger or driver).
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.PassengerID != userID && (ride.DriverID == nil || *ride.DriverID != userID) {
		return nil, domain.ErrForbidden
	}

	payment, err := uc.paymentRepo.GetByRideID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	return payment, nil
}
