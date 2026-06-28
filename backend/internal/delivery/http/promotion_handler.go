package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type PromotionHandler struct {
	promotionUC domain.PromotionUseCase
}

func NewPromotionHandler(pUC domain.PromotionUseCase) *PromotionHandler {
	return &PromotionHandler{
		promotionUC: pUC,
	}
}

// ListActive handles GET /promotions
func (h *PromotionHandler) ListActive(c *gin.Context) {
	promos, err := h.promotionUC.ListActive(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}

	resp := make([]dto.PromotionResponse, len(promos))
	for i, p := range promos {
		resp[i] = dto.NewPromotionResponse(p)
	}

	respondOK(c, resp)
}

// Validate handles POST /promotions/validate
func (h *PromotionHandler) Validate(c *gin.Context) {
	var req dto.PromotionValidateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	promo, err := h.promotionUC.ValidateCode(c.Request.Context(), req.Code, req.RideFare)
	if err != nil {
		respondError(c, err)
		return
	}

	respondOK(c, dto.NewPromotionResponse(promo))
}
