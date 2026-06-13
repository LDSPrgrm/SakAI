package handler_test

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
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

// mountFiles builds the /files/*filepath route by calling the SAME shared
// handler.FilesRouteHandler that router.New uses, so the test exercises the
// exact production authorization path (M1) with no duplicated wrapper that
// could silently drift: a DRIVER goes straight to files.Serve (which enforces
// the owns-prefix rule in canReadKey), while any admin-tier role must first
// clear requirePerm("kyc_verification","read") before Serve runs.
func mountFiles(role domain.UserRole, userID uuid.UUID, requirePerm middleware.PermissionGuardFactory, filesRoot string) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set("userID", userID)
		c.Set("role", string(role))
		c.Next()
	})
	files := handler.NewFilesHandler(filesRoot)
	r.GET("/files/*filepath", handler.FilesRouteHandler(files, requirePerm))
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
// guard AND have Serve deliver the file. We seed the target under the files
// root so a 200 proves both that the perm gate let the request through (not a
// 403) and that Serve resolved and served the real file (not a 404).
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

	// Serve maps URL /files/documents/x/license/a.jpg to
	// <FilesRoot>/documents/x/license/a.jpg (strip /files prefix + leading
	// slash, join under root). Seed that exact path so the gate-passing read
	// returns a real 200.
	dir := t.TempDir()
	target := filepath.Join(dir, "documents", "x", "license", "a.jpg")
	if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(target, []byte("x"), 0o600); err != nil {
		t.Fatal(err)
	}

	r := mountFiles(domain.RoleOperations, userID, requirePerm, dir)
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/files/documents/x/license/a.jpg", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}
