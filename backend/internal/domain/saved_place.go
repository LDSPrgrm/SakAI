package domain

import (
	"time"

	"github.com/google/uuid"
)

type SavedPlaceType string

const (
	SavedPlaceTypeHome  SavedPlaceType = "home"
	SavedPlaceTypeWork  SavedPlaceType = "work"
	SavedPlaceTypeOther SavedPlaceType = "other"
)

type SavedPlace struct {
	ID        uuid.UUID      `json:"id"`
	UserID    uuid.UUID      `json:"user_id"`
	Name      string         `json:"name"`
	Address   string         `json:"address"`
	Latitude  float64        `json:"latitude"`
	Longitude float64        `json:"longitude"`
	Type      SavedPlaceType `json:"type"`
	CreatedAt time.Time      `json:"created_at"`
}
