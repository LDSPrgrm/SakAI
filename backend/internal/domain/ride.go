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
	// RideStatusCreated marks a ride that was just placed but is not yet
	// being dispatched to drivers (e.g. waiting for fare confirmation).
	// RFC v2 §7 — pre-`requested` state.
	RideStatusCreated RideStatus = "created"

	RideStatusRequested  RideStatus = "requested"
	RideStatusAccepted   RideStatus = "accepted"
	RideStatusArrived    RideStatus = "arrived"
	RideStatusInProgress RideStatus = "in_progress"

	// RideStatusPaymentPending sits between in_progress and completed for
	// rides that finish with a non-cash payment method whose settlement
	// hasn't been confirmed by the gateway. RFC v2 §7. Driver sees
	// "Payment processing…" until payment.succeeded transitions through.
	RideStatusPaymentPending RideStatus = "payment_pending"

	RideStatusCompleted RideStatus = "completed"
	RideStatusCancelled RideStatus = "cancelled"
)

// validTransitions defines the allowed state machine transitions.
// Any transition not listed here is invalid and must be rejected.
var validTransitions = map[RideStatus]map[RideStatus]bool{
	RideStatusCreated:        {RideStatusRequested: true, RideStatusCancelled: true},
	RideStatusRequested:      {RideStatusAccepted: true, RideStatusCancelled: true},
	RideStatusAccepted:       {RideStatusArrived: true, RideStatusCancelled: true},
	RideStatusArrived:        {RideStatusInProgress: true, RideStatusCancelled: true},
	RideStatusInProgress:     {RideStatusCompleted: true, RideStatusPaymentPending: true},
	RideStatusPaymentPending: {RideStatusCompleted: true, RideStatusCancelled: true},
	RideStatusCompleted:      {},
	RideStatusCancelled:      {},
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
// RFC v2 §8 splits reason codes by actor: passengers and drivers see
// different pickers in the UI, and `other` is the only shared code.
type CancellationReason string

const (
	// Passenger-side reasons (selected by passenger in cancel flow).
	ReasonDriverTooFar    CancellationReason = "driver_too_far"
	ReasonChangedPlans    CancellationReason = "changed_plans"
	ReasonWrongPickup     CancellationReason = "wrong_pickup"
	ReasonDriverNotMoving CancellationReason = "driver_not_moving"
	ReasonSafetyConcern   CancellationReason = "safety_concern"

	// Driver-side reasons (selected by driver in cancel flow). RFC v2 §8.6.
	ReasonPassengerNoShow      CancellationReason = "passenger_no_show"
	ReasonUnsafePickupArea     CancellationReason = "unsafe_pickup_area"
	ReasonVehicleIssue         CancellationReason = "vehicle_issue"
	ReasonPassengerRequest     CancellationReason = "passenger_request"
	ReasonOtherDriverReason    CancellationReason = "other_driver_reason"

	// Shared.
	ReasonOther CancellationReason = "other"
)

// passengerReasons + driverReasons partition the taxonomy by actor.
// `other` is intentionally in both sets so the validators stay symmetrical.
var passengerReasons = map[CancellationReason]struct{}{
	ReasonDriverTooFar:    {},
	ReasonChangedPlans:    {},
	ReasonWrongPickup:     {},
	ReasonDriverNotMoving: {},
	ReasonSafetyConcern:   {},
	ReasonOther:           {},
}

var driverReasons = map[CancellationReason]struct{}{
	ReasonPassengerNoShow:   {},
	ReasonUnsafePickupArea:  {},
	ReasonVehicleIssue:      {},
	ReasonPassengerRequest:  {},
	ReasonOtherDriverReason: {},
	ReasonOther:             {},
}

// IsValidCancellationReason returns true if the string is a valid
// cancellation reason for any actor. Use [IsValidCancellationReasonFor]
// when actor context is known — the actor-scoped check rejects driver
// codes from passengers and vice versa.
func IsValidCancellationReason(s string) bool {
	r := CancellationReason(s)
	if _, ok := passengerReasons[r]; ok {
		return true
	}
	_, ok := driverReasons[r]
	return ok
}

// IsValidCancellationReasonFor scopes reason validation to the actor that
// chose it. RFC v2 §8: rejecting cross-actor codes catches both API
// misuse and stale clients.
func IsValidCancellationReasonFor(by CancelledBy, s string) bool {
	r := CancellationReason(s)
	switch by {
	case CancelledByPassenger:
		_, ok := passengerReasons[r]
		return ok
	case CancelledByDriver:
		_, ok := driverReasons[r]
		return ok
	case CancelledBySystem:
		// System cancellations carry their own reasons (offer expiry,
		// auto-cancel); any value in either set is acceptable.
		return IsValidCancellationReason(s)
	}
	return false
}

// Ride is the central aggregate for a single trip lifecycle.
type Ride struct {
	ID                   uuid.UUID    `json:"id"`
	Seq                  int64        `json:"seq"`
	DisplayID            string       `json:"display_id"`
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
