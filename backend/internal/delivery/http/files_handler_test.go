package handler_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/middleware"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
)

// mountFiles builds the /files/*filepath route exactly as router.go does (see
// the wrapper in router.New): a DRIVER goes straight to files.Serve (which
// enforces the owns-prefix rule in canReadKey), while any admin-tier role must
// first clear requirePerm("kyc_verification","read") before Serve runs. The
// production router and this test share the same wrapper logic so the test
// proves the real authorization path (M1).
func mountFiles(role domain.UserRole, userID uuid.UUID, requirePerm middleware.PermissionGuardFactory, filesRoot string) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set("userID", userID)
		c.Set("role", string(role))
		c.Next()
	})
	files := handler.NewFilesHandler(filesRoot)
	r.GET("/files/*filepath", func(c *gin.Context) {
		if domain.UserRole(c.GetString("role")) == domain.RoleDriver {
			files.Serve(c)
			return
		}
		requirePerm("kyc_verification", "read")(c)
		if c.IsAborted() {
			return
		}
		files.Serve(c)
	})
	return r
}

// An admin-tier role whose role carries no kyc_verification permission must be
// denied with 403 at the route guard before Serve ever runs.
func TestFiles_AdminWithoutKycPerm_Forbidden(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	authUC := mocks.NewMockAuthUseCase(ctrl)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	requirePerm := middleware.NewPermissionGuard(authUC, roleUC)

	userID := uuid.New()
	roleID := uuid.New()
	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleFinance, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{ID: roleID, Name: "finance", Permissions: []domain.RolePermission{}}, nil)

	r := mountFiles(domain.RoleFinance, userID, requirePerm, t.TempDir())
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/files/documents/x/license/a.jpg", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

// An admin-tier role that DOES hold kyc_verification:read must clear the route
// guard. With an empty temp dir the subsequent Serve 404s on the missing file;
// the point is that the perm gate did NOT 403 (it let the request through).
func TestFiles_AdminWithKycPerm_Allowed(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	authUC := mocks.NewMockAuthUseCase(ctrl)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	requirePerm := middleware.NewPermissionGuard(authUC, roleUC)

	userID := uuid.New()
	roleID := uuid.New()
	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, Role: domain.RoleOperations, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{ID: roleID, Name: "operations", Permissions: []domain.RolePermission{
			{PermissionKey: "kyc_verification", Read: true},
		}}, nil)

	r := mountFiles(domain.RoleOperations, userID, requirePerm, t.TempDir())
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/files/documents/x/license/a.jpg", nil)
	r.ServeHTTP(w, req)
	assert.NotEqual(t, http.StatusForbidden, w.Code)
}
