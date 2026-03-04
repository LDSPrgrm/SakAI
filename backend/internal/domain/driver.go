package domain

import (
	"time"

	"github.com/google/uuid"
)

// DriverStatus tracks whether the driver is visible to the matching engine.
type DriverStatus string

const (
	DriverStatusOnline  DriverStatus = "online"
	DriverStatusOffline DriverStatus = "offline"
)

// DriverLocation extends LatLng with an optional compass heading for map rendering.
type DriverLocation struct {
	LatLng
	Heading *float64 `json:"heading,omitempty"`
}

// Driver represents the real-time operational state of a driver.
// Kept separate from User to decouple identity from availability.
type Driver struct {
	UserID    uuid.UUID       `json:"user_id"`
	Status    DriverStatus    `json:"status"`
	Location  *DriverLocation `json:"location,omitempty"`
	UpdatedAt time.Time       `json:"updated_at"`
}
