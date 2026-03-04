package dto

import (
	"time"

	"github.com/sakai/backend/internal/domain"
)

// RequestRideRequest is the body for POST /rides.
type RequestRideRequest struct {
	Origin             LatLngInput `json:"origin" binding:"required"`
	Destination        LatLngInput `json:"destination" binding:"required"`
	OriginAddress      string      `json:"origin_address"`
	DestinationAddress string      `json:"destination_address"`
	Notes              string      `json:"notes" binding:"max=500"`
}

// LatLngInput is the API representation of a geographic coordinate pair.
type LatLngInput struct {
	Lat float64 `json:"lat" binding:"required,min=-90,max=90"`
	Lng float64 `json:"lng" binding:"required,min=-180,max=180"`
}

// ToDomainLatLng converts the DTO to the domain type.
func (l LatLngInput) ToDomainLatLng() domain.LatLng {
	return domain.LatLng{Lat: l.Lat, Lng: l.Lng}
}

// RideResponse is the public API shape for a ride.
type RideResponse struct {
	ID                 string              `json:"id"`
	PassengerID        string              `json:"passenger_id"`
	DriverID           *string             `json:"driver_id,omitempty"`
	Status             domain.RideStatus   `json:"status"`
	Origin             domain.LatLng       `json:"origin"`
	Destination        domain.LatLng       `json:"destination"`
	OriginAddress      string              `json:"origin_address,omitempty"`
	DestinationAddress string              `json:"destination_address,omitempty"`
	Notes              string              `json:"notes,omitempty"`
	CancelledBy        *domain.CancelledBy `json:"cancelled_by,omitempty"`
	CreatedAt          time.Time           `json:"created_at"`
	UpdatedAt          time.Time           `json:"updated_at"`
}

// NewRideResponse maps a domain.Ride into the API response shape.
func NewRideResponse(r *domain.Ride) RideResponse {
	resp := RideResponse{
		ID:                 r.ID.String(),
		PassengerID:        r.PassengerID.String(),
		Status:             r.Status,
		Origin:             r.Origin,
		Destination:        r.Destination,
		OriginAddress:      r.OriginAddress,
		DestinationAddress: r.DestinationAddress,
		Notes:              r.Notes,
		CancelledBy:        r.CancelledBy,
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}
	if r.DriverID != nil {
		s := r.DriverID.String()
		resp.DriverID = &s
	}
	return resp
}
