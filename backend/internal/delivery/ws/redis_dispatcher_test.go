package ws

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
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
