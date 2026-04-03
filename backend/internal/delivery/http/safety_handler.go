package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type SafetyHandler struct {
	uc domain.SafetyUseCase
}

func NewSafetyHandler(uc domain.SafetyUseCase) *SafetyHandler {
	return &SafetyHandler{uc: uc}
}

func (h *SafetyHandler) ListKyc(c *gin.Context) {
	entries, err := h.uc.ListKyc(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	res := make([]dto.KycEntryDTO, 0, len(entries))
	for _, e := range entries {
		res = append(res, dto.NewKycEntryDTO(e))
	}
	respondOK(c, res)
}

func (h *SafetyHandler) UpdateKyc(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid kyc id"})
		return
	}
	var req dto.UpdateKycRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateKyc(c.Request.Context(), actorID, id, req.Status, req.Reason); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *SafetyHandler) BatchKyc(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req dto.KycBatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	ids := make([]uuid.UUID, 0, len(req.IDs))
	for _, s := range req.IDs {
		id, err := uuid.Parse(s)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid id: " + s})
			return
		}
		ids = append(ids, id)
	}
	count, err := h.uc.BatchKyc(c.Request.Context(), actorID, ids, req.Status)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, gin.H{"processed": count})
}

func (h *SafetyHandler) GetCompliance(c *gin.Context) {
	data, err := h.uc.GetCompliance(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, data)
}
