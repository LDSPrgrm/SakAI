package domain

import (
	"time"

	"github.com/google/uuid"
)

// Incident represents a safety or compliance trigger (SOS, report).
type Incident struct {
	ID              uuid.UUID  `json:"id"`
	RideID          uuid.UUID  `json:"ride_id"`
	TriggeredBy     string     `json:"triggered_by"` // 'rider', 'driver'
	RiderID         uuid.UUID  `json:"rider_id"`
	DriverID        uuid.UUID  `json:"driver_id"`
	Type            string     `json:"type"`   // 'sos_triggered', 'reported_incident', etc.
	Status          string     `json:"status"` // 'open', 'investigating', 'resolved', 'escalated'
	AssignedTo      *uuid.UUID `json:"assigned_to,omitempty"`
	ResolutionNotes string     `json:"resolution_notes,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	ResolvedAt      *time.Time `json:"resolved_at,omitempty"`
}
