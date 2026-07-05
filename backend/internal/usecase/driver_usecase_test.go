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

func newDriverUC(ctrl *gomock.Controller) (domain.DriverUseCase, *mocks.MockDriverRepository, *mocks.MockRideRepository, *mocks.MockIncidentRepository) {
	driverRepo := mocks.NewMockDriverRepository(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)
	incidentRepo := mocks.NewMockIncidentRepository(ctrl)
	uc := usecase.NewDriverUseCase(driverRepo, rideRepo, earningsRepo, incidentRepo)
	return uc, driverRepo, rideRepo, incidentRepo
}

func TestDriverUseCase_SetStatus_Online(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _, _ := newDriverUC(ctrl)
	driverID := uuid.New()

	driverRepo.EXPECT().UpdateStatus(gomock.Any(), driverID, domain.DriverStatusOnline).Return(&domain.Driver{UserID: driverID, Status: domain.DriverStatusOnline}, nil)

	if _, err := uc.SetStatus(context.Background(), driverID, domain.DriverStatusOnline); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestDriverUseCase_SetStatus_Offline_NoActiveRide(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, rideRepo, _ := newDriverUC(ctrl)
	driverID := uuid.New()

	rideRepo.EXPECT().GetActiveByDriverID(gomock.Any(), driverID).Return(nil, domain.ErrNotFound)
	driverRepo.EXPECT().UpdateStatus(gomock.Any(), driverID, domain.DriverStatusOffline).Return(&domain.Driver{UserID: driverID, Status: domain.DriverStatusOffline}, nil)

	if _, err := uc.SetStatus(context.Background(), driverID, domain.DriverStatusOffline); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestDriverUseCase_SetStatus_Offline_ActiveRide(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, rideRepo, _ := newDriverUC(ctrl)
	driverID := uuid.New()
	activeRide := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusInProgress
	})

	rideRepo.EXPECT().GetActiveByDriverID(gomock.Any(), driverID).Return(activeRide, nil)

	_, err := uc.SetStatus(context.Background(), driverID, domain.DriverStatusOffline)
	if err != domain.ErrCannotGoOffline {
		t.Errorf("expected ErrCannotGoOffline, got %v", err)
	}
}

func TestDriverUseCase_UpdateLocation_OnlineDriver(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _, incidentRepo := newDriverUC(ctrl)
	driverID := uuid.New()

	loc := domain.DriverLocation{LatLng: domain.LatLng{Lat: 14.5, Lng: 120.9}}

	driverRepo.EXPECT().UpdateLocation(gomock.Any(), driverID, loc).Return(nil)
	incidentRepo.EXPECT().FindActiveByDriver(gomock.Any(), driverID).Return(nil, nil)

	if err := uc.UpdateLocation(context.Background(), driverID, loc); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestDriverUseCase_UpdateLocation_OfflineDriver(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _, _ := newDriverUC(ctrl)
	driverID := uuid.New()

	driverRepo.EXPECT().UpdateLocation(gomock.Any(), driverID, domain.DriverLocation{}).Return(domain.ErrForbidden)

	err := uc.UpdateLocation(context.Background(), driverID, domain.DriverLocation{})
	if err != domain.ErrForbidden {
		t.Errorf("expected ErrForbidden for offline driver, got %v", err)
	}
}

func TestDriverUseCase_GetNearbyDriversAllTypes_GroupsByVehicleType(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, driverRepo, _, _ := newDriverUC(ctrl)

	all := []domain.NearbyDriver{
		{ID: uuid.New().String(), VehicleType: string(domain.RideTypeCar)},
		{ID: uuid.New().String(), VehicleType: string(domain.RideTypeMotorcycle)},
		{ID: uuid.New().String(), VehicleType: string(domain.RideTypeTricycle)},
	}

	driverRepo.EXPECT().FindNearbyOnlineAllTypes(gomock.Any(), 14.5, 120.9, 5000.0).Return(all, nil)

	result, err := uc.GetNearbyDriversAllTypes(context.Background(), 14.5, 120.9, 5000.0)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	for _, rt := range []domain.RideType{domain.RideTypeCar, domain.RideTypeMotorcycle, domain.RideTypeTricycle} {
		drivers, ok := result[rt]
		if !ok {
			t.Fatalf("expected key %q present in result", rt)
		}
		if len(drivers) != 1 {
			t.Errorf("expected exactly 1 driver for %q, got %d", rt, len(drivers))
		}
	}
}

func TestDriverUseCase_GetIncomingRide_RequestedOnly(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, rideRepo, _ := newDriverUC(ctrl)
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
