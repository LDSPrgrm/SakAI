package ws

import (
	"sync"
	"time"

	"github.com/google/uuid"
)

// DefaultAckRetrySchedule is the exponential backoff used by [AckTracker]
// when retransmitting envelopes that have not been ACK'd by the client.
// After the last entry elapses without an ACK, the envelope is dropped and
// the delivery-failed metric increments.
var DefaultAckRetrySchedule = []time.Duration{
	500 * time.Millisecond,
	time.Second,
	2 * time.Second,
	4 * time.Second,
}

// AckTracker holds envelopes that need a client-side ACK and retries
// delivery on a backoff schedule until the client confirms or the budget
// is exhausted. Goroutine-safe.
//
// Lifecycle:
//
//	hub.SendToUser → writePump enqueues envelope → tracker.Track
//	client receives → applies → sends {type:"ack", event_id}
//	handler.handleInbound → tracker.Ack(event_id) → cancels retry timer
//
// On retry, the same envelope is handed back to [Hub.sendEnvelope]; the
// client may receive duplicates, which is fine because consumers dedupe on
// event_id. At-least-once on the wire, exactly-once in effect — RFC §3.
type AckTracker struct {
	mu       sync.Mutex
	pending  map[string]*pendingAck
	hub      *Hub
	schedule []time.Duration
}

type pendingAck struct {
	userID  uuid.UUID
	env     Envelope
	attempt int
	timer   *time.Timer
}

// NewAckTracker builds a tracker with [DefaultAckRetrySchedule]. Use
// [NewAckTrackerWithSchedule] for tests that want faster timing.
func NewAckTracker(hub *Hub) *AckTracker {
	return NewAckTrackerWithSchedule(hub, DefaultAckRetrySchedule)
}

// NewAckTrackerWithSchedule builds a tracker with a custom retry sequence.
// The schedule must be non-empty; the tracker emits one re-send per entry.
func NewAckTrackerWithSchedule(hub *Hub, schedule []time.Duration) *AckTracker {
	if len(schedule) == 0 {
		schedule = DefaultAckRetrySchedule
	}
	cp := make([]time.Duration, len(schedule))
	copy(cp, schedule)
	return &AckTracker{
		pending:  map[string]*pendingAck{},
		hub:      hub,
		schedule: cp,
	}
}

// Track registers env as awaiting ACK from userID. Calling Track twice for
// the same event_id is a no-op so retried sends don't double-arm the timer.
func (t *AckTracker) Track(userID uuid.UUID, env Envelope) {
	key := env.EventID.String()
	t.mu.Lock()
	if _, exists := t.pending[key]; exists {
		t.mu.Unlock()
		return
	}
	p := &pendingAck{userID: userID, env: env, attempt: 0}
	t.pending[key] = p
	t.mu.Unlock()
	metrics.IncAckTracked(env.Event)
	t.armNext(key)
}

// Ack drops the pending entry for eventID. Idempotent — repeated ACKs are
// no-ops, which is desirable because the client may re-ACK if it doesn't
// observe the server stop re-sending.
func (t *AckTracker) Ack(eventID string) {
	t.mu.Lock()
	p, ok := t.pending[eventID]
	if !ok {
		t.mu.Unlock()
		return
	}
	if p.timer != nil {
		p.timer.Stop()
	}
	event := p.env.Event
	delete(t.pending, eventID)
	t.mu.Unlock()
	metrics.IncAckAcked(event)
}

// Pending returns the number of envelopes awaiting ACK across all users.
// Exposed for tests and a future Prometheus gauge.
func (t *AckTracker) Pending() int {
	t.mu.Lock()
	defer t.mu.Unlock()
	return len(t.pending)
}

func (t *AckTracker) armNext(key string) {
	t.mu.Lock()
	p, ok := t.pending[key]
	if !ok {
		t.mu.Unlock()
		return
	}
	if p.attempt >= len(t.schedule) {
		event := p.env.Event
		delete(t.pending, key)
		t.mu.Unlock()
		metrics.IncAckFailed(event)
		return
	}
	delay := t.schedule[p.attempt]
	p.attempt++
	p.timer = time.AfterFunc(delay, func() { t.fire(key) })
	t.mu.Unlock()
}

func (t *AckTracker) fire(key string) {
	t.mu.Lock()
	p, ok := t.pending[key]
	if !ok {
		t.mu.Unlock()
		return
	}
	userID := p.userID
	env := p.env
	t.mu.Unlock()
	if t.hub != nil {
		t.hub.sendEnvelope(userID, env)
	}
	metrics.IncAckRetried(env.Event)
	t.armNext(key)
}

// Close cancels all pending timers. Used at server shutdown to release
// AfterFunc goroutines deterministically.
func (t *AckTracker) Close() {
	t.mu.Lock()
	defer t.mu.Unlock()
	for k, p := range t.pending {
		if p.timer != nil {
			p.timer.Stop()
		}
		delete(t.pending, k)
	}
}
