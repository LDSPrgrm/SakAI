package handler_test

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
)

func setupAuthTest(t *testing.T) (*gin.Engine, *mocks.MockAuthUseCase) {
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	mockUC := mocks.NewMockAuthUseCase(ctrl)
	h := handler.NewAuthHandler(mockUC)

	r := gin.New()
	auth := r.Group("/auth")
	{
		auth.POST("/register", h.Register)
		auth.POST("/login", h.Login)
		auth.POST("/refresh", h.Refresh)
		auth.POST("/logout", h.Logout)
	}

	users := r.Group("/users")
	{
		// Simulate auth middleware
		users.Use(func(c *gin.Context) {
			c.Set("userID", uuid.MustParse("00000000-0000-0000-0000-000000000001"))
			c.Next()
		})
		users.GET("/me", h.GetMe)
		users.POST("/change-password", h.ChangePassword)
	}

	return r, mockUC
}

func TestAuthHandler_Register_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.RegisterRequest{
		Name:     "Alice",
		Email:    "alice@example.com",
		Password: "password123",
		Role:     domain.RolePassenger,
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		Register(gomock.Any(), req.Name, req.Email, req.Password, req.Role, gomock.Any()).
		Return(&domain.AuthOutput{
			AccessToken:  "access",
			RefreshToken: "refresh",
			User: &domain.User{
				ID:    uuid.New(),
				Name:  req.Name,
				Email: req.Email,
				Role:  req.Role,
			},
		}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/register", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusCreated, w.Code)
	var resp dto.AuthResponse
	json.Unmarshal(w.Body.Bytes(), &resp)
	assert.Equal(t, "access", resp.AccessToken)
}

func TestAuthHandler_Login_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.LoginRequest{
		Email:    "alice@example.com",
		Password: "password123",
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		Login(gomock.Any(), req.Email, req.Password).
		Return(&domain.AuthOutput{
			AccessToken:  "access",
			RefreshToken: "refresh",
			User:         &domain.User{Email: req.Email},
		}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAuthHandler_Login_Error(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.LoginRequest{
		Email:    "alice@example.com",
		Password: "wrong",
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		Login(gomock.Any(), req.Email, req.Password).
		Return(nil, domain.ErrInvalidCredentials)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestAuthHandler_Refresh_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.RefreshRequest{
		RefreshToken: "old-refresh",
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		Refresh(gomock.Any(), req.RefreshToken).
		Return(&domain.AuthOutput{
			AccessToken:  "new-access",
			RefreshToken: "new-refresh",
			User:         &domain.User{Email: "alice@example.com"},
		}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/refresh", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAuthHandler_Logout_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.RefreshRequest{
		RefreshToken: "token",
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		Logout(gomock.Any(), req.RefreshToken).
		Return(nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/logout", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestAuthHandler_GetMe_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	mockUC.EXPECT().
		GetUserByID(gomock.Any(), gomock.Any()).
		Return(&domain.User{Name: "Alice"}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("GET", "/users/me", nil)
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusOK, w.Code)
	var resp dto.UserResponse
	json.Unmarshal(w.Body.Bytes(), &resp)
	assert.Equal(t, "Alice", resp.Name)
}

func TestAuthHandler_GetMe_Driver_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	mockUC.EXPECT().
		GetUserByID(gomock.Any(), gomock.Any()).
		Return(&domain.User{
			Name: "Bob",
			Role: domain.RoleDriver,
			Vehicle: &domain.Vehicle{
				Make:  "Toyota",
				Model: "Corolla",
				Color: "Blue",
				Plate: "ABC-123",
			},
		}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("GET", "/users/me", nil)
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusOK, w.Code)
	var resp dto.UserResponse
	json.Unmarshal(w.Body.Bytes(), &resp)
	assert.Equal(t, "Bob", resp.Name)
	assert.NotNil(t, resp.Vehicle)
	assert.Equal(t, "Toyota", resp.Vehicle.Make)
	assert.Equal(t, "ABC-123", resp.Vehicle.Plate)
}

func TestAuthHandler_ChangePassword_Success(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.ChangePasswordRequest{
		OldPassword: "oldpassword",
		NewPassword: "newpassword",
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		ChangePassword(gomock.Any(), gomock.Any(), req.OldPassword, req.NewPassword).
		Return(nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/users/change-password", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestAuthHandler_Register_ValidationError(t *testing.T) {
	r, _ := setupAuthTest(t)

	req := dto.RegisterRequest{
		Name:  "A", // Too short
		Email: "not-an-email",
	}
	body, _ := json.Marshal(req)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/register", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAuthHandler_Login_UseCaseError(t *testing.T) {
	r, mockUC := setupAuthTest(t)

	req := dto.LoginRequest{
		Email:    "error@example.com",
		Password: "password123",
	}
	body, _ := json.Marshal(req)

	mockUC.EXPECT().
		Login(gomock.Any(), req.Email, req.Password).
		Return(nil, errors.New("unexpected error"))

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
}
