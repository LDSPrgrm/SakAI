package ws

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestEnvelopeAuditEvent_HashesPayloadDeterministically(t *testing.T) {
	payload := map[string]any{"ride_id": "r1", "status": "arrived"}
	env := Envelope{
		Event:     EventRideStatusChanged,
		Payload:   payload,
		Timestamp: time.Date(2026, 5, 20, 1, 0, 0, 0, time.UTC),
		EventID:   uuid.New(),
		V:         EnvelopeVersion,
		Seq:       42,
	}
	rideID := uuid.New()
	ev := EnvelopeAuditEvent(env, nil, &rideID)

	rawJSON, _ := json.Marshal(payload)
	sum := sha256.Sum256(rawJSON)
	want := hex.EncodeToString(sum[:])
	if ev.PayloadHash != want {
		t.Errorf("PayloadHash = %s, want %s", ev.PayloadHash, want)
	}
	if ev.RideID == nil || *ev.RideID != rideID {
		t.Errorf("RideID = %v, want %v", ev.RideID, rideID)
	}
	if ev.Seq == nil || *ev.Seq != 42 {
		t.Errorf("Seq = %v, want 42", ev.Seq)
	}
	if !ev.PIISafe {
		t.Error("PIISafe should default to true")
	}
}

func TestEnvelopeAuditEvent_AckRequiredFlagsThrough(t *testing.T) {
	ack := true
	env := Envelope{
		Event:       EventRideAccepted,
		Payload:     nil,
		Timestamp:   time.Now().UTC(),
		EventID:     uuid.New(),
		AckRequired: &ack,
	}
	ev := EnvelopeAuditEvent(env, nil, nil)
	if !ev.AckRequired {
		t.Error("AckRequired should be true when envelope flag is set")
	}
}

func TestEnvelopeAuditEvent_NoSeq_LeavesNil(t *testing.T) {
	env := Envelope{
		Event:     EventRideStatusChanged,
		Payload:   nil,
		Timestamp: time.Now().UTC(),
		EventID:   uuid.New(),
	}
	ev := EnvelopeAuditEvent(env, nil, nil)
	if ev.Seq != nil {
		t.Errorf("Seq = %v, want nil for zero-seq envelope", *ev.Seq)
	}
}

func TestMemAuditWriter_RecordsAllEvents(t *testing.T) {
	w := &MemAuditWriter{}
	ctx := context.Background()
	rideID := uuid.New()
	envA := NewEnvelope(EventRideRequested, map[string]any{"ride_id": rideID.String()})
	envB := NewEnvelope(EventRideStatusChanged, map[string]any{"ride_id": rideID.String(), "status": "arrived"})
	if err := w.Write(ctx, EnvelopeAuditEvent(envA, nil, &rideID)); err != nil {
		t.Fatalf("write a: %v", err)
	}
	if err := w.Write(ctx, EnvelopeAuditEvent(envB, nil, &rideID)); err != nil {
		t.Fatalf("write b: %v", err)
	}
	if len(w.Events) != 2 {
		t.Errorf("events = %d, want 2", len(w.Events))
	}
	if w.Events[0].EventType != EventRideRequested {
		t.Errorf("first event = %s", w.Events[0].EventType)
	}
}

func TestNoopAuditWriter_NeverErrors(t *testing.T) {
	w := NoopAuditWriter{}
	if err := w.Write(context.Background(), AuditEvent{}); err != nil {
		t.Errorf("noop write returned: %v", err)
	}
}
