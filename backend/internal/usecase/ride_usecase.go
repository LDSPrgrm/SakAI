package usecase

import (
	"context"
	"errors"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type rideUseCase struct {
	rideRepo   domain.RideRepository
	driverRepo domain.DriverRepository
}

// NewRideUseCase creates a new domain.RideUseCase.
func NewRideUseCase(rideRepo domain.RideRepository, driverRepo domain.DriverRepository) domain.RideUseCase {
	return &rideUseCase{rideRepo: rideRepo, driverRepo: driverRepo}
}

func (uc *rideUseCase) RequestRide(ctx context.Context, passengerID uuid.UUID, origin, destination domain.LatLng, originAddr, destAddr, notes, idempotencyKey string) (*domain.Ride, error) {
	// Idempotency: return existing ride if key already used.
	if existing, err := uc.rideRepo.GetByIdempotencyKey(ctx, idempotencyKey); err == nil {
		return existing, nil
	}

	// Guard: passenger cannot have two active rides.
	if _, err := uc.rideRepo.GetActiveByPassengerID(ctx, passengerID); err == nil {
		return nil, domain.ErrPassengerHasActiveRide
	} else if !errors.Is(err, domain.ErrNotFound) {
		return nil, err
	}

	// Find the nearest online driver.
	drivers, err := uc.driverRepo.FindNearbyOnline(ctx, origin, 5000)
	if err != nil {
		return nil, err
	}
	if len(drivers) == 0 {
		return nil, domain.ErrNoDriversAvailable
	}

	now := time.Now()
	ride := &domain.Ride{
		ID:                 uuid.New(),
		PassengerID:        passengerID,
		DriverID:           &drivers[0].UserID, // assign closest driver
		Status:             domain.RideStatusRequested,
		Origin:             origin,
		Destination:        destination,
		OriginAddress:      originAddr,
		DestinationAddress: destAddr,
		Notes:              notes,
		IdempotencyKey:     idempotencyKey,
		CreatedAt:          now,
		UpdatedAt:          now,
	}
	if err := uc.rideRepo.Create(ctx, ride); err != nil {
		return nil, err
	}
	return ride, nil
}

func (uc *rideUseCase) GetActive(ctx context.Context, userID uuid.UUID, role domain.UserRole) (*domain.Ride, error) {
	if role == domain.RolePassenger {
		return uc.rideRepo.GetActiveByPassengerID(ctx, userID)
	}
	return uc.rideRepo.GetActiveByDriverID(ctx, userID)
}

func (uc *rideUseCase) GetByID(ctx context.Context, userID uuid.UUID, rideID uuid.UUID) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	// Only the passenger and assigned driver may view a ride.
	if ride.PassengerID != userID && (ride.DriverID == nil || *ride.DriverID != userID) {
		return nil, domain.ErrForbidden
	}
	return ride, nil
}

func (uc *rideUseCase) Accept(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	return uc.transition(ctx, driverID, rideID, domain.RideStatusAccepted, func(r *domain.Ride) bool {
		return r.DriverID != nil && *r.DriverID == driverID
	})
}

func (uc *rideUseCase) Decline(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.DriverID == nil || *ride.DriverID != driverID {
		return nil, domain.ErrForbidden
	}
	// Clear the driver assignment in the DB first so the partial unique index
	// on driver_id is freed and the ride can be matched to another driver.
	if err := uc.rideRepo.ClearDriver(ctx, rideID); err != nil {
		return nil, err
	}
	if err := uc.rideRepo.UpdateStatus(ctx, rideID, domain.RideStatusRequested); err != nil {
		return nil, err
	}
	return uc.rideRepo.GetByID(ctx, rideID)
}

func (uc *rideUseCase) Arrive(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	return uc.transition(ctx, driverID, rideID, domain.RideStatusArrived, func(r *domain.Ride) bool {
		return r.DriverID != nil && *r.DriverID == driverID
	})
}

func (uc *rideUseCase) Start(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	return uc.transition(ctx, driverID, rideID, domain.RideStatusInProgress, func(r *domain.Ride) bool {
		return r.DriverID != nil && *r.DriverID == driverID
	})
}

func (uc *rideUseCase) Complete(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	ride, err := uc.transition(ctx, driverID, rideID, domain.RideStatusCompleted, func(r *domain.Ride) bool {
		return r.DriverID != nil && *r.DriverID == driverID
	})
	if err != nil {
		return nil, err
	}
	// Return driver to online pool automatically on completion.
	// Non-fatal: if this fails the driver can manually set their status.
	// Log so operations can detect stuck drivers in monitoring.
	if err := uc.driverRepo.UpdateStatus(ctx, driverID, domain.DriverStatusOnline); err != nil {
		log.Printf("warn: could not reset driver %s to online after ride completion: %v", driverID, err)
	}
	return ride, nil
}

func (uc *rideUseCase) Cancel(ctx context.Context, userID uuid.UUID, role domain.UserRole, rideID uuid.UUID) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if !ride.Status.CanTransitionTo(domain.RideStatusCancelled) {
		return nil, domain.ErrInvalidStateTransition
	}
	var by domain.CancelledBy
	switch role {
	case domain.RolePassenger:
		if ride.PassengerID != userID {
			return nil, domain.ErrForbidden
		}
		by = domain.CancelledByPassenger
	case domain.RoleDriver:
		if ride.DriverID == nil || *ride.DriverID != userID {
			return nil, domain.ErrForbidden
		}
		by = domain.CancelledByDriver
	}
	if err := uc.rideRepo.SetCancelled(ctx, rideID, by); err != nil {
		return nil, err
	}
	return uc.rideRepo.GetByID(ctx, rideID)
}

// transition is a shared helper for driver-initiated state advances.
// authCheck approves the caller's identity before the transition is applied.
func (uc *rideUseCase) transition(ctx context.Context, callerID, rideID uuid.UUID, next domain.RideStatus, authCheck func(*domain.Ride) bool) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if !authCheck(ride) {
		return nil, domain.ErrForbidden
	}
	if !ride.Status.CanTransitionTo(next) {
		return nil, domain.ErrInvalidStateTransition
	}
	if err := uc.rideRepo.UpdateStatus(ctx, rideID, next); err != nil {
		return nil, err
	}
	return uc.rideRepo.GetByID(ctx, rideID)
}
