package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/sakai/backend/internal/domain"
)

// sosPrefsRepo implements domain.SosPrefsRepository using PostgreSQL.
type sosPrefsRepo struct{ db *pgxpool.Pool }

// NewSosPrefsRepo creates a new Postgres-backed SosPrefsRepository.
func NewSosPrefsRepo(db *pgxpool.Pool) domain.SosPrefsRepository {
	return &sosPrefsRepo{db: db}
}

func (r *sosPrefsRepo) GetLiveLocationOptIn(ctx context.Context, userID uuid.UUID) (bool, error) {
	const q = `SELECT live_location_opt_in FROM sos_safety_prefs WHERE user_id = $1`
	var optIn bool
	err := r.db.QueryRow(ctx, q, userID).Scan(&optIn)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) { // no row → fail closed
			return false, nil
		}
		return false, err
	}
	return optIn, nil
}

func (r *sosPrefsRepo) SetLiveLocationOptIn(ctx context.Context, userID uuid.UUID, optIn bool) error {
	const q = `
		INSERT INTO sos_safety_prefs (user_id, live_location_opt_in, updated_at)
		VALUES ($1, $2, now())
		ON CONFLICT (user_id) DO UPDATE
		SET live_location_opt_in = EXCLUDED.live_location_opt_in, updated_at = now()`
	_, err := r.db.Exec(ctx, q, userID, optIn)
	return err
}
