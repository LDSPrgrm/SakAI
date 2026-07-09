package middleware

import (
	"context"
	"log"
	"strconv"
	"sync/atomic"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

// PerfSampler is the minimal sink needed for the perf middleware. Matches the
// RecordHTTPTiming method on domain.SystemRepository so wiring stays in main.go.
type PerfSampler interface {
	RecordHTTPTiming(ctx context.Context, method, path string, statusCode int, durationMs float64) error
}

var (
	httpDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "sakai_http_request_duration_seconds",
		Help:    "HTTP request latency by matched route template.",
		Buckets: prometheus.DefBuckets,
	}, []string{"method", "path", "status"})
	perfSampleCounter atomic.Uint64
)

// perfDBSampleEvery: 1-in-N requests also land in http_request_timings so the
// admin dashboard keeps data without a per-request INSERT write amplifier.
const perfDBSampleEvery = 100

// Perf returns a Gin middleware that records request duration as a Prometheus
// histogram (always, scraped via /metrics) and, for 1-in-perfDBSampleEvery
// requests when sampler is non-nil, also writes to the http_request_timings
// table via sampler so the admin dashboard keeps a bounded-volume sample.
// Samples the matched route template (e.g. "/api/rides/:rideId") rather than
// the raw URL so cardinality stays bounded. The histogram is recorded
// synchronously in-request on every call; DB writes are async (goroutine)
// and sampled (1-in-perfDBSampleEvery) with a short timeout so the request
// hot path is never blocked on the DB.
func Perf(sampler PerfSampler) gin.HandlerFunc {
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

		httpDuration.WithLabelValues(method, path, strconv.Itoa(status)).Observe(elapsed / 1000)

		// Counter pre-increments before the modulo check, so the first eligible
		// request is #100, not #1.
		if sampler != nil && perfSampleCounter.Add(1)%perfDBSampleEvery == 0 {
			go func() {
				ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
				defer cancel()
				if err := sampler.RecordHTTPTiming(ctx, method, path, status, elapsed); err != nil {
					log.Printf("perf-middleware: record timing: %v", err)
				}
			}()
		}
	}
}
