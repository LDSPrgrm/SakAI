package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type AlertHandler struct {
	uc domain.AlertUseCase
}

func NewAlertHandler(uc domain.AlertUseCase) *AlertHandler {
	return &AlertHandler{uc: uc}
}

type alertRuleInput struct {
	Name    string          `json:"name" binding:"required"`
	Type    string          `json:"type" binding:"required"`
	Enabled *bool           `json:"enabled"`
	Config  json.RawMessage `json:"config"`
}

func (h *AlertHandler) ListRules(c *gin.Context) {
	rules, err := h.uc.ListRules(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, rules)
}

func (h *AlertHandler) ListEvents(c *gin.Context) {
	limit := 100
	if raw := c.Query("limit"); raw != "" {
		if n, err := strconv.Atoi(raw); err == nil {
			limit = n
		}
	}
	events, err := h.uc.ListEvents(c.Request.Context(), limit)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, events)
}

func (h *AlertHandler) CreateRule(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var in alertRuleInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	rule := &domain.AlertRule{
		Name:    in.Name,
		Type:    domain.AlertRuleType(in.Type),
		Enabled: in.Enabled == nil || *in.Enabled,
		Config:  in.Config,
	}
	if err := h.uc.CreateRule(c.Request.Context(), actorID, rule); err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, rule)
}

func (h *AlertHandler) UpdateRule(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid id"})
		return
	}
	var in alertRuleInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	rule := &domain.AlertRule{
		ID:      id,
		Name:    in.Name,
		Type:    domain.AlertRuleType(in.Type),
		Enabled: in.Enabled == nil || *in.Enabled,
		Config:  in.Config,
	}
	if err := h.uc.UpdateRule(c.Request.Context(), actorID, rule); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *AlertHandler) DeleteRule(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid id"})
		return
	}
	if err := h.uc.DeleteRule(c.Request.Context(), actorID, id); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}
