package ws

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 4096,
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
	h.hub.Register(userID, conn)

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
