package ws

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func scrape(t *testing.T, url string) string {
	t.Helper()
	resp, err := http.Get(url)
	if err != nil {
		t.Fatalf("scrape %s: %v", url, err)
	}
	defer resp.Body.Close()
	b, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read scrape body: %v", err)
	}
	return string(b)
}

func TestPrometheusEmitCounter(t *testing.T) {
	reg := prometheus.NewRegistry()
	// Force a fresh collector set for this test by resetting the singleton
	// guard. Production code uses sync.Once so RegisterPrometheus is no-op
	// after the first call; tests need to bypass that. promMetrics is an
	// atomic.Pointer so the Store(nil) is safe against concurrent
	// Conn*/promInc* reads from goroutines leaked by other tests.
	promOnce = sync.Once{}
	promMetrics.Store(nil)
	RegisterPrometheus(reg)

	// Drive the in-memory counter — the Inc wires the Prometheus side too.
	metrics.IncEmitted(EventRideRequested)
	metrics.IncEmitted(EventRideRequested)

	srv := httptest.NewServer(promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
	defer srv.Close()

	body := scrape(t, srv.URL)
	if !strings.Contains(body, `sakai_ws_events_emitted_total{event="ride.requested"} 2`) {
		t.Fatalf("expected emitted counter to read 2 for ride.requested, got:\n%s", body)
	}
}

func TestPrometheusNotRegistered(t *testing.T) {
	// When RegisterPrometheus isn't called, the promInc* helpers should be
	// no-ops. We can't rebind the singleton mid-test cheaply, so simply
	// assert that nil-safety holds by invoking the helpers directly with
	// the singleton zeroed.
	saved := promMetrics.Load()
	promMetrics.Store(nil)
	defer promMetrics.Store(saved)

	// These should not panic.
	promIncEmitted(EventRideRequested)
	promIncAck(EventRideAccepted)
	promIncNack(EventRideCancelled)
	promIncFSMRejection(EventRideRequested, "test")
	promIncEnvelopeIDFallback()
	ConnOpened()
	ConnClosed()
	ReplayRequested()
	HeartbeatMissed()
	RedisPublishError()
	SendBufferFull()
}
