package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type PaymentHandler struct {
	uc domain.PaymentUseCase
}

func NewPaymentHandler(uc domain.PaymentUseCase) *PaymentHandler {
	return &PaymentHandler{uc: uc}
}

func (h *PaymentHandler) ListTransactions(c *gin.Context) {
	page := parseIntQuery(c, "page", 1)
	limit := parseIntQuery(c, "limit", 20)
	txns, total, err := h.uc.ListTransactions(c.Request.Context(), page, limit)
	if err != nil {
		respondError(c, err)
		return
	}
	res := make([]dto.TransactionDTO, 0, len(txns))
	for _, t := range txns {
		res = append(res, dto.NewTransactionDTO(t))
	}
	respondOK(c, gin.H{"data": res, "total": total})
}

func (h *PaymentHandler) GetSummary(c *gin.Context) {
	summary, err := h.uc.GetSummary(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, summary)
}

func (h *PaymentHandler) ListPayouts(c *gin.Context) {
	payouts, err := h.uc.ListPayouts(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	res := make([]dto.DriverPayoutDTO, 0, len(payouts))
	for _, p := range payouts {
		res = append(res, dto.NewDriverPayoutDTO(p))
	}
	respondOK(c, res)
}

func (h *PaymentHandler) ApprovePayout(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid payout id"})
		return
	}
	if err := h.uc.ApprovePayout(c.Request.Context(), actorID, id); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *PaymentHandler) BatchApprovePayouts(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req dto.BatchApproveRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	ids := make([]uuid.UUID, 0, len(req.IDs))
	for _, s := range req.IDs {
		id, err := uuid.Parse(s)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid payout id: " + s})
			return
		}
		ids = append(ids, id)
	}
	count, err := h.uc.BatchApprovePayouts(c.Request.Context(), actorID, ids)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, gin.H{"approved": count})
}

func (h *PaymentHandler) GetGatewayConfigs(c *gin.Context) {
	configs, err := h.uc.GetGatewayConfigs(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, configs)
}

func (h *PaymentHandler) UpdateGatewayConfig(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	provider := c.Param("provider")
	var config domain.PaymentGatewayConfig
	if err := c.ShouldBindJSON(&config); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	config.Provider = provider
	if err := h.uc.UpdateGatewayConfig(c.Request.Context(), actorID, &config); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *PaymentHandler) GetCommissionSettings(c *gin.Context) {
	settings, err := h.uc.GetCommissionSettings(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, settings)
}

func (h *PaymentHandler) UpdateCommissionSettings(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req dto.CommissionUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	settings := &domain.CommissionSettings{
		VehicleType:   req.VehicleType,
		RatePercent:   req.RatePercent,
		MinCommission: req.MinCommission,
	}
	if err := h.uc.UpdateCommissionSettings(c.Request.Context(), actorID, settings); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}
