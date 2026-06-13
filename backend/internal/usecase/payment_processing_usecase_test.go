package usecase_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/internal/usecase"
	"go.uber.org/mock/gomock"
)

type mockTxManager struct{}

func (m *mockTxManager) WithTransaction(ctx context.Context, fn func(ctx context.Context) error) error {
	return fn(ctx)
}

func TestPaymentProcessingUsecase_ChargeRide_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	passengerID := uuid.New()
	driverID := uuid.New()
	rideID := uuid.New()
	stripeChargeID := "ch_test_123"
	idemKey := "idem-pay-1"
	rideAmount := 250.0
	paymentMethodID := "pm_test_123"

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)

	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	// Ride repo expects the ride lookup
	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{
		ID:            rideID,
		PassengerID:   passengerID,
		DriverID:      &driverID,
		ActualFare:    &rideAmount,
		EstimatedFare: &rideAmount,
	}, nil)

	// Idempotency check: no prior payment exists for this ride.
	paymentRepo.EXPECT().GetByRideID(gomock.Any(), rideID).Return(nil, domain.ErrNotFound)

	// Stripe client expects the charge call
	stripeClient.EXPECT().ChargePaymentMethod(gomock.Any(), paymentMethodID, rideAmount, "USD", idemKey).Return(&domain.StripeChargeResult{
		Success:  true,
		ChargeID: stripeChargeID,
	}, nil)

	// Payment repo expects Create
	paymentRepo.EXPECT().Create(gomock.Any(), gomock.Any()).DoAndReturn(func(ctx context.Context, p *domain.Payment) error {
		if p.Status != domain.PaymentStatusCompleted {
			t.Errorf("expected payment status completed, got %s", p.Status)
		}
		if p.StripeChargeID == nil || *p.StripeChargeID != stripeChargeID {
			t.Errorf("expected stripe charge ID %s, got %v", stripeChargeID, p.StripeChargeID)
		}
		return nil
	})

	// Earnings repo expects Create
	earningsRepo.EXPECT().Create(gomock.Any(), gomock.Any()).DoAndReturn(func(ctx context.Context, e *domain.DriverEarnings) error {
		if e.DriverID != driverID {
			t.Errorf("expected driver ID %s, got %s", driverID, e.DriverID)
		}
		if e.RideID != rideID {
			t.Errorf("expected ride ID %s, got %s", rideID, e.RideID)
		}
		return nil
	})

	err := uc.ChargeRide(context.Background(), passengerID, rideID, paymentMethodID, idemKey)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestPaymentProcessingUsecase_ChargeRide_Failure(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	passengerID := uuid.New()
	driverID := uuid.New()
	rideID := uuid.New()
	idemKey := "idem-pay-fail"
	rideAmount := 250.0
	paymentMethodID := "pm_declined"
	failureReason := "Your card was declined."

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)

	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{
		ID:            rideID,
		PassengerID:   passengerID,
		DriverID:      &driverID,
		ActualFare:    &rideAmount,
		EstimatedFare: &rideAmount,
	}, nil)

	// Idempotency check: no prior payment exists for this ride.
	paymentRepo.EXPECT().GetByRideID(gomock.Any(), rideID).Return(nil, domain.ErrNotFound)

	stripeClient.EXPECT().ChargePaymentMethod(gomock.Any(), paymentMethodID, rideAmount, "USD", idemKey).Return(&domain.StripeChargeResult{
		Success:       false,
		FailureReason: failureReason,
	}, nil)

	paymentRepo.EXPECT().Create(gomock.Any(), gomock.Any()).DoAndReturn(func(ctx context.Context, p *domain.Payment) error {
		if p.Status != domain.PaymentStatusFailed {
			t.Errorf("expected payment status failed, got %s", p.Status)
		}
		if p.FailureReason == nil || *p.FailureReason != failureReason {
			t.Errorf("expected failure reason %q, got %v", failureReason, p.FailureReason)
		}
		return nil
	})

	// Earnings should NOT be created on failed charge
	earningsRepo.EXPECT().Create(gomock.Any(), gomock.Any()).Times(0)

	err := uc.ChargeRide(context.Background(), passengerID, rideID, paymentMethodID, idemKey)
	if err == nil {
		t.Fatal("expected error for failed charge, got nil")
	}
}

func TestPaymentProcessingUsecase_ChargeRide_RideNotFound(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	passengerID := uuid.New()
	rideID := uuid.New()
	idemKey := "idem-pay-404"
	paymentMethodID := "pm_test"

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)

	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(nil, domain.ErrNotFound)

	err := uc.ChargeRide(context.Background(), passengerID, rideID, paymentMethodID, idemKey)
	if err == nil {
		t.Fatal("expected error for missing ride, got nil")
	}
}

func TestChargeRide_RejectsForeignPassenger(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	owner := uuid.New()
	attacker := uuid.New()
	rideID := uuid.New()
	fare := 250.0

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)
	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{
		ID: rideID, PassengerID: owner, EstimatedFare: &fare,
	}, nil)
	// Must NOT charge a foreign passenger's ride.
	stripeClient.EXPECT().ChargePaymentMethod(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Times(0)

	err := uc.ChargeRide(context.Background(), attacker, rideID, "pm_x", "idem-x")
	if err != domain.ErrForbidden {
		t.Fatalf("got %v; want ErrForbidden", err)
	}
}

func TestChargeRide_ShortCircuitsWhenAlreadyPaid(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	passenger := uuid.New()
	rideID := uuid.New()
	fare := 250.0

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)
	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{
		ID: rideID, PassengerID: passenger, EstimatedFare: &fare,
	}, nil)
	paymentRepo.EXPECT().GetByRideID(gomock.Any(), rideID).
		Return(&domain.Payment{ID: uuid.New(), RideID: rideID}, nil)
	// Already paid → no second charge.
	stripeClient.EXPECT().ChargePaymentMethod(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Times(0)

	if err := uc.ChargeRide(context.Background(), passenger, rideID, "pm_x", "idem-x"); err != nil {
		t.Fatalf("expected idempotent no-op, got %v", err)
	}
}
