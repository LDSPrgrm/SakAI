package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type SystemHandler struct {
	uc domain.SystemUseCase
}

func NewSystemHandler(uc domain.SystemUseCase) *SystemHandler {
	return &SystemHandler{uc: uc}
}

func (h *SystemHandler) ListServices(c *gin.Context) {
	services, err := h.uc.ListServices(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, services)
}

func (h *SystemHandler) ListFeatureFlags(c *gin.Context) {
	flags, err := h.uc.ListFeatureFlags(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, flags)
}

func (h *SystemHandler) UpdateFeatureFlag(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	key := c.Param("key")
	var req dto.UpdateFeatureFlagRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateFeatureFlag(c.Request.Context(), actorID, key, req.Enabled); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *SystemHandler) ListIntegrations(c *gin.Context) {
	integrations, err := h.uc.ListIntegrations(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, integrations)
}

func (h *SystemHandler) UpdateIntegration(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	service := c.Param("service")
	var req dto.UpdateIntegrationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateIntegration(c.Request.Context(), actorID, service, req.Config); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *SystemHandler) TestIntegration(c *gin.Context) {
	service := c.Param("service")
	result, err := h.uc.TestIntegration(c.Request.Context(), service)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.IntegrationTestResultDTO{
		Service:   result.Name,
		Status:    result.Status,
		LatencyMs: result.LatencyMs,
		Message:   integrationMessage(result.Status),
	})
}

// integrationMessage gives the UI a one-line status summary without exposing
// the raw provider error body (which may include API tokens).
func integrationMessage(status string) string {
	if status == "ok" {
		return "connection verified"
	}
	return "connection failed — check credentials or try again"
}

func (h *SystemHandler) GetInfraMetrics(c *gin.Context) {
	metrics, err := h.uc.GetInfraMetrics(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, metrics)
}

func (h *SystemHandler) ListNotificationTemplates(c *gin.Context) {
	templates, err := h.uc.ListNotificationTemplates(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, templates)
}

func (h *SystemHandler) UpdateNotificationTemplate(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	event := c.Param("event")
	var req dto.UpdateNotificationTemplateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateNotificationTemplate(c.Request.Context(), actorID, event, req.Subject, req.Body); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}
