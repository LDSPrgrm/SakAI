package ws

import (
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

// Handler upgrades HTTP connections to WebSocket and registers them with the Hub.
// The auth middleware must have already placed userID in the Gin context.
type Handler struct{ hub *Hub }

func NewHandler(hub *Hub) *Handler { return &Handler{hub: hub} }

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

	// readPump — discard inbound frames; detect disconnection.
	// WebSocket is server-push only in this design.
	go func() {
		defer h.hub.Unregister(userID)
		for {
			if _, _, err := conn.ReadMessage(); err != nil {
				break
			}
		}
	}()
}
