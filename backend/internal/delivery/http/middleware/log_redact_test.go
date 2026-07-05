package middleware

import (
	"bytes"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestRedactQueryToken(t *testing.T) {
	cases := []struct{ in, want string }{
		{"/api/ws?token=eyJhbGciOi.abc.def", "/api/ws?token=%5BREDACTED%5D"},
		{"/api/ws?foo=1&token=xyz&bar=2", "/api/ws?foo=1&token=%5BREDACTED%5D&bar=2"},
		{"/api/health", "/api/health"},
		{"/api/rides?page=2", "/api/rides?page=2"},
	}
	for _, c := range cases {
		if got := RedactQueryToken(c.in); got != c.want {
			t.Errorf("RedactQueryToken(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}

func TestAccessLoggerWithErrorMessage(t *testing.T) {
	// Swap DefaultWriter to capture log output.
	oldWriter := gin.DefaultWriter
	logBuffer := bytes.NewBuffer(nil)
	gin.DefaultWriter = logBuffer
	defer func() { gin.DefaultWriter = oldWriter }()

	// Create a test engine with AccessLogger middleware.
	engine := gin.New()
	engine.Use(AccessLogger())

	// Add a route handler that calls c.Error().
	engine.GET("/api/test", func(c *gin.Context) {
		c.Error(errors.New("test handler error"))
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	// Make a request through the middleware.
	req := httptest.NewRequest("GET", "/api/test", nil)
	w := httptest.NewRecorder()
	engine.ServeHTTP(w, req)

	// Verify error message appears in the log.
	logOutput := logBuffer.String()
	if !strings.Contains(logOutput, "test handler error") {
		t.Errorf("AccessLogger did not include error message in log output.\nGot: %q", logOutput)
	}
}
