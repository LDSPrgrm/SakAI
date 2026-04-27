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
	{domain.ErrUnpaidRideBlocked, http.StatusForbidden, "UNPAID_RIDE_BLOCKED"},
	{domain.ErrInvalidRideType, http.StatusBadRequest, "INVALID_RIDE_TYPE"},
	// Document errors
	{domain.ErrInvalidDocumentType, http.StatusBadRequest, "INVALID_DOCUMENT_TYPE"},
	{domain.ErrFileTooLarge, http.StatusRequestEntityTooLarge, "FILE_TOO_LARGE"},
	{domain.ErrInvalidFileFormat, http.StatusUnprocessableEntity, "INVALID_FILE_FORMAT"},
	// Rating errors
	{domain.ErrInvalidRating, http.StatusBadRequest, "INVALID_RATING"},
	{domain.ErrFeedbackTooLong, http.StatusBadRequest, "FEEDBACK_TOO_LONG"},
	{domain.ErrAlreadyRated, http.StatusConflict, "ALREADY_RATED"},
	{domain.ErrRideNotCompleted, http.StatusUnprocessableEntity, "RIDE_NOT_COMPLETED"},
	// Payment errors
	{domain.ErrPaymentFailed, http.StatusPaymentRequired, "PAYMENT_FAILED"},
	{domain.ErrInvalidPaymentToken, http.StatusBadRequest, "INVALID_PAYMENT_TOKEN"},
	{domain.ErrDuplicatePayment, http.StatusConflict, "DUPLICATE_PAYMENT"},
	{domain.ErrIdempotencyConflict, http.StatusConflict, "DUPLICATE_PAYMENT"},
	// Tip errors
	{domain.ErrInvalidTipAmount, http.StatusBadRequest, "INVALID_TIP_AMOUNT"},
	{domain.ErrTipAlreadyAdded, http.StatusConflict, "TIP_ALREADY_ADDED"},
	{domain.ErrTipExceedsLimit, http.StatusBadRequest, "TIP_EXCEEDS_LIMIT"},
	// Payment method errors
	{domain.ErrPaymentMethodUnsupported, http.StatusBadRequest, "PAYMENT_METHOD_UNSUPPORTED"},
	{domain.ErrPaymentMethodDuplicate, http.StatusConflict, "PAYMENT_METHOD_DUPLICATE"},
	{domain.ErrPaymentGatewayError, http.StatusBadGateway, "PAYMENT_GATEWAY_ERROR"},
	{domain.ErrPaymentMethodNotFound, http.StatusNotFound, "PAYMENT_METHOD_NOT_FOUND"},
	{domain.ErrPaymentMethodLastMethod, http.StatusConflict, "PAYMENT_METHOD_LAST_METHOD"},
	// Proximity validation errors
	{domain.ErrDriverTooFarFromPickup, http.StatusConflict, "DRIVER_TOO_FAR"},
	{domain.ErrDriverTooFarFromDestination, http.StatusConflict, "DRIVER_TOO_FAR_FROM_DESTINATION"},
	{domain.ErrPromotionExpired, http.StatusUnprocessableEntity, "PROMOTION_EXPIRED"},
	{domain.ErrPromotionMinAmountNotMet, http.StatusBadRequest, "PROMOTION_MIN_AMOUNT_NOT_MET"},
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

// contextUserRole extracts the authenticated user role set by the auth middleware.
func contextUserRole(c *gin.Context) domain.UserRole {
	return domain.UserRole(c.MustGet("role").(string))
}
