package ws

import (
	"context"
	"encoding/json"
	"errors"
	"strconv"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
)

// mockXEntries fabricates redis.XMessage entries with the same shape that
// RedisReplayStore.Append writes (env JSON + event_id value), so the
// pure-function collectAfter can be exercised without a Redis backend.
func mockXEntries(envs ...Envelope) []redis.XMessage {
	out := make([]redis.XMessage, 0, len(envs))
	for i, env := range envs {
		b, _ := json.Marshal(env)
		out = append(out, redis.XMessage{
			ID: strconv.Itoa(i) + "-0",
			Values: map[string]interface{}{
				"env":      string(b),
				"event_id": env.EventID.String(),
			},
		})
	}
	return out
}

func makeEnv(t *testing.T, event EventType) Envelope {
	t.Helper()
	id, err := uuid.NewV7()
	if err != nil {
		t.Fatalf("uuid v7: %v", err)
	}
	return Envelope{
		Event:     event,
		Payload:   map[string]any{"ride_id": "r1"},
		Timestamp: time.Now().UTC(),
		EventID:   id,
		V:         EnvelopeVersion,
	}
}

func TestMemReplayStore_Append_Range_ReturnsEverythingAfterCursor(t *testing.T) {
	ctx := context.Background()
	store := NewMemReplayStore(100)
	userID := uuid.New()

	a := makeEnv(t, EventRideRequested)
	b := makeEnv(t, EventRideAccepted)
	c := makeEnv(t, EventRideStatusChanged)
	for _, env := range []Envelope{a, b, c} {
		if err := store.Append(ctx, userID, env); err != nil {
			t.Fatalf("append: %v", err)
		}
	}

	got, err := store.Range(ctx, userID, a.EventID.String())
	if err != nil {
		t.Fatalf("range: %v", err)
	}
	if len(got) != 2 {
		t.Fatalf("got %d events after a, want 2", len(got))
	}
	if got[0].EventID != b.EventID || got[1].EventID != c.EventID {
		t.Errorf("range order = [%v, %v], want [%v, %v]",
			got[0].EventID, got[1].EventID, b.EventID, c.EventID)
	}
}

func TestMemReplayStore_Range_EmptyCursor_ReturnsAll(t *testing.T) {
	ctx := context.Background()
	store := NewMemReplayStore(0)
	userID := uuid.New()

	a := makeEnv(t, EventRideRequested)
	b := makeEnv(t, EventRideAccepted)
	_ = store.Append(ctx, userID, a)
	_ = store.Append(ctx, userID, b)

	got, err := store.Range(ctx, userID, "")
	if err != nil {
		t.Fatalf("range: %v", err)
	}
	if len(got) != 2 {
		t.Errorf("len = %d, want 2", len(got))
	}
}

func TestMemReplayStore_Range_UnknownCursor_ReturnsErrReplayOutOfWindow(t *testing.T) {
	ctx := context.Background()
	store := NewMemReplayStore(100)
	userID := uuid.New()

	_ = store.Append(ctx, userID, makeEnv(t, EventRideRequested))
	_ = store.Append(ctx, userID, makeEnv(t, EventRideAccepted))

	_, err := store.Range(ctx, userID, "not-a-real-event-id")
	if !errors.Is(err, ErrReplayOutOfWindow) {
		t.Errorf("err = %v, want ErrReplayOutOfWindow", err)
	}
}

func TestMemReplayStore_MaxLen_BoundsStream(t *testing.T) {
	ctx := context.Background()
	store := NewMemReplayStore(3)
	userID := uuid.New()

	for i := 0; i < 5; i++ {
		_ = store.Append(ctx, userID, makeEnv(t, EventRideStatusChanged))
	}

	got, err := store.Range(ctx, userID, "")
	if err != nil {
		t.Fatalf("range: %v", err)
	}
	if len(got) != 3 {
		t.Errorf("len = %d, want 3 (bounded by maxLen)", len(got))
	}
}

func TestMemReplayStore_IsolatesUsers(t *testing.T) {
	ctx := context.Background()
	store := NewMemReplayStore(100)
	alice := uuid.New()
	bob := uuid.New()

	_ = store.Append(ctx, alice, makeEnv(t, EventRideRequested))
	_ = store.Append(ctx, bob, makeEnv(t, EventRideAccepted))

	aliceEvents, _ := store.Range(ctx, alice, "")
	bobEvents, _ := store.Range(ctx, bob, "")
	if len(aliceEvents) != 1 || len(bobEvents) != 1 {
		t.Errorf("alice=%d bob=%d, want 1 each", len(aliceEvents), len(bobEvents))
	}
	if aliceEvents[0].EventID == bobEvents[0].EventID {
		t.Error("user streams not isolated")
	}
}

// collectAfter is the pure helper inside RedisReplayStore.Range; verify it
// directly so the Redis-backed path doesn't have to mock XRANGE entries.
func TestCollectAfter_HappyPath(t *testing.T) {
	a := makeEnv(t, EventRideRequested)
	b := makeEnv(t, EventRideAccepted)
	entries := mockXEntries(a, b)

	got, err := collectAfter(entries, a.EventID.String())
	if err != nil {
		t.Fatalf("collectAfter: %v", err)
	}
	if len(got) != 1 || got[0].EventID != b.EventID {
		t.Errorf("got %d events, want 1 (b)", len(got))
	}
}

func TestCollectAfter_UnknownCursor(t *testing.T) {
	a := makeEnv(t, EventRideRequested)
	entries := mockXEntries(a)
	_, err := collectAfter(entries, "missing")
	if !errors.Is(err, ErrReplayOutOfWindow) {
		t.Errorf("err = %v, want ErrReplayOutOfWindow", err)
	}
}
