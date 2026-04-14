// Package domain defines the core business entities and logic for the SakAI platform.
package domain

import "errors"

// Sentinel errors used across the use case layer.
// HTTP handlers map these to specific status codes and ErrorCode strings.
var (
	ErrNotFound               = errors.New("not found")
	ErrInvalidCredentials     = errors.New("invalid credentials")
	ErrEmailAlreadyRegistered = errors.New("email already registered")
	ErrTokenInvalid           = errors.New("token invalid")
	ErrRefreshTokenInvalid    = errors.New("refresh token invalid or expired")
	ErrPassengerHasActiveRide = errors.New("passenger already has an active ride")
	ErrDriverHasActiveRide    = errors.New("driver already has an active ride")
	ErrInvalidStateTransition = errors.New("invalid ride state transition")
	ErrNoDriversAvailable     = errors.New("no drivers available")
	ErrForbidden              = errors.New("forbidden")
	ErrCannotGoOffline        = errors.New("cannot go offline while ride is in progress")
	ErrIdempotencyConflict    = errors.New("idempotency key already used")
	// Document upload errors
	ErrInvalidDocumentType = errors.New("invalid document type")
	ErrFileTooLarge        = errors.New("file too large")
	ErrInvalidFileFormat   = errors.New("invalid file format")
	// Rating errors
	ErrInvalidRating    = errors.New("invalid rating")
	ErrFeedbackTooLong  = errors.New("feedback too long")
	ErrAlreadyRated     = errors.New("already rated")
	ErrRideNotCompleted = errors.New("ride not completed")
	// Payment errors
	ErrPaymentFailed        = errors.New("payment failed")
	ErrInvalidPaymentToken  = errors.New("invalid payment token")
	ErrDuplicatePayment     = errors.New("duplicate payment")
	// Tip errors
	ErrInvalidTipAmount    = errors.New("invalid tip amount")
	ErrTipAlreadyAdded     = errors.New("tip already added")
	// Payment method errors
	ErrPaymentMethodUnsupported = errors.New("unsupported payment method")
	ErrPaymentMethodDuplicate   = errors.New("duplicate payment method")
	ErrPaymentGatewayError      = errors.New("payment gateway error")
	ErrPaymentMethodNotFound    = errors.New("payment method not found")
	ErrPaymentMethodLastMethod  = errors.New("cannot remove last payment method")
	// Unpaid ride block
	ErrUnpaidRideBlocked        = errors.New("unpaid ride blocks new request")
	// Ride type errors
	ErrInvalidRideType = errors.New("invalid ride type: must be motorcycle, car, or tricycle")
	// Tip errors (additional)
	ErrTipExceedsLimit = errors.New("tip exceeds 50% of base fare")
	// Proximity validation errors
	ErrDriverTooFarFromPickup = errors.New("driver must be within 200 meters of pickup location")
)
