package ws

import (
	"context"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var _ = emptySnapshot{} // silence unused warning if compiler insists

// stubSnapshot reports a fixed RideStateSyncPayload regardless of userID.
type stubSnapshot struct {
	payload RideStateSyncPayload
	err     error
}

func (s *stubSnapshot) RideSnapshot(_ context.Context, _ uuid.UUID) (RideStateSyncPayload, error) {
	return s.payload, s.err
}

// emptySnapshot always returns an empty payload — used to assert the
// "no-active-ride" path.
type emptySnapshot struct{}

func (emptySnapshot) RideSnapshot(_ context.Context, _ uuid.UUID) (RideStateSyncPayload, error) {
	return RideStateSyncPayload{}, nil
}

// dialHandler stands up the package's real Handler against an httptest server
// so the readPump path (inbound JSON → handleInbound) is exercised against a
// real websocket — closer to prod than calling the unexported helpers directly.
func dialHandler(t *testing.T, hub *Hub, userID uuid.UUID, handler *Handler) (*websocket.Conn, func()) {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			t.Fatalf("upgrade: %v", err)
		}
		hub.Register(userID, conn, conn.Subprotocol())
		go func() {
			defer hub.Unregister(userID)
			for {
				msgType, raw, err := conn.ReadMessage()
				if err != nil {
					return
				}
				if msgType != websocket.TextMessage {
					continue
				}
				handler.handleInbound(userID, raw)
			}
		}()
	}))
	u, _ := url.Parse(srv.URL)
	wsURL := strings.Replace(u.String(), "http", "ws", 1)
	dialer := *websocket.DefaultDialer
	dialer.Subprotocols = []string{SubprotocolV2}
	c, _, err := dialer.Dial(wsURL, nil)
	if err != nil {
		srv.Close()
		t.Fatalf("dial: %v", err)
	}
	time.Sleep(30 * time.Millisecond)
	return c, func() {
		c.Close()
		srv.Close()
	}
}

func sendInbound(t *testing.T, c *websocket.Conn, payload any) {
	t.Helper()
	b, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	if err := c.WriteMessage(websocket.TextMessage, b); err != nil {
		t.Fatalf("write: %v", err)
	}
}

func readEnvelope(t *testing.T, c *websocket.Conn) Envelope {
	t.Helper()
	c.SetReadDeadline(time.Now().Add(2 * time.Second))
	_, raw, err := c.ReadMessage()
	if err != nil {
		t.Fatalf("read: %v", err)
	}
	var env Envelope
	if err := json.Unmarshal(raw, &env); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	return env
}

// When the user's last_event_id is in the replay window, replay.request
// re-sends every envelope after that cursor in order.
func TestHandler_ReplayRequest_DrainsBacklog(t *testing.T) {
	hub := NewHub(30 * time.Second)
	store := NewMemReplayStore(100)
	handler := NewHandler(hub).WithReplayStore(store)
	userID := uuid.New()

	a := makeEnv(t, EventRideRequested)
	b := makeEnv(t, EventRideAccepted)
	c := makeEnv(t, EventRideStatusChanged)
	ctx := context.Background()
	_ = store.Append(ctx, userID, a)
	_ = store.Append(ctx, userID, b)
	_ = store.Append(ctx, userID, c)

	conn, cleanup := dialHandler(t, hub, userID, handler)
	defer cleanup()

	sendInbound(t, conn, map[string]any{
		"type":          "replay.request",
		"last_event_id": a.EventID.String(),
	})

	gotB := readEnvelope(t, conn)
	gotC := readEnvelope(t, conn)
	if gotB.EventID != b.EventID {
		t.Errorf("first replayed = %v, want %v", gotB.EventID, b.EventID)
	}
	if gotC.EventID != c.EventID {
		t.Errorf("second replayed = %v, want %v", gotC.EventID, c.EventID)
	}
}

// Out-of-window cursor triggers state_sync; if a snapshot provider is wired,
// the payload comes from it. The store is intentionally empty here.
func TestHandler_ReplayRequest_OutOfWindow_EmitsStateSync(t *testing.T) {
	hub := NewHub(30 * time.Second)
	store := NewMemReplayStore(100)
	rideID := uuid.New()
	updated := time.Now().UTC().Truncate(time.Second)
	snap := &stubSnapshot{
		payload: RideStateSyncPayload{
			HasActiveRide: true,
			RideID:        &rideID,
			Status:        "accepted",
			UpdatedAt:     &updated,
		},
	}
	handler := NewHandler(hub).WithReplayStore(store).WithSnapshotProvider(snap)
	userID := uuid.New()

	conn, cleanup := dialHandler(t, hub, userID, handler)
	defer cleanup()

	sendInbound(t, conn, map[string]any{
		"type":          "replay.request",
		"last_event_id": "missing-event-id",
	})

	env := readEnvelope(t, conn)
	if env.Event != EventRideStateSync {
		t.Fatalf("event = %q, want %q", env.Event, EventRideStateSync)
	}
	// Re-marshal the payload to assert the snapshot reached the wire.
	payloadJSON, _ := json.Marshal(env.Payload)
	var got RideStateSyncPayload
	if err := json.Unmarshal(payloadJSON, &got); err != nil {
		t.Fatalf("payload unmarshal: %v", err)
	}
	if !got.HasActiveRide || got.RideID == nil || *got.RideID != rideID {
		t.Errorf("snapshot not propagated: %+v", got)
	}
}

// No replay store wired → handler still emits state_sync (empty payload).
func TestHandler_ReplayRequest_NoStore_EmitsEmptyStateSync(t *testing.T) {
	hub := NewHub(30 * time.Second)
	handler := NewHandler(hub) // no replay store, no snapshot
	userID := uuid.New()

	conn, cleanup := dialHandler(t, hub, userID, handler)
	defer cleanup()

	sendInbound(t, conn, map[string]any{"type": "replay.request"})

	env := readEnvelope(t, conn)
	if env.Event != EventRideStateSync {
		t.Errorf("event = %q, want %q", env.Event, EventRideStateSync)
	}
}

// Unknown inbound types must not crash the readPump or trigger any outbound.
func TestHandler_Inbound_UnknownTypeIgnored(t *testing.T) {
	hub := NewHub(30 * time.Second)
	handler := NewHandler(hub)
	userID := uuid.New()

	conn, cleanup := dialHandler(t, hub, userID, handler)
	defer cleanup()

	sendInbound(t, conn, map[string]any{"type": "totally.bogus"})

	conn.SetReadDeadline(time.Now().Add(300 * time.Millisecond))
	_, _, err := conn.ReadMessage()
	if err == nil {
		t.Error("expected read timeout on no outbound, got data")
	}
	var nerr net.Error
	if !errors.As(err, &nerr) || !nerr.Timeout() {
		t.Errorf("err = %v, want timeout", err)
	}
}
