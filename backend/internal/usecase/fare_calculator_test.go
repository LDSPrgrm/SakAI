package usecase_test

import (
	"testing"

	"github.com/sakai/backend/internal/usecase"
)

func TestFareCalculator_EstimateFare_Basic(t *testing.T) {
	calc := usecase.NewFareCalculator()

	// 5 km, 15 min, base=50, perKm=10, perMin=2, booking=5
	fare := calc.EstimateFare(5.0, 15.0, 50.0, 10.0, 2.0, 5.0)
	// Expected: 50 + (10*5) + (2*15) + 5 = 50 + 50 + 30 + 5 = 135.00
	expected := 135.00
	if fare != expected {
		t.Errorf("expected fare %.2f, got %.2f", expected, fare)
	}
}

func TestFareCalculator_EstimateFare_ZeroDistance(t *testing.T) {
	calc := usecase.NewFareCalculator()

	// 0 km, 5 min, base=50, perKm=10, perMin=2, booking=5
	fare := calc.EstimateFare(0.0, 5.0, 50.0, 10.0, 2.0, 5.0)
	// Expected: 50 + 0 + (2*5) + 5 = 50 + 0 + 10 + 5 = 65.00
	expected := 65.00
	if fare != expected {
		t.Errorf("expected fare %.2f, got %.2f", expected, fare)
	}
}

func TestFareCalculator_CalculateActualFare_SurgePricing(t *testing.T) {
	calc := usecase.NewFareCalculator()

	// 10 km, 30 min, base=50, perKm=10, perMin=2, booking=5, surge=1.5, no cancellation
	total, breakdown := calc.CalculateActualFare(10.0, 30.0, 50.0, 10.0, 2.0, 5.0, 1.5, 0.0)

	// Breakdown: base=50, distance=100, time=60, booking=5
	if breakdown.BaseFare != 50.0 {
		t.Errorf("expected base fare 50.0, got %.2f", breakdown.BaseFare)
	}
	if breakdown.DistanceCharge != 100.0 {
		t.Errorf("expected distance charge 100.0, got %.2f", breakdown.DistanceCharge)
	}
	if breakdown.TimeCharge != 60.0 {
		t.Errorf("expected time charge 60.0, got %.2f", breakdown.TimeCharge)
	}
	if breakdown.BookingFee != 5.0 {
		t.Errorf("expected booking fee 5.0, got %.2f", breakdown.BookingFee)
	}
	if breakdown.SurgeMultiplier != 1.5 {
		t.Errorf("expected surge multiplier 1.5, got %.2f", breakdown.SurgeMultiplier)
	}

	// Total before surge: 50 + 100 + 60 + 5 = 215
	// After surge (1.5x): 215 * 1.5 = 322.50
	expected := 322.50
	if total != expected {
		t.Errorf("expected total fare %.2f, got %.2f", expected, total)
	}
}

func TestFareCalculator_CalculateActualFare_CancellationFee(t *testing.T) {
	calc := usecase.NewFareCalculator()

	// 3 km, 10 min, base=50, perKm=10, perMin=2, booking=5, no surge, cancellation=25
	total, breakdown := calc.CalculateActualFare(3.0, 10.0, 50.0, 10.0, 2.0, 5.0, 1.0, 25.0)

	if breakdown.CancellationFee != 25.0 {
		t.Errorf("expected cancellation fee 25.0, got %.2f", breakdown.CancellationFee)
	}

	// Total: 50 + 30 + 20 + 5 = 105 (no surge since multiplier is 1.0) + 25 cancellation = 130.00
	expected := 130.00
	if total != expected {
		t.Errorf("expected total fare %.2f, got %.2f", expected, total)
	}
}

func TestFareCalculator_EstimateFare_Rounding(t *testing.T) {
	calc := usecase.NewFareCalculator()

	// Test that rounding to 2 decimal places works correctly
	fare := calc.EstimateFare(3.33, 7.77, 50.0, 10.0, 2.0, 5.0)
	// 50 + 33.3 + 15.54 + 5 = 103.84
	expected := 103.84
	if fare != expected {
		t.Errorf("expected fare %.2f, got %.2f", expected, fare)
	}
}

func TestFareCalculator_CalculateActualFare_NoSurge(t *testing.T) {
	calc := usecase.NewFareCalculator()

	// When surge multiplier is 1.0 or less, no surge should be applied
	total, breakdown := calc.CalculateActualFare(5.0, 10.0, 50.0, 10.0, 2.0, 5.0, 1.0, 0.0)

	// 50 + 50 + 20 + 5 = 125.00
	expected := 125.00
	if total != expected {
		t.Errorf("expected total fare %.2f, got %.2f", expected, total)
	}
	if breakdown.SurgeMultiplier != 1.0 {
		t.Errorf("expected surge multiplier 1.0, got %.2f", breakdown.SurgeMultiplier)
	}
}
