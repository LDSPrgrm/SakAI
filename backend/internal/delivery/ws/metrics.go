package ws

import "sync"

// wsMetrics holds in-process counters for the WebSocket emit path.
//
// We avoid a hard dependency on prometheus/client_golang in this package —
// when the rest of the backend wires Prometheus, expose Get*Count() through
// a thin adapter at the wiring layer.
type wsMetrics struct {
	mu              sync.RWMutex
	emitted         map[EventType]int64
	invalid         map[EventType]map[string]int64
	envelopeIDFback int64
}

// metrics is the package-level singleton. Tests use newMetrics() for isolation.
var metrics = newMetrics()

func newMetrics() *wsMetrics {
	return &wsMetrics{
		emitted: make(map[EventType]int64),
		invalid: make(map[EventType]map[string]int64),
	}
}

func (m *wsMetrics) IncEmitted(event EventType) {
	m.mu.Lock()
	m.emitted[event]++
	m.mu.Unlock()
}

func (m *wsMetrics) IncInvalid(event EventType, reason string) {
	m.mu.Lock()
	if _, ok := m.invalid[event]; !ok {
		m.invalid[event] = make(map[string]int64)
	}
	m.invalid[event][reason]++
	m.mu.Unlock()
}

func (m *wsMetrics) IncEnvelopeIDFallback() {
	m.mu.Lock()
	m.envelopeIDFback++
	m.mu.Unlock()
}

func (m *wsMetrics) EmittedCount(event EventType) int64 {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.emitted[event]
}

func (m *wsMetrics) InvalidCount(event EventType, reason string) int64 {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if rs, ok := m.invalid[event]; ok {
		return rs[reason]
	}
	return 0
}

func (m *wsMetrics) EnvelopeIDFallbackCount() int64 {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.envelopeIDFback
}

// MetricsSnapshot is the exported read-only view for /healthz or future
// Prometheus adapters. Returns deep-copied maps so callers can iterate safely.
type MetricsSnapshot struct {
	Emitted             map[EventType]int64
	Invalid             map[EventType]map[string]int64
	EnvelopeIDFallbacks int64
}

func Metrics() MetricsSnapshot {
	metrics.mu.RLock()
	defer metrics.mu.RUnlock()
	em := make(map[EventType]int64, len(metrics.emitted))
	for k, v := range metrics.emitted {
		em[k] = v
	}
	inv := make(map[EventType]map[string]int64, len(metrics.invalid))
	for k, sub := range metrics.invalid {
		c := make(map[string]int64, len(sub))
		for r, n := range sub {
			c[r] = n
		}
		inv[k] = c
	}
	return MetricsSnapshot{
		Emitted:             em,
		Invalid:             inv,
		EnvelopeIDFallbacks: metrics.envelopeIDFback,
	}
}
