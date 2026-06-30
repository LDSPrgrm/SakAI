package ws

import (
	"sync"
	"sync/atomic"

	"github.com/prometheus/client_golang/prometheus"
)

// Prometheus adapter for WebSocket delivery metrics (RFC v2 P8.1, §12.5).
//
// Lives alongside the in-memory wsMetrics rather than replacing it so test
// suites that read `metrics.EmittedCount(...)` keep working. Each Inc* on
// wsMetrics now also bumps the matching Prometheus counter/gauge through
// the package-level promMetrics singleton.
//
// Registration is opt-in via RegisterPrometheus(reg). Callers (e.g. the
// HTTP wiring layer) pass a registry; if nil, the global default is used.
// This keeps the package free of init-time registration side effects that
// would otherwise duplicate metrics in test binaries.

type promCollectors struct {
	connTotal              prometheus.Counter
	connActive             prometheus.Gauge
	eventsEmittedTotal     *prometheus.CounterVec
	eventsAckTotal         *prometheus.CounterVec
	eventsNackTotal        *prometheus.CounterVec
	replayRequestsTotal    prometheus.Counter
	fsmRejectionsTotal     *prometheus.CounterVec
	heartbeatMissesTotal   prometheus.Counter
	redisPublishErrors     prometheus.Counter
	sendBufferFullTotal    prometheus.Counter
	envelopeIDFallbacks    prometheus.Counter
}

// promMetrics is held in an atomic.Pointer so the hot-path reads in
// promInc* / Conn* / Replay* / Heartbeat* / Redis* / SendBuffer*
// stay lock-free while tests can swap the collectors in and out
// without racing pod goroutines still in flight (data race observed
// in CI between TestPrometheusEmitCounter resetting the pointer and
// Hub.Unregister's deferred ConnClosed() read from a chaos-test pod).
var (
	promOnce    sync.Once
	promMetrics atomic.Pointer[promCollectors]
)

// RegisterPrometheus registers the WebSocket metric collectors with the
// supplied registry. Pass nil to use prometheus.DefaultRegisterer.
//
// Safe to call multiple times — only the first call wires collectors.
// Subsequent calls are no-ops, which matches the package singleton model
// and avoids "duplicate metric" panics in long-running processes.
func RegisterPrometheus(reg prometheus.Registerer) {
	if reg == nil {
		reg = prometheus.DefaultRegisterer
	}
	promOnce.Do(func() {
		c := newPromCollectors()
		reg.MustRegister(
			c.connTotal,
			c.connActive,
			c.eventsEmittedTotal,
			c.eventsAckTotal,
			c.eventsNackTotal,
			c.replayRequestsTotal,
			c.fsmRejectionsTotal,
			c.heartbeatMissesTotal,
			c.redisPublishErrors,
			c.sendBufferFullTotal,
			c.envelopeIDFallbacks,
		)
		promMetrics.Store(c)
	})
}

func newPromCollectors() *promCollectors {
	return &promCollectors{
		connTotal: prometheus.NewCounter(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "conn_total",
			Help: "Total WebSocket connections established.",
		}),
		connActive: prometheus.NewGauge(prometheus.GaugeOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "conn_active",
			Help: "Currently open WebSocket connections.",
		}),
		eventsEmittedTotal: prometheus.NewCounterVec(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "events_emitted_total",
			Help: "WebSocket events written to a client connection, by event type.",
		}, []string{"event"}),
		eventsAckTotal: prometheus.NewCounterVec(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "events_ack_total",
			Help: "Client ACKs received for ack-required events.",
		}, []string{"event"}),
		eventsNackTotal: prometheus.NewCounterVec(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "events_nack_total",
			Help: "Events that exhausted retries without an ACK.",
		}, []string{"event"}),
		replayRequestsTotal: prometheus.NewCounter(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "replay_requests_total",
			Help: "replay.request frames handled by the WS handler.",
		}),
		fsmRejectionsTotal: prometheus.NewCounterVec(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "fsm_rejections_total",
			Help: "Envelopes rejected by the server FSM, by event type and reason.",
		}, []string{"event", "reason"}),
		heartbeatMissesTotal: prometheus.NewCounter(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "heartbeat_misses_total",
			Help: "Connections closed because their heartbeat watchdog fired.",
		}),
		redisPublishErrors: prometheus.NewCounter(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "redis_publish_errors_total",
			Help: "Redis publish/XADD failures observed by the dispatcher.",
		}),
		sendBufferFullTotal: prometheus.NewCounter(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "send_buffer_full_total",
			Help: "Client send buffer dropped frames because it was full.",
		}),
		envelopeIDFallbacks: prometheus.NewCounter(prometheus.CounterOpts{
			Namespace: "sakai", Subsystem: "ws", Name: "envelope_id_fallback_total",
			Help: "Envelopes that fell back to the legacy ID generation path.",
		}),
	}
}

// promInc* helpers are nil-safe so callers don't have to check whether
// RegisterPrometheus was invoked. Tests that don't register simply skip
// the Prometheus path while still exercising the in-memory counters.

func promIncEmitted(event EventType) {
	if p := promMetrics.Load(); p != nil {
		p.eventsEmittedTotal.WithLabelValues(string(event)).Inc()
	}
}

func promIncAck(event EventType) {
	if p := promMetrics.Load(); p != nil {
		p.eventsAckTotal.WithLabelValues(string(event)).Inc()
	}
}

func promIncNack(event EventType) {
	if p := promMetrics.Load(); p != nil {
		p.eventsNackTotal.WithLabelValues(string(event)).Inc()
	}
}

func promIncFSMRejection(event EventType, reason string) {
	if p := promMetrics.Load(); p != nil {
		p.fsmRejectionsTotal.WithLabelValues(string(event), reason).Inc()
	}
}

func promIncEnvelopeIDFallback() {
	if p := promMetrics.Load(); p != nil {
		p.envelopeIDFallbacks.Inc()
	}
}

// ConnOpened / ConnClosed are public so the Hub can record lifecycle events.
// They no-op when Prometheus isn't wired.
func ConnOpened() {
	if p := promMetrics.Load(); p != nil {
		p.connTotal.Inc()
		p.connActive.Inc()
	}
}

func ConnClosed() {
	if p := promMetrics.Load(); p != nil {
		p.connActive.Dec()
	}
}

// ReplayRequested is incremented from the WS handler when an inbound
// replay.request frame is dispatched to the replay store.
func ReplayRequested() {
	if p := promMetrics.Load(); p != nil {
		p.replayRequestsTotal.Inc()
	}
}

// HeartbeatMissed is incremented when the read-deadline watchdog fires.
func HeartbeatMissed() {
	if p := promMetrics.Load(); p != nil {
		p.heartbeatMissesTotal.Inc()
	}
}

// RedisPublishError is incremented from redis_dispatcher on a publish failure.
func RedisPublishError() {
	if p := promMetrics.Load(); p != nil {
		p.redisPublishErrors.Inc()
	}
}

// SendBufferFull is incremented when the per-client send queue drops a frame.
func SendBufferFull() {
	if p := promMetrics.Load(); p != nil {
		p.sendBufferFullTotal.Inc()
	}
}
