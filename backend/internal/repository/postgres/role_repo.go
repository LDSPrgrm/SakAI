package postgres

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type roleRepo struct {
	db *pgxpool.Pool //nolint:unused
}

func NewRoleRepo(db *pgxpool.Pool) domain.RoleRepository {
	return &roleRepo{db: db}
}

// stubRoles returns built-in system roles used as seed data until a roles table exists.
func stubRoles() []*domain.Role {
	return []*domain.Role{
		{
			ID: uuid.MustParse("10000000-0000-0000-0000-000000000001"),
			Name: "super_admin", Description: "Full platform access", IsSystem: true,
			AdminCount: 1, CreatedAt: time.Now(), UpdatedAt: time.Now(),
		},
		{
			ID: uuid.MustParse("10000000-0000-0000-0000-000000000002"),
			Name: "operations", Description: "Users, rides, KYC, safety", IsSystem: true,
			AdminCount: 0, CreatedAt: time.Now(), UpdatedAt: time.Now(),
		},
		{
			ID: uuid.MustParse("10000000-0000-0000-0000-000000000003"),
			Name: "finance", Description: "Payments and reports", IsSystem: true,
			AdminCount: 0, CreatedAt: time.Now(), UpdatedAt: time.Now(),
		},
		{
			ID: uuid.MustParse("10000000-0000-0000-0000-000000000004"),
			Name: "support", Description: "Read-only: users, rides, incidents", IsSystem: true,
			AdminCount: 0, CreatedAt: time.Now(), UpdatedAt: time.Now(),
		},
	}
}

func (r *roleRepo) ListRoles(_ context.Context) ([]*domain.Role, error) {
	return stubRoles(), nil
}

func (r *roleRepo) CreateRole(_ context.Context, role *domain.Role) error {
	if role.ID == uuid.Nil {
		role.ID = uuid.New()
	}
	role.CreatedAt = time.Now()
	role.UpdatedAt = time.Now()
	return nil
}

func (r *roleRepo) GetRoleByID(_ context.Context, id uuid.UUID) (*domain.Role, error) {
	for _, role := range stubRoles() {
		if role.ID == id {
			return role, nil
		}
	}
	return &domain.Role{
		ID: id, Name: "custom_role", Description: "Custom role", IsSystem: false,
		CreatedAt: time.Now(), UpdatedAt: time.Now(),
	}, nil
}

func (r *roleRepo) UpdateRole(_ context.Context, role *domain.Role) error {
	role.UpdatedAt = time.Now()
	return nil
}

func (r *roleRepo) DeleteRole(_ context.Context, _ uuid.UUID) error {
	return nil
}

func (r *roleRepo) GetRolePermissions(_ context.Context, _ uuid.UUID) ([]domain.RolePermission, error) {
	return []domain.RolePermission{
		{PermissionKey: "dashboard", Read: true, Write: false},
		{PermissionKey: "fare_config", Read: true, Write: true},
		{PermissionKey: "payments", Read: true, Write: true},
	}, nil
}

func (r *roleRepo) GetAdminsByRole(_ context.Context, _ uuid.UUID) ([]*domain.User, error) {
	return []*domain.User{}, nil
}
