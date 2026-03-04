package dto

import "github.com/sakai/backend/internal/domain"

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
