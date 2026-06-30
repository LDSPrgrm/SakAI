// Package ws provides the WebSocket hub and client management for real-time
// event delivery. Each authenticated connection is registered by userID so the
// server can target events at specific passengers or drivers.
package ws

import (
	"context"
	"log"
	"sync"
	"sync/atomic"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/sakai/backend/internal/domain"
)

// Subprotocol identifiers used in the Sec-WebSocket-Protocol negotiation.
// SubprotocolV2 enables envelope v2 fields (seq, corr_id, ack_required) on
// the wire; anything else is treated as v1.
const (
	SubprotocolV1 = "sakai-ws-v1"
	SubprotocolV2 = "sakai-ws-v2"
)

// Dispatcher is the interface for isolating HTTP handlers from the concrete
// Pub/Sub system, allowing tests to use local Hubs while Prod uses Redis.
type Dispatcher interface {
	PublishToUser(ctx context.Context, userID uuid.UUID, event EventType, payload any) error
	PublishToRide(ctx context.Context, ride *domain.Ride, event EventType, payload any) error
}

// EventType is a typed string for WebSocket event names.
type EventType string

const (
	EventRideRequested         EventType = "ride.requested"
	EventRideAccepted          EventType = "ride.accepted"
	EventRideDeclined          EventType = "ride.declined"
	EventRideStatusChanged     EventType = "ride.status_changed"
	EventRideCompleted         EventType = "ride.completed"
	EventRideCancelled         EventType = "ride.cancelled"
	EventRideOfferExpired      EventType = "ride.offer_expired"
	EventRideSOS               EventType = "ride.sos_triggered"
	EventSosLocationStream     EventType = "sos.location_stream"
	EventIncidentAssigned      EventType = "incident.assigned"
	EventIncidentResolved      EventType = "incident.resolved"
	EventDriverLocationUpdated EventType = "driver.location_updated"
	EventConnWelcome           EventType = "conn.welcome"
	EventRideStateSync         EventType = "ride.state_sync"
)

// Client wraps a single WebSocket connection for one authenticated user.
//
// The wire envelope is defined in envelope.go; the channel here carries
// already-stamped Envelopes so the writePump never has to allocate. seq is
// stamped per-connection at write time so envelopes re-broadcast across pods
// get the correct sequence on each peer.
type Client struct {
	userID   uuid.UUID
	conn     *websocket.Conn
	send     chan Envelope
	once     sync.Once
	protocol string
	seq      atomic.Uint64
}

func newClient(userID uuid.UUID, conn *websocket.Conn, protocol string) *Client {
	return &Client{
		userID:   userID,
		conn:     conn,
		send:     make(chan Envelope, 64),
		protocol: protocol,
	}
}

// writePump drains the send channel and writes to the WebSocket.
// One goroutine per client — runs until the client disconnects.
func (cl *Client) writePump(pingInterval time.Duration) {
	ticker := time.NewTicker(pingInterval)
	defer func() {
		ticker.Stop()
		cl.conn.Close()
	}()
	for {
		select {
		case msg, ok := <-cl.send:
			if !ok {
				cl.conn.WriteMessage(websocket.CloseMessage, nil) //nolint:errcheck
				return
			}
			if cl.protocol == SubprotocolV2 {
				msg.Seq = cl.seq.Add(1)
			} else {
				// v1 connections see a v1.3-shape envelope.
				msg.V = 0
				msg.Seq = 0
				msg.CorrID = ""
				msg.AckRequired = nil
			}
			if err := cl.conn.WriteJSON(msg); err != nil {
				return
			}
		case <-ticker.C:
			if err := cl.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// close shuts down the send channel exactly once.
func (cl *Client) close() {
	cl.once.Do(func() { close(cl.send) })
}

// MaxDevicesPerUser caps concurrent WS connections per user at RFC v2 §7.4
// + §20 decision 2's documented N≤3. Registering a fourth connection
// evicts the OLDEST existing one (FIFO) so a long-suspended phone in a
// bag doesn't block a tablet the user is actively using.
const MaxDevicesPerUser = 3

// Hub maintains the registry of connected WebSocket clients. Each user
// may have up to [MaxDevicesPerUser] simultaneous connections — fanout
// iterates the slice so every device sees the event.
type Hub struct {
	mu           sync.RWMutex
	clients      map[uuid.UUID][]*Client // userID → connected clients (cap MaxDevicesPerUser)
	pingInterval time.Duration
	ackTracker   *AckTracker
}

// NewHub creates a ready-to-use Hub.
func NewHub(pingInterval time.Duration) *Hub {
	return &Hub{
		clients:      make(map[uuid.UUID][]*Client),
		pingInterval: pingInterval,
	}
}

// WithAckTracker wires the [AckTracker] so envelopes published with
// `AckRequired:true` are retried until the client confirms or the budget
// is exhausted. nil disables retry (best-effort delivery only).
func (h *Hub) WithAckTracker(t *AckTracker) *Hub {
	h.ackTracker = t
	return h
}

// AckTracker returns the attached tracker (nil if none).
func (h *Hub) AckTracker() *AckTracker { return h.ackTracker }

// Register adds a client to the hub and starts its write pump.
// If the same user already has a connection, the old one is evicted.
// The protocol argument is the Sec-WebSocket-Protocol value selected during
// upgrade — empty means a v1 client (no v2 envelope fields on the wire).
//
// OUTSTANDING (RFC v2 §7.4 + §20 decision 2 — multi-device fanout, N≤3):
// the current single-slot eviction model is incompatible with the multi-
// device claim. To support phone+tablet for the same user the clients map
// must become map[uuid.UUID][]*Client with a 3-element cap, and every
// fanout site (sendEnvelope / BroadcastToRide / BroadcastToRideByIDs)
// must iterate the slice. ack_tracker.Track keys on event_id only, so
// multi-device ACK semantics already hold — a single client ACK drops the
// pending entry and stops retries to all peers.
// Register returns the *Client so the caller's readPump goroutine can
// invoke UnregisterClient on exit. Coarse Unregister still exists for
// codepaths that want to evict all of a user's devices (e.g. force
// logout) but new callers should prefer per-device cleanup.
func (h *Hub) Register(userID uuid.UUID, conn *websocket.Conn, protocol string) *Client {
	cl := newClient(userID, conn, protocol)
	h.mu.Lock()
	existing := h.clients[userID]
	// Evict the oldest if we're at capacity. FIFO eviction matches the
	// "long-stale phone in a bag" intuition — newer connections are more
	// likely to be the active device.
	if len(existing) >= MaxDevicesPerUser {
		oldest := existing[0]
		existing = existing[1:]
		oldest.close()
		// Capacity eviction keeps the user-level conn_active gauge steady:
		// one client closed, one opened.
	} else {
		// Net-new device: bump the gauge once.
		ConnOpened()
	}
	h.clients[userID] = append(existing, cl)
	h.mu.Unlock()

	go cl.writePump(h.pingInterval)
	return cl
}

// Size returns the count of distinct connected USERS (not devices). Used
// by health probes / SystemHealth dashboard, which historically tracked
// "how many people online" rather than raw socket count.
func (h *Hub) Size() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// DeviceCount returns the total number of connected sockets across all
// users. Useful for capacity planning + Prometheus-side cross-checks
// against the conn_active counter.
func (h *Hub) DeviceCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	total := 0
	for _, devices := range h.clients {
		total += len(devices)
	}
	return total
}

// Unregister removes ALL clients for the given user. Used at the
// readPump-exit path for now; per-device cleanup happens transparently
// when the underlying conn returns from ReadMessage with an error and
// the corresponding writePump exits via cl.send close.
//
// NOTE: this is a coarse-grained unregister — it kills every device for
// a user. The per-device readPump-driven path needs UnregisterClient
// (added below) so one bad socket doesn't take down the user's other
// devices.
func (h *Hub) Unregister(userID uuid.UUID) {
	h.mu.Lock()
	if devices, ok := h.clients[userID]; ok {
		for _, cl := range devices {
			cl.close()
		}
		delete(h.clients, userID)
		// One ConnClosed per device — keeps Prometheus aligned with the
		// per-device ConnOpened calls in Register.
		for range devices {
			ConnClosed()
		}
	}
	h.mu.Unlock()
}

// UnregisterClient removes a single device. Called by the readPump
// goroutine when its conn returns an error. Other devices for the same
// user remain registered.
func (h *Hub) UnregisterClient(userID uuid.UUID, cl *Client) {
	h.mu.Lock()
	devices := h.clients[userID]
	kept := devices[:0]
	removed := 0
	for _, d := range devices {
		if d == cl {
			d.close()
			removed++
			continue
		}
		kept = append(kept, d)
	}
	if len(kept) == 0 {
		delete(h.clients, userID)
	} else {
		h.clients[userID] = kept
	}
	h.mu.Unlock()
	for i := 0; i < removed; i++ {
		ConnClosed()
	}
}

// SendToUser sends an event to a specific user if they are connected.
//
// The payload is wrapped in a fresh Envelope (timestamp + UUIDv7 event_id
// stamped at send time). Callers may still pass `gin.H` maps or typed
// payload structs; the wire format is normalized here.
func (h *Hub) SendToUser(userID uuid.UUID, event EventType, payload any) {
	h.sendEnvelope(userID, NewEnvelope(event, payload))
}

// sendEnvelope dispatches an already-built Envelope. Used by RedisDispatcher
// so timestamp + event_id stay stable across the cluster — the publishing
// node stamps once, all subscribing nodes forward the same envelope.
//
// If [AckTracker] is wired and env.AckRequired is true, the envelope is
// registered for retry on the same call. Track is idempotent on event_id,
// so a retransmission from the tracker re-uses the original entry.
func (h *Hub) sendEnvelope(userID uuid.UUID, env Envelope) {
	h.mu.RLock()
	devices := h.clients[userID]
	// Snapshot the slice header so the broadcast loop runs without
	// holding the read lock — sends below may block on a slow consumer.
	snapshot := make([]*Client, len(devices))
	copy(snapshot, devices)
	h.mu.RUnlock()

	if len(snapshot) == 0 {
		log.Printf("[WS] SendToUser FAILED: user %s not connected (total users: %d)", userID, h.Size())
		return
	}
	var slow []*Client
	delivered := false
	for _, cl := range snapshot {
		select {
		case cl.send <- env:
			delivered = true
		default:
			// Slow consumer — collect for eviction outside the loop so
			// we don't mutate the map while iterating.
			slow = append(slow, cl)
		}
	}
	// ack_tracker.Track keys on event_id; recording once per envelope is
	// correct even with N devices because any one ACK drops the pending
	// entry. Skip if literally no device accepted the frame — there's
	// nothing to retry to.
	if delivered && h.ackTracker != nil && env.AckRequired != nil && *env.AckRequired {
		h.ackTracker.Track(userID, env)
	}
	for _, cl := range slow {
		h.UnregisterClient(userID, cl)
	}
}

// SendToDriver is a convenience alias used by the driver location handler.
func (h *Hub) SendToDriver(driverID uuid.UUID, event EventType, payload any) {
	h.SendToUser(driverID, event, payload)
}

// BroadcastToRide targets both the passenger and the assigned driver of a ride.
// Both recipients receive the *same* Envelope (same event_id) so clients can
// dedupe across reconnects without coordination.
func (h *Hub) BroadcastToRide(ride *domain.Ride, event EventType, payload any) {
	env := NewEnvelope(event, payload)
	h.sendEnvelope(ride.PassengerID, env)
	if ride.DriverID != nil {
		h.sendEnvelope(*ride.DriverID, env)
	}
}

// BroadcastToRideByIDs targets both the passenger and driver given explicit IDs,
// avoiding the need to construct a full domain.Ride for Redis-sourced events.
// Like BroadcastToRide, both recipients share the same Envelope/event_id.
func (h *Hub) BroadcastToRideByIDs(rideID uuid.UUID, passengerID uuid.UUID, driverID *uuid.UUID, event EventType, payload any) {
	env := NewEnvelope(event, payload)
	h.sendEnvelope(passengerID, env)
	if driverID != nil {
		h.sendEnvelope(*driverID, env)
	}
	_ = rideID // rideID is logged/available for future tracing
}
