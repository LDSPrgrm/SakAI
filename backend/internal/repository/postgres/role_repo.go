package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type roleRepo struct {
	db *pgxpool.Pool
}

func NewRoleRepo(db *pgxpool.Pool) domain.RoleRepository {
	return &roleRepo{db: db}
}

// ListRoles returns all roles ordered by system roles first, then name.
// Each role's permissions and admin_count are populated.
func (r *roleRepo) ListRoles(ctx context.Context) ([]*domain.Role, error) {
	const q = `
		SELECT r.id, r.name, r.description, r.is_system, r.created_by, r.created_at, r.updated_at,
		       (SELECT COUNT(*) FROM users u WHERE u.role_id = r.id) AS admin_count
		FROM roles r
		ORDER BY r.is_system DESC, r.name`

	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var roles []*domain.Role
	for rows.Next() {
		role := &domain.Role{}
		var createdBy *uuid.UUID
		if err := rows.Scan(
			&role.ID, &role.Name, &role.Description, &role.IsSystem,
			&createdBy, &role.CreatedAt, &role.UpdatedAt, &role.AdminCount,
		); err != nil {
			return nil, err
		}
		if createdBy != nil {
			role.CreatedBy = *createdBy
		}
		roles = append(roles, role)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Load permissions for each role
	for _, role := range roles {
		perms, err := r.GetRolePermissions(ctx, role.ID)
		if err != nil {
			return nil, err
		}
		role.Permissions = perms
	}
	return roles, nil
}

// CreateRole inserts a new role and its permissions in a single transaction.
func (r *roleRepo) CreateRole(ctx context.Context, role *domain.Role) error {
	if role.ID == uuid.Nil {
		role.ID = uuid.New()
	}

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	const insertRole = `
		INSERT INTO roles (id, name, description, is_system, created_by, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`

	var createdBy *uuid.UUID
	if role.CreatedBy != uuid.Nil {
		createdBy = &role.CreatedBy
	}
	if _, err := tx.Exec(ctx, insertRole,
		role.ID, role.Name, role.Description, role.IsSystem,
		createdBy, role.CreatedAt, role.UpdatedAt,
	); err != nil {
		return err
	}

	if err := insertPermissions(ctx, tx, role.ID, role.Permissions); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// GetRoleByID returns a single role with its permissions and admin_count.
func (r *roleRepo) GetRoleByID(ctx context.Context, id uuid.UUID) (*domain.Role, error) {
	const q = `
		SELECT r.id, r.name, r.description, r.is_system, r.created_by, r.created_at, r.updated_at,
		       (SELECT COUNT(*) FROM users u WHERE u.role_id = r.id) AS admin_count
		FROM roles r
		WHERE r.id = $1`

	role := &domain.Role{}
	var createdBy *uuid.UUID
	err := r.db.QueryRow(ctx, q, id).Scan(
		&role.ID, &role.Name, &role.Description, &role.IsSystem,
		&createdBy, &role.CreatedAt, &role.UpdatedAt, &role.AdminCount,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if createdBy != nil {
		role.CreatedBy = *createdBy
	}

	perms, err := r.GetRolePermissions(ctx, role.ID)
	if err != nil {
		return nil, err
	}
	role.Permissions = perms
	return role, nil
}

// UpdateRole replaces the role's fields and permissions atomically.
func (r *roleRepo) UpdateRole(ctx context.Context, role *domain.Role) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	const updateRole = `
		UPDATE roles
		SET name = $1, description = $2, updated_at = $3
		WHERE id = $4`

	if _, err := tx.Exec(ctx, updateRole,
		role.Name, role.Description, role.UpdatedAt, role.ID,
	); err != nil {
		return err
	}

	// Replace permissions: delete existing, re-insert new ones
	if _, err := tx.Exec(ctx, `DELETE FROM role_permissions WHERE role_id = $1`, role.ID); err != nil {
		return err
	}
	if err := insertPermissions(ctx, tx, role.ID, role.Permissions); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// DeleteRole removes the role; ON DELETE CASCADE removes its permissions.
func (r *roleRepo) DeleteRole(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM roles WHERE id = $1`, id)
	return err
}

// GetRolePermissions returns all permissions for a role.
func (r *roleRepo) GetRolePermissions(ctx context.Context, roleID uuid.UUID) ([]domain.RolePermission, error) {
	const q = `
		SELECT permission_key, read, write
		FROM role_permissions
		WHERE role_id = $1
		ORDER BY permission_key`

	rows, err := r.db.Query(ctx, q, roleID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var perms []domain.RolePermission
	for rows.Next() {
		var p domain.RolePermission
		if err := rows.Scan(&p.PermissionKey, &p.Read, &p.Write); err != nil {
			return nil, err
		}
		perms = append(perms, p)
	}
	return perms, rows.Err()
}

// GetAdminsByRole returns users assigned to the given role via the role_id FK.
func (r *roleRepo) GetAdminsByRole(ctx context.Context, roleID uuid.UUID) ([]*domain.User, error) {
	const q = `
		SELECT u.id, u.name, u.email, u.role, u.created_at
		FROM users u
		WHERE u.role_id = $1`

	rows, err := r.db.Query(ctx, q, roleID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*domain.User
	for rows.Next() {
		u := &domain.User{}
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.Role, &u.CreatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

// ── helpers ───────────────────────────────────────────────────────────────────

// insertPermissions batch-inserts role permissions within an existing transaction.
func insertPermissions(ctx context.Context, tx pgx.Tx, roleID uuid.UUID, perms []domain.RolePermission) error {
	const q = `
		INSERT INTO role_permissions (role_id, permission_key, read, write)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (role_id, permission_key) DO UPDATE
		    SET read = EXCLUDED.read, write = EXCLUDED.write`

	for _, p := range perms {
		if _, err := tx.Exec(ctx, q, roleID, p.PermissionKey, p.Read, p.Write); err != nil {
			return err
		}
	}
	return nil
}
