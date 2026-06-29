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

func TestNewEnvelope_StampsV2Version(t *testing.T) {
	env := NewEnvelope(EventRideAccepted, map[string]any{"ride_id": "r1"})
	if env.V != EnvelopeVersion {
		t.Errorf("V = %d, want %d", env.V, EnvelopeVersion)
	}
}

func TestEnvelope_JSON_OmitsV2FieldsWhenZero(t *testing.T) {
	env := Envelope{
		Event:     EventRideAccepted,
		Payload:   map[string]any{"ride_id": "r1"},
		Timestamp: time.Now().UTC(),
		EventID:   uuid.New(),
	}
	raw, err := json.Marshal(env)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	s := string(raw)
	for _, key := range []string{`"v":`, `"seq":`, `"corr_id":`, `"ack_required":`} {
		if strings.Contains(s, key) {
			t.Errorf("v1-shape envelope leaked %s into wire: %s", key, s)
		}
	}
}

func TestEnvelope_JSON_EmitsV2FieldsWhenSet(t *testing.T) {
	ack := true
	env := Envelope{
		Event:       EventRideAccepted,
		Payload:     map[string]any{"ride_id": "r1"},
		Timestamp:   time.Now().UTC(),
		EventID:     uuid.New(),
		V:           2,
		Seq:         7,
		CorrID:      "abc-123",
		AckRequired: &ack,
	}
	raw, err := json.Marshal(env)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got map[string]any
	if err := json.Unmarshal(raw, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got["v"].(float64) != 2 {
		t.Errorf("v = %v, want 2", got["v"])
	}
	if got["seq"].(float64) != 7 {
		t.Errorf("seq = %v, want 7", got["seq"])
	}
	if got["corr_id"] != "abc-123" {
		t.Errorf("corr_id = %v", got["corr_id"])
	}
	if got["ack_required"] != true {
		t.Errorf("ack_required = %v", got["ack_required"])
	}
}

// dialNegotiated mirrors dialHub from hub_envelope_test.go but uses the
// package upgrader (which advertises subprotocols) and lets callers pick the
// client-proposed list. Empty list = v1-default client.
func dialNegotiated(t *testing.T, hub *Hub, userID uuid.UUID, clientProtocols []string) (*websocket.Conn, func()) {
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
	dialer := *websocket.DefaultDialer
	dialer.Subprotocols = clientProtocols
	c, _, err := dialer.Dial(wsURL, nil)
	if err != nil {
		srv.Close()
		t.Fatalf("dial: %v", err)
	}
	time.Sleep(20 * time.Millisecond)
	return c, func() {
		c.Close()
		srv.Close()
	}
}

// V1 connections (no Sec-WebSocket-Protocol header) must see an envelope
// shape byte-for-byte compatible with v1.3.
func TestHub_V1Connection_StripsV2FieldsFromWire(t *testing.T) {
	hub := NewHub(30 * time.Second)
	userID := uuid.New()
	conn, cleanup := dialNegotiated(t, hub, userID, nil)
	defer cleanup()

	hub.SendToUser(userID, EventRideAccepted, map[string]any{"ride_id": "r1"})

	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	_, raw, err := conn.ReadMessage()
	if err != nil {
		t.Fatalf("read: %v", err)
	}
	s := string(raw)
	for _, key := range []string{`"v":`, `"seq":`, `"corr_id":`, `"ack_required":`} {
		if strings.Contains(s, key) {
			t.Errorf("v1-conn wire leaked %s: %s", key, s)
		}
	}
}

// V2 connections must see V=2 and a monotonically-increasing seq per envelope.
func TestHub_V2Connection_StampsSequence(t *testing.T) {
	hub := NewHub(30 * time.Second)
	userID := uuid.New()
	conn, cleanup := dialNegotiated(t, hub, userID, []string{SubprotocolV2})
	defer cleanup()

	readEnv := func() Envelope {
		conn.SetReadDeadline(time.Now().Add(2 * time.Second))
		_, raw, err := conn.ReadMessage()
		if err != nil {
			t.Fatalf("read: %v", err)
		}
		var env Envelope
		if err := json.Unmarshal(raw, &env); err != nil {
			t.Fatalf("unmarshal: %v", err)
		}
		return env
	}

	hub.SendToUser(userID, EventRideAccepted, map[string]any{"ride_id": "r1"})
	hub.SendToUser(userID, EventRideStatusChanged, map[string]any{"ride_id": "r1", "status": "arrived"})

	first := readEnv()
	if first.V != EnvelopeVersion {
		t.Errorf("first V = %d, want %d", first.V, EnvelopeVersion)
	}
	if first.Seq != 1 {
		t.Errorf("first seq = %d, want 1", first.Seq)
	}
	second := readEnv()
	if second.Seq != 2 {
		t.Errorf("second seq = %d, want 2", second.Seq)
	}
}

// Server lists v2 first in upgrader.Subprotocols, so a client proposing both
// should land on v2.
func TestHub_NegotiatesV2WhenBothProposed(t *testing.T) {
	hub := NewHub(30 * time.Second)
	userID := uuid.New()
	conn, cleanup := dialNegotiated(t, hub, userID, []string{SubprotocolV2, SubprotocolV1})
	defer cleanup()
	if got := conn.Subprotocol(); got != SubprotocolV2 {
		t.Errorf("negotiated subprotocol = %q, want %q", got, SubprotocolV2)
	}
}
