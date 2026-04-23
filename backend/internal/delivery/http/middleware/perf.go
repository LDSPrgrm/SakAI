package middleware

import (
	"context"
	"log"
	"time"

	"github.com/gin-gonic/gin"
)

// PerfSampler is the minimal sink needed for the perf middleware. Matches the
// RecordHTTPTiming method on domain.SystemRepository so wiring stays in main.go.
type PerfSampler interface {
	RecordHTTPTiming(ctx context.Context, method, path string, statusCode int, durationMs float64) error
}

// Perf returns a Gin middleware that records request duration into the
// http_request_timings table via sampler. Samples the matched route template
// (e.g. "/api/rides/:rideId") rather than the raw URL so aggregations are
// bounded in cardinality. Writes asynchronously with a short timeout so the
// request hot path is never blocked on the DB.
func Perf(sampler PerfSampler) gin.HandlerFunc {
	if sampler == nil {
		return func(c *gin.Context) { c.Next() }
	}
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		elapsed := time.Since(start).Seconds() * 1000

		path := c.FullPath()
		if path == "" {
			// Route did not match (404). Skip to avoid unbounded cardinality on
			// random 404s — the null-route path is not load-bearing.
			return
		}

		method := c.Request.Method
		status := c.Writer.Status()

		go func() {
			ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
			defer cancel()
			if err := sampler.RecordHTTPTiming(ctx, method, path, status, elapsed); err != nil {
				log.Printf("perf-middleware: record timing: %v", err)
			}
		}()
	}
}

