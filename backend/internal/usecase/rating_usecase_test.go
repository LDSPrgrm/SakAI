package usecase_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/internal/usecase"
	"go.uber.org/mock/gomock"
)

func newRatingUC(ctrl *gomock.Controller) (domain.RatingUseCase, *mocks.MockRatingRepository, *mocks.MockRideRepository) {
	ratingRepo := mocks.NewMockRatingRepository(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	uc := usecase.NewRatingUseCase(ratingRepo, rideRepo)
	return uc, ratingRepo, rideRepo
}

func TestRatingUseCase_SubmitRating_Success_PassengerRatingDriver(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, ratingRepo, rideRepo := newRatingUC(ctrl)
	passengerID := uuid.New()
	driverID := uuid.New()
	rideID := uuid.New()
	feedback := "Great ride!"

	ride := &domain.Ride{
		ID:          rideID,
		PassengerID: passengerID,
		DriverID:    &driverID,
		Status:      domain.RideStatusCompleted,
	}

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(ride, nil)
	ratingRepo.EXPECT().GetByRideAndRater(gomock.Any(), rideID, passengerID).Return(nil, domain.ErrNotFound)
	ratingRepo.EXPECT().Create(gomock.Any(), gomock.Any()).DoAndReturn(func(ctx context.Context, r *domain.Rating) error {
		if r.RideID != rideID || r.RaterID != passengerID || r.RateeID != driverID || r.Stars != 5 || *r.Feedback != feedback {
			t.Errorf("unexpected rating data: %+v", r)
		}
		return nil
	})

	rating, err := uc.SubmitRating(context.Background(), passengerID, rideID, 5, &feedback)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if rating == nil {
		t.Fatal("expected rating to be returned")
	}
}

func TestRatingUseCase_SubmitRating_Success_DriverRatingPassenger(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, ratingRepo, rideRepo := newRatingUC(ctrl)
	passengerID := uuid.New()
	driverID := uuid.New()
	rideID := uuid.New()

	ride := &domain.Ride{
		ID:          rideID,
		PassengerID: passengerID,
		DriverID:    &driverID,
		Status:      domain.RideStatusCompleted,
	}

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(ride, nil)
	ratingRepo.EXPECT().GetByRideAndRater(gomock.Any(), rideID, driverID).Return(nil, domain.ErrNotFound)
	ratingRepo.EXPECT().Create(gomock.Any(), gomock.Any()).DoAndReturn(func(ctx context.Context, r *domain.Rating) error {
		if r.RideID != rideID || r.RaterID != driverID || r.RateeID != passengerID || r.Stars != 4 {
			t.Errorf("unexpected rating data: %+v", r)
		}
		return nil
	})

	_, err := uc.SubmitRating(context.Background(), driverID, rideID, 4, nil)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestRatingUseCase_SubmitRating_InvalidStars(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, _ := newRatingUC(ctrl)
	_, err := uc.SubmitRating(context.Background(), uuid.New(), uuid.New(), 0, nil)
	if err != domain.ErrInvalidRating {
		t.Errorf("expected ErrInvalidRating, got %v", err)
	}

	_, err = uc.SubmitRating(context.Background(), uuid.New(), uuid.New(), 6, nil)
	if err != domain.ErrInvalidRating {
		t.Errorf("expected ErrInvalidRating, got %v", err)
	}
}

func TestRatingUseCase_SubmitRating_RideNotCompleted(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, rideRepo := newRatingUC(ctrl)
	rideID := uuid.New()
	ride := &domain.Ride{
		ID:     rideID,
		Status: domain.RideStatusInProgress,
	}

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(ride, nil)

	_, err := uc.SubmitRating(context.Background(), uuid.New(), rideID, 5, nil)
	if err != domain.ErrRideNotCompleted {
		t.Errorf("expected ErrRideNotCompleted, got %v", err)
	}
}

func TestRatingUseCase_SubmitRating_Forbidden(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, rideRepo := newRatingUC(ctrl)
	rideID := uuid.New()
	driverID := uuid.New()
	ride := &domain.Ride{
		ID:          rideID,
		PassengerID: uuid.New(),
		DriverID:    &driverID,
		Status:      domain.RideStatusCompleted,
	}

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(ride, nil)

	_, err := uc.SubmitRating(context.Background(), uuid.New(), rideID, 5, nil)
	if err != domain.ErrForbidden {
		t.Errorf("expected ErrForbidden, got %v", err)
	}
}

func TestRatingUseCase_SubmitRating_AlreadyRated(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, ratingRepo, rideRepo := newRatingUC(ctrl)
	passengerID := uuid.New()
	driverID := uuid.New()
	rideID := uuid.New()
	ride := &domain.Ride{
		ID:          rideID,
		PassengerID: passengerID,
		DriverID:    &driverID,
		Status:      domain.RideStatusCompleted,
	}

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(ride, nil)
	ratingRepo.EXPECT().GetByRideAndRater(gomock.Any(), rideID, passengerID).Return(&domain.Rating{}, nil)

	_, err := uc.SubmitRating(context.Background(), passengerID, rideID, 5, nil)
	if err != domain.ErrAlreadyRated {
		t.Errorf("expected ErrAlreadyRated, got %v", err)
	}
}

func TestRatingUseCase_GetRatingSummary(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, ratingRepo, _ := newRatingUC(ctrl)
	userID := uuid.New()
	expected := &domain.RatingSummary{
		UserID:        userID,
		AverageRating: 4.5,
		RatingCount:   10,
	}

	ratingRepo.EXPECT().GetAverageByUserID(gomock.Any(), userID).Return(expected, nil)

	summary, err := uc.GetRatingSummary(context.Background(), userID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if summary != expected {
		t.Errorf("expected summary %+v, got %+v", expected, summary)
	}
}
