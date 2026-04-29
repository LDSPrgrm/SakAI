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

func newRideUC(ctrl *gomock.Controller) (domain.RideUseCase, *mocks.MockRideRepository, *mocks.MockDriverRepository, *mocks.MockIncidentRepository) {
	rideRepo := mocks.NewMockRideRepository(ctrl)
	driverRepo := mocks.NewMockDriverRepository(ctrl)
	incidentRepo := mocks.NewMockIncidentRepository(ctrl)
	fareCalc := usecase.NewFareCalculator()
	uc := usecase.NewRideUseCase(rideRepo, driverRepo, incidentRepo, fareCalc)
	return uc, rideRepo, driverRepo, incidentRepo
}

func TestRideUseCase_RequestRide_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	driverID := uuid.New()
	idem := "idem-key-1"

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), idem).Return(nil, domain.ErrNotFound)
	rideRepo.EXPECT().GetActiveByPassengerID(gomock.Any(), passengerID).Return(nil, domain.ErrNotFound)
	driverRepo.EXPECT().FindNearbyOnlineByType(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Return([]domain.NearbyDriver{
		{ID: driverID.String()},
	}, nil)
	rideRepo.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	origin := domain.LatLng{Lat: 14.5, Lng: 120.9}
	dest := domain.LatLng{Lat: 14.6, Lng: 121.0}

	ride, err := uc.RequestRide(context.Background(), passengerID, origin, dest, "", "", "", idem, domain.RideTypeCar, domain.PaymentMethodCash)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if ride.Status != domain.RideStatusRequested {
		t.Errorf("expected status requested, got %s", ride.Status)
	}
	if *ride.DriverID != driverID {
		t.Errorf("expected driverID %s, got %s", driverID, ride.DriverID)
	}
	if ride.RideType != domain.RideTypeCar {
		t.Errorf("expected ride type %s, got %s", domain.RideTypeCar, ride.RideType)
	}
	if ride.EstimatedFare == nil {
		t.Error("expected estimated fare to be set")
	}
}

func TestRideUseCase_RequestRide_Idempotent(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	existing := testutil.NewTestRide(passengerID)

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), "idem-key").Return(existing, nil)

	ride, err := uc.RequestRide(context.Background(), passengerID, existing.Origin, existing.Destination, "", "", "", "idem-key", domain.RideTypeCar, domain.PaymentMethodCash)
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

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), gomock.Any()).Return(nil, domain.ErrNotFound)
	rideRepo.EXPECT().GetActiveByPassengerID(gomock.Any(), passengerID).Return(testutil.NewTestRide(passengerID), nil)

	_, err := uc.RequestRide(context.Background(), passengerID, domain.LatLng{}, domain.LatLng{}, "", "", "", "new-key", domain.RideTypeCar, domain.PaymentMethodCash)
	if err != domain.ErrPassengerHasActiveRide {
		t.Errorf("expected ErrPassengerHasActiveRide, got %v", err)
	}
}

func TestRideUseCase_RequestRide_NoDrivers(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()

	rideRepo.EXPECT().GetByIdempotencyKey(gomock.Any(), gomock.Any()).Return(nil, domain.ErrNotFound)
	rideRepo.EXPECT().GetActiveByPassengerID(gomock.Any(), passengerID).Return(nil, domain.ErrNotFound)
	driverRepo.EXPECT().FindNearbyOnlineByType(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Return([]domain.NearbyDriver{}, nil)

	_, err := uc.RequestRide(context.Background(), passengerID, domain.LatLng{}, domain.LatLng{}, "", "", "", "key", domain.RideTypeCar, domain.PaymentMethodCash)
	if err != domain.ErrNoDriversAvailable {
		t.Errorf("expected ErrNoDriversAvailable, got %v", err)
	}
}

func TestRideUseCase_Accept_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
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

	uc, rideRepo, _, _ := newRideUC(ctrl)
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

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	ride := testutil.NewTestRide(passengerID)
	reasonCode := "changed_plans"
	reasonText := "Plans changed"

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().SetCancelled(gomock.Any(), ride.ID, domain.CancelledByPassenger, &reasonCode, &reasonText, gomock.Any()).Return(nil)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID, &reasonCode, &reasonText)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_Cancel_WithReasonCode(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	estimatedFare := 150.0
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.RideType = domain.RideTypeCar
		r.EstimatedFare = &estimatedFare
	})
	reasonCode := "safety_concern"

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	// Expect SetCancelled with a non-nil cancellation fee (10% of 150 = 15, min 20 -> 20)
	rideRepo.EXPECT().SetCancelled(gomock.Any(), ride.ID, domain.CancelledByPassenger, &reasonCode, gomock.Any(), gomock.Any()).DoAndReturn(
		func(ctx context.Context, id uuid.UUID, by domain.CancelledBy, rc *string, rt *string, fee *float64) error {
			if rc == nil || *rc != "safety_concern" {
				t.Errorf("expected reason_code safety_concern, got %v", rc)
			}
			if fee == nil {
				t.Error("expected cancellation fee to be set")
			} else if *fee != 20.0 {
				t.Errorf("expected cancellation fee 20.0 (minimum), got %f", *fee)
			}
			return nil
		},
	)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID, &reasonCode, nil)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_Cancel_FeeApplication(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	estimatedFare := 500.0
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.RideType = domain.RideTypeCar
		r.EstimatedFare = &estimatedFare
	})
	reasonCode := "driver_too_far"

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	// 10% of 500 = 50, which is above the 20 minimum
	rideRepo.EXPECT().SetCancelled(gomock.Any(), ride.ID, domain.CancelledByPassenger, &reasonCode, gomock.Any(), gomock.Any()).DoAndReturn(
		func(ctx context.Context, id uuid.UUID, by domain.CancelledBy, rc *string, rt *string, fee *float64) error {
			if fee == nil {
				t.Fatal("expected cancellation fee to be set")
			}
			expected := 50.0
			if *fee != expected {
				t.Errorf("expected cancellation fee %f, got %f", expected, *fee)
			}
			return nil
		},
	)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID, &reasonCode, nil)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_Cancel_InProgressBlocked(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.Status = domain.RideStatusInProgress
	})
	reasonCode := "changed_plans"

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID, &reasonCode, nil)
	if err != domain.ErrInvalidStateTransition {
		t.Errorf("expected ErrInvalidStateTransition for in_progress ride, got %v", err)
	}
}

func TestRideUseCase_Cancel_InvalidTransition(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.Status = domain.RideStatusCompleted
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Cancel(context.Background(), passengerID, domain.RolePassenger, ride.ID, nil, nil)
	if err != domain.ErrInvalidStateTransition {
		t.Errorf("expected ErrInvalidStateTransition, got %v", err)
	}
}

func TestRideUseCase_Decline_ReMatchFound(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo, _ := newRideUC(ctrl)
	driverID := uuid.New()
	newDriverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusRequested
		r.RideType = domain.RideTypeCar
		r.Origin = domain.LatLng{Lat: 14.5, Lng: 120.9}
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().ClearDriver(gomock.Any(), ride.ID).Return(nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusRequested).Return(nil)
	rideRepo.EXPECT().IncrementDeclineCount(gomock.Any(), ride.ID).Return(nil)
	driverRepo.EXPECT().FindNearbyOnlineByType(gomock.Any(), ride.Origin.Lat, ride.Origin.Lng, gomock.Any(), domain.RideTypeCar).
		Return([]domain.NearbyDriver{{ID: newDriverID.String()}}, nil)
	rideRepo.EXPECT().AssignDriver(gomock.Any(), ride.ID, newDriverID).Return(nil)
	// Return updated ride with new driver.
	updatedRide := *ride
	updatedRide.DriverID = &newDriverID
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(&updatedRide, nil)

	result, err := uc.Decline(context.Background(), driverID, ride.ID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if !result.NewDriverFound {
		t.Error("expected new driver to be found")
	}
	if result.NewDriverID == nil || *result.NewDriverID != newDriverID {
		t.Errorf("expected new driver ID %s, got %v", newDriverID, result.NewDriverID)
	}
}

func TestRideUseCase_Decline_NoDriversAvailable(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusRequested
		r.RideType = domain.RideTypeCar
		r.Origin = domain.LatLng{Lat: 14.5, Lng: 120.9}
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().ClearDriver(gomock.Any(), ride.ID).Return(nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusRequested).Return(nil)
	rideRepo.EXPECT().IncrementDeclineCount(gomock.Any(), ride.ID).Return(nil)
	driverRepo.EXPECT().FindNearbyOnlineByType(gomock.Any(), ride.Origin.Lat, ride.Origin.Lng, gomock.Any(), domain.RideTypeCar).
		Return([]domain.NearbyDriver{}, nil)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	result, err := uc.Decline(context.Background(), driverID, ride.ID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if result.NewDriverFound {
		t.Error("expected no new driver to be found")
	}
	if result.Ride.Status != domain.RideStatusRequested {
		t.Errorf("expected status requested, got %s", result.Ride.Status)
	}
}

func TestRideUseCase_Complete_SuccessWithFareCalculation(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusInProgress
		r.RideType = domain.RideTypeCar
		// Origin and destination are ~11km apart in the fixture.
		r.Origin = domain.LatLng{Lat: 14.5, Lng: 120.9}
		r.Destination = domain.LatLng{Lat: 14.6, Lng: 121.0}
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	// Expect UpdateRideFare to be called with computed actual fare.
	rideRepo.EXPECT().UpdateRideFare(gomock.Any(), ride.ID, gomock.Any(), gomock.Any()).DoAndReturn(
		func(ctx context.Context, id uuid.UUID, actualFare float64, breakdown domain.JSONMap) error {
			if actualFare <= 0 {
				t.Error("expected actual fare to be positive")
			}
			// Verify JSONB breakdown has expected keys.
			for _, key := range []string{"base_fare", "distance_charge", "time_charge", "booking_fee"} {
				if _, ok := breakdown[key]; !ok {
					t.Errorf("expected breakdown key %q, not found", key)
				}
			}
			return nil
		},
	)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusCompleted).Return(nil)
	// Return completed ride with fare set.
	completedRide := *ride
	completedRide.Status = domain.RideStatusCompleted
	actualFare := 135.0
	completedRide.ActualFare = &actualFare
	breakdown := domain.JSONMap{"base_fare": 50.0, "distance_charge": 50.0, "time_charge": 30.0, "booking_fee": 5.0}
	completedRide.FareBreakdown = &breakdown
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(&completedRide, nil)
	driverRepo.EXPECT().UpdateStatus(gomock.Any(), driverID, domain.DriverStatusOnline).Return(nil)

	// Driver location at destination (within 100m).
	driverLocation := domain.LatLng{Lat: 14.6, Lng: 121.0}
	result, err := uc.Complete(context.Background(), driverID, ride.ID, driverLocation)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if result.Status != domain.RideStatusCompleted {
		t.Errorf("expected status completed, got %s", result.Status)
	}
}

func TestRideUseCase_Complete_WrongDriver(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	driverID := uuid.New()
	wrongDriverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusInProgress
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	// Driver location at destination (within 100m).
	driverLocation := domain.LatLng{Lat: ride.Destination.Lat, Lng: ride.Destination.Lng}
	_, err := uc.Complete(context.Background(), wrongDriverID, ride.ID, driverLocation)
	if err != domain.ErrForbidden {
		t.Errorf("expected ErrForbidden, got %v", err)
	}
}

func TestRideUseCase_Complete_InvalidStateTransition(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusRequested // cannot go directly to completed
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	// Driver location at destination (within 100m).
	driverLocation := domain.LatLng{Lat: ride.Destination.Lat, Lng: ride.Destination.Lng}
	_, err := uc.Complete(context.Background(), driverID, ride.ID, driverLocation)
	if err != domain.ErrInvalidStateTransition {
		t.Errorf("expected ErrInvalidStateTransition, got %v", err)
	}
}

func TestRideUseCase_Decline_MultipleSequentialDeclines(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, driverRepo, _ := newRideUC(ctrl)
	passengerID := uuid.New()
	firstDriverID := uuid.New()
	secondDriverID := uuid.New()
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.DriverID = &firstDriverID
		r.Status = domain.RideStatusRequested
		r.RideType = domain.RideTypeCar
		r.Origin = domain.LatLng{Lat: 14.5, Lng: 120.9}
		r.DeclineCount = 0
	})

	// First decline: re-match found with second driver.
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().ClearDriver(gomock.Any(), ride.ID).Return(nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusRequested).Return(nil)
	rideRepo.EXPECT().IncrementDeclineCount(gomock.Any(), ride.ID).Return(nil)
	driverRepo.EXPECT().FindNearbyOnlineByType(gomock.Any(), ride.Origin.Lat, ride.Origin.Lng, gomock.Any(), domain.RideTypeCar).
		Return([]domain.NearbyDriver{{ID: secondDriverID.String()}}, nil)
	rideRepo.EXPECT().AssignDriver(gomock.Any(), ride.ID, secondDriverID).Return(nil)
	updatedRide1 := *ride
	updatedRide1.DriverID = &secondDriverID
	updatedRide1.DeclineCount = 1
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(&updatedRide1, nil)

	result1, err := uc.Decline(context.Background(), firstDriverID, ride.ID)
	if err != nil {
		t.Fatalf("first decline: expected no error, got %v", err)
	}
	if !result1.NewDriverFound {
		t.Error("first decline: expected new driver to be found")
	}

	// Second decline: no more drivers available.
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(&updatedRide1, nil)
	rideRepo.EXPECT().ClearDriver(gomock.Any(), ride.ID).Return(nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusRequested).Return(nil)
	rideRepo.EXPECT().IncrementDeclineCount(gomock.Any(), ride.ID).Return(nil)
	driverRepo.EXPECT().FindNearbyOnlineByType(gomock.Any(), ride.Origin.Lat, ride.Origin.Lng, gomock.Any(), domain.RideTypeCar).
		Return([]domain.NearbyDriver{}, nil)
	updatedRide2 := updatedRide1
	updatedRide2.DriverID = nil
	updatedRide2.DeclineCount = 2
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(&updatedRide2, nil)

	result2, err := uc.Decline(context.Background(), secondDriverID, ride.ID)
	if err != nil {
		t.Fatalf("second decline: expected no error, got %v", err)
	}
	if result2.NewDriverFound {
		t.Error("second decline: expected no new driver to be found")
	}
	if result2.Ride.DeclineCount != 2 {
		t.Errorf("second decline: expected decline_count 2, got %d", result2.Ride.DeclineCount)
	}
}

func TestRideUseCase_Arrive_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusAccepted
		r.Origin = domain.LatLng{Lat: 14.5, Lng: 120.9}
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusArrived).Return(nil)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	// Within 50m of origin
	_, err := uc.Arrive(context.Background(), driverID, ride.ID, ride.Origin)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_Arrive_TooFar(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusAccepted
		r.Origin = domain.LatLng{Lat: 14.5, Lng: 120.9}
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	// Too far from origin (approx 100m away)
	farLocation := domain.LatLng{Lat: 14.501, Lng: 120.901}
	_, err := uc.Arrive(context.Background(), driverID, ride.ID, farLocation)
	if err != domain.ErrDriverTooFarFromPickup {
		t.Errorf("expected ErrDriverTooFarFromPickup, got %v", err)
	}
}

func TestRideUseCase_Start_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, _ := newRideUC(ctrl)
	driverID := uuid.New()
	ride := testutil.NewTestRide(uuid.New(), func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusArrived
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	rideRepo.EXPECT().UpdateStatus(gomock.Any(), ride.ID, domain.RideStatusInProgress).Return(nil)
	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)

	_, err := uc.Start(context.Background(), driverID, ride.ID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRideUseCase_TriggerSOS_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, rideRepo, _, incidentRepo := newRideUC(ctrl)
	passengerID := uuid.New()
	driverID := uuid.New()
	ride := testutil.NewTestRide(passengerID, func(r *domain.Ride) {
		r.DriverID = &driverID
		r.Status = domain.RideStatusInProgress
	})

	rideRepo.EXPECT().GetByID(gomock.Any(), ride.ID).Return(ride, nil)
	incidentRepo.EXPECT().Create(gomock.Any(), gomock.Any()).DoAndReturn(func(ctx context.Context, i *domain.Incident) error {
		if i.RideID != ride.ID || i.RiderID != passengerID || i.DriverID != driverID || i.Type != "sos_triggered" {
			t.Errorf("unexpected incident data: %+v", i)
		}
		return nil
	})

	_, err := uc.TriggerSOS(context.Background(), passengerID, domain.RolePassenger, ride.ID, "Help!")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}
