package handler

import (
	"encoding/json"
	"fmt"
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
	if req.Role == "" && req.RoleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "role or role_id is required"})
		return
	}

	var roleID *uuid.UUID
	if req.RoleID != "" {
		parsed, err := uuid.Parse(req.RoleID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid role_id format"})
			return
		}
		roleID = &parsed
	}

	user, err := h.uc.CreateAdmin(c.Request.Context(), actorID, req.Name, req.Email, req.Password, domain.UserRole(req.Role), roleID)
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

func (h *AdminHandler) DeactivateAdmin(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	targetID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid user id"})
		return
	}
	if err := h.uc.DeactivateAdmin(c.Request.Context(), actorID, targetID); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *AdminHandler) GetAdminActivity(c *gin.Context) {
	adminID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid user id"})
		return
	}
	logs, err := h.uc.GetAdminActivity(c.Request.Context(), adminID)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, logs)
}

// ResetUserPassword lets a superadmin set another admin's password
// (PUT /admin/users/:id/password). Matches swagger adminResetUserPassword.
func (h *AdminHandler) ResetUserPassword(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	targetID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid user id"})
		return
	}
	var req dto.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.ResetUserPassword(c.Request.Context(), actorID, targetID, req.NewPassword); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *AdminHandler) ListRides(c *gin.Context) {
	filter := domain.AdminRideFilter{
		Page:  parseIntQuery(c, "page", 1),
		Limit: parseIntQuery(c, "limit", 20),
	}
	if s := c.Query("status"); s != "" {
		rs := domain.RideStatus(s)
		filter.Status = &rs
	}
	items, meta, err := h.uc.ListRides(c.Request.Context(), filter)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewAdminRideListResponse(items, meta))
}

func (h *AdminHandler) ListPassengers(c *gin.Context) {
	role := domain.RolePassenger
	filter := domain.UserListFilter{
		Role:   &role,
		Search: c.Query("search"),
		Page:   parseIntQuery(c, "page", 1),
		Limit:  parseIntQuery(c, "limit", 20),
	}
	users, meta, err := h.uc.ListUsers(c.Request.Context(), filter)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewAdminUserListResponse(users, meta))
}

func (h *AdminHandler) ListDrivers(c *gin.Context) {
	role := domain.RoleDriver
	filter := domain.UserListFilter{
		Role:   &role,
		Search: c.Query("search"),
		Page:   parseIntQuery(c, "page", 1),
		Limit:  parseIntQuery(c, "limit", 20),
	}
	users, meta, err := h.uc.ListUsers(c.Request.Context(), filter)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewAdminUserListResponse(users, meta))
}

// parseIntQuery reads an integer query param, returning defaultVal if absent or invalid.
func parseIntQuery(c *gin.Context, key string, defaultVal int) int {
	if s := c.Query(key); s != "" {
		var v int
		if _, err := fmt.Sscanf(s, "%d", &v); err == nil && v > 0 {
			return v
		}
	}
	return defaultVal
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

func (h *FareHandler) GetSurgeConfig(c *gin.Context) {
	_, surge, err := h.uc.GetConfig(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, surge)
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

func (h *AuditHandler) Export(c *gin.Context) {
	var q domain.AuditQuery
	_ = c.ShouldBindQuery(&q)
	csvData, err := h.uc.ExportLogs(c.Request.Context(), q)
	if err != nil {
		respondError(c, err)
		return
	}
	c.Header("Content-Disposition", "attachment; filename=audit-log.csv")
	c.Data(http.StatusOK, "text/csv", csvData)
}

// Create records an admin action in the audit trail.
// Called by the frontend after high-impact mutations (fare changes, role edits, payout approvals).
// Matches swagger operationId adminCreateAuditEntry (POST /admin/audit).
func (h *AuditHandler) Create(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req dto.CreateAuditEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	entry := &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       req.Action,
		ResourceType: req.ResourceType,
		ResourceID:   req.ResourceID,
		Reason:       req.Reason,
		IPAddress:    c.ClientIP(),
	}
	if req.BeforeState != nil {
		if b, err := json.Marshal(req.BeforeState); err == nil {
			entry.BeforeState = b
		}
	}
	if req.AfterState != nil {
		if b, err := json.Marshal(req.AfterState); err == nil {
			entry.AfterState = b
		}
	}

	if err := h.uc.LogAction(c.Request.Context(), entry); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}
