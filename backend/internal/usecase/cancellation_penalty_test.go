package usecase_test

import (
	"testing"

	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/usecase"
)

func TestCalculatePenalty(t *testing.T) {
	fare := func(v float64) *float64 { return &v }

	cases := []struct {
		name       string
		in         usecase.CancellationPenaltyInput
		wantFee    float64
		wantRefund float64
	}{
		{
			name:       "no ride returns zero",
			in:         usecase.CancellationPenaltyInput{Ride: nil},
			wantFee:    0,
			wantRefund: 0,
		},
		{
			name: "ride without estimated fare returns zero",
			in: usecase.CancellationPenaltyInput{Ride: &domain.Ride{
				RideType: domain.RideTypeCar,
			}},
			wantFee:    0,
			wantRefund: 0,
		},
		{
			name: "ride without type returns zero",
			in: usecase.CancellationPenaltyInput{Ride: &domain.Ride{
				EstimatedFare: fare(150),
			}},
			wantFee:    0,
			wantRefund: 0,
		},
		{
			name: "10% above floor",
			in: usecase.CancellationPenaltyInput{Ride: &domain.Ride{
				RideType:      domain.RideTypeCar,
				EstimatedFare: fare(500),
			}, Actor: domain.CancelledByPassenger},
			wantFee: 50,
		},
		{
			name: "10% below floor → floor wins",
			in: usecase.CancellationPenaltyInput{Ride: &domain.Ride{
				RideType:      domain.RideTypeCar,
				EstimatedFare: fare(150),
			}, Actor: domain.CancelledByPassenger},
			wantFee: 20,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := usecase.CalculatePenalty(tc.in)
			if got.Fee != tc.wantFee {
				t.Errorf("Fee = %v, want %v", got.Fee, tc.wantFee)
			}
			if got.Refund != tc.wantRefund {
				t.Errorf("Refund = %v, want %v", got.Refund, tc.wantRefund)
			}
		})
	}
}
