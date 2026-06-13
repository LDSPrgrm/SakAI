package router

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

// With trusted proxies disabled, ClientIP must equal RemoteAddr and ignore XFF,
// so a rotating X-Forwarded-For cannot mint fresh rate-limit buckets (H4).
func TestTrustedProxiesIgnoreXForwardedFor(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	if err := configureTrustedProxies(r); err != nil {
		t.Fatalf("configureTrustedProxies: %v", err)
	}
	var got string
	r.GET("/ip", func(c *gin.Context) { got = c.ClientIP() })

	for _, xff := range []string{"1.1.1.1", "2.2.2.2", "3.3.3.3"} {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/ip", nil)
		req.RemoteAddr = "10.0.0.5:12345"
		req.Header.Set("X-Forwarded-For", xff)
		r.ServeHTTP(w, req)
		if got != "10.0.0.5" {
			t.Fatalf("ClientIP=%q with XFF=%q; want 10.0.0.5 (XFF ignored)", got, xff)
		}
	}
}
