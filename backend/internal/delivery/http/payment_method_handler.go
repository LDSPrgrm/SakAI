package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/usecase"
)

// PaymentMethodHandler handles /users/me/payment-methods/* routes.
type PaymentMethodHandler struct {
	uc usecase.PaymentMethodUseCase
}

// NewPaymentMethodHandler creates a new handler for payment method management.
func NewPaymentMethodHandler(uc usecase.PaymentMethodUseCase) *PaymentMethodHandler {
	return &PaymentMethodHandler{uc: uc}
}

// ListMethods handles GET /users/me/payment-methods
func (h *PaymentMethodHandler) ListMethods(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)

	methods, err := h.uc.ListMethods(c.Request.Context(), userID)
	if err != nil {
		respondError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": methods})
}

// AddMethod handles POST /users/me/payment-methods
func (h *PaymentMethodHandler) AddMethod(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)

	var req struct {
		Type         domain.SavedPaymentMethodType `json:"type" binding:"required"`
		CardToken    *string                       `json:"card_token"`
		Provider     *string                       `json:"provider"`
		AccountID    *string                       `json:"account_id"`
		SetAsDefault bool                          `json:"set_as_default"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	pm, err := h.uc.AddMethod(c.Request.Context(), userID, req.Type, req.CardToken, req.Provider, req.AccountID, req.SetAsDefault)
	if err != nil {
		if err.Error() != "" {
			c.JSON(http.StatusBadRequest, gin.H{"code": "PAYMENT_METHOD_UNSUPPORTED", "message": err.Error()})
			return
		}
		respondError(c, err)
		return
	}

	c.JSON(http.StatusCreated, pm)
}

// RemoveMethod handles DELETE /users/me/payment-methods/:paymentMethodId
func (h *PaymentMethodHandler) RemoveMethod(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)

	methodID, err := uuid.Parse(c.Param("paymentMethodId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid payment method ID"})
		return
	}

	if err := h.uc.RemoveMethod(c.Request.Context(), userID, methodID); err != nil {
		respondError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}

// SetDefault handles PUT /users/me/payment-methods/:paymentMethodId/default
func (h *PaymentMethodHandler) SetDefault(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)

	methodID, err := uuid.Parse(c.Param("paymentMethodId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid payment method ID"})
		return
	}

	pm, err := h.uc.SetDefault(c.Request.Context(), userID, methodID)
	if err != nil {
		respondError(c, err)
		return
	}

	c.JSON(http.StatusOK, pm)
}
