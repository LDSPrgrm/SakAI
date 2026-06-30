package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func ctxFor(path, query string) *gin.Context {
	gin.SetMode(gin.TestMode)
	c, _ := gin.CreateTestContext(httptest.NewRecorder())
	c.Request = httptest.NewRequest(http.MethodGet, path+"?"+query, nil)
	return c
}

func TestExtractToken_QueryOnlyForWS(t *testing.T) {
	// REST path: query token must be ignored.
	if got := extractToken(ctxFor("/api/v1/rides", "token=leaky")); got != "" {
		t.Fatalf("REST path returned query token %q; want empty", got)
	}
	// WS path: query token accepted.
	if got := extractToken(ctxFor("/api/ws", "token=wstok")); got != "wstok" {
		t.Fatalf("WS path returned %q; want wstok", got)
	}
}

func TestExtractToken_HeaderStillWorks(t *testing.T) {
	c := ctxFor("/api/v1/rides", "")
	c.Request.Header.Set("Authorization", "Bearer abc123")
	if got := extractToken(c); got != "abc123" {
		t.Fatalf("header path returned %q; want abc123", got)
	}
}
