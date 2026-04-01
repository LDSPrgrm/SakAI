// Package ws provides the WebSocket hub and client management for real-time
// event delivery. Each authenticated connection is registered by userID so the
// server can target events at specific passengers or drivers.
package ws

import (
	"context"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/sakai/backend/internal/domain"
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
	EventDriverLocationUpdated EventType = "driver.location_updated"
)

// envelope is the JSON shape sent over every WebSocket connection.
type envelope struct {
	Event   EventType `json:"event"`
	Payload any       `json:"payload"`
}

// Client wraps a single WebSocket connection for one authenticated user.
type Client struct {
	userID uuid.UUID
	conn   *websocket.Conn
	send   chan envelope
	once   sync.Once
}

func newClient(userID uuid.UUID, conn *websocket.Conn) *Client {
	return &Client{
		userID: userID,
		conn:   conn,
		send:   make(chan envelope, 64),
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
func (h *Hub) Register(userID uuid.UUID, conn *websocket.Conn) {
	cl := newClient(userID, conn)
	h.mu.Lock()
	if old, ok := h.clients[userID]; ok {
		old.close()
	}
	h.clients[userID] = cl
	h.mu.Unlock()

	go cl.writePump(h.pingInterval)
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
func (h *Hub) SendToUser(userID uuid.UUID, event EventType, payload any) {
	h.mu.RLock()
	cl, ok := h.clients[userID]
	h.mu.RUnlock()
	if !ok {
		return
	}
	select {
	case cl.send <- envelope{Event: event, Payload: payload}:
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
func (h *Hub) BroadcastToRide(ride *domain.Ride, event EventType, payload any) {
	h.SendToUser(ride.PassengerID, event, payload)
	if ride.DriverID != nil {
		h.SendToUser(*ride.DriverID, event, payload)
	}
}
