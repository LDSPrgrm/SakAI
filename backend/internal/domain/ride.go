package domain

import (
	"time"

	"github.com/google/uuid"
)

// RideType represents the type of vehicle requested.
type RideType string

const (
	RideTypeMotorcycle RideType = "motorcycle"
	RideTypeCar        RideType = "car"
	RideTypeTricycle   RideType = "tricycle"
)

// RideStatus represents the current state of a ride in the state machine.
type RideStatus string

const (
	RideStatusRequested  RideStatus = "requested"
	RideStatusAccepted   RideStatus = "accepted"
	RideStatusArrived    RideStatus = "arrived"
	RideStatusInProgress RideStatus = "in_progress"
	RideStatusCompleted  RideStatus = "completed"
	RideStatusCancelled  RideStatus = "cancelled"
)

// validTransitions defines the allowed state machine transitions.
// Any transition not listed here is invalid and must be rejected.
var validTransitions = map[RideStatus]map[RideStatus]bool{
	RideStatusRequested:  {RideStatusAccepted: true, RideStatusCancelled: true},
	RideStatusAccepted:   {RideStatusArrived: true, RideStatusCancelled: true},
	RideStatusArrived:    {RideStatusInProgress: true, RideStatusCancelled: true},
	RideStatusInProgress: {RideStatusCompleted: true},
	RideStatusCompleted:  {},
	RideStatusCancelled:  {},
}

// CanTransitionTo returns true if moving from the current status to next is a valid transition.
func (s RideStatus) CanTransitionTo(next RideStatus) bool {
	return validTransitions[s][next]
}

// IsTerminal returns true if no further transitions are possible.
func (s RideStatus) IsTerminal() bool {
	return s == RideStatusCompleted || s == RideStatusCancelled
}

// CancelledBy identifies which party initiated the cancellation.
type CancelledBy string

const (
	CancelledByPassenger CancelledBy = "passenger"
	CancelledByDriver    CancelledBy = "driver"
	CancelledBySystem    CancelledBy = "system" // offer expiry, auto-cancellation
)

// CancellationReason represents a predefined reason code for cancellation.
type CancellationReason string

const (
	ReasonDriverTooFar    CancellationReason = "driver_too_far"
	ReasonChangedPlans    CancellationReason = "changed_plans"
	ReasonWrongPickup     CancellationReason = "wrong_pickup"
	ReasonDriverNotMoving CancellationReason = "driver_not_moving"
	ReasonSafetyConcern   CancellationReason = "safety_concern"
	ReasonOther           CancellationReason = "other"
)

// IsValidCancellationReason returns true if the string is a valid cancellation reason.
func IsValidCancellationReason(s string) bool {
	switch CancellationReason(s) {
	case ReasonDriverTooFar, ReasonChangedPlans, ReasonWrongPickup,
		ReasonDriverNotMoving, ReasonSafetyConcern, ReasonOther:
		return true
	}
	return false
}

// Ride is the central aggregate for a single trip lifecycle.
type Ride struct {
	ID                   uuid.UUID    `json:"id"`
	PassengerID          uuid.UUID    `json:"passenger_id"`
	DriverID             *uuid.UUID   `json:"driver_id,omitempty"`
	Status               RideStatus   `json:"status"`
	Origin               LatLng       `json:"origin"`
	Destination          LatLng       `json:"destination"`
	OriginAddress        string       `json:"origin_address,omitempty"`
	DestinationAddress   string       `json:"destination_address,omitempty"`
	Notes                string       `json:"notes,omitempty"`
	Fare                 float64      `json:"fare,omitempty"`                   // Final fare (set on completion)
	EstimatedFare        *float64     `json:"estimated_fare,omitempty"`         // Estimated fare at request time
	ActualFare           *float64     `json:"actual_fare,omitempty"`            // Actual fare after completion
	RideType             RideType     `json:"ride_type"`                        // Type of vehicle requested
	FareBreakdown        *JSONMap     `json:"fare_breakdown,omitempty"`         // Detailed fare breakdown
	CancelledBy          *CancelledBy `json:"cancelled_by,omitempty"`
	CancellationReason   *string      `json:"cancellation_reason,omitempty"`    // Reason code for cancellation
	CancellationReasonText *string    `json:"cancellation_reason_text,omitempty"` // Free-text cancellation reason
	DeclineCount         int          `json:"decline_count"`                    // Number of times ride was declined
	IdempotencyKey       string       `json:"-"`                                // internal, never serialized
	CreatedAt            time.Time    `json:"created_at"`
	UpdatedAt            time.Time    `json:"updated_at"`
}
