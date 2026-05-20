package ws

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestNewEnvelope_StampsTimestampAndEventID(t *testing.T) {
	before := time.Now().UTC()
	env := NewEnvelope(EventRideRequested, map[string]any{"ride_id": "abc"})
	after := time.Now().UTC()

	if env.Event != EventRideRequested {
		t.Fatalf("event = %q, want %q", env.Event, EventRideRequested)
	}
	if env.Timestamp.Before(before) || env.Timestamp.After(after) {
		t.Fatalf("timestamp %v not in [%v, %v]", env.Timestamp, before, after)
	}
	if env.EventID == uuid.Nil {
		t.Fatal("event_id is nil")
	}
	// UUIDv7 has version field == 7.
	if env.EventID.Version() != 7 {
		t.Fatalf("event_id version = %d, want 7 (UUIDv7)", env.EventID.Version())
	}
}

func TestNewEnvelope_GeneratesUniqueIDs(t *testing.T) {
	a := NewEnvelope(EventRideAccepted, nil)
	b := NewEnvelope(EventRideAccepted, nil)
	if a.EventID == b.EventID {
		t.Fatalf("expected distinct event_ids, both = %v", a.EventID)
	}
}

func TestEnvelope_JSONShape(t *testing.T) {
	env := Envelope{
		Event:     EventRideStatusChanged,
		Payload:   map[string]any{"ride_id": "r1", "status": "arrived"},
		Timestamp: time.Date(2026, 5, 20, 12, 34, 56, 0, time.UTC),
		EventID:   uuid.MustParse("018f4e6e-8b1c-7000-a000-000000000000"),
	}
	b, err := json.Marshal(env)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	var got map[string]any
	if err := json.Unmarshal(b, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	if got["event"] != string(EventRideStatusChanged) {
		t.Errorf("event = %v, want %v", got["event"], EventRideStatusChanged)
	}
	if got["timestamp"] != "2026-05-20T12:34:56Z" {
		t.Errorf("timestamp = %v, want 2026-05-20T12:34:56Z", got["timestamp"])
	}
	if got["event_id"] != "018f4e6e-8b1c-7000-a000-000000000000" {
		t.Errorf("event_id = %v, want 018f4e6e-...", got["event_id"])
	}
	payload, ok := got["payload"].(map[string]any)
	if !ok {
		t.Fatalf("payload not a map: %T", got["payload"])
	}
	if payload["ride_id"] != "r1" || payload["status"] != "arrived" {
		t.Errorf("payload = %v", payload)
	}
}
