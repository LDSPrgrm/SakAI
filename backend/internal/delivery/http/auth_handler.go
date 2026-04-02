package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

// AuthHandler handles /auth/* routes.
type AuthHandler struct{ uc domain.AuthUseCase }

func NewAuthHandler(uc domain.AuthUseCase) *AuthHandler { return &AuthHandler{uc: uc} }

func (h *AuthHandler) Register(c *gin.Context) {
	var req dto.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	out, err := h.uc.Register(c.Request.Context(), req.Name, req.Email, req.Password, req.Role, req.Vehicle.ToDomainVehicle())
	if err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, dto.NewAuthResponse(out))
}

func (h *AuthHandler) CreateAdmin(c *gin.Context) {
	var req dto.CreateAdminRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	out, err := h.uc.Register(c.Request.Context(), req.Name, req.Email, req.Password, req.Role, nil)
	if err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, dto.NewAuthResponse(out))
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req dto.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	out, err := h.uc.Login(c.Request.Context(), req.Email, req.Password)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewAuthResponse(out))
}

func (h *AuthHandler) Refresh(c *gin.Context) {
	var req dto.RefreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	out, err := h.uc.Refresh(c.Request.Context(), req.RefreshToken)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewAuthResponse(out))
}

func (h *AuthHandler) Logout(c *gin.Context) {
	var req dto.RefreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.Logout(c.Request.Context(), req.RefreshToken); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

// GetMe serves GET /users/me — re-hydrates the authenticated session on cold start.
func (h *AuthHandler) GetMe(c *gin.Context) {
	userID, ok := c.MustGet("userID").(uuid.UUID)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"code": "TOKEN_INVALID", "message": "invalid token context"})
		return
	}
	user, err := h.uc.GetUserByID(c.Request.Context(), userID)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewUserResponse(user))
}
