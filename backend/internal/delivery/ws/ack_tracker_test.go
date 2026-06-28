package ws

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

// fastSchedule shaves three orders of magnitude off the production schedule
// so tests don't have to wait 7.5 seconds for the full 4-attempt budget.
var fastSchedule = []time.Duration{
	10 * time.Millisecond,
	20 * time.Millisecond,
	30 * time.Millisecond,
	40 * time.Millisecond,
}

// trackTestClient stands up a real Hub + connected dialer with a v2
// subprotocol so the Hub's writePump runs end-to-end. Returns the dialer
// conn, hub, and a cleanup func.
func trackTestClient(t *testing.T, userID uuid.UUID, hub *Hub) (*websocket.Conn, func()) {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			t.Fatalf("upgrade: %v", err)
		}
		hub.Register(userID, conn, conn.Subprotocol())
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

func mustAckEnvelope(t *testing.T, event EventType) Envelope {
	t.Helper()
	ack := true
	return Envelope{
		Event:       event,
		Payload:     map[string]any{"ride_id": "r1"},
		Timestamp:   time.Now().UTC(),
		EventID:     uuid.New(),
		V:           EnvelopeVersion,
		AckRequired: &ack,
	}
}

func TestAckTracker_Track_ThenAck_ClearsPending(t *testing.T) {
	hub := NewHub(30 * time.Second)
	tracker := NewAckTrackerWithSchedule(hub, fastSchedule)
	hub.WithAckTracker(tracker)

	userID := uuid.New()
	env := mustAckEnvelope(t, EventRideAccepted)
	tracker.Track(userID, env)
	if tracker.Pending() != 1 {
		t.Fatalf("pending = %d, want 1", tracker.Pending())
	}
	tracker.Ack(env.EventID.String())
	if tracker.Pending() != 0 {
		t.Errorf("pending after ack = %d, want 0", tracker.Pending())
	}
}

func TestAckTracker_Ack_UnknownEventID_IsNoOp(t *testing.T) {
	tracker := NewAckTracker(NewHub(30 * time.Second))
	tracker.Ack("not-a-real-event-id")
	if tracker.Pending() != 0 {
		t.Errorf("pending = %d, want 0", tracker.Pending())
	}
}

func TestAckTracker_Retry_RedeliversEnvelope(t *testing.T) {
	hub := NewHub(30 * time.Second)
	tracker := NewAckTrackerWithSchedule(hub, fastSchedule)
	hub.WithAckTracker(tracker)
	userID := uuid.New()

	conn, cleanup := trackTestClient(t, userID, hub)
	defer cleanup()

	env := mustAckEnvelope(t, EventRideAccepted)
	hub.sendEnvelope(userID, env)

	// First send + at least one retry should land within ~20ms.
	conn.SetReadDeadline(time.Now().Add(200 * time.Millisecond))
	first := readEnv(t, conn)
	conn.SetReadDeadline(time.Now().Add(200 * time.Millisecond))
	second := readEnv(t, conn)

	if first.EventID != env.EventID || second.EventID != env.EventID {
		t.Errorf("first=%v second=%v want both %v",
			first.EventID, second.EventID, env.EventID)
	}
	tracker.Ack(env.EventID.String())
}

func TestAckTracker_BudgetExhausted_StopsRetrying(t *testing.T) {
	hub := NewHub(30 * time.Second)
	// Schedule = 3 entries of 10ms; after 3 retries (4 total sends), give up.
	tracker := NewAckTrackerWithSchedule(hub, []time.Duration{
		10 * time.Millisecond,
		10 * time.Millisecond,
		10 * time.Millisecond,
	})
	hub.WithAckTracker(tracker)
	userID := uuid.New()

	conn, cleanup := trackTestClient(t, userID, hub)
	defer cleanup()

	env := mustAckEnvelope(t, EventRideCancelled)
	before := metrics.AckFailedCount(EventRideCancelled)
	hub.sendEnvelope(userID, env)

	// Drain any retries that the conn receives, ignoring count.
	go func() {
		for {
			conn.SetReadDeadline(time.Now().Add(100 * time.Millisecond))
			if _, _, err := conn.ReadMessage(); err != nil {
				return
			}
		}
	}()

	// Wait past the full schedule + slack.
	time.Sleep(150 * time.Millisecond)
	if tracker.Pending() != 0 {
		t.Errorf("pending after budget exhausted = %d, want 0", tracker.Pending())
	}
	after := metrics.AckFailedCount(EventRideCancelled)
	if after-before != 1 {
		t.Errorf("ack_failed delta = %d, want 1", after-before)
	}
}

func TestAckTracker_ConcurrentAcks_Idempotent(t *testing.T) {
	tracker := NewAckTrackerWithSchedule(NewHub(30*time.Second), fastSchedule)
	userID := uuid.New()
	env := mustAckEnvelope(t, EventRideAccepted)
	tracker.Track(userID, env)

	var wg sync.WaitGroup
	for i := 0; i < 16; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			tracker.Ack(env.EventID.String())
		}()
	}
	wg.Wait()

	if tracker.Pending() != 0 {
		t.Errorf("pending = %d, want 0", tracker.Pending())
	}
}

func TestAckTracker_Track_SameEventID_Idempotent(t *testing.T) {
	tracker := NewAckTrackerWithSchedule(NewHub(30*time.Second), fastSchedule)
	userID := uuid.New()
	env := mustAckEnvelope(t, EventRideAccepted)
	tracker.Track(userID, env)
	tracker.Track(userID, env)
	if tracker.Pending() != 1 {
		t.Errorf("pending = %d, want 1 (Track must dedupe)", tracker.Pending())
	}
	tracker.Ack(env.EventID.String())
}

func TestNewEnvelope_SetsAckRequiredForCriticalEvents(t *testing.T) {
	cases := []struct {
		event EventType
		want  bool
	}{
		{EventRideRequested, true},
		{EventRideAccepted, true},
		{EventRideCancelled, true},
		{EventRideSOS, true},
		{EventRideStatusChanged, false},
		{EventDriverLocationUpdated, false},
		{EventConnWelcome, false},
	}
	for _, tc := range cases {
		env := NewEnvelope(tc.event, nil)
		got := env.AckRequired != nil && *env.AckRequired
		if got != tc.want {
			t.Errorf("AckRequired for %s = %v, want %v", tc.event, got, tc.want)
		}
	}
}

func TestHub_SendEnvelope_TracksAckRequired(t *testing.T) {
	hub := NewHub(30 * time.Second)
	tracker := NewAckTrackerWithSchedule(hub, fastSchedule)
	hub.WithAckTracker(tracker)
	userID := uuid.New()

	conn, cleanup := trackTestClient(t, userID, hub)
	defer cleanup()

	env := mustAckEnvelope(t, EventRideAccepted)
	hub.sendEnvelope(userID, env)
	// Drain.
	conn.SetReadDeadline(time.Now().Add(200 * time.Millisecond))
	_, _, _ = conn.ReadMessage()

	if tracker.Pending() != 1 {
		t.Errorf("pending = %d, want 1 (hub should have tracked ack-required envelope)", tracker.Pending())
	}
	tracker.Ack(env.EventID.String())
}

// readEnv is a helper that decodes the next text frame into an Envelope.
func readEnv(t *testing.T, c *websocket.Conn) Envelope {
	t.Helper()
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
