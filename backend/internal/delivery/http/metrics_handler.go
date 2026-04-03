package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type MetricsHandler struct {
	uc domain.MetricsUseCase
}

func NewMetricsHandler(uc domain.MetricsUseCase) *MetricsHandler {
	return &MetricsHandler{uc: uc}
}

func (h *MetricsHandler) GetRiders(c *gin.Context) {
	m, err := h.uc.GetRiderMetrics(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewMetricResponseDTO(m))
}

func (h *MetricsHandler) GetDrivers(c *gin.Context) {
	m, err := h.uc.GetDriverMetrics(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewMetricResponseDTO(m))
}

func (h *MetricsHandler) GetRides(c *gin.Context) {
	period := c.Query("period")
	m, err := h.uc.GetRideMetrics(c.Request.Context(), period)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewMetricResponseDTO(m))
}

func (h *MetricsHandler) GetRevenue(c *gin.Context) {
	period := c.Query("period")
	m, err := h.uc.GetRevenueMetrics(c.Request.Context(), period)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewMetricResponseDTO(m))
}

func (h *MetricsHandler) GetWaitTime(c *gin.Context) {
	m, err := h.uc.GetWaitTimeMetrics(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewMetricResponseDTO(m))
}
