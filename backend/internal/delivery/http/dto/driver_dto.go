package dto

import (
	"time"

	"github.com/sakai/backend/internal/domain"
)

// EarningsItem mirrors openapi EarningsItem.
type EarningsItem struct {
	ID          string    `json:"id"`
	RideID      string    `json:"ride_id"`
	FareAmount  float64   `json:"fare_amount"`
	TipAmount   float64   `json:"tip_amount"`
	TotalAmount float64   `json:"total_amount"`
	Currency    string    `json:"currency"`
	CompletedAt time.Time `json:"completed_at"`
}

// NewEarningsItem converts a domain.DriverEarnings into the API shape.
func NewEarningsItem(e *domain.DriverEarnings) EarningsItem {
	total := e.TotalAmount
	if total == 0 {
		total = e.FareAmount + e.TipAmount
	}
	return EarningsItem{
		ID:          e.ID.String(),
		RideID:      e.RideID.String(),
		FareAmount:  e.FareAmount,
		TipAmount:   e.TipAmount,
		TotalAmount: total,
		Currency:    e.Currency,
		CompletedAt: e.CompletedAt,
	}
}

// PaginationMeta matches the openapi PaginationMeta shape used across list endpoints.
type PaginationMeta struct {
	CurrentPage int `json:"current_page"`
	Limit       int `json:"limit"`
	TotalItems  int `json:"total_items"`
	TotalPages  int `json:"total_pages"`
}

// SetStatusRequest is the body for PUT /driver/status.
type SetStatusRequest struct {
	Status domain.DriverStatus `json:"status" binding:"required,oneof=online offline"`
}

// UpdateLocationRequest is the body for PUT /driver/location.
type UpdateLocationRequest struct {
	Location struct {
		Lat float64 `json:"lat" binding:"required,min=-90,max=90"`
		Lng float64 `json:"lng" binding:"required,min=-180,max=180"`
	} `json:"location" binding:"required"`
	Heading *float64 `json:"heading"`
}

// ToDomainDriverLocation converts the DTO to the domain type.
func (r *UpdateLocationRequest) ToDomainDriverLocation() domain.DriverLocation {
	return domain.DriverLocation{
		LatLng:  domain.LatLng{Lat: r.Location.Lat, Lng: r.Location.Lng},
		Heading: r.Heading,
	}
}

// SetStatusResponse is returned after PUT /driver/status.
type SetStatusResponse struct {
	DriverID string              `json:"driver_id"`
	Status   domain.DriverStatus `json:"status"`
}
