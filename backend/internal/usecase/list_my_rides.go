package usecase

import (
	"context"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// UserRideUseCase provides user-specific ride listing (history).
type UserRideUseCase interface {
	ListMyRides(ctx context.Context, passengerID uuid.UUID, filter domain.UserRideFilter) ([]*domain.Ride, domain.PaginationMeta, error)
}

type userRideUseCase struct {
	rideRepo domain.RideRepository
}

// NewUserRideUseCase creates a usecase for user ride history operations.
func NewUserRideUseCase(rideRepo domain.RideRepository) UserRideUseCase {
	return &userRideUseCase{rideRepo: rideRepo}
}

// ListMyRides returns a paginated list of rides for the authenticated passenger.
func (uc *userRideUseCase) ListMyRides(ctx context.Context, passengerID uuid.UUID, filter domain.UserRideFilter) ([]*domain.Ride, domain.PaginationMeta, error) {
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.Limit < 1 {
		filter.Limit = 20
	}
	if filter.Limit > 50 {
		filter.Limit = 50
	}

	rides, total, err := uc.rideRepo.ListByPassengerID(ctx, passengerID, filter)
	if err != nil {
		return nil, domain.PaginationMeta{}, err
	}

	totalPages := (total + filter.Limit - 1) / filter.Limit
	pagination := domain.PaginationMeta{
		Page:       filter.Page,
		Limit:      filter.Limit,
		Total:      total,
		TotalPages: totalPages,
	}

	return rides, pagination, nil
}
