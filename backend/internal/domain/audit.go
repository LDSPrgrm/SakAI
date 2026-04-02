package domain

import (
	"time"

	"github.com/google/uuid"
)

// AuditLogEntry is an immutable record of an administrative action.
type AuditLogEntry struct {
	ID           uuid.UUID `json:"id"`
	Timestamp    time.Time `json:"timestamp"`
	ActorID      uuid.UUID `json:"actor_id"`
	IPAddress    string    `json:"ip_address"`
	Action       string    `json:"action"` // CREATE, UPDATE, DELETE, etc.
	ResourceType string    `json:"resource_type"`
	ResourceID   string    `json:"resource_id"`
	BeforeState  []byte    `json:"before_state,omitempty"` // JSON
	AfterState   []byte    `json:"after_state,omitempty"`  // JSON
	Reason       string    `json:"reason,omitempty"`
}
