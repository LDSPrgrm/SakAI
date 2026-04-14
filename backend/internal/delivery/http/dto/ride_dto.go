package dto

import (
	"context"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// RequestRideRequest is the body for POST /rides.
type RequestRideRequest struct {
	Origin             LatLngInput `json:"origin" binding:"required"`
	Destination        LatLngInput `json:"destination" binding:"required"`
	OriginAddress      string      `json:"origin_address"`
	DestinationAddress string      `json:"destination_address"`
	Notes              string      `json:"notes" binding:"max=500"`
	RideType           string      `json:"ride_type"`
	PaymentMethod      string      `json:"payment_method"`
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

// VehicleInfoDTO holds vehicle details for a driver.
type VehicleInfoDTO struct {
	Make  string `json:"make"`
	Model string `json:"model"`
	Color string `json:"color"`
	Plate string `json:"plate"`
}

// UserProfileDTO is the public API shape for a user's identity.
type UserProfileDTO struct {
	ID        string          `json:"id"`
	Name      string          `json:"name"`
	Email     string          `json:"email"`
	Role      domain.UserRole `json:"role"`
	Vehicle   *VehicleInfoDTO `json:"vehicle,omitempty"`
	CreatedAt time.Time       `json:"created_at"`
}

// DriverSummaryDTO is minimal driver info embedded in ride responses.
type DriverSummaryDTO struct {
	ID              string          `json:"id"`
	Name            string          `json:"name"`
	Vehicle         *VehicleInfoDTO `json:"vehicle"`
	CurrentLocation *domain.LatLng  `json:"current_location,omitempty"`
}

// RideResponse is the public API shape for a ride.
type RideResponse struct {
	ID                   string                `json:"id"`
	Status               domain.RideStatus     `json:"status"`
	Passenger            *UserProfileDTO       `json:"passenger"`
	Driver               *DriverSummaryDTO     `json:"driver,omitempty"`
	Origin               domain.LatLng         `json:"origin"`
	Destination          domain.LatLng         `json:"destination"`
	OriginAddress        *string               `json:"origin_address,omitempty"`
	DestinationAddress   *string               `json:"destination_address,omitempty"`
	Notes                *string               `json:"notes,omitempty"`
	Fare                 *float64              `json:"fare,omitempty"`
	EstimatedFare        *float64              `json:"estimated_fare,omitempty"`
	ActualFare           *float64              `json:"actual_fare,omitempty"`
	RideType             *string               `json:"ride_type,omitempty"`
	FareBreakdown        *domain.JSONMap       `json:"fare_breakdown,omitempty"`
	CancellationReason   *string               `json:"cancellation_reason,omitempty"`
	CancellationReasonText *string             `json:"cancellation_reason_text,omitempty"`
	DeclineCount         int                   `json:"decline_count"`
	PaymentMethod        *string               `json:"payment_method,omitempty"`
	CancelledBy          *domain.CancelledBy   `json:"cancelled_by,omitempty"`
	CreatedAt            time.Time             `json:"created_at"`
	UpdatedAt            time.Time             `json:"updated_at"`
}

// RideResponseEnricher provides access to user/driver data for response enrichment.
// This interface keeps the DTO decoupled from concrete repository implementations.
type RideResponseEnricher interface {
	GetUserByID(ctx context.Context, id uuid.UUID) (*domain.User, error)
	GetDriverByUserID(ctx context.Context, userID uuid.UUID) (*domain.Driver, error)
}

// RidePaymentEnricher provides access to ride payment data for response enrichment.
type RidePaymentEnricher interface {
	GetPaymentByRideID(ctx context.Context, rideID uuid.UUID) (*domain.Payment, error)
}

// NewRideResponse maps a domain.Ride into the API response shape.
// If enricher is provided, passenger and driver details are populated.
// If paymentEnricher is provided, payment method is fetched from ride_payments table.
func NewRideResponse(r *domain.Ride, enricher RideResponseEnricher, paymentEnricher ...RidePaymentEnricher) RideResponse {
	resp := RideResponse{
		ID:     r.ID.String(),
		Status: r.Status,
		Passenger: &UserProfileDTO{
			ID:        r.PassengerID.String(),
			Name:      "", // will be enriched if enricher provided
			Role:      domain.RolePassenger,
			CreatedAt: r.CreatedAt,
		},
		Origin:      r.Origin,
		Destination: r.Destination,
		CreatedAt:   r.CreatedAt,
		UpdatedAt:   r.UpdatedAt,
	}

	// Optional string fields
	if r.OriginAddress != "" {
		resp.OriginAddress = &r.OriginAddress
	}
	if r.DestinationAddress != "" {
		resp.DestinationAddress = &r.DestinationAddress
	}
	if r.Notes != "" {
		resp.Notes = &r.Notes
	}

	// Fare fields
	if r.Fare > 0 {
		resp.Fare = &r.Fare
	}
	if r.EstimatedFare != nil && *r.EstimatedFare > 0 {
		resp.EstimatedFare = r.EstimatedFare
	}
	if r.ActualFare != nil && *r.ActualFare > 0 {
		resp.ActualFare = r.ActualFare
	}
	if r.RideType != "" {
		rt := string(r.RideType)
		resp.RideType = &rt
	}
	if r.FareBreakdown != nil {
		resp.FareBreakdown = r.FareBreakdown
	}
	if r.CancellationReason != nil {
		resp.CancellationReason = r.CancellationReason
	}
	if r.CancellationReasonText != nil {
		resp.CancellationReasonText = r.CancellationReasonText
	}
	resp.DeclineCount = r.DeclineCount

	// Payment method: fetch from ride_payments table if available, otherwise default to cash.
	if len(paymentEnricher) > 0 && paymentEnricher[0] != nil {
		if payment, err := paymentEnricher[0].GetPaymentByRideID(context.Background(), r.ID); err == nil && payment != nil {
			pm := string(payment.Method)
			resp.PaymentMethod = &pm
		}
	}
	if resp.PaymentMethod == nil {
		pm := string(domain.PaymentMethodCash)
		resp.PaymentMethod = &pm
	}

	resp.CancelledBy = r.CancelledBy

	// Enrich with user details if enricher provided
	if enricher != nil {
		enrichRideResponse(&resp, r, enricher)
	}

	return resp
}

// enrichRideResponse fetches passenger and driver details and populates the response.
func enrichRideResponse(resp *RideResponse, r *domain.Ride, e RideResponseEnricher) {
	ctx := context.Background()

	// Fetch passenger details - always populate with at least the ID
	if passenger, err := e.GetUserByID(ctx, r.PassengerID); err == nil {
		resp.Passenger = &UserProfileDTO{
			ID:        passenger.ID.String(),
			Name:      passenger.Name,
			Email:     passenger.Email,
			Role:      passenger.Role,
			CreatedAt: passenger.CreatedAt,
		}
	} else {
		// Enrichment failed: passenger record not found or DB error.
		// Keep the minimal stub with ID already set by NewRideResponse.
		// This ensures the API contract (non-null passenger) is always honored.
		log.Printf("[ENRICH] Failed to fetch passenger %s: %v (using minimal stub)", r.PassengerID, err)
	}

	// Fetch driver details if assigned
	if r.DriverID == nil {
		return
	}

	driverResp := &DriverSummaryDTO{
		ID:   r.DriverID.String(),
		Name: "",
	}

	if driver, err := e.GetUserByID(ctx, *r.DriverID); err == nil {
		driverResp.Name = driver.Name
		if driver.Vehicle != nil {
			driverResp.Vehicle = &VehicleInfoDTO{
				Make:  driver.Vehicle.Make,
				Model: driver.Vehicle.Model,
				Color: driver.Vehicle.Color,
				Plate: driver.Vehicle.Plate,
			}
		}
	}

	// Try to get driver location if available
	if driverState, err := e.GetDriverByUserID(ctx, *r.DriverID); err == nil && driverState.Location != nil {
		driverResp.CurrentLocation = &driverState.Location.LatLng
	}

	resp.Driver = driverResp
}

// CancelRideRequest is the body for POST /rides/:rideId/cancel.
type CancelRideRequest struct {
	ReasonCode *string `json:"reason_code" binding:"omitempty,oneof=driver_too_far changed_plans wrong_pickup driver_not_moving safety_concern other"`
	ReasonText *string `json:"reason_text" binding:"omitempty,max=500"`
}

// ArriveAtPickupRequest is the body for POST /rides/:rideId/arrive.
type ArriveAtPickupRequest struct {
	DriverLocation LatLngInput `json:"driver_location" binding:"required"`
}

// UserRideItemResponse is the public API shape for a ride in the history list.
type UserRideItemResponse struct {
	ID                 string              `json:"id"`
	Status             domain.RideStatus   `json:"status"`
	OriginAddress      string              `json:"origin_address"`
	DestinationAddress string              `json:"destination_address"`
	Fare               *float64            `json:"fare,omitempty"`
	EstimatedFare      *float64            `json:"estimated_fare,omitempty"`
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
