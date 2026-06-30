package ws

import (
	"encoding/json"
	"testing"

	"github.com/google/uuid"
)

// TestGlobalEvent_LegacyShape_BackwardCompat: an OLD node publishing the
// pre-v1.3.0 shape `{event, payload, target_user_id}` (no nested envelope)
// must still be parseable by a NEW node during a rolling deploy. Without
// this, a mixed-version cluster silently drops events.
func TestGlobalEvent_LegacyShape_BackwardCompat(t *testing.T) {
	userID := uuid.New()
	legacy := []byte(`{
		"target_user_id": "` + userID.String() + `",
		"event": "ride.accepted",
		"payload": {"ride_id": "r1"}
	}`)

	var ge globalEvent
	if err := json.Unmarshal(legacy, &ge); err != nil {
		t.Fatalf("unmarshal legacy: %v", err)
	}

	if ge.Envelope.Event != EventRideAccepted {
		t.Errorf("event = %q, want %q (legacy fields not migrated into envelope)",
			ge.Envelope.Event, EventRideAccepted)
	}
	if ge.TargetUserID == nil || *ge.TargetUserID != userID {
		t.Errorf("target_user_id = %v, want %v", ge.TargetUserID, userID)
	}
	// Timestamp / event_id missing on legacy frames — acceptable, just zero values.
	// Clients that need them must tolerate absence (which they do per spec v1.3.0).
}

// TestGlobalEvent_NewShape_StillWorks: defensive — the new {envelope: {...}}
// shape unmarshals correctly even after the compat hook is in place.
func TestGlobalEvent_NewShape_StillWorks(t *testing.T) {
	userID := uuid.New()
	env := NewEnvelope(EventRideStatusChanged, map[string]any{"ride_id": "r1"})
	source := globalEvent{TargetUserID: &userID, Envelope: env}

	b, err := json.Marshal(source)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	var got globalEvent
	if err := json.Unmarshal(b, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got.Envelope.EventID != env.EventID {
		t.Errorf("event_id round-trip mismatch: %v vs %v", got.Envelope.EventID, env.EventID)
	}
}
