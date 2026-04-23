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

// IncidentStatusEvent is one row of the SOS timeline. Populated by the DB
// trigger on insert/update of `incidents`, or explicitly from the use case
// when an admin reassigns or adds a note.
type IncidentStatusEvent struct {
	ID           uuid.UUID  `json:"id"`
	IncidentID   uuid.UUID  `json:"incident_id"`
	FromStatus   *string    `json:"from_status,omitempty"`
	ToStatus     string     `json:"to_status"`
	FromAssignee *uuid.UUID `json:"from_assignee,omitempty"`
	ToAssignee   *uuid.UUID `json:"to_assignee,omitempty"`
	ActorID      *uuid.UUID `json:"actor_id,omitempty"`
	ActorName    string     `json:"actor_name,omitempty"`
	Note         string     `json:"note,omitempty"`
	OccurredAt   time.Time  `json:"occurred_at"`
}

// IncidentLocationPoint is one GPS ping captured during an active incident.
// Rows only exist for drivers with an unresolved incident at ping time.
type IncidentLocationPoint struct {
	Lat        float64   `json:"lat"`
	Lng        float64   `json:"lng"`
	RecordedAt time.Time `json:"recorded_at"`
}

// IncidentDetail is the aggregate returned by GET /admin/incidents/{id}.
type IncidentDetail struct {
	Incident      *Incident               `json:"incident"`
	StatusHistory []*IncidentStatusEvent  `json:"status_history"`
	LocationTrail []*IncidentLocationPoint `json:"location_trail"`
}
