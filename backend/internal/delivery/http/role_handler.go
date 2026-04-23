package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type RoleHandler struct {
	uc     domain.RoleUseCase
	authUC domain.AuthUseCase
}

func NewRoleHandler(uc domain.RoleUseCase, authUC domain.AuthUseCase) *RoleHandler {
	return &RoleHandler{uc: uc, authUC: authUC}
}

func (h *RoleHandler) ListRoles(c *gin.Context) {
	roles, err := h.uc.ListRoles(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	res := make([]dto.RoleResponse, 0, len(roles))
	for _, r := range roles {
		res = append(res, dto.NewRoleResponse(r))
	}
	respondOK(c, res)
}

func (h *RoleHandler) CreateRole(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var req dto.CreateRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	perms := make([]domain.RolePermission, len(req.Permissions))
	for i, p := range req.Permissions {
		perms[i] = domain.RolePermission{PermissionKey: p.PermissionKey, Read: p.Read, Write: p.Write}
	}
	role, err := h.uc.CreateRole(c.Request.Context(), actorID, req.Name, req.Description, perms)
	if err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, dto.NewRoleResponse(role))
}

func (h *RoleHandler) GetRole(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid role id"})
		return
	}
	role, err := h.uc.GetRole(c.Request.Context(), id)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewRoleResponse(role))
}

func (h *RoleHandler) UpdateRole(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid role id"})
		return
	}
	var req dto.UpdateRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	perms := make([]domain.RolePermission, len(req.Permissions))
	for i, p := range req.Permissions {
		perms[i] = domain.RolePermission{PermissionKey: p.PermissionKey, Read: p.Read, Write: p.Write}
	}
	role, err := h.uc.UpdateRole(c.Request.Context(), actorID, id, req.Name, req.Description, perms)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewRoleResponse(role))
}

func (h *RoleHandler) DeleteRole(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid role id"})
		return
	}
	if err := h.uc.DeleteRole(c.Request.Context(), actorID, id); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

// GetMyPermissions serves GET /admin/me/permissions. Returns the authenticated
// user's role with its permissions. Users without a role_id (e.g. passengers
// or drivers) receive an empty role envelope so the frontend can merge cleanly.
func (h *RoleHandler) GetMyPermissions(c *gin.Context) {
	userID, ok := c.MustGet("userID").(uuid.UUID)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
			"code":    "TOKEN_INVALID",
			"message": "invalid token context",
		})
		return
	}
	user, err := h.authUC.GetUserByID(c.Request.Context(), userID)
	if err != nil {
		respondError(c, err)
		return
	}
	if user.RoleID == nil {
		respondOK(c, dto.RoleResponse{Permissions: []dto.RolePermissionDTO{}})
		return
	}
	role, err := h.uc.GetRole(c.Request.Context(), *user.RoleID)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewRoleResponse(role))
}

func (h *RoleHandler) GetRolePermissions(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid role id"})
		return
	}
	perms, err := h.uc.GetRolePermissions(c.Request.Context(), id)
	if err != nil {
		respondError(c, err)
		return
	}
	res := make([]dto.RolePermissionDTO, len(perms))
	for i, p := range perms {
		res[i] = dto.RolePermissionDTO{PermissionKey: p.PermissionKey, Read: p.Read, Write: p.Write}
	}
	respondOK(c, res)
}

func (h *RoleHandler) GetRoleAdmins(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid role id"})
		return
	}
	admins, err := h.uc.GetRoleAdmins(c.Request.Context(), id)
	if err != nil {
		respondError(c, err)
		return
	}
	res := make([]dto.UserResponse, 0, len(admins))
	for _, a := range admins {
		res = append(res, dto.NewUserResponse(a))
	}
	respondOK(c, res)
}

// DuplicateRole clones a role and returns the new copy (POST /admin/roles/:id/duplicate).
func (h *RoleHandler) DuplicateRole(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid role id"})
		return
	}
	role, err := h.uc.DuplicateRole(c.Request.Context(), actorID, id)
	if err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, dto.NewRoleResponse(role))
}
