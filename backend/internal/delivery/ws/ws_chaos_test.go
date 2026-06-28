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
)

// chaosServer stands up a Handler against an httptest server, returning the
// server + a teardown. Multiple connects to the same server are supported.
func chaosServer(t *testing.T, hub *Hub, handler *Handler) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userIDStr := r.Header.Get("X-User-ID")
		userID, err := uuid.Parse(userIDStr)
		if err != nil {
			http.Error(w, "bad user", http.StatusBadRequest)
			return
		}
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			return
		}
		hub.Register(userID, conn, conn.Subprotocol())
		// Match handler.ServeWS readPump loop.
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
	return srv
}

// dialChaos dials srv with a Sec-WebSocket-Protocol and X-User-ID header so
// the server-side handler can register the upgrade against a known user.
func dialChaos(t *testing.T, srv *httptest.Server, userID uuid.UUID) *websocket.Conn {
	t.Helper()
	u, _ := url.Parse(srv.URL)
	wsURL := strings.Replace(u.String(), "http", "ws", 1)
	dialer := *websocket.DefaultDialer
	dialer.Subprotocols = []string{SubprotocolV2}
	header := http.Header{"X-User-ID": []string{userID.String()}}
	c, _, err := dialer.Dial(wsURL, header)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	time.Sleep(20 * time.Millisecond)
	return c
}

// publishEnv emulates a real dispatcher publish: it appends to the replay
// store and immediately delivers via the hub (if the user is connected).
func publishEnv(t *testing.T, hub *Hub, store ReplayStore, userID uuid.UUID, env Envelope) {
	t.Helper()
	if err := store.Append(context.Background(), userID, env); err != nil {
		t.Fatalf("store.Append: %v", err)
	}
	hub.sendEnvelope(userID, env)
}

// readEnvDeadline drains the next envelope or fails on timeout.
func readEnvDeadline(t *testing.T, c *websocket.Conn, d time.Duration) Envelope {
	t.Helper()
	c.SetReadDeadline(time.Now().Add(d))
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

// TestChaos_RandomTCPDropsLoseNoEvents simulates a flaky link by closing the
// client's TCP socket between batches of publishes. After each drop, the
// client reconnects, sends `replay.request` with the last applied event_id,
// and must receive every envelope that was published while disconnected, in
// order, with no duplicates and no omissions.
//
// This is the package-level proof of the durability contract from RFC §17:
// no event survives a reboot for free, but a reconnecting client never sees
// a gap as long as the cursor is still inside the replay window.
func TestChaos_RandomTCPDropsLoseNoEvents(t *testing.T) {
	hub := NewHub(30 * time.Second)
	store := NewMemReplayStore(1024)
	handler := NewHandler(hub).WithReplayStore(store)
	srv := chaosServer(t, hub, handler)
	defer srv.Close()

	userID := uuid.New()
	conn := dialChaos(t, srv, userID)

	// applied tracks the event_ids the client has surfaced so we can assert
	// exactly-once + ordered delivery across reconnects.
	applied := make([]uuid.UUID, 0, 64)
	lastEventID := ""

	const cycles = 5
	const batchSize = 4

	for cycle := 0; cycle < cycles; cycle++ {
		// Phase 1: publish a batch while connected. Drain it on the wire.
		live := make([]Envelope, 0, batchSize)
		for i := 0; i < batchSize; i++ {
			env := makeEnv(t, EventRideStatusChanged)
			live = append(live, env)
			publishEnv(t, hub, store, userID, env)
		}
		for _, want := range live {
			got := readEnvDeadline(t, conn, 2*time.Second)
			if got.EventID != want.EventID {
				t.Fatalf("cycle %d live: got %v, want %v", cycle, got.EventID, want.EventID)
			}
			applied = append(applied, got.EventID)
			lastEventID = got.EventID.String()
		}

		// Phase 2: drop the TCP link mid-flight. Server detects via ReadMessage
		// error → Unregister. Future publishes go only to the replay store.
		_ = conn.Close()
		// Let the server-side readPump finish unregistering before we publish.
		// Without this the publish would still land on the now-doomed channel.
		waitFor(t, 500*time.Millisecond, func() bool {
			return hub.Size() == 0
		})

		// Phase 3: publish a batch while disconnected. These must materialise
		// on reconnect via the replay path.
		missed := make([]Envelope, 0, batchSize)
		for i := 0; i < batchSize; i++ {
			env := makeEnv(t, EventRideStatusChanged)
			missed = append(missed, env)
			publishEnv(t, hub, store, userID, env)
		}

		// Phase 4: reconnect, request replay from cursor, drain missed batch.
		conn = dialChaos(t, srv, userID)
		sendInbound(t, conn, map[string]any{
			"type":          "replay.request",
			"last_event_id": lastEventID,
		})
		for _, want := range missed {
			got := readEnvDeadline(t, conn, 2*time.Second)
			if got.EventID != want.EventID {
				t.Fatalf("cycle %d replay: got %v, want %v", cycle, got.EventID, want.EventID)
			}
			applied = append(applied, got.EventID)
			lastEventID = got.EventID.String()
		}
	}
	_ = conn.Close()

	// Cross-check: applied stream is exactly (cycles * 2 * batchSize) and
	// contains no duplicates. The order check above already proved we got
	// the right events in the right order on each path.
	wantTotal := cycles * 2 * batchSize
	if len(applied) != wantTotal {
		t.Fatalf("applied=%d, want %d", len(applied), wantTotal)
	}
	seen := make(map[uuid.UUID]struct{}, len(applied))
	for _, id := range applied {
		if _, dup := seen[id]; dup {
			t.Fatalf("duplicate event_id surfaced: %v", id)
		}
		seen[id] = struct{}{}
	}
}

// TestChaos_OutOfWindowFallsBackToStateSync proves that when the cursor is
// older than the retention window (we model this with a tiny MaxLen store),
// the server emits ride.state_sync instead of replaying — clients must not
// be left waiting for events that have already been pruned.
func TestChaos_OutOfWindowFallsBackToStateSync(t *testing.T) {
	hub := NewHub(30 * time.Second)
	// MaxLen=2 means the third Append drops the oldest. After two more
	// publishes the original cursor is no longer in the stream.
	store := NewMemReplayStore(2)
	rideID := uuid.New()
	snap := &stubSnapshot{
		payload: RideStateSyncPayload{
			HasActiveRide: true,
			RideID:        &rideID,
			Status:        "in_progress",
		},
	}
	handler := NewHandler(hub).WithReplayStore(store).WithSnapshotProvider(snap)
	srv := chaosServer(t, hub, handler)
	defer srv.Close()

	userID := uuid.New()
	conn := dialChaos(t, srv, userID)

	// Burn the window: first publish becomes the cursor, then evict it.
	first := makeEnv(t, EventRideRequested)
	publishEnv(t, hub, store, userID, first)
	gotFirst := readEnvDeadline(t, conn, 2*time.Second)
	if gotFirst.EventID != first.EventID {
		t.Fatalf("first event: got %v, want %v", gotFirst.EventID, first.EventID)
	}
	cursor := gotFirst.EventID.String()

	_ = conn.Close()
	waitFor(t, 500*time.Millisecond, func() bool { return hub.Size() == 0 })

	// Two more publishes evict the first one out of the MaxLen=2 window.
	publishEnv(t, hub, store, userID, makeEnv(t, EventRideStatusChanged))
	publishEnv(t, hub, store, userID, makeEnv(t, EventRideStatusChanged))

	// Reconnect with the now-stale cursor → server must fall back to state_sync.
	conn = dialChaos(t, srv, userID)
	defer conn.Close()
	sendInbound(t, conn, map[string]any{
		"type":          "replay.request",
		"last_event_id": cursor,
	})
	env := readEnvDeadline(t, conn, 2*time.Second)
	if env.Event != EventRideStateSync {
		t.Fatalf("event = %q, want %q", env.Event, EventRideStateSync)
	}
}

// waitFor polls cond every 5ms up to d. Used to synchronize on the server-side
// Unregister so chaos publishes can land on a known-empty hub. Failures
// surface as a test fatal rather than a hang.
func waitFor(t *testing.T, d time.Duration, cond func() bool) {
	t.Helper()
	deadline := time.Now().Add(d)
	for time.Now().Before(deadline) {
		if cond() {
			return
		}
		time.Sleep(5 * time.Millisecond)
	}
	t.Fatalf("waitFor: condition not met within %v", d)
}
