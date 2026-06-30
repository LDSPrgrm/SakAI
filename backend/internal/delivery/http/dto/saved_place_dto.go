package dto

import (
	"time"

	"github.com/sakai/backend/internal/domain"
)

type SavedPlaceResponse struct {
	ID        string                `json:"id"`
	Name      string                `json:"name"`
	Address   string                `json:"address"`
	Latitude  float64               `json:"latitude"`
	Longitude float64               `json:"longitude"`
	Type      domain.SavedPlaceType `json:"type"`
	CreatedAt time.Time             `json:"created_at"`
}

type SavedPlaceCreateRequest struct {
	Name      string               `json:"name" binding:"required"`
	Address   string               `json:"address" binding:"required"`
	Latitude  float64              `json:"latitude" binding:"required"`
	Longitude float64              `json:"longitude" binding:"required"`
	Type      domain.SavedPlaceType `json:"type" binding:"required,oneof=home work other"`
}

func (req *SavedPlaceCreateRequest) ToDomain() *domain.SavedPlace {
	return &domain.SavedPlace{
		Name:      req.Name,
		Address:   req.Address,
		Latitude:  req.Latitude,
		Longitude: req.Longitude,
		Type:      req.Type,
	}
}

func NewSavedPlaceResponse(sp *domain.SavedPlace) SavedPlaceResponse {
	return SavedPlaceResponse{
		ID:        sp.ID.String(),
		Name:      sp.Name,
		Address:   sp.Address,
		Latitude:  sp.Latitude,
		Longitude: sp.Longitude,
		Type:      sp.Type,
		CreatedAt: sp.CreatedAt,
	}
}
