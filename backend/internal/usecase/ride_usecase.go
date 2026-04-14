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
	rideRepo      domain.RideRepository
	driverRepo    domain.DriverRepository
	fareCalculator *FareCalculator
}

// NewRideUseCase creates a new domain.RideUseCase.
func NewRideUseCase(rideRepo domain.RideRepository, driverRepo domain.DriverRepository, fareCalculator *FareCalculator) domain.RideUseCase {
	return &rideUseCase{rideRepo: rideRepo, driverRepo: driverRepo, fareCalculator: fareCalculator}
}

func (uc *rideUseCase) RequestRide(ctx context.Context, passengerID uuid.UUID, origin, destination domain.LatLng, originAddr, destAddr, notes, idempotencyKey string, rideType domain.RideType, paymentMethod domain.PaymentMethod) (*domain.Ride, error) {
	// Note: paymentMethod is accepted for future payment processing integration.
	// Currently rides default to cash; card payments are handled separately via PaymentProcessingUseCase.
	_ = paymentMethod // suppress unused variable warning until payment integration

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

	// Find the nearest online driver matching the requested vehicle type.
	drivers, err := uc.driverRepo.FindNearbyOnlineByType(ctx, origin.Lat, origin.Lng, 5000, rideType)
	if err != nil {
		log.Printf("[RIDE] Error finding drivers: %v", err)
		return nil, err
	}
	log.Printf("[RIDE] Found %d drivers near (%.5f, %.5f) within 5000m for ride_type=%s", len(drivers), origin.Lat, origin.Lng, rideType)
	if len(drivers) == 0 {
		return nil, domain.ErrNoDriversAvailable
	}

	// Calculate estimated fare using the fare calculator.
	// Distance is approximated from the straight-line distance between origin and destination.
	distanceM := origin.DistanceTo(destination)
	distanceKm := distanceM / 1000.0
	durationMin := distanceKm * 3.0 // rough estimate: 3 min per km (20 km/h average)
	// Use default car rates for estimation — in production these come from fare_configs table.
	baseFare := 50.0
	perKmRate := 10.0
	perMinRate := 2.0
	bookingFee := 5.0
	estimatedFare := uc.fareCalculator.EstimateFare(distanceKm, durationMin, baseFare, perKmRate, perMinRate, bookingFee)

	// Parse the driver ID from string to UUID.
	driverID, err := uuid.Parse(drivers[0].ID)
	if err != nil {
		log.Printf("[RIDE] Error parsing driver ID: %v", err)
		return nil, err
	}

	now := time.Now()
	ride := &domain.Ride{
		ID:                 uuid.New(),
		PassengerID:        passengerID,
		DriverID:           &driverID, // assign closest driver
		Status:             domain.RideStatusRequested,
		Origin:             origin,
		Destination:        destination,
		OriginAddress:      originAddr,
		DestinationAddress: destAddr,
		Notes:              notes,
		IdempotencyKey:     idempotencyKey,
		RideType:           rideType,
		EstimatedFare:      &estimatedFare,
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

func (uc *rideUseCase) Decline(ctx context.Context, driverID, rideID uuid.UUID) (*domain.DeclineResult, error) {
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
	// Reset status to requested and increment decline count.
	if err := uc.rideRepo.UpdateStatus(ctx, rideID, domain.RideStatusRequested); err != nil {
		return nil, err
	}
	if err := uc.rideRepo.IncrementDeclineCount(ctx, rideID); err != nil {
		log.Printf("[RIDE] Warn: could not increment decline count for ride %s: %v", rideID, err)
	}

	// Attempt re-match: find nearest online driver of the same ride type.
	drivers, err := uc.driverRepo.FindNearbyOnlineByType(ctx, ride.Origin.Lat, ride.Origin.Lng, 5000, ride.RideType)
	if err != nil {
		log.Printf("[RIDE] Error finding re-match drivers for ride %s: %v", rideID, err)
	}
	if len(drivers) == 0 {
		// No drivers available — leave ride in requested state; expiry worker handles it.
		ride, _ = uc.rideRepo.GetByID(ctx, rideID)
		return &domain.DeclineResult{Ride: ride, NewDriverFound: false}, nil
	}

	// Assign the new driver.
	newDriverID, err := uuid.Parse(drivers[0].ID)
	if err != nil {
		log.Printf("[RIDE] Error parsing re-match driver ID: %v", err)
		ride, _ = uc.rideRepo.GetByID(ctx, rideID)
		return &domain.DeclineResult{Ride: ride, NewDriverFound: false}, nil
	}
	if err := uc.rideRepo.AssignDriver(ctx, rideID, newDriverID); err != nil {
		log.Printf("[RIDE] Error assigning re-match driver for ride %s: %v", rideID, err)
		ride, _ = uc.rideRepo.GetByID(ctx, rideID)
		return &domain.DeclineResult{Ride: ride, NewDriverFound: false}, nil
	}

	ride, _ = uc.rideRepo.GetByID(ctx, rideID)
	return &domain.DeclineResult{Ride: ride, NewDriverID: &newDriverID, NewDriverFound: true}, nil
}

func (uc *rideUseCase) Arrive(ctx context.Context, driverID, rideID uuid.UUID, driverLocation domain.LatLng) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.DriverID == nil || *ride.DriverID != driverID {
		return nil, domain.ErrForbidden
	}
	if !ride.Status.CanTransitionTo(domain.RideStatusArrived) {
		return nil, domain.ErrInvalidStateTransition
	}

	// Validate driver is within 200 meters of pickup location.
	distanceToPickup := driverLocation.DistanceTo(ride.Origin)
	const maxArrivalDistanceMeters = 200.0
	if distanceToPickup > maxArrivalDistanceMeters {
		return nil, domain.ErrDriverTooFarFromPickup
	}

	if err := uc.rideRepo.UpdateStatus(ctx, rideID, domain.RideStatusArrived); err != nil {
		return nil, err
	}
	return uc.rideRepo.GetByID(ctx, rideID)
}

func (uc *rideUseCase) Start(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	return uc.transition(ctx, driverID, rideID, domain.RideStatusInProgress, func(r *domain.Ride) bool {
		return r.DriverID != nil && *r.DriverID == driverID
	})
}

func (uc *rideUseCase) Complete(ctx context.Context, driverID, rideID uuid.UUID) (*domain.Ride, error) {
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.DriverID == nil || *ride.DriverID != driverID {
		return nil, domain.ErrForbidden
	}
	if !ride.Status.CanTransitionTo(domain.RideStatusCompleted) {
		return nil, domain.ErrInvalidStateTransition
	}

	// Calculate actual fare using actual distance/duration.
	// Distance is approximated from the straight-line distance between origin and destination.
	distanceM := ride.Origin.DistanceTo(ride.Destination)
	distanceKm := distanceM / 1000.0
	durationMin := distanceKm * 3.0 // rough estimate: 3 min per km (20 km/h average)
	// Use default car rates — in production these come from fare_configs table.
	baseFare := 50.0
	perKmRate := 10.0
	perMinRate := 2.0
	bookingFee := 5.0
	actualFare, breakdown := uc.fareCalculator.CalculateActualFare(distanceKm, durationMin, baseFare, perKmRate, perMinRate, bookingFee, 1.0, 0.0)

	// Convert breakdown to JSONMap for storage.
	breakdownJSON := domain.JSONMap{
		"base_fare":       breakdown.BaseFare,
		"distance_charge": breakdown.DistanceCharge,
		"time_charge":     breakdown.TimeCharge,
		"booking_fee":     breakdown.BookingFee,
	}

	// Store actual fare and breakdown on the ride.
	if err := uc.rideRepo.UpdateRideFare(ctx, rideID, actualFare, breakdownJSON); err != nil {
		log.Printf("[RIDE] Warn: could not update fare for ride %s: %v", rideID, err)
	}

	// Transition to completed status.
	if err := uc.rideRepo.UpdateStatus(ctx, rideID, domain.RideStatusCompleted); err != nil {
		return nil, err
	}

	ride, err = uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}

	// Return driver to online pool automatically on completion.
	// Non-fatal: if this fails the driver can manually set their status.
	if err := uc.driverRepo.UpdateStatus(ctx, driverID, domain.DriverStatusOnline); err != nil {
		log.Printf("warn: could not reset driver %s to online after ride completion: %v", driverID, err)
	}
	return ride, nil
}

func (uc *rideUseCase) Cancel(ctx context.Context, userID uuid.UUID, role domain.UserRole, rideID uuid.UUID, reasonCode *string, reasonText *string) (*domain.Ride, error) {
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

	// Validate reason code if provided.
	if reasonCode != nil && !domain.IsValidCancellationReason(*reasonCode) {
		reasonCode = nil
	}

	// Determine cancellation fee from fare configs.
	// Use default rates — in production these come from fare_configs table.
	var cancellationFee *float64
	if ride.RideType != "" {
		// Default cancellation fee: 10% of estimated fare, minimum 20.0
		if ride.EstimatedFare != nil && *ride.EstimatedFare > 0 {
			fee := (*ride.EstimatedFare) * 0.10
			if fee < 20.0 {
				fee = 20.0
			}
			cancellationFee = &fee
		}
	}

	if err := uc.rideRepo.SetCancelled(ctx, rideID, by, reasonCode, reasonText, cancellationFee); err != nil {
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
