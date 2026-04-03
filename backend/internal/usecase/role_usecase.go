package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type roleUseCase struct {
	roleRepo  domain.RoleRepository
	auditRepo domain.AuditRepository
}

func NewRoleUseCase(roleRepo domain.RoleRepository, auditRepo domain.AuditRepository) domain.RoleUseCase {
	return &roleUseCase{roleRepo: roleRepo, auditRepo: auditRepo}
}

func (uc *roleUseCase) ListRoles(ctx context.Context) ([]*domain.Role, error) {
	return uc.roleRepo.ListRoles(ctx)
}

func (uc *roleUseCase) CreateRole(ctx context.Context, actorID uuid.UUID, name, description string, permissions []domain.RolePermission) (*domain.Role, error) {
	if name == "" {
		return nil, errors.New("role name is required")
	}
	if len(permissions) == 0 {
		return nil, errors.New("at least one permission is required")
	}
	role := &domain.Role{
		ID:          uuid.New(),
		Name:        name,
		Description: description,
		IsSystem:    false,
		Permissions: permissions,
		CreatedBy:   actorID,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	if err := uc.roleRepo.CreateRole(ctx, role); err != nil {
		return nil, err
	}
	after, _ := json.Marshal(role)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "CREATE", ResourceType: "role",
		ResourceID: role.ID.String(), AfterState: after, IPAddress: "internal",
	})
	return role, nil
}

func (uc *roleUseCase) GetRole(ctx context.Context, id uuid.UUID) (*domain.Role, error) {
	return uc.roleRepo.GetRoleByID(ctx, id)
}

func (uc *roleUseCase) UpdateRole(ctx context.Context, actorID, roleID uuid.UUID, name, description string, permissions []domain.RolePermission) (*domain.Role, error) {
	existing, err := uc.roleRepo.GetRoleByID(ctx, roleID)
	if err != nil {
		return nil, err
	}
	if existing.Name == "super_admin" {
		return nil, errors.New("cannot modify the super_admin role")
	}
	before, _ := json.Marshal(existing)
	existing.Name = name
	existing.Description = description
	existing.Permissions = permissions
	existing.UpdatedAt = time.Now()
	if err := uc.roleRepo.UpdateRole(ctx, existing); err != nil {
		return nil, err
	}
	after, _ := json.Marshal(existing)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "role",
		ResourceID: roleID.String(), BeforeState: before, AfterState: after, IPAddress: "internal",
	})
	return existing, nil
}

func (uc *roleUseCase) DeleteRole(ctx context.Context, actorID, roleID uuid.UUID) error {
	existing, err := uc.roleRepo.GetRoleByID(ctx, roleID)
	if err != nil {
		return err
	}
	if existing.IsSystem {
		return errors.New("cannot delete a system role")
	}
	admins, err := uc.roleRepo.GetAdminsByRole(ctx, roleID)
	if err != nil {
		return err
	}
	if len(admins) > 0 {
		return errors.New("cannot delete a role with active admins assigned")
	}
	if err := uc.roleRepo.DeleteRole(ctx, roleID); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "DELETE", ResourceType: "role",
		ResourceID: roleID.String(), IPAddress: "internal",
	})
	return nil
}

func (uc *roleUseCase) GetRolePermissions(ctx context.Context, roleID uuid.UUID) ([]domain.RolePermission, error) {
	return uc.roleRepo.GetRolePermissions(ctx, roleID)
}

func (uc *roleUseCase) GetRoleAdmins(ctx context.Context, roleID uuid.UUID) ([]*domain.User, error) {
	return uc.roleRepo.GetAdminsByRole(ctx, roleID)
}
