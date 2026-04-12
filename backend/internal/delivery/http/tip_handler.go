package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

// TipHandler handles /rides/{rideId}/tip routes.
type TipHandler struct {
	tipUC domain.TipUseCase
}

// NewTipHandler creates a new TipHandler.
func NewTipHandler(tipUC domain.TipUseCase) *TipHandler {
	return &TipHandler{tipUC: tipUC}
}

// AddTip handles POST /rides/{rideId}/tip.
func (h *TipHandler) AddTip(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.AddTipRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	passengerID := c.MustGet("userID").(uuid.UUID)

	tipOutput, err := h.tipUC.AddTip(c.Request.Context(), passengerID, rideID, req.TipAmount)
	if err != nil {
		respondError(c, err)
		return
	}

	respondOK(c, dto.NewTipResponse(tipOutput))
}
