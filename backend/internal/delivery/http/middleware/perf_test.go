package middleware

import (
	"context"
	"net/http/httptest"
	"sync"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
)

// fakePerfSampler counts RecordHTTPTiming invocations in a thread-safe way,
// since the perf middleware fires the write in a goroutine.
type fakePerfSampler struct {
	mu    sync.Mutex
	calls int
}

func (f *fakePerfSampler) RecordHTTPTiming(ctx context.Context, method, path string, statusCode int, durationMs float64) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls++
	return nil
}

func (f *fakePerfSampler) count() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.calls
}

// waitForCount polls fn until it returns >= want or the deadline elapses,
// then returns the last observed value.
func waitForCount(fn func() int, want int, timeout time.Duration) int {
	deadline := time.Now().Add(timeout)
	for {
		got := fn()
		if got >= want || time.Now().After(deadline) {
			return got
		}
		time.Sleep(2 * time.Millisecond)
	}
}

func TestPerfRecordsHistogram(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(Perf(nil)) // nil sampler: histogram must still record
	r.GET("/ping", func(c *gin.Context) { c.Status(200) })

	req := httptest.NewRequest("GET", "/ping", nil)
	r.ServeHTTP(httptest.NewRecorder(), req)

	mfs, err := prometheus.DefaultGatherer.Gather()
	if err != nil {
		t.Fatal(err)
	}
	for _, mf := range mfs {
		if mf.GetName() == "sakai_http_request_duration_seconds" {
			for _, m := range mf.GetMetric() {
				if m.GetHistogram().GetSampleCount() >= 1 {
					return
				}
			}
		}
	}
	t.Fatal("sakai_http_request_duration_seconds not recorded")
}

// TestPerfSamplesDBWritesOneInN drives 200 matched requests through the
// middleware with a non-nil sampler and asserts exactly 2 DB writes occur
// (1-in-100 sampling). perfSampleCounter is package-level and shared across
// tests, so we assert on the delta of our fake's own counter rather than any
// absolute global counter value.
func TestPerfSamplesDBWritesOneInN(t *testing.T) {
	gin.SetMode(gin.TestMode)
	sampler := &fakePerfSampler{}
	r := gin.New()
	r.Use(Perf(sampler))
	r.GET("/sampled", func(c *gin.Context) { c.Status(200) })

	const requests = 200
	for i := 0; i < requests; i++ {
		req := httptest.NewRequest("GET", "/sampled", nil)
		r.ServeHTTP(httptest.NewRecorder(), req)
	}

	const wantCalls = requests / perfDBSampleEvery
	got := waitForCount(sampler.count, wantCalls, 2*time.Second)
	if got != wantCalls {
		t.Fatalf("expected exactly %d DB writes for %d requests (1-in-%d sampling), got %d", wantCalls, requests, perfDBSampleEvery, got)
	}
}

// TestPerfSkipsUnmatchedRoutes verifies that requests to routes not
// registered on the engine (c.FullPath() == "") are skipped entirely: no
// sampler calls and no new histogram observations for any 404 label set.
func TestPerfSkipsUnmatchedRoutes(t *testing.T) {
	gin.SetMode(gin.TestMode)
	sampler := &fakePerfSampler{}
	r := gin.New()
	r.Use(Perf(sampler))
	r.GET("/known", func(c *gin.Context) { c.Status(200) })

	req := httptest.NewRequest("GET", "/does-not-exist", nil)
	rec := httptest.NewRecorder()
	r.ServeHTTP(rec, req)

	if rec.Code != 404 {
		t.Fatalf("expected 404 for unmatched route, got %d", rec.Code)
	}

	// Give any (unexpected) async goroutine a brief window to fire before
	// asserting it did not.
	got := waitForCount(sampler.count, 1, 100*time.Millisecond)
	if got != 0 {
		t.Fatalf("expected 0 sampler calls for unmatched route, got %d", got)
	}
}
