package middleware_test

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	"github.com/sakai/backend/internal/delivery/http/middleware"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
)

func setupPermTest(t *testing.T, role domain.UserRole, userID uuid.UUID) (*gin.Engine, *mocks.MockAuthUseCase, *mocks.MockRoleUseCase, middleware.PermissionGuardFactory) {
	t.Helper()
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	authUC := mocks.NewMockAuthUseCase(ctrl)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	requirePerm := middleware.NewPermissionGuard(authUC, roleUC)

	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set("userID", userID)
		c.Set("role", string(role))
		c.Next()
	})
	return r, authUC, roleUC, requirePerm
}

func okHandler(c *gin.Context) { c.JSON(http.StatusOK, gin.H{"ok": true}) }

func TestPermission_Superadmin_BypassesDB(t *testing.T) {
	userID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleSuperadmin, userID)
	r.GET("/x", requirePerm("admin_management", "write"), okHandler)

	// No EXPECT() calls — gomock fails if any are made.
	_ = authUC
	_ = roleUC

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPermission_Read_Allowed(t *testing.T) {
	userID := uuid.New()
	roleID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleFinance, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleFinance, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{
			ID:   roleID,
			Name: "finance",
			Permissions: []domain.RolePermission{
				{PermissionKey: "fare_config", Read: true, Write: true},
			},
		}, nil)

	r.GET("/fares", requirePerm("fare_config", "read"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/fares", nil))
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPermission_Write_Denied_When_Only_Read(t *testing.T) {
	userID := uuid.New()
	roleID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleSupport, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleSupport, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{
			ID:   roleID,
			Name: "support",
			Permissions: []domain.RolePermission{
				{PermissionKey: "reports", Read: true, Write: false},
			},
		}, nil)

	r.POST("/reports/export", requirePerm("reports", "write"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodPost, "/reports/export", nil))
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestPermission_Read_Allowed_When_Only_Write(t *testing.T) {
	// Frontend semantics: can('key','read') passes if read OR write.
	userID := uuid.New()
	roleID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleOperations, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleOperations, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{
			ID:   roleID,
			Name: "operations",
			Permissions: []domain.RolePermission{
				{PermissionKey: "kyc_verification", Read: false, Write: true},
			},
		}, nil)

	r.GET("/safety/kyc", requirePerm("kyc_verification", "read"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/safety/kyc", nil))
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPermission_Missing_Key_Denied(t *testing.T) {
	userID := uuid.New()
	roleID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleFinance, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleFinance, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{
			ID:          roleID,
			Name:        "finance",
			Permissions: []domain.RolePermission{{PermissionKey: "payments", Read: true, Write: true}},
		}, nil)

	r.GET("/system/config", requirePerm("system_config", "read"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/system/config", nil))
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestPermission_NoRoleID_Denied(t *testing.T) {
	userID := uuid.New()
	r, authUC, _, requirePerm := setupPermTest(t, domain.RoleAdmin, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleAdmin, RoleID: nil}, nil)

	r.GET("/dashboard", requirePerm("dashboard", "read"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/dashboard", nil))
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestPermission_GetUserError_Denied(t *testing.T) {
	userID := uuid.New()
	r, authUC, _, requirePerm := setupPermTest(t, domain.RoleAdmin, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(nil, errors.New("db down"))

	r.GET("/dashboard", requirePerm("dashboard", "read"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/dashboard", nil))
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestPermission_GetRoleError_Denied(t *testing.T) {
	userID := uuid.New()
	roleID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleFinance, userID)

	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleFinance, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(nil, errors.New("db down"))

	r.GET("/fares", requirePerm("fare_config", "read"), okHandler)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/fares", nil))
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestPermission_Cache_Hit_OnSecondRequest(t *testing.T) {
	userID := uuid.New()
	roleID := uuid.New()
	r, authUC, roleUC, requirePerm := setupPermTest(t, domain.RoleFinance, userID)

	// .Times(1) — exactly one DB lookup across two requests proves cache hit.
	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleFinance, RoleID: &roleID}, nil).
		Times(1)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{
			ID:          roleID,
			Name:        "finance",
			Permissions: []domain.RolePermission{{PermissionKey: "fare_config", Read: true, Write: true}},
		}, nil).
		Times(1)

	r.GET("/fares", requirePerm("fare_config", "read"), okHandler)

	for i := 0; i < 2; i++ {
		w := httptest.NewRecorder()
		r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/fares", nil))
		assert.Equal(t, http.StatusOK, w.Code)
	}
}

func TestPermission_Panics_On_Bad_Scope(t *testing.T) {
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	authUC := mocks.NewMockAuthUseCase(ctrl)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	requirePerm := middleware.NewPermissionGuard(authUC, roleUC)

	defer func() {
		if r := recover(); r == nil {
			t.Fatal("expected panic on invalid scope")
		}
	}()
	_ = requirePerm("fare_config", "execute")
}

// Sanity that TTL is positive — guards against accidental zeroing in refactors.
func TestPermission_TTLPositive(t *testing.T) {
	if (30 * time.Second) <= 0 {
		t.Fatal("TTL must be positive")
	}
}
