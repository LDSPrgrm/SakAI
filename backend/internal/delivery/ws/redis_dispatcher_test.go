package ws

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"github.com/sakai/backend/internal/observability/corrid"
)

// TestGlobalEvent_PreservesEnvelopeAcrossBus simulates the round-trip a
// message takes through Redis Pub/Sub: marshal a globalEvent on the
// publisher, unmarshal on the subscriber, and assert the Envelope's
// timestamp + event_id survive intact (NOT re-stamped per node).
func TestGlobalEvent_PreservesEnvelopeAcrossBus(t *testing.T) {
	userID := uuid.New()
	env := NewEnvelope(EventRideAccepted, map[string]any{"ride_id": "r1"})

	ge := globalEvent{
		TargetUserID: &userID,
		Envelope:     env,
	}
	b, err := json.Marshal(ge)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	var got globalEvent
	if err := json.Unmarshal(b, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	if got.Envelope.Event != env.Event {
		t.Errorf("event = %q, want %q", got.Envelope.Event, env.Event)
	}
	if got.Envelope.EventID != env.EventID {
		t.Errorf("event_id = %v, want %v", got.Envelope.EventID, env.EventID)
	}
	if !got.Envelope.Timestamp.Equal(env.Timestamp) {
		t.Errorf("timestamp = %v, want %v", got.Envelope.Timestamp, env.Timestamp)
	}
	if got.TargetUserID == nil || *got.TargetUserID != userID {
		t.Errorf("target_user_id = %v, want %v", got.TargetUserID, userID)
	}
}

// TestRedisDispatcher_RunExitsWhenSubscriptionCloses guards against the nil
// pointer panic seen in CI: when the Redis client closes (test cleanup, pod
// shutdown, connection loss) the subscription channel closes and `<-ch`
// yields a nil *redis.Message. Run must return, not dereference it.
func TestRedisDispatcher_RunExitsWhenSubscriptionCloses(t *testing.T) {
	_, rdb := newMiniRedis(t)
	hub := NewHub(30 * time.Second)
	d := NewRedisDispatcher(rdb, hub)

	// ctx stays live for the whole test: Run's only exit path here is the
	// closed subscription channel, not ctx.Done().
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	done := make(chan struct{})
	go func() {
		defer close(done)
		d.Run(ctx)
	}()

	// Give the subscription time to establish, then close the client out
	// from under the running loop — exactly what t.Cleanup does to the
	// chaos-test pods.
	time.Sleep(100 * time.Millisecond)
	_ = rdb.Close()

	select {
	case <-done:
		// Run returned cleanly.
	case <-time.After(2 * time.Second):
		t.Fatal("Run did not return after subscription channel closed")
	}
}

// TestMergePayloadFields_TypedStruct guards against the regression where
// typed payloads (e.g. RideCompletedPayload, RideSOSPayload) failed a naive
// `payload.(map[string]any)` assertion in PublishToRide and were silently
// dropped — leaving subscribers with only the base routing fields and zero
// fare / breakdown / SOS reason data.
func TestMergePayloadFields_TypedStruct(t *testing.T) {
	tip := 50.0
	rideID := uuid.New()
	payload := RideCompletedPayload{
		RideID: rideID,
		Fare:   180.0,
		FareBreakdown: &FareBreakdown{
			BaseFare:       40,
			DistanceCharge: 120,
			TimeCharge:     20,
			BookingFee:     0,
		},
		PaymentMethod: "gcash",
		TipAmount:     &tip,
		CompletedAt:   time.Now().UTC(),
	}

	m, ok := mergePayloadFields(payload)
	if !ok {
		t.Fatalf("mergePayloadFields returned ok=false for typed struct")
	}
	required := []string{"ride_id", "fare", "fare_breakdown", "payment_method", "tip_amount", "completed_at"}
	for _, k := range required {
		if _, present := m[k]; !present {
			t.Errorf("merged payload missing key %q: %#v", k, m)
		}
	}
	if got, _ := m["fare"].(float64); got != 180.0 {
		t.Errorf("fare = %v, want 180", got)
	}
	if got, _ := m["payment_method"].(string); got != "gcash" {
		t.Errorf("payment_method = %q, want gcash", got)
	}
}

// TestMergePayloadFields_MapPassthrough ensures gin.H / map[string]any
// callers (the legacy path) still work without an unnecessary JSON
// round-trip.
func TestMergePayloadFields_MapPassthrough(t *testing.T) {
	in := map[string]any{"foo": "bar", "n": 7}
	out, ok := mergePayloadFields(in)
	if !ok {
		t.Fatal("ok=false for map[string]any")
	}
	if &in == &out {
		// pointers differ in Go map semantics; just check key survival
	}
	if out["foo"] != "bar" || out["n"] != 7 {
		t.Errorf("map fields not preserved: %#v", out)
	}
}

// TestStampCorrID guards the corr_id threading wired in P8.2: when the call
// site's context carries a correlation ID, the envelope must surface it on
// the wire so audit + replay + client traces can all stitch back to the
// originating HTTP request.
func TestStampCorrID(t *testing.T) {
	t.Run("absent ctx leaves envelope unchanged", func(t *testing.T) {
		env := NewEnvelope(EventRideAccepted, map[string]any{"ride_id": "r1"})
		stampCorrID(context.Background(), &env)
		if env.CorrID != "" {
			t.Fatalf("CorrID = %q, want empty (no value on ctx)", env.CorrID)
		}
	})
	t.Run("present ctx populates CorrID", func(t *testing.T) {
		env := NewEnvelope(EventRideAccepted, map[string]any{"ride_id": "r1"})
		ctx := corrid.WithCorrID(context.Background(), "req-42")
		stampCorrID(ctx, &env)
		if env.CorrID != "req-42" {
			t.Fatalf("CorrID = %q, want req-42", env.CorrID)
		}
	})
}

func TestRedisDispatcher_RouteLocally_DeliversSameEnvelope(t *testing.T) {
	hub := NewHub(30 * time.Second)
	userID := uuid.New()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			t.Fatalf("upgrade: %v", err)
		}
		hub.Register(userID, conn, conn.Subprotocol())
	}))
	defer srv.Close()

	u, _ := url.Parse(srv.URL)
	u.Scheme = "ws"
	wsURL := strings.Replace(u.String(), "http", "ws", 1)
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	defer conn.Close()
	time.Sleep(20 * time.Millisecond)

	env := NewEnvelope(EventRideCancelled, map[string]any{"ride_id": "r2", "cancelled_by": "passenger"})
	d := &RedisDispatcher{hub: hub}
	d.routeLocally(&globalEvent{
		TargetUserID: &userID,
		Envelope:     env,
	})

	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	_, raw, err := conn.ReadMessage()
	if err != nil {
		t.Fatalf("read: %v", err)
	}

	var got Envelope
	if err := json.Unmarshal(raw, &got); err != nil {
		t.Fatalf("unmarshal: %v\nraw: %s", err, string(raw))
	}
	if got.EventID != env.EventID {
		t.Errorf("event_id = %v, want %v (envelope was re-stamped)", got.EventID, env.EventID)
	}
}
