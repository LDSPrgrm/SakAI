package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestCORS_AllowlistOnly(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(CORS([]string{"https://app.sakai.ph"}))
	r.GET("/x", func(c *gin.Context) { c.Status(200) })

	// Allowed origin is echoed.
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("Origin", "https://app.sakai.ph")
	r.ServeHTTP(w, req)
	assert.Equal(t, "https://app.sakai.ph", w.Header().Get("Access-Control-Allow-Origin"))

	// Untrusted origin is NOT echoed.
	w2 := httptest.NewRecorder()
	req2 := httptest.NewRequest(http.MethodGet, "/x", nil)
	req2.Header.Set("Origin", "https://evil.example")
	r.ServeHTTP(w2, req2)
	assert.Equal(t, "", w2.Header().Get("Access-Control-Allow-Origin"))
}
