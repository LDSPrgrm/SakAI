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
)
