// Package expiry implements a background worker that expires ride offers that
// have been in the "requested" state for too long without being accepted or
// declined by the assigned driver.
//
// This closes the gap where a driver goes silent after being dispatched,
// causing the ride to hang forever in the "requested" state.
package expiry

import (
	"context"
	"log"
	"time"

	"github.com/sakai/backend/internal/domain"
)

const (
	// OfferTimeout is how long a ride may stay in "requested" before it is
	// automatically cancelled. Tune via OFFER_TIMEOUT_SECONDS env var if needed.
	OfferTimeout = 5 * time.Minute

	// tickInterval controls how often the worker scans for expired offers.
	// Set to half the timeout so no ride waits more than 1.5× the timeout.
	tickInterval = 2*time.Minute + 30*time.Second
)

// Worker scans for rides that have been in "requested" status for longer than
// OfferTimeout and cancels them, freeing the passenger to re-request.
type Worker struct {
	rideRepo domain.RideRepository
}

// New creates a new expiry Worker.
func New(rideRepo domain.RideRepository) *Worker {
	return &Worker{rideRepo: rideRepo}
}

// Run starts the expiry loop. It blocks until ctx is cancelled (e.g. on
// graceful shutdown). Call it in a goroutine.
func (w *Worker) Run(ctx context.Context) {
	ticker := time.NewTicker(tickInterval)
	defer ticker.Stop()

	log.Printf("offer-expiry: worker started (timeout=%s, tick=%s)", OfferTimeout, tickInterval)

	for {
		select {
		case <-ctx.Done():
			log.Println("offer-expiry: worker stopped")
			return
		case <-ticker.C:
			if err := w.expire(ctx); err != nil {
				// Non-fatal: log and continue. A transient DB error should not
				// crash the process; the next tick will retry.
				log.Printf("offer-expiry: %v", err)
			}
		}
	}
}

// expire cancels all rides that have been in "requested" status for longer
// than OfferTimeout.
func (w *Worker) expire(ctx context.Context) error {
	n, err := w.rideRepo.CancelExpiredOffers(ctx, OfferTimeout)
	if err != nil {
		return err
	}
	if n > 0 {
		log.Printf("offer-expiry: cancelled %d expired offer(s)", n)
	}
	return nil
}

// Compile-time assertion: domain.CancelledBySystem must exist.
var _ = domain.CancelledBySystem
