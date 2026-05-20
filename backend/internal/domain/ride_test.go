package domain

import "testing"

// allRideStatuses is the canonical set of states used to assert exhaustive
// coverage of the FSM: every state must appear in validTransitions as a key
// so undefined-states panic in development.
var allRideStatuses = []RideStatus{
	RideStatusCreated,
	RideStatusRequested,
	RideStatusAccepted,
	RideStatusArrived,
	RideStatusInProgress,
	RideStatusPaymentPending,
	RideStatusCompleted,
	RideStatusCancelled,
}

func TestValidTransitions_AllStatesPresent(t *testing.T) {
	for _, s := range allRideStatuses {
		if _, ok := validTransitions[s]; !ok {
			t.Errorf("validTransitions missing key %q", s)
		}
	}
}

func TestCanTransitionTo_HappyPath(t *testing.T) {
	cases := []struct {
		from, to RideStatus
		ok       bool
	}{
		// Lifecycle: created → requested → accepted → arrived → in_progress → completed
		{RideStatusCreated, RideStatusRequested, true},
		{RideStatusRequested, RideStatusAccepted, true},
		{RideStatusAccepted, RideStatusArrived, true},
		{RideStatusArrived, RideStatusInProgress, true},
		{RideStatusInProgress, RideStatusCompleted, true},

		// New: in_progress → payment_pending → completed
		{RideStatusInProgress, RideStatusPaymentPending, true},
		{RideStatusPaymentPending, RideStatusCompleted, true},
		{RideStatusPaymentPending, RideStatusCancelled, true},

		// Cancellation paths
		{RideStatusCreated, RideStatusCancelled, true},
		{RideStatusRequested, RideStatusCancelled, true},
		{RideStatusAccepted, RideStatusCancelled, true},
		{RideStatusArrived, RideStatusCancelled, true},

		// Invalid jumps
		{RideStatusCreated, RideStatusAccepted, false},
		{RideStatusCreated, RideStatusArrived, false},
		{RideStatusCreated, RideStatusCompleted, false},
		{RideStatusRequested, RideStatusArrived, false},
		{RideStatusRequested, RideStatusInProgress, false},
		{RideStatusAccepted, RideStatusInProgress, false},
		{RideStatusAccepted, RideStatusCompleted, false},
		{RideStatusArrived, RideStatusCompleted, false},
		{RideStatusInProgress, RideStatusCancelled, false}, // cannot cancel after ride started; only via payment_pending or finished
		{RideStatusInProgress, RideStatusArrived, false},
		{RideStatusPaymentPending, RideStatusArrived, false},

		// Terminal states never advance
		{RideStatusCompleted, RideStatusCancelled, false},
		{RideStatusCompleted, RideStatusInProgress, false},
		{RideStatusCancelled, RideStatusRequested, false},
		{RideStatusCancelled, RideStatusCompleted, false},
	}
	for _, tc := range cases {
		got := tc.from.CanTransitionTo(tc.to)
		if got != tc.ok {
			t.Errorf("%s → %s: got %v, want %v", tc.from, tc.to, got, tc.ok)
		}
	}
}

func TestIsTerminal(t *testing.T) {
	for _, s := range allRideStatuses {
		want := s == RideStatusCompleted || s == RideStatusCancelled
		if got := s.IsTerminal(); got != want {
			t.Errorf("IsTerminal(%s) = %v, want %v", s, got, want)
		}
	}
}

// TestNoTransitionsToCreated guarantees `created` is only ever an entry
// point. Allowing transitions BACK into created would corrupt the ride
// lifecycle invariants (e.g. a driver assignment to a ride that hasn't
// been dispatched yet).
func TestNoTransitionsToCreated(t *testing.T) {
	for _, s := range allRideStatuses {
		if validTransitions[s][RideStatusCreated] {
			t.Errorf("state %s should not allow transition into RideStatusCreated", s)
		}
	}
}

// TestPaymentPendingReachable codifies that payment_pending is reachable
// from in_progress but not from any other state — gateway settlement is a
// post-trip concern.
func TestPaymentPendingReachable(t *testing.T) {
	for _, s := range allRideStatuses {
		allows := validTransitions[s][RideStatusPaymentPending]
		want := s == RideStatusInProgress
		if allows != want {
			t.Errorf("PaymentPending reachable from %s = %v, want %v", s, allows, want)
		}
	}
}
