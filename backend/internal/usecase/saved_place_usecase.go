package usecase

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type savedPlaceUseCase struct {
	repo domain.SavedPlaceRepository
}

func NewSavedPlaceUseCase(repo domain.SavedPlaceRepository) domain.SavedPlaceUseCase {
	return &savedPlaceUseCase{repo: repo}
}

func (uc *savedPlaceUseCase) AddPlace(ctx context.Context, userID uuid.UUID, name, address string, lat, lng float64, placeType domain.SavedPlaceType) (*domain.SavedPlace, error) {
	place := &domain.SavedPlace{
		ID:        uuid.New(),
		UserID:    userID,
		Name:      name,
		Address:   address,
		Latitude:  lat,
		Longitude: lng,
		Type:      placeType,
		CreatedAt: time.Now(),
	}

	if err := uc.repo.Create(ctx, place); err != nil {
		return nil, err
	}
	return place, nil
}

func (uc *savedPlaceUseCase) ListPlaces(ctx context.Context, userID uuid.UUID) ([]*domain.SavedPlace, error) {
	return uc.repo.ListByUserID(ctx, userID)
}

func (uc *savedPlaceUseCase) UpdatePlace(ctx context.Context, userID, placeID uuid.UUID, name, address *string, lat, lng *float64, placeType *domain.SavedPlaceType) (*domain.SavedPlace, error) {
	place, err := uc.repo.GetByID(ctx, placeID)
	if err != nil {
		return nil, err
	}

	if place.UserID != userID {
		return nil, domain.ErrForbidden
	}

	if name != nil {
		place.Name = *name
	}
	if address != nil {
		place.Address = *address
	}
	if lat != nil {
		place.Latitude = *lat
	}
	if lng != nil {
		place.Longitude = *lng
	}
	if placeType != nil {
		place.Type = *placeType
	}

	if err := uc.repo.Update(ctx, place); err != nil {
		return nil, err
	}
	return place, nil
}

func (uc *savedPlaceUseCase) DeletePlace(ctx context.Context, userID, placeID uuid.UUID) error {
	place, err := uc.repo.GetByID(ctx, placeID)
	if err != nil {
		return err
	}

	if place.UserID != userID {
		return domain.ErrForbidden
	}

	return uc.repo.Delete(ctx, placeID)
}
