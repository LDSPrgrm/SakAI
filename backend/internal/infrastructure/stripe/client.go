// Package stripe provides a real Stripe Go SDK client implementation,
// replacing the previous stub client.
package stripe

import (
	"context"
	"fmt"
	"math"

	"github.com/sakai/backend/internal/domain"
	"github.com/stripe/stripe-go/v76"
	"github.com/stripe/stripe-go/v76/paymentintent"
)

// Client wraps the Stripe Go SDK for payment operations.
type Client struct {
	secretKey string
}

// New creates a new Stripe client.
func New(secretKey string) *Client {
	stripe.Key = secretKey
	return &Client{secretKey: secretKey}
}

// ChargePaymentMethod creates a PaymentIntent and confirms it against the given payment method.
func (c *Client) ChargePaymentMethod(ctx context.Context, paymentMethodID string, amount float64, currency string, idempotencyKey string) (*domain.StripeChargeResult, error) {
	// Stripe expects amounts in the smallest currency unit (cents for USD).
	amountInt := int64(math.Round(amount * 100))

	params := &stripe.PaymentIntentParams{
		Amount:             stripe.Int64(amountInt),
		Currency:           stripe.String(currency),
		PaymentMethod:      stripe.String(paymentMethodID),
		ConfirmationMethod: stripe.String(string(stripe.PaymentIntentConfirmationMethodAutomatic)),
		Confirm:            stripe.Bool(true),
		Params: stripe.Params{
			IdempotencyKey: stripe.String(idempotencyKey),
		},
	}

	pi, err := paymentintent.New(params)
	if err != nil {
		// Stripe errors are returned as *stripe.Error
		if se, ok := err.(*stripe.Error); ok {
			return &domain.StripeChargeResult{
				Success:       false,
				FailureReason: formatStripeError(se),
			}, nil
		}
		return &domain.StripeChargeResult{
			Success:       false,
			FailureReason: fmt.Sprintf("payment failed: %v", err),
		}, nil
	}

	if pi.Status == stripe.PaymentIntentStatusSucceeded {
		return &domain.StripeChargeResult{
			Success:  true,
			ChargeID: pi.LatestCharge.ID,
		}, nil
	}

	return &domain.StripeChargeResult{
		Success:       false,
		FailureReason: fmt.Sprintf("payment intent status: %s", pi.Status),
	}, nil
}

// formatStripeError converts a Stripe error into a user-friendly message.
func formatStripeError(e *stripe.Error) string {
	if e.Msg != "" {
		return e.Msg
	}
	if e.Type != "" {
		return fmt.Sprintf("stripe error: %s", e.Type)
	}
	return "payment processing error"
}
