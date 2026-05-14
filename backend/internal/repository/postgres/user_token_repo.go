// Package postgres provides PostgreSQL implementations of the repository interfaces.
// SQL schema must be applied via migrations before these can be used.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/displayid"
	"github.com/sakai/backend/internal/infrastructure/database"
)

// userRepo implements repository.UserRepository using PostgreSQL.
type userRepo struct{ db *pgxpool.Pool }

// NewUserRepo creates a new Postgres-backed UserRepository.
func NewUserRepo(db *pgxpool.Pool) domain.UserRepository {
	return &userRepo{db: db}
}

func (r *userRepo) Create(ctx context.Context, u *domain.User) error {
	const q = `
		INSERT INTO users (id, name, email, password_hash, role, role_id, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.db.Exec(ctx, q, u.ID, u.Name, u.Email, u.Password, u.Role, u.RoleID, u.CreatedAt)
	return err
}

func (r *userRepo) UpdatePassword(ctx context.Context, userID uuid.UUID, passwordHash string) error {
	const q = `UPDATE users SET password_hash = $1 WHERE id = $2`
	_, err := r.db.Exec(ctx, q, passwordHash, userID)
	return err
}

func (r *userRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	const q = `SELECT id, name, email, password_hash, role, role_id, created_at FROM users WHERE id = $1`
	u := &domain.User{}
	err := r.db.QueryRow(ctx, q, id).Scan(&u.ID, &u.Name, &u.Email, &u.Password, &u.Role, &u.RoleID, &u.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if u.Role == domain.RoleDriver {
		u.Vehicle, _ = r.getVehicle(ctx, u.ID)
	}
	return u, nil
}

func (r *userRepo) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	const q = `SELECT id, name, email, password_hash, role, role_id, created_at FROM users WHERE email = $1`
	u := &domain.User{}
	err := r.db.QueryRow(ctx, q, email).Scan(&u.ID, &u.Name, &u.Email, &u.Password, &u.Role, &u.RoleID, &u.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if u.Role == domain.RoleDriver {
		u.Vehicle, _ = r.getVehicle(ctx, u.ID)
	}
	return u, nil
}

// --- Vehicle helper ---

func (r *userRepo) getVehicle(ctx context.Context, userID uuid.UUID) (*domain.Vehicle, error) {
	const q = `SELECT make, model, color, plate FROM vehicles WHERE user_id = $1`
	v := &domain.Vehicle{}
	err := r.db.QueryRow(ctx, q, userID).Scan(&v.Make, &v.Model, &v.Color, &v.Plate)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return v, err
}

// CreateWithTokens atomically inserts the user row and their first refresh
// token inside a single DB transaction. If either step fails the whole
// operation is rolled back, preventing orphaned user records.
func (r *userRepo) CreateWithTokens(
	ctx context.Context,
	u *domain.User,
	refreshToken string,
	expiresAt time.Time,
) error {
	return database.Transact(ctx, r.db, func(tx pgx.Tx) error {
		const insertUser = `
			INSERT INTO users (id, name, email, password_hash, role, created_at)
			VALUES ($1, $2, $3, $4, $5, $6)`
		if _, err := tx.Exec(ctx, insertUser,
			u.ID, u.Name, u.Email, u.Password, u.Role, u.CreatedAt,
		); err != nil {
			return err
		}

		// If the user is a driver, persist their vehicle in the same transaction.
		if u.Vehicle != nil {
			const insertVehicle = `
				INSERT INTO vehicles (user_id, make, model, color, plate)
				VALUES ($1, $2, $3, $4, $5)`
			if _, err := tx.Exec(ctx, insertVehicle,
				u.ID, u.Vehicle.Make, u.Vehicle.Model, u.Vehicle.Color, u.Vehicle.Plate,
			); err != nil {
				return err
			}
		}

		const insertToken = `
			INSERT INTO refresh_tokens (token, user_id, expires_at)
			VALUES ($1, $2, $3)`
		_, err := tx.Exec(ctx, insertToken, refreshToken, u.ID, expiresAt)
		return err
	})
}

func (r *userRepo) Delete(ctx context.Context, id uuid.UUID) error {
	return database.Transact(ctx, r.db, func(tx pgx.Tx) error {
		// Delete refresh tokens first
		const delTokens = `DELETE FROM refresh_tokens WHERE user_id = $1`
		if _, err := tx.Exec(ctx, delTokens, id); err != nil {
			return err
		}

		// Delete vehicle if it exists
		const delVehicle = `DELETE FROM vehicles WHERE user_id = $1`
		if _, err := tx.Exec(ctx, delVehicle, id); err != nil {
			return err
		}

		// Finally delete the user
		const delUser = `DELETE FROM users WHERE id = $1`
		res, err := tx.Exec(ctx, delUser, id)
		if err != nil {
			return err
		}
		if res.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		return nil
	})
}

// ListByRole returns a paginated list of users filtered by role and an
// optional case-insensitive substring search against name or email.
func (r *userRepo) ListByRole(ctx context.Context, f domain.UserListFilter) ([]*domain.User, int, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.Limit < 1 {
		f.Limit = 20
	}
	offset := (f.Page - 1) * f.Limit

	// Build args and WHERE clause dynamically.
	args := []any{}
	conditions := []string{}

	if f.Role != nil {
		args = append(args, *f.Role)
		conditions = append(conditions, fmt.Sprintf("role = $%d", len(args)))
	}
	if f.Search != "" {
		args = append(args, "%"+f.Search+"%")
		idx := len(args)
		conditions = append(conditions, fmt.Sprintf("(name ILIKE $%d OR email ILIKE $%d)", idx, idx))
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + joinAnd(conditions)
	}

	countQ := "SELECT COUNT(*) FROM users " + where
	var total int
	if err := r.db.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}
	if total == 0 {
		return nil, 0, nil
	}

	limitIdx := len(args) + 1
	offsetIdx := limitIdx + 1
	args = append(args, f.Limit, offset)

	dataQ := fmt.Sprintf(
		"SELECT id, seq, name, email, password_hash, role, created_at "+
			"FROM users %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		where, limitIdx, offsetIdx,
	)

	rows, err := r.db.Query(ctx, dataQ, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var users []*domain.User
	for rows.Next() {
		u := &domain.User{}
		if err := rows.Scan(&u.ID, &u.Seq, &u.Name, &u.Email, &u.Password, &u.Role, &u.CreatedAt); err != nil {
			return nil, 0, err
		}
		u.DisplayID = displayid.User(u.Seq)
		users = append(users, u)
	}
	return users, total, rows.Err()
}

// joinAnd joins SQL condition strings with " AND ".
func joinAnd(parts []string) string {
	result := ""
	for i, p := range parts {
		if i > 0 {
			result += " AND "
		}
		result += p
	}
	return result
}

// --- Token repository ---

type tokenRepo struct{ db *pgxpool.Pool }

// NewTokenRepo creates a new Postgres-backed TokenRepository.
func NewTokenRepo(db *pgxpool.Pool) domain.TokenRepository {
	return &tokenRepo{db: db}
}

func (r *tokenRepo) Store(ctx context.Context, userID uuid.UUID, token string, expiresAt time.Time) error {
	const q = `
		INSERT INTO refresh_tokens (token, user_id, expires_at)
		VALUES ($1, $2, $3)`
	_, err := r.db.Exec(ctx, q, token, userID, expiresAt)
	return err
}

func (r *tokenRepo) GetUserID(ctx context.Context, token string) (uuid.UUID, error) {
	const q = `SELECT user_id, expires_at FROM refresh_tokens WHERE token = $1`
	var userID uuid.UUID
	var expiresAt time.Time
	err := r.db.QueryRow(ctx, q, token).Scan(&userID, &expiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return uuid.Nil, domain.ErrRefreshTokenInvalid
	}
	if err != nil {
		return uuid.Nil, err
	}
	if time.Now().After(expiresAt) {
		_ = r.Delete(ctx, token) // best-effort cleanup
		return uuid.Nil, domain.ErrRefreshTokenInvalid
	}
	return userID, nil
}

func (r *tokenRepo) Delete(ctx context.Context, token string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM refresh_tokens WHERE token = $1`, token)
	return err
}

func (r *tokenRepo) Rotate(ctx context.Context, oldToken string, newToken string, userID uuid.UUID, expiresAt time.Time) error {
	return database.Transact(ctx, r.db, func(tx pgx.Tx) error {
		const delQ = `DELETE FROM refresh_tokens WHERE token = $1`
		if _, err := tx.Exec(ctx, delQ, oldToken); err != nil {
			return err
		}

		const insQ = `INSERT INTO refresh_tokens (token, user_id, expires_at) VALUES ($1, $2, $3)`
		if _, err := tx.Exec(ctx, insQ, newToken, userID, expiresAt); err != nil {
			return err
		}

		return nil
	})
}
