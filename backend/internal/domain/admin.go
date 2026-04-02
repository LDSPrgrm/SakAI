package domain

import (
	"time"

	"github.com/google/uuid"
)

// FareConfig represents the pricing rules for a specific vehicle type.
type FareConfig struct {
	ID              uuid.UUID `json:"id"`
	VehicleType     string    `json:"vehicle_type"`
	BaseFare        float64   `json:"base_fare"`
	PerKmRate       float64   `json:"per_km_rate"`
	PerMinRate      float64   `json:"per_min_rate"`
	MinimumFare     float64   `json:"minimum_fare"`
	BookingFee      float64   `json:"booking_fee"`
	CancellationFee float64   `json:"cancellation_fee"`
	UpdatedAt       time.Time `json:"updated_at"`
	UpdatedBy       uuid.UUID `json:"updated_by"`
}

// SurgeConfig represents global and zone-specific surge pricing rules.
type SurgeConfig struct {
	ID            uuid.UUID `json:"id"`
	Enabled       bool      `json:"enabled"`
	MaxMultiplier float64   `json:"max_multiplier"`
	TriggerRatio  float64   `json:"trigger_ratio"`
	Zones         []byte    `json:"zones"`          // GeoJSON
	BlackoutHours []byte    `json:"blackout_hours"` // JSON
	UpdatedAt     time.Time `json:"updated_at"`
	UpdatedBy     uuid.UUID `json:"updated_by"`
}

// PaymentGatewayConfig carries settings for external payment providers.
type PaymentGatewayConfig struct {
	ID           uuid.UUID `json:"id"`
	Provider     string    `json:"provider"`
	ConfigFields []byte    `json:"config_fields"` // JSON
	IsActive     bool      `json:"is_active"`
	UpdatedAt    time.Time `json:"updated_at"`
	UpdatedBy    uuid.UUID `json:"updated_by"`
}

// CommissionSettings defines platform revenue rules.
type CommissionSettings struct {
	ID            uuid.UUID `json:"id"`
	VehicleType   string    `json:"vehicle_type"`
	RatePercent   float64   `json:"rate_percent"`
	MinCommission float64   `json:"min_commission"`
	UpdatedAt     time.Time `json:"updated_at"`
	UpdatedBy     uuid.UUID `json:"updated_by"`
}
