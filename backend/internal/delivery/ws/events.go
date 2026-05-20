package ws

import (
	"time"

	"github.com/google/uuid"
)

// Typed payload structs for each WebSocket event. These mirror the
// `WsEvent*` schemas in openapi/swagger.yaml.
//
// Callers may still pass `gin.H`/`map[string]any` to the Hub for
// backward compatibility — the typed structs are a discipline
// callers can adopt incrementally. Future tightening will replace
// `payload any` signatures with a sealed payload interface.

// RideRequestedPayload carries the data for `ride.requested`
// (server → driver: a new ride offer).
type RideRequestedPayload struct {
	RideID             uuid.UUID `json:"ride_id"`
	PassengerID        uuid.UUID `json:"passenger_id"`
	Origin             LatLng    `json:"origin"`
	Destination        LatLng    `json:"destination"`
	OriginAddress      *string   `json:"origin_address,omitempty"`
	DestinationAddress *string   `json:"destination_address,omitempty"`
	Notes              *string   `json:"notes,omitempty"`
	ExpiresAt          time.Time `json:"expires_at"`
}

// RideAcceptedPayload carries the data for `ride.accepted`
// (server → passenger: driver assigned).
type RideAcceptedPayload struct {
	RideID   uuid.UUID `json:"ride_id"`
	DriverID uuid.UUID `json:"driver_id"`
}

// RideDeclinedPayload carries the data for `ride.declined`
// (server → passenger: assigned driver declined).
type RideDeclinedPayload struct {
	RideID  uuid.UUID `json:"ride_id"`
	Message string    `json:"message,omitempty"`
}

// RideOfferExpiredPayload carries the data for `ride.offer_expired`
// (server → driver: acceptance window closed).
type RideOfferExpiredPayload struct {
	RideID uuid.UUID `json:"ride_id"`
}

// RideStatusChangedPayload carries the data for `ride.status_changed`
// (server → both: lifecycle transition).
type RideStatusChangedPayload struct {
	RideID    uuid.UUID `json:"ride_id"`
	Status    string    `json:"status"`
	UpdatedAt time.Time `json:"updated_at"`
}

// RideCancelledPayload carries the data for `ride.cancelled`
// (server → both: either party cancelled).
type RideCancelledPayload struct {
	RideID      uuid.UUID `json:"ride_id"`
	CancelledBy string    `json:"cancelled_by"` // "passenger" | "driver"
	Reason      *string   `json:"reason,omitempty"`
}

// RideSOSPayload carries the data for `ride.sos_triggered`.
type RideSOSPayload struct {
	RideID      uuid.UUID `json:"ride_id"`
	IncidentID  uuid.UUID `json:"incident_id"`
	TriggeredBy string    `json:"triggered_by"` // "rider" | "driver"
	Reason      *string   `json:"reason,omitempty"`
}

// NoDriversAvailablePayload carries the data for `ride.no_drivers`.
type NoDriversAvailablePayload struct {
	RideID  uuid.UUID `json:"ride_id"`
	Message string    `json:"message,omitempty"`
}

// RideStateSyncPayload carries the data for `ride.state_sync`, emitted by
// the WS handler when a reconnecting client's `last_event_id` is outside
// the replay window. The client uses this to reconcile UI state without
// hitting REST.
type RideStateSyncPayload struct {
	// HasActiveRide tells the client whether to drop into "no active ride"
	// UI (false) or hydrate the active-ride screen (true).
	HasActiveRide bool       `json:"has_active_ride"`
	RideID        *uuid.UUID `json:"ride_id,omitempty"`
	Status        string     `json:"status,omitempty"`
	DriverID      *uuid.UUID `json:"driver_id,omitempty"`
	PassengerID   *uuid.UUID `json:"passenger_id,omitempty"`
	UpdatedAt     *time.Time `json:"updated_at,omitempty"`
}

// DriverLocationPayload carries the data for `driver.location_updated`.
//
// Marked high-frequency in the spec — clients may use a hand-coded
// fast-path deserializer keyed only on lat/lng/heading/ride_id.
type DriverLocationPayload struct {
	RideID   uuid.UUID `json:"ride_id"`
	Location LatLng    `json:"location"`
	Heading  *float64  `json:"heading,omitempty"`
}

// LatLng is the lat/lng pair shared by ride origin/destination and
// driver location updates. Mirrors components/schemas/LatLng in OpenAPI.
type LatLng struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}
