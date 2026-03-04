package usecase

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type driverUseCase struct {
	driverRepo domain.DriverRepository
	rideRepo   domain.RideRepository
}

// NewDriverUseCase creates a new domain.DriverUseCase.
func NewDriverUseCase(driverRepo domain.DriverRepository, rideRepo domain.RideRepository) domain.DriverUseCase {
	return &driverUseCase{driverRepo: driverRepo, rideRepo: rideRepo}
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
	driver, err := uc.driverRepo.GetByUserID(ctx, driverID)
	if err != nil {
		return err
	}
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
