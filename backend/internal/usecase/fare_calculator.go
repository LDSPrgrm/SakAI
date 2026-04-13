package usecase

import (
	"math"
)

// FareBreakdown holds the detailed components of a ride fare.
type FareBreakdown struct {
	BaseFare        float64 `json:"base_fare"`
	DistanceCharge  float64 `json:"distance_charge"`
	TimeCharge      float64 `json:"time_charge"`
	BookingFee      float64 `json:"booking_fee"`
	SurgeMultiplier float64 `json:"surge_multiplier,omitempty"`
	CancellationFee float64 `json:"cancellation_fee,omitempty"`
}

// FareCalculator calculates estimated and actual ride fares.
type FareCalculator struct{}

// NewFareCalculator creates a new FareCalculator.
func NewFareCalculator() *FareCalculator {
	return &FareCalculator{}
}

// EstimateFare calculates estimated fare at request time.
// distanceKm and durationMin come from the route estimation service.
// rateConfig values come from fare_configs table (base_fare, per_km_rate, per_min_rate, booking_fee).
func (f *FareCalculator) EstimateFare(distanceKm, durationMin, baseFare, perKmRate, perMinRate, bookingFee float64) float64 {
	total := baseFare + (perKmRate * distanceKm) + (perMinRate * durationMin) + bookingFee
	return math.Round(total*100) / 100 // round to 2 decimal places
}

// CalculateActualFare calculates final fare at completion.
// Returns the total fare and a detailed breakdown.
func (f *FareCalculator) CalculateActualFare(distanceKm, durationMin, baseFare, perKmRate, perMinRate, bookingFee, surgeMultiplier, cancellationFee float64) (float64, FareBreakdown) {
	breakdown := FareBreakdown{
		BaseFare:        baseFare,
		DistanceCharge:  math.Round(perKmRate*distanceKm*100) / 100,
		TimeCharge:      math.Round(perMinRate*durationMin*100) / 100,
		BookingFee:      bookingFee,
		SurgeMultiplier: surgeMultiplier,
		CancellationFee: cancellationFee,
	}

	total := baseFare + breakdown.DistanceCharge + breakdown.TimeCharge + bookingFee
	if surgeMultiplier > 1.0 {
		total *= surgeMultiplier
	}
	total += cancellationFee

	return math.Round(total*100) / 100, breakdown
}
