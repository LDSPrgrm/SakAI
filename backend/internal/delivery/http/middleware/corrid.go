package middleware

import (
	"github.com/gin-gonic/gin"

	"github.com/sakai/backend/internal/observability/corrid"
)

// CorrID is the Gin middleware that materialises the per-request correlation
// ID (RFC v2 §4.3 / §12.4).
//
//   - If the inbound request already carries X-Correlation-ID, that value is
//     honoured so callers can stitch their own client-side logs to ours.
//   - Otherwise a fresh UUIDv4 is minted via corrid.New().
//
// The value is then:
//   - written back as X-Correlation-ID on the response so clients can pick
//     it up from any successful call (including ones that never hit a
//     handler — the header is set BEFORE c.Next()).
//   - stored on c.Request.Context() so downstream collaborators (use cases,
//     the WS dispatcher, audit writers) can read it via corrid.FromContext.
//   - mirrored onto gin.Context with the "corr_id" key so handlers that
//     prefer the gin shape can grab it with c.GetString("corr_id").
func CorrID() gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.GetHeader(corrid.HeaderName)
		if id == "" {
			id = corrid.New()
		}
		c.Set("corr_id", id)
		c.Request = c.Request.WithContext(corrid.WithCorrID(c.Request.Context(), id))
		c.Writer.Header().Set(corrid.HeaderName, id)
		c.Next()
	}
}
