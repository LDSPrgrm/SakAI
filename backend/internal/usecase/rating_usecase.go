package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type ratingUseCase struct {
	ratingRepo domain.RatingRepository
	rideRepo   domain.RideRepository
}

// NewRatingUseCase creates a new domain.RatingUseCase.
func NewRatingUseCase(ratingRepo domain.RatingRepository, rideRepo domain.RideRepository) domain.RatingUseCase {
	return &ratingUseCase{ratingRepo: ratingRepo, rideRepo: rideRepo}
}

func (uc *ratingUseCase) SubmitRating(ctx context.Context, raterID uuid.UUID, rideID uuid.UUID, stars int, feedback *string) (*domain.Rating, error) {
	// Validate star rating.
	if stars < 1 || stars > 5 {
		return nil, domain.ErrInvalidRating
	}

	// Validate feedback length.
	if feedback != nil && len(*feedback) > 500 {
		return nil, domain.ErrFeedbackTooLong
	}

	// Verify ride exists and is completed.
	ride, err := uc.rideRepo.GetByID(ctx, rideID)
	if err != nil {
		return nil, err
	}
	if ride.Status != domain.RideStatusCompleted {
		return nil, domain.ErrRideNotCompleted
	}

	// Verify rater is either the passenger or driver of this ride.
	if ride.PassengerID != raterID && (ride.DriverID == nil || *ride.DriverID != raterID) {
		return nil, domain.ErrForbidden
	}

	// Determine ratee (the other party).
	var rateeID uuid.UUID
	if ride.PassengerID == raterID {
		if ride.DriverID == nil {
			return nil, domain.ErrNotFound // Should not happen for completed rides.
		}
		rateeID = *ride.DriverID
	} else {
		rateeID = ride.PassengerID
	}

	// Check if rating already exists.
	existing, err := uc.ratingRepo.GetByRideAndRater(ctx, rideID, raterID)
	if err == nil && existing != nil {
		return nil, domain.ErrAlreadyRated
	} else if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return nil, err
	}

	now := time.Now()
	rating := &domain.Rating{
		ID:        uuid.New(),
		RideID:    rideID,
		RaterID:   raterID,
		RateeID:   rateeID,
		Stars:     stars,
		Feedback:  feedback,
		CreatedAt: now,
	}

	if err := uc.ratingRepo.Create(ctx, rating); err != nil {
		return nil, err
	}
	return rating, nil
}

func (uc *ratingUseCase) GetRatingSummary(ctx context.Context, userID uuid.UUID) (*domain.RatingSummary, error) {
	return uc.ratingRepo.GetAverageByUserID(ctx, userID)
}
