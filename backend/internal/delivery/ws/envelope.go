package ws

import (
	"time"

	"github.com/google/uuid"
)

// EnvelopeVersion is the current wire protocol version stamped into outbound
// envelopes when the receiving connection negotiated `sakai-ws-v2`. v1
// connections strip this field before write (see hub.writePump).
const EnvelopeVersion = 2

// Envelope is the canonical JSON shape pushed over every WebSocket connection.
//
// The wire format is documented in openapi/swagger.yaml under WsEnvelope.
// Adding fields here is safe (clients ignore unknown keys); removing or
// renaming requires a coordinated client upgrade.
//
// v2 fields (V, Seq, CorrID, AckRequired) carry protocol metadata for the
// replay/ack subsystems (RFC v2 §4). They use `omitempty` so v1 consumers see
// a wire shape identical to v1.3.
type Envelope struct {
	Event       EventType `json:"event"`
	Payload     any       `json:"payload"`
	Timestamp   time.Time `json:"timestamp"`
	EventID     uuid.UUID `json:"event_id"`
	V           int       `json:"v,omitempty"`
	Seq         uint64    `json:"seq,omitempty"`
	CorrID      string    `json:"corr_id,omitempty"`
	AckRequired *bool     `json:"ack_required,omitempty"`
}

// NewEnvelope builds an Envelope and stamps the server-side metadata
// (timestamp + UUIDv7 event_id + protocol version). UUIDv7 is monotonic,
// which lets clients dedupe by id and sort by arrival without trusting
// wall-clock skew. Per-connection Seq is stamped later by the Hub.
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
		V:         EnvelopeVersion,
	}
}
