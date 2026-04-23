package domain

import (
	"encoding/json"
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
	UpdatedByName   string    `json:"updated_by_name,omitempty"`
}

// SurgeConfig represents global and zone-specific surge pricing rules.
// Zones holds the raw JSONB as [{name, multiplier, polygon: [[lat,lng]...]}, ...]
// consumed by usecase.ParseSurgeZones + point-in-polygon fare lookup.
type SurgeConfig struct {
	ID            uuid.UUID       `json:"id"`
	Enabled       bool            `json:"enabled"`
	MaxMultiplier float64         `json:"max_multiplier"`
	TriggerRatio  float64         `json:"trigger_ratio"`
	Zones         json.RawMessage `json:"zones"`
	BlackoutHours json.RawMessage `json:"blackout_hours"`
	UpdatedAt     time.Time       `json:"updated_at"`
	UpdatedBy     uuid.UUID       `json:"updated_by"`
	UpdatedByName string          `json:"updated_by_name,omitempty"`
}

// PaymentGatewayConfig carries settings for external payment providers.
// ConfigFields is a string→string map serialized to/from JSONB. Secret-like
// keys are masked on read responses by maskSecrets() in system_repo.go.
type PaymentGatewayConfig struct {
	ID           uuid.UUID         `json:"id"`
	Provider     string            `json:"provider"`
	ConfigFields map[string]string `json:"config_fields"`
	IsActive     bool              `json:"is_active"`
	UpdatedAt    time.Time         `json:"updated_at"`
	UpdatedBy    uuid.UUID         `json:"updated_by"`
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

// Role represents a named permission set assignable to admin users.
type Role struct {
	ID          uuid.UUID        `json:"id"`
	Name        string           `json:"name"`
	Description string           `json:"description"`
	IsSystem    bool             `json:"is_system"`
	Permissions []RolePermission `json:"permissions"`
	AdminCount  int              `json:"admin_count"`
	CreatedBy   uuid.UUID        `json:"created_by"`
	CreatedAt   time.Time        `json:"created_at"`
	UpdatedAt   time.Time        `json:"updated_at"`
}

// RolePermission defines read/write access for a single permission key.
type RolePermission struct {
	PermissionKey string `json:"permission_key"`
	Read          bool   `json:"read"`
	Write         bool   `json:"write"`
}

// Transaction represents a payment record for a completed ride.
type Transaction struct {
	ID            uuid.UUID `json:"id"`
	RideID        uuid.UUID `json:"ride_id"`
	RiderName     string    `json:"rider_name"`
	DriverName    string    `json:"driver_name"`
	Amount        float64   `json:"amount"`
	PaymentMethod string    `json:"payment_method"`
	Status        string    `json:"status"`
	Commission    float64   `json:"commission"`
	CreatedAt     time.Time `json:"created_at"`
}

// DriverPayout represents a batch payout to drivers.
type DriverPayout struct {
	ID          uuid.UUID `json:"id"`
	Batch       string    `json:"batch"`
	DriverCount int       `json:"driver_count"`
	TotalAmount float64   `json:"total_amount"`
	Period      string    `json:"period"`
	Status      string    `json:"status"`
}

// PaymentSummary aggregates financial KPIs.
type PaymentSummary struct {
	TotalRevenue       float64 `json:"total_revenue"`
	Payouts            float64 `json:"payouts"`
	Commission         float64 `json:"commission"`
	PendingSettlements float64 `json:"pending_settlements"`
}

// HeatmapPosition is a single online driver's last known location for the
// admin driver-supply visualization.
type HeatmapPosition struct {
	DriverID    uuid.UUID `json:"driver_id"`
	Lat         float64   `json:"lat"`
	Lng         float64   `json:"lng"`
	VehicleType string    `json:"vehicle_type,omitempty"`
	IsAvailable bool      `json:"is_available"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// HeatmapBounds is the lat/lng bounding box the UI uses for the SVG fallback
// map. Server returns the actual extents of the returned positions when there
// is data, else a Metro Manila default.
type HeatmapBounds struct {
	North float64 `json:"north"`
	South float64 `json:"south"`
	East  float64 `json:"east"`
	West  float64 `json:"west"`
}

// DriverHeatmap is the response shape for GET /admin/drivers/heatmap.
type DriverHeatmap struct {
	Positions   []HeatmapPosition `json:"positions"`
	Bounds      HeatmapBounds     `json:"bounds"`
	GeneratedAt time.Time         `json:"generated_at"`
}

// KycEntry represents a driver KYC submission in the review queue.
type KycEntry struct {
	ID          uuid.UUID `json:"id"`
	DriverID    uuid.UUID `json:"driver_id"`
	DriverName  string    `json:"driver_name"`
	SubmittedAt time.Time `json:"submitted_at"`
	Docs        []string  `json:"docs"`
	Status      string    `json:"status"`
}

// FeatureFlag is a system-level toggle.
type FeatureFlag struct {
	Key         string `json:"key"`
	Label       string `json:"label"`
	Description string `json:"description"`
	Enabled     bool   `json:"enabled"`
}

// Integration holds external service configuration and health status.
type Integration struct {
	Service  string            `json:"service"`
	Status   string            `json:"status"`
	LastSync time.Time         `json:"last_sync"`
	Config   map[string]string `json:"config"`
}

// NotificationTemplate is a configurable message template for a platform event.
type NotificationTemplate struct {
	Event   string `json:"event"`
	Channel string `json:"channel"`
	Subject string `json:"subject"`
	Body    string `json:"body"`
}

// SystemService represents a backend service and its health snapshot.
type SystemService struct {
	Name        string    `json:"name"`
	Status      string    `json:"status"`
	LatencyMs   int       `json:"latency_ms"`
	UptimePct   float64   `json:"uptime_pct"`
	LastChecked time.Time `json:"last_checked"`
}

// ReportDefinition describes an available report type.
type ReportDefinition struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
}

// ComplianceData holds LTFRB regulatory compliance status. Mirrors the
// regulatory_compliance singleton row in Postgres.
type ComplianceData struct {
	AccreditationStatus  string     `json:"accreditation_status"`
	AccreditationExpiry  time.Time  `json:"accreditation_expiry"`
	DriverComplianceRate float64    `json:"driver_compliance_rate"`
	ViolationCount       int        `json:"violation_count"`
	ViolationsOpen       int        `json:"violations_open"`
	ViolationsResolved   int        `json:"violations_resolved"`
	LastAuditAt          *time.Time `json:"last_audit_at,omitempty"`
}

// MetricResponse carries a single KPI with trend data.
type MetricResponse struct {
	Current       float64 `json:"current"`
	Previous      float64 `json:"previous"`
	ChangePercent float64 `json:"change_percent"`
	Trend         string  `json:"trend"` // "up", "down", "flat"
}
