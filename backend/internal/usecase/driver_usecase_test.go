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

func newDriverUC(ctrl *gomock.Controller) (domain.DriverUseCase, *mocks.MockDriverRepository, *mocks.MockRideRepository) {
	driverRepo := mocks.NewMockDriverRepository(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	uc := usecase.NewDriverUseCase(driverRepo, rideRepo)
	return uc, driverRepo, rideRepo
}

func TestDriverUseCase_SetStatus_Online(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _ := newDriverUC(ctrl)
	driverID := uuid.New()

	driverRepo.EXPECT().UpdateStatus(gomock.Any(), driverID, domain.DriverStatusOnline).Return(nil)

	if err := uc.SetStatus(context.Background(), driverID, domain.DriverStatusOnline); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestDriverUseCase_SetStatus_Offline_NoActiveRide(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, rideRepo := newDriverUC(ctrl)
	driverID := uuid.New()

	rideRepo.EXPECT().GetActiveByDriverID(gomock.Any(), driverID).Return(nil, domain.ErrNotFound)
	driverRepo.EXPECT().UpdateStatus(gomock.Any(), driverID, domain.DriverStatusOffline).Return(nil)

	if err := uc.SetStatus(context.Background(), driverID, domain.DriverStatusOffline); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestDriverUseCase_SetStatus_Offline_ActiveRide(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, rideRepo := newDriverUC(ctrl)
	driverID := uuid.New()
	activeRide := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusInProgress
	})

	rideRepo.EXPECT().GetActiveByDriverID(gomock.Any(), driverID).Return(activeRide, nil)

	err := uc.SetStatus(context.Background(), driverID, domain.DriverStatusOffline)
	if err != domain.ErrCannotGoOffline {
		t.Errorf("expected ErrCannotGoOffline, got %v", err)
	}
}

func TestDriverUseCase_UpdateLocation_OnlineDriver(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _ := newDriverUC(ctrl)
	driverID := uuid.New()
	driver := testutil.NewTestDriverRecord(driverID)

	loc := domain.DriverLocation{LatLng: domain.LatLng{Lat: 14.5, Lng: 120.9}}

	driverRepo.EXPECT().GetByUserID(gomock.Any(), driverID).Return(driver, nil)
	driverRepo.EXPECT().UpdateLocation(gomock.Any(), driverID, loc).Return(nil)

	if err := uc.UpdateLocation(context.Background(), driverID, loc); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestDriverUseCase_UpdateLocation_OfflineDriver(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _ := newDriverUC(ctrl)
	driverID := uuid.New()
	driver := testutil.NewTestDriverRecord(driverID, func(d *domain.Driver) {
		d.Status = domain.DriverStatusOffline
	})

	driverRepo.EXPECT().GetByUserID(gomock.Any(), driverID).Return(driver, nil)

	err := uc.UpdateLocation(context.Background(), driverID, domain.DriverLocation{})
	if err != domain.ErrForbidden {
		t.Errorf("expected ErrForbidden for offline driver, got %v", err)
	}
}

func TestDriverUseCase_GetIncomingRide_RequestedOnly(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, rideRepo := newDriverUC(ctrl)
	driverID := uuid.New()

	// If the active ride is not in "requested" state, GetIncomingRide should return ErrNotFound.
	acceptedRide := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusAccepted
	})
	rideRepo.EXPECT().GetActiveByDriverID(gomock.Any(), driverID).Return(acceptedRide, nil)

	_, err := uc.GetIncomingRide(context.Background(), driverID)
	if err != domain.ErrNotFound {
		t.Errorf("expected ErrNotFound for non-requested ride, got %v", err)
	}
}
