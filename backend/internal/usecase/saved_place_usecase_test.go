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

func TestSavedPlaceUseCase_AddPlace_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	repo := mocks.NewMockSavedPlaceRepository(ctrl)
	uc := usecase.NewSavedPlaceUseCase(repo)

	userID := uuid.New()
	name := "Home"
	address := "123 Street"
	lat, lng := 14.5, 120.9
	ptype := domain.SavedPlaceTypeHome

	repo.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	place, err := uc.AddPlace(context.Background(), userID, name, address, lat, lng, ptype)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if place.Name != name {
		t.Errorf("expected name %s, got %s", name, place.Name)
	}
}

func TestSavedPlaceUseCase_UpdatePlace_Forbidden(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	repo := mocks.NewMockSavedPlaceRepository(ctrl)
	uc := usecase.NewSavedPlaceUseCase(repo)

	userID := uuid.New()
	otherUserID := uuid.New()
	placeID := uuid.New()
	existing := &domain.SavedPlace{
		ID:     placeID,
		UserID: otherUserID,
	}

	repo.EXPECT().GetByID(gomock.Any(), placeID).Return(existing, nil)

	_, err := uc.UpdatePlace(context.Background(), userID, placeID, nil, nil, nil, nil, nil)
	if err != domain.ErrForbidden {
		t.Errorf("expected ErrForbidden, got %v", err)
	}
}

func TestSavedPlaceUseCase_DeletePlace_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	repo := mocks.NewMockSavedPlaceRepository(ctrl)
	uc := usecase.NewSavedPlaceUseCase(repo)

	userID := uuid.New()
	placeID := uuid.New()
	existing := &domain.SavedPlace{
		ID:     placeID,
		UserID: userID,
	}

	repo.EXPECT().GetByID(gomock.Any(), placeID).Return(existing, nil)
	repo.EXPECT().Delete(gomock.Any(), placeID).Return(nil)

	err := uc.DeletePlace(context.Background(), userID, placeID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}
