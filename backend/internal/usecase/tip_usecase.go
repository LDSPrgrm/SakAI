package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type tipUseCase struct {
	tipRepo  domain.TipRepository
	rideRepo domain.RideRepository
	stripe   domain.StripeClient
}

// NewTipUseCase creates a new domain.TipUseCase.
func NewTipUseCase(
	tipRepo domain.TipRepository,
	rideRepo domain.RideRepository,
	stripe domain.StripeClient,
) domain.TipUseCase {
	return &tipUseCase{
		tipRepo:  tipRepo,
		rideRepo: rideRepo,
		stripe:   stripe,
	}
}

func (uc *tipUseCase) AddTip(ctx context.Context, passengerID uuid.UUID, rideID uuid.UUID, tipAmount float64) (*domain.TipOutput, error) {
	// Verify ride exists and belongs to passenger.
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.PassengerID != passengerID {
		return nil, domain.ErrForbidden
	}

	// Guard: ride must be completed before tipping.
	if ride.Status != domain.RideStatusCompleted {
		return nil, domain.ErrRideNotCompleted
	}

	// Validate tip amount: must be > 0.
	if tipAmount <= 0 {
		return nil, domain.ErrInvalidTipAmount
	}

	// Validate tip amount: must be <= 50% of base fare.
	maxTip := ride.Fare * 0.5
	if tipAmount > maxTip {
		return nil, fmt.Errorf("%w: tip exceeds 50%% of base fare", domain.ErrInvalidTipAmount)
	}

	// Check if tip already added for this ride.
	existingTip, err := uc.tipRepo.GetByRideID(ctx, rideID)
	if err != nil && err != domain.ErrNotFound {
		return nil, err
	}
	if existingTip != nil {
		return nil, domain.ErrTipAlreadyAdded
	}

	// Process the tip via Stripe.
	currency := "USD" // TODO: make configurable per region.
	idempotencyKey := fmt.Sprintf("tip_%s_%s", rideID.String(), uuid.New().String()[:8])

	// Note: Tips are charged to the passenger's saved payment method on file.
	// For now, we use a placeholder — in production, look up the passenger's default payment method.
	result, err := uc.stripe.ChargePaymentMethod(ctx, "", tipAmount, currency, idempotencyKey)
	if err != nil {
		return nil, fmt.Errorf("stripe charge failed: %w", err)
	}
	if !result.Success {
		return nil, fmt.Errorf("tip charge failed: %s", result.FailureReason)
	}
	transactionID := result.ChargeID

	// Delegate to repository to persist the tip record.
	tipOutput, err := uc.tipRepo.AddTip(ctx, rideID, tipAmount)
	if err != nil {
		return nil, err
	}

	// Enrich with transaction ID from Stripe.
	tipOutput.TransactionID = transactionID

	return tipOutput, nil
}
