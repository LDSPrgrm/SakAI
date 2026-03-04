package usecase_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/internal/usecase"
	"github.com/sakai/backend/pkg/testutil"
	"go.uber.org/mock/gomock"
)

func newRideUC(ctrl *gomock.Controller) (domain.RideUseCase, *mocks.MockRideRepository, *mocks.MockDriverRepository) {
	rideRepo := mocks.NewMockRideRepository(ctrl)
	driverRepo := mocks.NewMockDriverRepository(ctrl)
	uc := usecase.NewRideUseCase(rideRepo, driverRepo)
	return uc, rideRepo, driverRepo
}

func TestRideUseCase_RequestRide_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo := newRideUC(ctrl)
	passengerID := uuid.New()
	driverID := uuid.New()
	idem := "idem-key-1"

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), idem).Return(nil, domain.ErrNotFound)
	rideRepo.EXPECT().GetActiveByPassengerID(gomock.Any(), passengerID).Return(nil, domain.ErrNotFound)
	driverRepo.EXPECT().FindNearbyOnline(gomock.Any(), gomock.Any(), gomock.Any()).Return([]*domain.Driver{
		{UserID: driverID, Status: domain.DriverStatusOnline},
	}, nil)
	rideRepo.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	origin := domain.LatLng{Lat: 14.5, Lng: 120.9}
	dest := domain.LatLng{Lat: 14.6, Lng: 121.0}

	ride, err := uc.RequestRide(context.Background(), passengerID, origin, dest, "", "", "", idem)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if ride.Status != domain.RideStatusRequested {
		t.Errorf("expected status requested, got %s", ride.Status)
	}
	if *ride.DriverID != driverID {
		t.Errorf("expected driverID %s, got %s", driverID, ride.DriverID)
	}
}

func TestRideUseCase_RequestRide_Idempotent(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	existing := testutil.NewTestRide(passengerID)

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), "idem-key").Return(existing, nil)

	ride, err := uc.RequestRide(context.Background(), passengerID, existing.Origin, existing.Destination, "", "", "", "idem-key")
	if err != nil {
		t.Fatalf("idempotent request should not error, got %v", err)
	}
	if ride.ID != existing.ID {
		t.Error("idempotent request should return the existing ride")
	}
}

func TestRideUseCase_RequestRide_PassengerHasActiveRide(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), gomock.Any()).Return(nil, domain.ErrNotFound)
	rideRepo.EXPECT().GetActiveByPassengerID(gomock.Any(), passengerID).Return(testutil.NewTestRide(passengerID), nil)

	_, err := uc.RequestRide(context.Background(), passengerID, domain.LatLng{}, domain.LatLng{}, "", "", "", "new-key")
	if err != domain.ErrPassengerHasActiveRide {
		t.Errorf("expected ErrPassengerHasActiveRide, got %v", err)
	}
}

func TestRideUseCase_RequestRide_NoDrivers(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo := newRideUC(ctrl)
	passengerID := uuid.New()

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), gomock.Any()).Return(nil, domain.ErrNotFound)
	rideRepo.EXPECT().GetActiveByPassengerID(gomock.Any(), passengerID).Return(nil, domain.ErrNotFound)
	driverRepo.EXPECT().FindNearbyOnline(gomock.Any(), gomock.Any(), gomock.Any()).Return([]*domain.Driver{}, nil)

	_, err := uc.RequestRide(context.Background(), passengerID, domain.LatLng{}, domain.LatLng{}, "", "", "", "key")
	if err != domain.ErrNoDriversAvailable {
		t.Errorf("expected ErrNoDriversAvailable, got %v", err)
	}
}

func TestRideUseCase_Accept_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusRequested
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusAccepted).Return(nil)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Accept(context.Background(), driverID, ride.ID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_Accept_Forbidden(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _ := newRideUC(ctrl)
	otherDriver := uuid.New()
	assignedDriver := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &assignedDriver
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Accept(context.Background(), otherDriver, ride.ID)
	if err != domain.ErrForbidden {
		t.Errorf("expected ErrForbidden, got %v", err)
	}
}

func TestRideUseCase_Cancel_ByPassenger(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	ride := testutil.NewTestRide(passengerID)

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().SetCancelled(gomock.Any(), ride.ID, domain.CancelledByPassenger).Return(nil)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_Cancel_InvalidTransition(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.Status = domain.RideStatusCompleted
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID)
	if err != domain.ErrInvalidStateTransition {
		t.Errorf("expected ErrInvalidStateTransition, got %v", err)
	}
}
