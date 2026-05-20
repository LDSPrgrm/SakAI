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

// dialHub spins up an httptest server that upgrades to a WebSocket and
// registers the connection on the given hub under userID. Returns the
// client-side conn and a cleanup func.
func dialHub(t *testing.T, hub *Hub, userID uuid.UUID) (*websocket.Conn, func()) {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			t.Fatalf("upgrade: %v", err)
		}
		hub.Register(userID, conn, conn.Subprotocol())
	}))

	u, _ := url.Parse(srv.URL)
	u.Scheme = "ws"
	wsURL := strings.Replace(u.String(), "http", "ws", 1)

	c, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		srv.Close()
		t.Fatalf("dial: %v", err)
	}
	// Give Register time to wire up.
	time.Sleep(20 * time.Millisecond)
	return c, func() {
		c.Close()
		srv.Close()
	}
}

func TestHub_SendToUser_WritesEnvelopeWithTimestampAndID(t *testing.T) {
	hub := NewHub(30 * time.Second)
	userID := uuid.New()

	conn, cleanup := dialHub(t, hub, userID)
	defer cleanup()

	before := time.Now().UTC().Add(-time.Second)
	hub.SendToUser(userID, EventRideAccepted, map[string]any{"ride_id": "abc"})

	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	_, raw, err := conn.ReadMessage()
	if err != nil {
		t.Fatalf("read: %v", err)
	}

	var got struct {
		Event     string         `json:"event"`
		Payload   map[string]any `json:"payload"`
		Timestamp time.Time      `json:"timestamp"`
		EventID   string         `json:"event_id"`
	}
	if err := json.Unmarshal(raw, &got); err != nil {
		t.Fatalf("unmarshal: %v\nraw: %s", err, string(raw))
	}

	if got.Event != string(EventRideAccepted) {
		t.Errorf("event = %q, want %q", got.Event, EventRideAccepted)
	}
	if got.Payload["ride_id"] != "abc" {
		t.Errorf("payload.ride_id = %v, want abc", got.Payload["ride_id"])
	}
	if got.Timestamp.Before(before) {
		t.Errorf("timestamp %v older than %v", got.Timestamp, before)
	}
	id, err := uuid.Parse(got.EventID)
	if err != nil {
		t.Fatalf("event_id %q not a uuid: %v", got.EventID, err)
	}
	if id.Version() != 7 {
		t.Errorf("event_id version = %d, want 7", id.Version())
	}
}

func TestHub_SendToUser_IncrementsEmittedCounter(t *testing.T) {
	hub := NewHub(30 * time.Second)
	userID := uuid.New()
	conn, cleanup := dialHub(t, hub, userID)
	defer cleanup()

	// Reset package counter for deterministic assertion.
	before := metrics.EmittedCount(EventRideDeclined)
	hub.SendToUser(userID, EventRideDeclined, nil)

	// Read so the writePump definitely processed the send.
	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	if _, _, err := conn.ReadMessage(); err != nil {
		t.Fatalf("read: %v", err)
	}

	after := metrics.EmittedCount(EventRideDeclined)
	if after-before != 1 {
		t.Errorf("emitted delta = %d, want 1", after-before)
	}
}
