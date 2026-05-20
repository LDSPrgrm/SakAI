package ws

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

// upgrader advertises both protocol versions; gorilla/websocket picks the
// first match against the client's Sec-WebSocket-Protocol list. v2-aware
// clients propose "sakai-ws-v2" first; legacy clients send nothing and the
// selected subprotocol on the resulting conn is the empty string.
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 4096,
	Subprotocols:    []string{SubprotocolV2, SubprotocolV1},
	// In production, restrict CheckOrigin to your app's domains.
	CheckOrigin: func(r *http.Request) bool { return true },
}

// SnapshotProvider builds the current `ride.state_sync` payload for a user.
// Implemented by the ride service so the WS layer doesn't depend on the DB
// schema directly.
type SnapshotProvider interface {
	RideSnapshot(ctx context.Context, userID uuid.UUID) (RideStateSyncPayload, error)
}

// Handler upgrades HTTP connections to WebSocket and registers them with the Hub.
// The auth middleware must have already placed userID in the Gin context.
type Handler struct {
	hub         *Hub
	replayStore ReplayStore
	snapshot    SnapshotProvider
}

func NewHandler(hub *Hub) *Handler { return &Handler{hub: hub} }

// WithReplayStore attaches the ReplayStore used to satisfy `replay.request`
// frames. nil disables replay (handler falls straight to ride.state_sync).
func (h *Handler) WithReplayStore(s ReplayStore) *Handler {
	h.replayStore = s
	return h
}

// WithSnapshotProvider attaches the snapshot builder used when replay falls
// out of window. nil emits an empty state_sync (client refetches via REST).
func (h *Handler) WithSnapshotProvider(s SnapshotProvider) *Handler {
	h.snapshot = s
	return h
}

func (h *Handler) ServeWS(c *gin.Context) {
	userID, ok := c.MustGet("userID").(uuid.UUID)
	if !ok {
		c.AbortWithStatus(http.StatusUnauthorized)
		return
	}
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		// upgrader already wrote the HTTP error response.
		return
	}
	protocol := conn.Subprotocol()
	log.Printf("[WS] Registered connection for user %s (%s, proto=%q)", userID, c.GetString("role"), protocol)
	h.hub.Register(userID, conn, protocol)

	// First server-pushed event: announces the negotiated protocol so clients
	// can verify the upgrade succeeded before sending replay/ack frames.
	h.hub.SendToUser(userID, EventConnWelcome, map[string]any{
		"protocol": protocol,
		"v":        EnvelopeVersion,
	})

	// Hardening: read limit and deadline prevent resource exhaustion.
	conn.SetReadLimit(4096)
	conn.SetReadDeadline(time.Now().Add(2 * h.hub.pingInterval))
	conn.SetPongHandler(func(string) error {
		conn.SetReadDeadline(time.Now().Add(2 * h.hub.pingInterval))
		return nil
	})

	// readPump — parse inbound control frames (ping, ack, replay.request)
	// and detect disconnection. Application events still flow server→client
	// only; inbound frames carry protocol metadata, not commands.
	go func() {
		defer h.hub.Unregister(userID)
		for {
			msgType, raw, err := conn.ReadMessage()
			if err != nil {
				// ReadMessage returns a net.OpError with Timeout()==true when
				// the read deadline (heartbeat watchdog) fires. Other errors
				// are normal disconnects.
				if ne, ok := err.(interface{ Timeout() bool }); ok && ne.Timeout() {
					HeartbeatMissed()
				}
				break
			}
			if msgType != websocket.TextMessage {
				continue
			}
			h.handleInbound(userID, raw)
		}
	}()
}

// inboundFrame is the union of every v2 client→server frame shape. Unknown
// types are ignored silently to preserve forward-compat.
type inboundFrame struct {
	Type        string `json:"type"`
	LastEventID string `json:"last_event_id,omitempty"`
	EventID     string `json:"event_id,omitempty"`
}

func (h *Handler) handleInbound(userID uuid.UUID, raw []byte) {
	var frame inboundFrame
	if err := json.Unmarshal(raw, &frame); err != nil {
		// Not JSON or wrong shape — pre-v2 servers discarded inbound entirely,
		// so silent drop preserves that contract.
		return
	}
	switch frame.Type {
	case "ping":
		// Client heartbeat — no response needed; presence of the read kept
		// the read-deadline timer fresh upstream.
	case "replay.request":
		ReplayRequested()
		h.handleReplayRequest(userID, frame.LastEventID)
	case "ack":
		if tracker := h.hub.AckTracker(); tracker != nil && frame.EventID != "" {
			tracker.Ack(frame.EventID)
		}
	}
}

// handleReplayRequest drains the user's replay stream past lastEventID and
// fans the missed envelopes back over the connection. If the cursor falls
// outside the retention window (or the store is unconfigured), we emit a
// `ride.state_sync` snapshot instead so the client can reconcile UI state.
func (h *Handler) handleReplayRequest(userID uuid.UUID, lastEventID string) {
	if h.replayStore == nil {
		h.emitStateSync(userID)
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	envs, err := h.replayStore.Range(ctx, userID, lastEventID)
	if errors.Is(err, ErrReplayOutOfWindow) {
		h.emitStateSync(userID)
		return
	}
	if err != nil {
		log.Printf("[WS] replay range failed user=%s: %v", userID, err)
		return
	}
	for _, env := range envs {
		h.hub.sendEnvelope(userID, env)
	}
}

func (h *Handler) emitStateSync(userID uuid.UUID) {
	if h.snapshot == nil {
		h.hub.SendToUser(userID, EventRideStateSync, RideStateSyncPayload{})
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	snap, err := h.snapshot.RideSnapshot(ctx, userID)
	if err != nil {
		log.Printf("[WS] snapshot failed user=%s: %v", userID, err)
		// Best-effort: send a default state_sync so the client doesn't hang.
		snap = RideStateSyncPayload{}
	}
	h.hub.SendToUser(userID, EventRideStateSync, snap)
}
