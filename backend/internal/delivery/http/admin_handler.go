package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type AdminHandler struct {
	uc      domain.AdminUseCase
	auditUc domain.AuditUseCase
}

func NewAdminHandler(uc domain.AdminUseCase, auditUc domain.AuditUseCase) *AdminHandler {
	return &AdminHandler{uc: uc, auditUc: auditUc}
}

func (h *AdminHandler) GetDashboard(c *gin.Context) {
	metrics, err := h.uc.GetDashboard(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewDashboardResponse(metrics))
}

func (h *AdminHandler) ListAdmins(c *gin.Context) {
	admins, err := h.uc.ListAdmins(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	var res []dto.UserResponse
	for _, a := range admins {
		res = append(res, dto.NewUserResponse(a))
	}
	respondOK(c, res)
}

func (h *AdminHandler) CreateAdmin(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req dto.CreateAdminRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	user, err := h.uc.CreateAdmin(c.Request.Context(), actorID, req.Name, req.Email, req.Password, req.Role)
	if err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, dto.NewUserResponse(user))
}

func (h *AdminHandler) UpdateAdminStatus(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	targetID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid user id"})
		return
	}
	var req dto.UpdateAdminStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateAdminStatus(c.Request.Context(), actorID, targetID, req.Role); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *AdminHandler) ListIncidents(c *gin.Context) {
	status := c.Query("status")
	var s *string
	if status != "" {
		s = &status
	}
	incidents, err := h.uc.ListIncidents(c.Request.Context(), s)
	if err != nil {
		respondError(c, err)
		return
	}
	var res []*dto.IncidentDTO
	for _, i := range incidents {
		res = append(res, dto.NewIncidentDTO(i))
	}
	respondOK(c, res)
}

func (h *AdminHandler) ResolveIncident(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	incidentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid incident id"})
		return
	}
	var req struct {
		Notes string `json:"notes" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.ResolveIncident(c.Request.Context(), actorID, incidentID, req.Notes); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *AdminHandler) GetReportChart(c *gin.Context) {
	// chartType := c.Param("type")
	// For now, return stub data to satisfy frontend charting
	data := []gin.H{
		{"label": "Mon", "value": 10},
		{"label": "Tue", "value": 20},
		{"label": "Wed", "value": 15},
		{"label": "Thu", "value": 25},
		{"label": "Fri", "value": 30},
		{"label": "Sat", "value": 40},
		{"label": "Sun", "value": 35},
	}
	respondOK(c, data)
}

type FareHandler struct {
	uc domain.FareUseCase
}

func NewFareHandler(uc domain.FareUseCase) *FareHandler {
	return &FareHandler{uc: uc}
}

func (h *FareHandler) GetConfig(c *gin.Context) {
	fares, surge, err := h.uc.GetConfig(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, gin.H{
		"fares": fares,
		"surge": surge,
	})
}

func (h *FareHandler) UpdateFares(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req []*domain.FareConfig
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateFares(c.Request.Context(), actorID, req); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *FareHandler) UpdateSurge(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req domain.SurgeConfig
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.UpdateSurge(c.Request.Context(), actorID, &req); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *FareHandler) SimulateFare(c *gin.Context) {
	var req struct {
		VehicleType string        `json:"vehicle_type" binding:"required"`
		Origin      domain.LatLng `json:"origin" binding:"required"`
		Destination domain.LatLng `json:"destination" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	fare, err := h.uc.SimulateFare(c.Request.Context(), req.VehicleType, req.Origin, req.Destination)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, gin.H{"estimated_fare": fare})
}

type AuditHandler struct {
	uc domain.AuditUseCase
}

func NewAuditHandler(uc domain.AuditUseCase) *AuditHandler {
	return &AuditHandler{uc: uc}
}

func (h *AuditHandler) List(c *gin.Context) {
	var q domain.AuditQuery
	// Basic paging
	if err := c.ShouldBindQuery(&q); err != nil {
		// fallback or ignored
	}
	logs, total, err := h.uc.GetLogs(c.Request.Context(), q)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, gin.H{
		"logs":  logs,
		"total": total,
	})
}
