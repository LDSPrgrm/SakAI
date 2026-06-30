package ws

import (
	"testing"
)

func TestMetrics_IncEmitted_TracksPerEvent(t *testing.T) {
	m := newMetrics()
	m.IncEmitted(EventRideRequested)
	m.IncEmitted(EventRideRequested)
	m.IncEmitted(EventRideAccepted)

	if got := m.EmittedCount(EventRideRequested); got != 2 {
		t.Errorf("ride.requested emitted count = %d, want 2", got)
	}
	if got := m.EmittedCount(EventRideAccepted); got != 1 {
		t.Errorf("ride.accepted emitted count = %d, want 1", got)
	}
	if got := m.EmittedCount(EventRideCancelled); got != 0 {
		t.Errorf("ride.cancelled emitted count = %d, want 0", got)
	}
}

func TestMetrics_IncInvalid_TracksPerEventAndReason(t *testing.T) {
	m := newMetrics()
	m.IncInvalid(EventRideRequested, "missing_field")
	m.IncInvalid(EventRideRequested, "missing_field")
	m.IncInvalid(EventRideRequested, "wrong_type")

	if got := m.InvalidCount(EventRideRequested, "missing_field"); got != 2 {
		t.Errorf("missing_field count = %d, want 2", got)
	}
	if got := m.InvalidCount(EventRideRequested, "wrong_type"); got != 1 {
		t.Errorf("wrong_type count = %d, want 1", got)
	}
}

func TestMetrics_IncEnvelopeIDFallback(t *testing.T) {
	m := newMetrics()
	m.IncEnvelopeIDFallback()
	m.IncEnvelopeIDFallback()
	if got := m.EnvelopeIDFallbackCount(); got != 2 {
		t.Errorf("fallback count = %d, want 2", got)
	}
}

func TestMetrics_ConcurrentSafe(t *testing.T) {
	m := newMetrics()
	const n = 1000
	done := make(chan struct{})
	for i := 0; i < n; i++ {
		go func() {
			m.IncEmitted(EventDriverLocationUpdated)
			done <- struct{}{}
		}()
	}
	for i := 0; i < n; i++ {
		<-done
	}
	if got := m.EmittedCount(EventDriverLocationUpdated); got != n {
		t.Errorf("emitted count = %d, want %d", got, n)
	}
}
