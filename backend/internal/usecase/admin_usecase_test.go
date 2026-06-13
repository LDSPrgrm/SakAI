package usecase_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/internal/usecase"
	"go.uber.org/mock/gomock"
)

type adminUCMocks struct {
	admin    *mocks.MockAdminRepository
	user     *mocks.MockUserRepository
	ride     *mocks.MockRideRepository
	incident *mocks.MockIncidentRepository
	metrics  *mocks.MockSystemMetricsRepository
	audit    *mocks.MockAuditRepository
	role     *mocks.MockRoleRepository
}

func newAdminUC(ctrl *gomock.Controller) (domain.AdminUseCase, adminUCMocks) {
	m := adminUCMocks{
		admin:    mocks.NewMockAdminRepository(ctrl),
		user:     mocks.NewMockUserRepository(ctrl),
		ride:     mocks.NewMockRideRepository(ctrl),
		incident: mocks.NewMockIncidentRepository(ctrl),
		metrics:  mocks.NewMockSystemMetricsRepository(ctrl),
		audit:    mocks.NewMockAuditRepository(ctrl),
		role:     mocks.NewMockRoleRepository(ctrl),
	}
	uc := usecase.NewAdminUseCase(m.admin, m.user, m.ride, m.incident, m.metrics, m.audit, m.role)
	return uc, m
}

func strPtr(s string) *string { return &s }

func adminFixture(id uuid.UUID, role domain.UserRole) *domain.User {
	return &domain.User{
		ID:        id,
		Name:      "Alice Admin",
		Email:     "alice@sakai.ph",
		Role:      role,
		CreatedAt: time.Now(),
	}
}

func TestUpdateAdminStatus_SelfModification(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, _ := newAdminUC(ctrl)

	id := uuid.New()
	err := uc.UpdateAdminStatus(context.Background(), id, id, nil, nil, uuid.New())
	if err == nil || err.Error() != "cannot modify own account status" {
		t.Fatalf("expected self-mod block, got %v", err)
	}
}

func TestUpdateAdminStatus_SystemRole_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.MustParse("10000000-0000-0000-0000-000000000002") // operations
	old := adminFixture(target, domain.RoleSupport)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "operations", IsSystem: true,
	}, nil)
	m.admin.EXPECT().UpdateAdminProfile(
		gomock.Any(), target, old.Name, old.Email, domain.RoleOperations, roleID,
	).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	if err := uc.UpdateAdminStatus(context.Background(), actor, target, nil, nil, roleID); err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}

func TestUpdateAdminStatus_CustomRole_BucketsIntoAdmin(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.New() // custom
	old := adminFixture(target, domain.RoleSupport)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "Marketing", IsSystem: false,
	}, nil)
	// custom role name not in ENUM → bucket into RoleAdmin
	m.admin.EXPECT().UpdateAdminProfile(
		gomock.Any(), target, old.Name, old.Email, domain.RoleAdmin, roleID,
	).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	if err := uc.UpdateAdminStatus(context.Background(), actor, target, nil, nil, roleID); err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}

func TestUpdateAdminStatus_RoleNotFound(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.New()
	old := adminFixture(target, domain.RoleSupport)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(nil, domain.ErrNotFound)

	err := uc.UpdateAdminStatus(context.Background(), actor, target, nil, nil, roleID)
	if !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
}

func TestUpdateAdminStatus_RejectSuperPromotion(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.MustParse("10000000-0000-0000-0000-000000000001")
	old := adminFixture(target, domain.RoleOperations)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "super_admin", IsSystem: true,
	}, nil)

	err := uc.UpdateAdminStatus(context.Background(), actor, target, nil, nil, roleID)
	if err == nil || err.Error() != "cannot promote to superadmin via role update" {
		t.Fatalf("expected super promotion block, got %v", err)
	}
}

func TestUpdateAdminStatus_LastSuperadminGuard(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.MustParse("10000000-0000-0000-0000-000000000002") // operations
	old := adminFixture(target, domain.RoleSuperadmin)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "operations", IsSystem: true,
	}, nil)
	// Only this superadmin exists.
	m.admin.EXPECT().GetAdmins(gomock.Any()).Return([]*domain.User{old}, nil)

	err := uc.UpdateAdminStatus(context.Background(), actor, target, nil, nil, roleID)
	if err == nil || err.Error() != "cannot remove the last superadmin" {
		t.Fatalf("expected last-superadmin block, got %v", err)
	}
}

func TestUpdateAdminStatus_NameEmailUpdate_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.MustParse("10000000-0000-0000-0000-000000000003") // finance
	old := adminFixture(target, domain.RoleFinance)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "finance", IsSystem: true,
	}, nil)
	// Email changed → collision check, no existing user.
	m.user.EXPECT().GetByEmail(gomock.Any(), "alice.new@sakai.ph").
		Return(nil, domain.ErrNotFound)
	m.admin.EXPECT().UpdateAdminProfile(
		gomock.Any(), target, "Alice Updated", "alice.new@sakai.ph",
		domain.RoleFinance, roleID,
	).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	err := uc.UpdateAdminStatus(context.Background(), actor, target,
		strPtr("Alice Updated"), strPtr("alice.new@sakai.ph"), roleID)
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}

func TestUpdateAdminStatus_EmailCollision(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	otherID := uuid.New()
	roleID := uuid.MustParse("10000000-0000-0000-0000-000000000003")
	old := adminFixture(target, domain.RoleFinance)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "finance", IsSystem: true,
	}, nil)
	m.user.EXPECT().GetByEmail(gomock.Any(), "taken@sakai.ph").
		Return(&domain.User{ID: otherID, Email: "taken@sakai.ph"}, nil)

	err := uc.UpdateAdminStatus(context.Background(), actor, target,
		nil, strPtr("taken@sakai.ph"), roleID)
	if !errors.Is(err, domain.ErrEmailAlreadyRegistered) {
		t.Fatalf("expected ErrEmailAlreadyRegistered, got %v", err)
	}
}

func TestUpdateAdminStatus_EmailUnchanged_NoCollisionCheck(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	roleID := uuid.MustParse("10000000-0000-0000-0000-000000000003")
	old := adminFixture(target, domain.RoleFinance)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "finance", IsSystem: true,
	}, nil)
	// No GetByEmail expectation → test asserts it's NOT called.
	m.admin.EXPECT().UpdateAdminProfile(
		gomock.Any(), target, old.Name, old.Email, domain.RoleFinance, roleID,
	).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	err := uc.UpdateAdminStatus(context.Background(), actor, target,
		nil, strPtr(old.Email), roleID)
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}

func TestCreateAdmin_RejectsSuperadminByEnum(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, _ := newAdminUC(ctrl)

	_, err := uc.CreateAdmin(context.Background(), uuid.New(),
		"Evil", "evil@sakai.ph", "password123", domain.RoleSuperadmin, nil)
	if err == nil {
		t.Fatal("expected superadmin creation to be rejected")
	}
}

func TestCreateAdmin_RejectsSuperadminByRoleID(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	roleID := uuid.New()
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "super_admin",
	}, nil)

	_, err := uc.CreateAdmin(context.Background(), uuid.New(),
		"Evil", "evil@sakai.ph", "password123", domain.RoleAdmin, &roleID)
	if err == nil {
		t.Fatal("expected superadmin-by-role_id creation to be rejected")
	}
}

func TestCreateAdmin_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	roleID := uuid.New()
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "operations", IsSystem: true,
	}, nil)
	m.user.EXPECT().GetByEmail(gomock.Any(), "new@admin.com").Return(nil, domain.ErrNotFound)
	m.user.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	_, err := uc.CreateAdmin(context.Background(), actor, "New Admin", "new@admin.com", "password123", domain.RoleOperations, &roleID)
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}

func TestDeactivateAdmin_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	old := adminFixture(target, domain.RoleSupport)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.admin.EXPECT().DeactivateAdmin(gomock.Any(), target).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	err := uc.DeactivateAdmin(context.Background(), actor, target)
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}

func TestResetUserPassword_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	old := adminFixture(target, domain.RoleSupport)

	m.user.EXPECT().GetByID(gomock.Any(), target).Return(old, nil)
	m.user.EXPECT().UpdatePassword(gomock.Any(), target, gomock.Any()).Return(nil)
	m.audit.EXPECT().Store(gomock.Any(), gomock.Any()).Return(nil)

	err := uc.ResetUserPassword(context.Background(), actor, target, "newpassword123")
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
}
