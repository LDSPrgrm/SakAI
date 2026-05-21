package middleware_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"github.com/sakai/backend/internal/delivery/http/middleware"
	"github.com/sakai/backend/internal/observability/corrid"
)

func setup() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(middleware.CorrID())
	return r
}

func TestCorrID_mintsWhenAbsent(t *testing.T) {
	r := setup()
	var seen string
	r.GET("/probe", func(c *gin.Context) {
		seen = corrid.FromContext(c.Request.Context())
		c.Status(http.StatusOK)
	})

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/probe", nil)
	r.ServeHTTP(w, req)

	if seen == "" {
		t.Fatal("corr_id was not stamped on request context")
	}
	if got := w.Header().Get(corrid.HeaderName); got != seen {
		t.Fatalf("response header = %q, want %q", got, seen)
	}
}

func TestCorrID_honoursInboundHeader(t *testing.T) {
	r := setup()
	var seenCtx, seenGin string
	r.GET("/probe", func(c *gin.Context) {
		seenCtx = corrid.FromContext(c.Request.Context())
		seenGin = c.GetString("corr_id")
		c.Status(http.StatusOK)
	})

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/probe", nil)
	req.Header.Set(corrid.HeaderName, "client-supplied-id")
	r.ServeHTTP(w, req)

	if seenCtx != "client-supplied-id" {
		t.Fatalf("ctx corr_id = %q, want client-supplied-id", seenCtx)
	}
	if seenGin != "client-supplied-id" {
		t.Fatalf("gin corr_id = %q, want client-supplied-id", seenGin)
	}
	if got := w.Header().Get(corrid.HeaderName); got != "client-supplied-id" {
		t.Fatalf("response header = %q, want echo", got)
	}
}
