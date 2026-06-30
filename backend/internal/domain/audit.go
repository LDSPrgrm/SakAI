package domain

import (
	"time"

	"github.com/google/uuid"
)

// AuditLogEntry is an immutable record of an administrative action.
type AuditLogEntry struct {
	ID              uuid.UUID `json:"id"`
	Seq             int64     `json:"seq"`
	DisplayID       string    `json:"display_id"`
	Timestamp       time.Time `json:"timestamp"`
	ActorID         uuid.UUID `json:"actor_id"`
	ActorDisplayID  string    `json:"actor_display_id,omitempty"`
	ActorName       string    `json:"actor_name,omitempty"`
	IPAddress    string    `json:"ip_address"`
	Action       string    `json:"action"` // CREATE, UPDATE, DELETE, etc.
	ResourceType string    `json:"resource_type"`
	ResourceID   string    `json:"resource_id"`
	BeforeState  []byte    `json:"before_state,omitempty"` // JSON
	AfterState   []byte    `json:"after_state,omitempty"`  // JSON
	Reason       string    `json:"reason,omitempty"`
}
