package dto

import (
	"time"

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

type UpdateAdminStatusRequest struct {
	Role domain.UserRole `json:"role" binding:"required"`
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
	return &IncidentDTO{
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
