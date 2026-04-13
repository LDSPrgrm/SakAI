package domain

import (
	"time"

	"github.com/google/uuid"
)

// DriverEarnings represents a single ride's earnings contribution for a driver.
type DriverEarnings struct {
	ID          uuid.UUID `json:"id"`
	DriverID    uuid.UUID `json:"driver_id"`
	RideID      uuid.UUID `json:"ride_id"`
	FareAmount  float64   `json:"fare_amount"`
	TipAmount   float64   `json:"tip_amount"`
	TotalAmount float64   `json:"total_amount"`
	Currency    string    `json:"currency"`
	CompletedAt time.Time `json:"completed_at"`
}
