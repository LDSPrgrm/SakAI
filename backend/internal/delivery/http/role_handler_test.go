package handler_test

import (
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

func setupRoleTest(t *testing.T) (*gin.Engine, *mocks.MockRoleUseCase, *mocks.MockAuthUseCase, uuid.UUID) {
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	authUC := mocks.NewMockAuthUseCase(ctrl)
	h := handler.NewRoleHandler(roleUC, authUC)

	userID := uuid.MustParse("00000000-0000-0000-0000-000000000001")

	r := gin.New()
	admin := r.Group("/admin")
	admin.Use(func(c *gin.Context) {
		c.Set("userID", userID)
		c.Next()
	})
	admin.GET("/me/permissions", h.GetMyPermissions)

	return r, roleUC, authUC, userID
}

func TestRoleHandler_GetMyPermissions_Success(t *testing.T) {
	r, roleUC, authUC, userID := setupRoleTest(t)

	roleID := uuid.New()
	authUC.EXPECT().
		GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleAdmin, RoleID: &roleID}, nil)

	roleUC.EXPECT().
		GetRole(gomock.Any(), roleID).
		Return(&domain.Role{
			ID:   roleID,
			Name: "operations",
			Permissions: []domain.RolePermission{
				{PermissionKey: "dashboard", Read: true, Write: false},
				{PermissionKey: "user_management", Read: true, Write: true},
			},
		}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("GET", "/admin/me/permissions", nil)
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusOK, w.Code)
	var resp dto.RoleResponse
	assert.NoError(t, json.Unmarshal(w.Body.Bytes(), &resp))
	assert.Equal(t, "operations", resp.Name)
	assert.Len(t, resp.Permissions, 2)
	assert.Equal(t, "user_management", resp.Permissions[1].PermissionKey)
	assert.True(t, resp.Permissions[1].Write)
}

func TestRoleHandler_GetMyPermissions_NoRoleID(t *testing.T) {
	r, _, authUC, userID := setupRoleTest(t)

	authUC.EXPECT().
		GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RolePassenger, RoleID: nil}, nil)

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("GET", "/admin/me/permissions", nil)
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusOK, w.Code)
	var resp dto.RoleResponse
	assert.NoError(t, json.Unmarshal(w.Body.Bytes(), &resp))
	assert.Empty(t, resp.Permissions)
	assert.Equal(t, "", resp.Name)
}

func TestRoleHandler_GetMyPermissions_UserLookupError(t *testing.T) {
	r, _, authUC, userID := setupRoleTest(t)

	authUC.EXPECT().
		GetUserByID(gomock.Any(), userID).
		Return(nil, errors.New("db down"))

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("GET", "/admin/me/permissions", nil)
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
}

func TestRoleHandler_GetMyPermissions_RoleLookupError(t *testing.T) {
	r, roleUC, authUC, userID := setupRoleTest(t)

	roleID := uuid.New()
	authUC.EXPECT().
		GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleAdmin, RoleID: &roleID}, nil)

	roleUC.EXPECT().
		GetRole(gomock.Any(), roleID).
		Return(nil, errors.New("role gone"))

	w := httptest.NewRecorder()
	reqHTTP, _ := http.NewRequest("GET", "/admin/me/permissions", nil)
	r.ServeHTTP(w, reqHTTP)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
}
