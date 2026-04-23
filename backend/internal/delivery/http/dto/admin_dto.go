package dto

import (
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type DashboardResponse struct {
	ActiveRiders       int     `json:"active_riders"`
	ActiveDrivers      int     `json:"active_drivers"`
	RidesToday         int     `json:"rides_today"`
	RevenueToday       float64 `json:"revenue_today"`
	AvgWaitTimeSeconds float64 `json:"avg_wait_time_seconds"`
	SystemUptime       float64 `json:"system_uptime"`
}

// UpdateAdminStatusRequest is the body of PUT /admin/users/:id.
// `role_id` is required; `name` / `email` are optional — absent fields
// keep the stored value. Email changes are checked for collision.
type UpdateAdminStatusRequest struct {
	Name   *string   `json:"name,omitempty"  binding:"omitempty,min=1,max=120"`
	Email  *string   `json:"email,omitempty" binding:"omitempty,email"`
	RoleID uuid.UUID `json:"role_id"         binding:"required"`
}

type FareConfigDTO struct {
	VehicleType     string  `json:"vehicle_type"`
	BaseFare        float64 `json:"base_fare"`
	PerKmRate       float64 `json:"per_km_rate"`
	PerMinRate      float64 `json:"per_min_rate"`
	MinimumFare     float64 `json:"minimum_fare"`
	BookingFee      float64 `json:"booking_fee"`
	CancellationFee float64 `json:"cancellation_fee"`
}

type SurgeConfigDTO struct {
	Enabled       bool    `json:"enabled"`
	MaxMultiplier float64 `json:"max_multiplier"`
	TriggerRatio  float64 `json:"trigger_ratio"`
	Zones         []byte  `json:"zones"`          // GeoJSON
	BlackoutHours []byte  `json:"blackout_hours"` // JSON
}

type AuditLogDTO struct {
	ID           string    `json:"id"`
	Timestamp    time.Time `json:"timestamp"`
	ActorID      string    `json:"actor_id"`
	Action       string    `json:"action"`
	ResourceType string    `json:"resource_type"`
	ResourceID   string    `json:"resource_id"`
	Reason       string    `json:"reason"`
}

type IncidentDTO struct {
	ID              string     `json:"id"`
	RideID          string     `json:"ride_id"`
	Type            string     `json:"type"`
	Status          string     `json:"status"`
	TriggeredBy     string     `json:"triggered_by"`
	RiderID         string     `json:"rider_id"`
	DriverID        string     `json:"driver_id"`
	AssignedTo      *string    `json:"assigned_to,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	ResolvedAt      *time.Time `json:"resolved_at,omitempty"`
	ResolutionNotes string     `json:"resolution_notes,omitempty"`
}

func NewDashboardResponse(m *domain.DashboardMetrics) *DashboardResponse {
	return &DashboardResponse{
		ActiveRiders:       m.ActiveRiders,
		ActiveDrivers:      m.ActiveDrivers,
		RidesToday:         m.RidesToday,
		RevenueToday:       m.RevenueToday,
		AvgWaitTimeSeconds: m.AvgWaitTimeSeconds,
		SystemUptime:       m.SystemUptime,
	}
}

func NewIncidentDTO(i *domain.Incident) *IncidentDTO {
	dto := &IncidentDTO{
		ID:              i.ID.String(),
		RideID:          i.RideID.String(),
		Type:            i.Type,
		Status:          i.Status,
		TriggeredBy:     i.TriggeredBy,
		RiderID:         i.RiderID.String(),
		DriverID:        i.DriverID.String(),
		CreatedAt:       i.CreatedAt,
		ResolvedAt:      i.ResolvedAt,
		ResolutionNotes: i.ResolutionNotes,
	}
	if i.AssignedTo != nil {
		s := i.AssignedTo.String()
		dto.AssignedTo = &s
	}
	return dto
}

// IncidentStatusEventDTO is a single row in the SOS timeline.
type IncidentStatusEventDTO struct {
	ID           string    `json:"id"`
	FromStatus   *string   `json:"from_status,omitempty"`
	ToStatus     string    `json:"to_status"`
	FromAssignee *string   `json:"from_assignee,omitempty"`
	ToAssignee   *string   `json:"to_assignee,omitempty"`
	ActorID      *string   `json:"actor_id,omitempty"`
	ActorName    string    `json:"actor_name,omitempty"`
	Note         string    `json:"note,omitempty"`
	OccurredAt   time.Time `json:"occurred_at"`
}

// IncidentLocationPointDTO is one GPS ping captured during an active incident.
type IncidentLocationPointDTO struct {
	Lat        float64   `json:"lat"`
	Lng        float64   `json:"lng"`
	RecordedAt time.Time `json:"recorded_at"`
}

// IncidentDetailDTO is returned by GET /admin/incidents/{id}.
type IncidentDetailDTO struct {
	Incident      *IncidentDTO               `json:"incident"`
	StatusHistory []IncidentStatusEventDTO   `json:"status_history"`
	LocationTrail []IncidentLocationPointDTO `json:"location_trail"`
}

func NewIncidentDetailDTO(d *domain.IncidentDetail) *IncidentDetailDTO {
	res := &IncidentDetailDTO{
		Incident:      NewIncidentDTO(d.Incident),
		StatusHistory: make([]IncidentStatusEventDTO, 0, len(d.StatusHistory)),
		LocationTrail: make([]IncidentLocationPointDTO, 0, len(d.LocationTrail)),
	}
	for _, ev := range d.StatusHistory {
		item := IncidentStatusEventDTO{
			ID:         ev.ID.String(),
			FromStatus: ev.FromStatus,
			ToStatus:   ev.ToStatus,
			ActorName:  ev.ActorName,
			Note:       ev.Note,
			OccurredAt: ev.OccurredAt,
		}
		if ev.FromAssignee != nil {
			s := ev.FromAssignee.String()
			item.FromAssignee = &s
		}
		if ev.ToAssignee != nil {
			s := ev.ToAssignee.String()
			item.ToAssignee = &s
		}
		if ev.ActorID != nil {
			s := ev.ActorID.String()
			item.ActorID = &s
		}
		res.StatusHistory = append(res.StatusHistory, item)
	}
	for _, p := range d.LocationTrail {
		res.LocationTrail = append(res.LocationTrail, IncidentLocationPointDTO{
			Lat:        p.Lat,
			Lng:        p.Lng,
			RecordedAt: p.RecordedAt,
		})
	}
	return res
}

// AdminRideItemDTO is the API representation of a ride in the admin browse list.
type AdminRideItemDTO struct {
	ID                 string `json:"id"`
	Status             string `json:"status"`
	OriginAddress      string `json:"origin_address"`
	DestinationAddress string `json:"destination_address"`
	PassengerName      string `json:"passenger_name"`
	DriverName         string `json:"driver_name,omitempty"`
	CreatedAt          string `json:"created_at"`
}

// AdminRideListResponse wraps a paginated list of rides.
type AdminRideListResponse struct {
	Data       []AdminRideItemDTO    `json:"data"`
	Pagination domain.PaginationMeta `json:"pagination"`
}

// AdminUserListResponse wraps a paginated list of users.
type AdminUserListResponse struct {
	Data       []UserResponse        `json:"data"`
	Pagination domain.PaginationMeta `json:"pagination"`
}

func NewAdminRideListResponse(items []*domain.AdminRideItem, meta domain.PaginationMeta) AdminRideListResponse {
	dtos := make([]AdminRideItemDTO, 0, len(items))
	for _, item := range items {
		dto := AdminRideItemDTO{
			ID:                 item.Ride.ID.String(),
			Status:             string(item.Ride.Status),
			OriginAddress:      item.Ride.OriginAddress,
			DestinationAddress: item.Ride.DestinationAddress,
			PassengerName:      item.PassengerName,
			DriverName:         item.DriverName,
			CreatedAt:          item.Ride.CreatedAt.Format(time.RFC3339),
		}
		dtos = append(dtos, dto)
	}
	return AdminRideListResponse{Data: dtos, Pagination: meta}
}

func NewAdminUserListResponse(users []*domain.User, meta domain.PaginationMeta) AdminUserListResponse {
	dtos := make([]UserResponse, 0, len(users))
	for _, u := range users {
		dtos = append(dtos, NewUserResponse(u))
	}
	return AdminUserListResponse{Data: dtos, Pagination: meta}
}

// ─── Role DTOs ────────────────────────────────────────────────────────────────

type RolePermissionDTO struct {
	PermissionKey string `json:"permission_key" binding:"required"`
	Read          bool   `json:"read"`
	Write         bool   `json:"write"`
}

type CreateRoleRequest struct {
	Name        string              `json:"name" binding:"required"`
	Description string              `json:"description"`
	Permissions []RolePermissionDTO `json:"permissions" binding:"required,min=1"`
}

type UpdateRoleRequest struct {
	Name        string              `json:"name" binding:"required"`
	Description string              `json:"description"`
	Permissions []RolePermissionDTO `json:"permissions" binding:"required,min=1"`
}

type RoleResponse struct {
	ID          string              `json:"id"`
	Name        string              `json:"name"`
	Description string              `json:"description"`
	IsSystem    bool                `json:"is_system"`
	Permissions []RolePermissionDTO `json:"permissions"`
	AdminCount  int                 `json:"admin_count"`
	CreatedAt   time.Time           `json:"created_at"`
	UpdatedAt   time.Time           `json:"updated_at"`
}

func NewRoleResponse(r *domain.Role) RoleResponse {
	perms := make([]RolePermissionDTO, len(r.Permissions))
	for i, p := range r.Permissions {
		perms[i] = RolePermissionDTO{PermissionKey: p.PermissionKey, Read: p.Read, Write: p.Write}
	}
	return RoleResponse{
		ID: r.ID.String(), Name: r.Name, Description: r.Description,
		IsSystem: r.IsSystem, Permissions: perms, AdminCount: r.AdminCount,
		CreatedAt: r.CreatedAt, UpdatedAt: r.UpdatedAt,
	}
}

// ─── Payment DTOs ─────────────────────────────────────────────────────────────

type TransactionDTO struct {
	ID            string    `json:"id"`
	RideID        string    `json:"ride_id"`
	RiderName     string    `json:"rider_name"`
	DriverName    string    `json:"driver_name"`
	Amount        float64   `json:"amount"`
	PaymentMethod string    `json:"payment_method"`
	Status        string    `json:"status"`
	Commission    float64   `json:"commission"`
	CreatedAt     time.Time `json:"created_at"`
}

type DriverPayoutDTO struct {
	ID          string  `json:"id"`
	Batch       string  `json:"batch"`
	DriverCount int     `json:"driver_count"`
	TotalAmount float64 `json:"total_amount"`
	Period      string  `json:"period"`
	Status      string  `json:"status"`
}

type BatchApproveRequest struct {
	IDs []string `json:"ids" binding:"required,min=1"`
}

type CommissionUpdateRequest struct {
	VehicleType   string  `json:"vehicle_type" binding:"required"`
	RatePercent   float64 `json:"rate_percent" binding:"required"`
	MinCommission float64 `json:"min_commission"`
}

func NewTransactionDTO(t *domain.Transaction) TransactionDTO {
	return TransactionDTO{
		ID: t.ID.String(), RideID: t.RideID.String(), RiderName: t.RiderName,
		DriverName: t.DriverName, Amount: t.Amount, PaymentMethod: t.PaymentMethod,
		Status: t.Status, Commission: t.Commission, CreatedAt: t.CreatedAt,
	}
}

func NewDriverPayoutDTO(p *domain.DriverPayout) DriverPayoutDTO {
	return DriverPayoutDTO{
		ID: p.ID.String(), Batch: p.Batch, DriverCount: p.DriverCount,
		TotalAmount: p.TotalAmount, Period: p.Period, Status: p.Status,
	}
}

// ─── Safety DTOs ──────────────────────────────────────────────────────────────

type KycEntryDTO struct {
	ID          string    `json:"id"`
	DriverID    string    `json:"driver_id"`
	DriverName  string    `json:"driver_name"`
	SubmittedAt time.Time `json:"submitted_at"`
	Docs        []string  `json:"docs"`
	Status      string    `json:"status"`
}

type UpdateKycRequest struct {
	Status string `json:"status" binding:"required,oneof=approved rejected"`
	Reason string `json:"reason"`
}

type KycBatchRequest struct {
	IDs    []string `json:"ids" binding:"required,min=1"`
	Status string   `json:"status" binding:"required,oneof=approved rejected"`
}

func NewKycEntryDTO(e *domain.KycEntry) KycEntryDTO {
	return KycEntryDTO{
		ID: e.ID.String(), DriverID: e.DriverID.String(), DriverName: e.DriverName,
		SubmittedAt: e.SubmittedAt, Docs: e.Docs, Status: e.Status,
	}
}

// ─── System DTOs ──────────────────────────────────────────────────────────────

type UpdateFeatureFlagRequest struct {
	Enabled bool `json:"enabled"`
}

type UpdateIntegrationRequest struct {
	Config map[string]string `json:"config" binding:"required"`
}

type UpdateNotificationTemplateRequest struct {
	Subject string `json:"subject"`
	Body    string `json:"body" binding:"required"`
}

type IntegrationTestResultDTO struct {
	Service   string `json:"service"`
	Status    string `json:"status"`
	LatencyMs int    `json:"latency_ms"`
	Message   string `json:"message"`
}

// ─── Metrics DTOs ─────────────────────────────────────────────────────────────

type MetricResponseDTO struct {
	Current       float64 `json:"current"`
	Previous      float64 `json:"previous"`
	ChangePercent float64 `json:"change_percent"`
	Trend         string  `json:"trend"`
}

func NewMetricResponseDTO(m *domain.MetricResponse) MetricResponseDTO {
	return MetricResponseDTO{
		Current: m.Current, Previous: m.Previous,
		ChangePercent: m.ChangePercent, Trend: m.Trend,
	}
}

// ─── Auth DTOs ────────────────────────────────────────────────────────────────

type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=8"`
}

// ResetPasswordRequest is the superadmin-initiated password reset payload
// (PUT /admin/users/{id}/password).
type ResetPasswordRequest struct {
	NewPassword string `json:"new_password" binding:"required,min=8"`
}

// CreateAuditEntryRequest matches the OpenAPI CreateAuditEntryRequest schema.
// Before/after state are arbitrary JSON objects persisted as raw bytes.
type CreateAuditEntryRequest struct {
	ResourceType string         `json:"resource_type" binding:"required"`
	ResourceID   string         `json:"resource_id"   binding:"required"`
	Action       string         `json:"action"        binding:"required,oneof=create update delete approve reject login logout"`
	BeforeState  map[string]any `json:"before_state,omitempty"`
	AfterState   map[string]any `json:"after_state,omitempty"`
	Reason       string         `json:"reason,omitempty"`
}
