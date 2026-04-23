package usecase

import (
	"context"
	"errors"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type driverUseCase struct {
	driverRepo   domain.DriverRepository
	rideRepo     domain.RideRepository
	earningsRepo domain.EarningsRepository
}

// NewDriverUseCase creates a new domain.DriverUseCase.
func NewDriverUseCase(driverRepo domain.DriverRepository, rideRepo domain.RideRepository, earningsRepo domain.EarningsRepository) domain.DriverUseCase {
	return &driverUseCase{driverRepo: driverRepo, rideRepo: rideRepo, earningsRepo: earningsRepo}
}

func (uc *driverUseCase) SetStatus(ctx context.Context, driverID uuid.UUID, status domain.DriverStatus) error {
	// Guard: cannot go offline with an active ride.
	if status == domain.DriverStatusOffline {
		active, err := uc.rideRepo.GetActiveByDriverID(ctx, driverID)
		if err != nil && !errors.Is(err, domain.ErrNotFound) {
			return err
		}
		if active != nil && !active.Status.IsTerminal() {
			return domain.ErrCannotGoOffline
		}
	}
	return uc.driverRepo.UpdateStatus(ctx, driverID, status)
}

func (uc *driverUseCase) UpdateLocation(ctx context.Context, driverID uuid.UUID, loc domain.DriverLocation) error {
	// Location updates are accepted only when driver is online.
	log.Printf("[DRIVER_UC] UpdateLocation: driverID=%s, loc=(%.5f, %.5f)", driverID, loc.Lat, loc.Lng)
	driver, err := uc.driverRepo.GetByUserID(ctx, driverID)
	if err != nil {
		log.Printf("[DRIVER_UC] GetByUserID error: %v", err)
		return err
	}
	log.Printf("[DRIVER_UC] Driver status: %s", driver.Status)
	if driver.Status != domain.DriverStatusOnline {
		return domain.ErrForbidden
	}
	return uc.driverRepo.UpdateLocation(ctx, driverID, loc)
}

func (uc *driverUseCase) GetIncomingRide(ctx context.Context, driverID uuid.UUID) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetActiveByDriverID(ctx, driverID)
	if err != nil {
		return nil, err
	}
	// Only surface rides that are in the 'requested' state (pending acceptance).
	if ride.Status != domain.RideStatusRequested {
		return nil, domain.ErrNotFound
	}
	return ride, nil
}

func (uc *driverUseCase) GetActiveRide(ctx context.Context, driverID uuid.UUID) (*domain.Ride, error) {
	return uc.rideRepo.GetActiveByDriverID(ctx, driverID)
}

func (uc *driverUseCase) GetNearbyDrivers(ctx context.Context, lat, lng float64, radiusM float64, rideType domain.RideType) ([]domain.NearbyDriver, error) {
	return uc.driverRepo.FindNearbyOnlineByType(ctx, lat, lng, radiusM, rideType)
}

func (uc *driverUseCase) GetEarnings(ctx context.Context, driverID uuid.UUID, from, to *time.Time, page, limit int) ([]*domain.DriverEarnings, int, error) {
	return uc.earningsRepo.ListByDriverID(ctx, driverID, from, to, page, limit)
}

// GetNearbyDriversAllTypes returns online drivers grouped by vehicle type.
func (uc *driverUseCase) GetNearbyDriversAllTypes(ctx context.Context, lat, lng float64, radiusM float64) (map[domain.RideType][]domain.NearbyDriver, error) {
	result := make(map[domain.RideType][]domain.NearbyDriver)
	for _, rt := range []domain.RideType{domain.RideTypeCar, domain.RideTypeMotorcycle, domain.RideTypeTricycle} {
		drivers, err := uc.driverRepo.FindNearbyOnlineByType(ctx, lat, lng, radiusM, rt)
		if err != nil {
			return nil, err
		}
		result[rt] = drivers
	}
	return result, nil
}
