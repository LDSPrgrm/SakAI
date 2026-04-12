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

// UserRideItemResponse is the public API shape for a ride in the history list.
type UserRideItemResponse struct {
	ID                 string              `json:"id"`
	Status             domain.RideStatus   `json:"status"`
	OriginAddress      string              `json:"origin_address"`
	DestinationAddress string              `json:"destination_address"`
	Fare               *float64            `json:"fare,omitempty"`
	EstimatedFare      float64             `json:"estimated_fare"`
	DriverName         *string             `json:"driver_name,omitempty"`
	PaymentMethod      string              `json:"payment_method"`
	CreatedAt          time.Time           `json:"created_at"`
	UpdatedAt          time.Time           `json:"updated_at"`
}

// NewUserRideItemResponse maps a domain.Ride into the history list item shape.
func NewUserRideItemResponse(r *domain.Ride) UserRideItemResponse {
	item := UserRideItemResponse{
		ID:                 r.ID.String(),
		Status:             r.Status,
		OriginAddress:      r.OriginAddress,
		DestinationAddress: r.DestinationAddress,
		EstimatedFare:      r.EstimatedFare,
		PaymentMethod:      string(domain.PaymentMethodCash), // Default, would come from payment data
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}
	// Include fare only if ride is completed
	if r.Status == domain.RideStatusCompleted && r.Fare > 0 {
		fare := r.Fare
		item.Fare = &fare
	}
	return item
}
