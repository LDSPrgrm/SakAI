package ws

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

// multiDeviceServer mounts a Hub against an httptest server with an
// X-Device-Label header so the test can distinguish which device receives
// each envelope. Per-device readPump exit uses UnregisterClient so a
// single conn closing does not evict the user's other devices.
func multiDeviceServer(t *testing.T, hub *Hub) *httptest.Server {
	t.Helper()
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userID, err := uuid.Parse(r.Header.Get("X-User-ID"))
		if err != nil {
			http.Error(w, "bad user", http.StatusBadRequest)
			return
		}
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			return
		}
		cl := hub.Register(userID, conn, conn.Subprotocol())
		go func() {
			// Per-device cleanup mirrors handler.go's readPump exit so
			// a single conn closing only evicts THIS device, not the
			// user's siblings.
			defer hub.UnregisterClient(userID, cl)
			for {
				if _, _, err := conn.ReadMessage(); err != nil {
					return
				}
			}
		}()
	}))
}

func dialMultiDevice(t *testing.T, srv *httptest.Server, userID uuid.UUID) *websocket.Conn {
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

// TestHub_MultiDevice_FansOutToAllDevices proves the N≤3 fanout invariant:
// every connected device for a user receives the envelope, and the same
// event_id reaches every device so client-side dedup keys still work.
func TestHub_MultiDevice_FansOutToAllDevices(t *testing.T) {
	hub := NewHub(30 * time.Second)
	srv := multiDeviceServer(t, hub)
	defer srv.Close()

	userID := uuid.New()
	phone := dialMultiDevice(t, srv, userID)
	defer phone.Close()
	tablet := dialMultiDevice(t, srv, userID)
	defer tablet.Close()

	if hub.DeviceCount() != 2 {
		t.Fatalf("DeviceCount = %d, want 2", hub.DeviceCount())
	}
	if hub.Size() != 1 {
		t.Fatalf("Size (distinct users) = %d, want 1", hub.Size())
	}

	env := makeEnv(t, EventRideCompleted)
	hub.sendEnvelope(userID, env)

	gotPhone := readEnvDeadline(t, phone, 2*time.Second)
	gotTablet := readEnvDeadline(t, tablet, 2*time.Second)
	if gotPhone.EventID != env.EventID {
		t.Errorf("phone event_id = %v, want %v", gotPhone.EventID, env.EventID)
	}
	if gotTablet.EventID != env.EventID {
		t.Errorf("tablet event_id = %v, want %v", gotTablet.EventID, env.EventID)
	}
}

// TestHub_MultiDevice_EvictsOldestPastCap covers the FIFO eviction policy
// for the fourth device. The cap of [MaxDevicesPerUser] is documented in
// RFC §7.4 + §20 decision 2.
func TestHub_MultiDevice_EvictsOldestPastCap(t *testing.T) {
	hub := NewHub(30 * time.Second)
	srv := multiDeviceServer(t, hub)
	defer srv.Close()

	userID := uuid.New()
	// Open MaxDevicesPerUser + 1 connections to force eviction.
	conns := make([]*websocket.Conn, 0, MaxDevicesPerUser+1)
	for i := 0; i < MaxDevicesPerUser+1; i++ {
		conns = append(conns, dialMultiDevice(t, srv, userID))
	}
	defer func() {
		for _, c := range conns {
			c.Close()
		}
	}()

	// Even after MaxDevicesPerUser+1 dials, the hub should hold exactly
	// MaxDevicesPerUser sockets.
	if got := hub.DeviceCount(); got != MaxDevicesPerUser {
		t.Errorf("DeviceCount after over-cap = %d, want %d", got, MaxDevicesPerUser)
	}

	// The first connection (oldest) should have been closed by the hub.
	conns[0].SetReadDeadline(time.Now().Add(500 * time.Millisecond))
	_, _, err := conns[0].ReadMessage()
	if err == nil {
		t.Errorf("oldest conn still open after cap eviction")
	}
}

// TestHub_MultiDevice_UnregisterClientKeepsSiblingAlive ensures a single
// readPump exit (e.g. phone dies) does not evict the user's tablet too.
// Pre-refactor, Unregister was coarse-grained per-user — this test is a
// regression guard for that.
func TestHub_MultiDevice_UnregisterClientKeepsSiblingAlive(t *testing.T) {
	hub := NewHub(30 * time.Second)
	srv := multiDeviceServer(t, hub)
	defer srv.Close()

	userID := uuid.New()
	phone := dialMultiDevice(t, srv, userID)
	tablet := dialMultiDevice(t, srv, userID)
	defer tablet.Close()

	// Close the phone. The serverside readPump's ReadMessage will return
	// an error and exit; we expect the tablet to still receive frames.
	_ = phone.Close()
	waitFor(t, 500*time.Millisecond, func() bool {
		return hub.DeviceCount() == 1
	})

	env := makeEnv(t, EventRideAccepted)
	hub.sendEnvelope(userID, env)
	got := readEnvDeadline(t, tablet, 2*time.Second)
	if got.EventID != env.EventID {
		t.Errorf("tablet event_id = %v, want %v", got.EventID, env.EventID)
	}
}
