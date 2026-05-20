package usecase

import "github.com/sakai/backend/internal/domain"

// Penalty represents the monetary outcome of a cancellation: a fee charged
// to the cancelling actor and any refund owed back. RFC v2 §8.
//
// Both values are PHP. Zero is meaningful (= "no charge / no refund"); nil
// values are unused — callers compare against zero, not nil.
type Penalty struct {
	Fee    float64
	Refund float64
}

// CancellationPenaltyInput carries the ride context needed to compute a
// cancellation penalty. The struct keeps the call site stable when product
// confirms a richer schedule (per-ride-type, per-actor, elapsed-time tiers).
type CancellationPenaltyInput struct {
	Ride          *domain.Ride
	Actor         domain.CancelledBy
	ElapsedSecond int64 // seconds since accept; 0 if pre-accept
}

// CalculatePenalty returns the cancellation fee and refund for a ride.
//
// CURRENT SCHEDULE (placeholder, awaiting product confirmation — RFC v2 §8
// commit 8cd35fd context): 10% of EstimatedFare with a ₱20 minimum. No refund
// component yet. Pre-accept cancellations and rides without an estimated fare
// incur no fee. Actor and ElapsedSecond are unused today but threaded through
// so the call site stays stable when product wires the real tiered schedule.
//
// DO NOT EXPAND THIS LOGIC IN A FIX OR REFACTOR. The numbers are owned by
// product/ops; touching them changes a business rule.
func CalculatePenalty(in CancellationPenaltyInput) Penalty {
	if in.Ride == nil || in.Ride.EstimatedFare == nil || *in.Ride.EstimatedFare <= 0 {
		return Penalty{}
	}
	if in.Ride.RideType == "" {
		return Penalty{}
	}
	const (
		feeRatio = 0.10
		feeFloor = 20.0
	)
	fee := *in.Ride.EstimatedFare * feeRatio
	if fee < feeFloor {
		fee = feeFloor
	}
	return Penalty{Fee: fee}
}
