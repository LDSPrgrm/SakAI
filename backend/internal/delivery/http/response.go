// Package handler provides the HTTP delivery layer for the SakAI API.
package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sakai/backend/internal/domain"
)

// errorCodeMap maps domain sentinel errors to HTTP status + API error codes.
var errorCodeMap = []struct {
	err  error
	code int
	key  string
}{
	{domain.ErrNotFound, http.StatusNotFound, "NOT_FOUND"},
	{domain.ErrInvalidCredentials, http.StatusUnauthorized, "INVALID_CREDENTIALS"},
	{domain.ErrEmailAlreadyRegistered, http.StatusConflict, "EMAIL_ALREADY_REGISTERED"},
	{domain.ErrTokenInvalid, http.StatusUnauthorized, "TOKEN_INVALID"},
	{domain.ErrRefreshTokenInvalid, http.StatusUnauthorized, "REFRESH_TOKEN_INVALID"},
	{domain.ErrPassengerHasActiveRide, http.StatusConflict, "PASSENGER_HAS_ACTIVE_RIDE"},
	{domain.ErrDriverHasActiveRide, http.StatusConflict, "DRIVER_HAS_ACTIVE_RIDE"},
	{domain.ErrInvalidStateTransition, http.StatusConflict, "RIDE_INVALID_STATE_TRANSITION"},
	{domain.ErrNoDriversAvailable, http.StatusServiceUnavailable, "NO_DRIVERS_AVAILABLE"},
	{domain.ErrForbidden, http.StatusForbidden, "FORBIDDEN"},
	{domain.ErrCannotGoOffline, http.StatusConflict, "DRIVER_HAS_ACTIVE_RIDE"},
}

// respondError writes a structured error response mapped from the domain error.
func respondError(c *gin.Context, err error) {
	for _, m := range errorCodeMap {
		if errors.Is(err, m.err) {
			c.JSON(m.code, gin.H{"code": m.key, "message": err.Error()})
			return
		}
	}
	c.JSON(http.StatusInternalServerError, gin.H{"code": "INTERNAL_SERVER_ERROR", "message": "an unexpected error occurred"})
}

// respondOK writes a 200 JSON response.
func respondOK(c *gin.Context, data any) {
	c.JSON(http.StatusOK, data)
}

// respondCreated writes a 201 JSON response.
func respondCreated(c *gin.Context, data any) {
	c.JSON(http.StatusCreated, data)
}

// contextUserID extracts the authenticated user ID set by the auth middleware.
func contextUserID(c *gin.Context) any { return c.MustGet("userID") }

// contextUserRole extracts the authenticated user role set by the auth middleware.
func contextUserRole(c *gin.Context) domain.UserRole {
	return domain.UserRole(c.MustGet("role").(string))
}
