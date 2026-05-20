package ws

import (
	"sync"

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

var (
	promOnce    sync.Once
	promMetrics *promCollectors
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
		promMetrics = newPromCollectors()
		reg.MustRegister(
			promMetrics.connTotal,
			promMetrics.connActive,
			promMetrics.eventsEmittedTotal,
			promMetrics.eventsAckTotal,
			promMetrics.eventsNackTotal,
			promMetrics.replayRequestsTotal,
			promMetrics.fsmRejectionsTotal,
			promMetrics.heartbeatMissesTotal,
			promMetrics.redisPublishErrors,
			promMetrics.sendBufferFullTotal,
			promMetrics.envelopeIDFallbacks,
		)
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
	if promMetrics != nil {
		promMetrics.eventsEmittedTotal.WithLabelValues(string(event)).Inc()
	}
}

func promIncAck(event EventType) {
	if promMetrics != nil {
		promMetrics.eventsAckTotal.WithLabelValues(string(event)).Inc()
	}
}

func promIncNack(event EventType) {
	if promMetrics != nil {
		promMetrics.eventsNackTotal.WithLabelValues(string(event)).Inc()
	}
}

func promIncFSMRejection(event EventType, reason string) {
	if promMetrics != nil {
		promMetrics.fsmRejectionsTotal.WithLabelValues(string(event), reason).Inc()
	}
}

func promIncEnvelopeIDFallback() {
	if promMetrics != nil {
		promMetrics.envelopeIDFallbacks.Inc()
	}
}

// ConnOpened / ConnClosed are public so the Hub can record lifecycle events.
// They no-op when Prometheus isn't wired.
func ConnOpened() {
	if promMetrics != nil {
		promMetrics.connTotal.Inc()
		promMetrics.connActive.Inc()
	}
}

func ConnClosed() {
	if promMetrics != nil {
		promMetrics.connActive.Dec()
	}
}

// ReplayRequested is incremented from the WS handler when an inbound
// replay.request frame is dispatched to the replay store.
func ReplayRequested() {
	if promMetrics != nil {
		promMetrics.replayRequestsTotal.Inc()
	}
}

// HeartbeatMissed is incremented when the read-deadline watchdog fires.
func HeartbeatMissed() {
	if promMetrics != nil {
		promMetrics.heartbeatMissesTotal.Inc()
	}
}

// RedisPublishError is incremented from redis_dispatcher on a publish failure.
func RedisPublishError() {
	if promMetrics != nil {
		promMetrics.redisPublishErrors.Inc()
	}
}

// SendBufferFull is incremented when the per-client send queue drops a frame.
func SendBufferFull() {
	if promMetrics != nil {
		promMetrics.sendBufferFullTotal.Inc()
	}
}
