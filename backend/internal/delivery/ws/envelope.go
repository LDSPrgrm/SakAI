package ws

import (
	"time"

	"github.com/google/uuid"
)

// Envelope is the canonical JSON shape pushed over every WebSocket connection.
//
// The wire format is documented in openapi/swagger.yaml under WsEnvelope.
// Adding fields here is safe (clients ignore unknown keys); removing or
// renaming requires a coordinated client upgrade.
type Envelope struct {
	Event     EventType `json:"event"`
	Payload   any       `json:"payload"`
	Timestamp time.Time `json:"timestamp"`
	EventID   uuid.UUID `json:"event_id"`
}

// NewEnvelope builds an Envelope and stamps the server-side metadata
// (timestamp + UUIDv7 event_id). UUIDv7 is monotonic, which lets clients
// dedupe by id and sort by arrival without trusting wall-clock skew.
func NewEnvelope(event EventType, payload any) Envelope {
	id, err := uuid.NewV7()
	if err != nil {
		// uuid.NewV7 only errors if crypto/rand fails — fall back to v4
		// so the system stays available; observability records the fallback.
		id = uuid.New()
		metrics.IncEnvelopeIDFallback()
	}
	metrics.IncEmitted(event)
	return Envelope{
		Event:     event,
		Payload:   payload,
		Timestamp: time.Now().UTC(),
		EventID:   id,
	}
}
