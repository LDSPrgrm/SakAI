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
	EventRideCancelled         EventType = "ride.cancelled"
	EventRideOfferExpired      EventType = "ride.offer_expired"
	EventRideSOS               EventType = "ride.sos_triggered"
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

// Hub maintains the registry of connected WebSocket clients.
type Hub struct {
	mu           sync.RWMutex
	clients      map[uuid.UUID]*Client // userID → client
	pingInterval time.Duration
}

// NewHub creates a ready-to-use Hub.
func NewHub(pingInterval time.Duration) *Hub {
	return &Hub{
		clients:      make(map[uuid.UUID]*Client),
		pingInterval: pingInterval,
	}
}

// Register adds a client to the hub and starts its write pump.
// If the same user already has a connection, the old one is evicted.
// The protocol argument is the Sec-WebSocket-Protocol value selected during
// upgrade — empty means a v1 client (no v2 envelope fields on the wire).
func (h *Hub) Register(userID uuid.UUID, conn *websocket.Conn, protocol string) {
	cl := newClient(userID, conn, protocol)
	h.mu.Lock()
	if old, ok := h.clients[userID]; ok {
		old.close()
	}
	h.clients[userID] = cl
	h.mu.Unlock()

	go cl.writePump(h.pingInterval)
}

// Size returns the number of currently-connected clients. Used by health
// probes and the SystemHealth dashboard.
func (h *Hub) Size() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// Unregister removes a client for the given user.
func (h *Hub) Unregister(userID uuid.UUID) {
	h.mu.Lock()
	if cl, ok := h.clients[userID]; ok {
		cl.close()
		delete(h.clients, userID)
	}
	h.mu.Unlock()
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
func (h *Hub) sendEnvelope(userID uuid.UUID, env Envelope) {
	h.mu.RLock()
	cl, ok := h.clients[userID]
	h.mu.RUnlock()
	if !ok {
		log.Printf("[WS] SendToUser FAILED: user %s not connected (total clients: %d)", userID, len(h.clients))
		return
	}
	select {
	case cl.send <- env:
	default:
		// Slow consumer — evict to avoid head-of-line blocking.
		h.Unregister(userID)
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
