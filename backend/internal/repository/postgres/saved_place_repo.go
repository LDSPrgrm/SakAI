package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type savedPlaceRepo struct{ db *pgxpool.Pool }

func NewSavedPlaceRepo(db *pgxpool.Pool) domain.SavedPlaceRepository {
	return &savedPlaceRepo{db: db}
}

func (r *savedPlaceRepo) Create(ctx context.Context, p *domain.SavedPlace) error {
	const q = `
		INSERT INTO saved_places (
			id, user_id, name, address, latitude, longitude, type, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(ctx, q,
		p.ID, p.UserID, p.Name, p.Address, p.Latitude, p.Longitude, p.Type, p.CreatedAt,
	)
	return err
}

func (r *savedPlaceRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.SavedPlace, error) {
	const q = `
		SELECT id, user_id, name, address, latitude, longitude, type, created_at
		FROM saved_places WHERE id = $1`
	return r.scanSavedPlace(r.db.QueryRow(ctx, q, id))
}

func (r *savedPlaceRepo) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*domain.SavedPlace, error) {
	const q = `
		SELECT id, user_id, name, address, latitude, longitude, type, created_at
		FROM saved_places WHERE user_id = $1
		ORDER BY created_at DESC`
	rows, err := r.db.Query(ctx, q, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var places []*domain.SavedPlace
	for rows.Next() {
		p, err := r.scanSavedPlace(rows)
		if err != nil {
			return nil, err
		}
		places = append(places, p)
	}
	return places, rows.Err()
}

func (r *savedPlaceRepo) Update(ctx context.Context, p *domain.SavedPlace) error {
	const q = `
		UPDATE saved_places
		SET name = $1, address = $2, latitude = $3, longitude = $4, type = $5
		WHERE id = $6 AND user_id = $7`
	_, err := r.db.Exec(ctx, q,
		p.Name, p.Address, p.Latitude, p.Longitude, p.Type, p.ID, p.UserID,
	)
	return err
}

func (r *savedPlaceRepo) Delete(ctx context.Context, id uuid.UUID) error {
	const q = `DELETE FROM saved_places WHERE id = $1`
	_, err := r.db.Exec(ctx, q, id)
	return err
}

func (r *savedPlaceRepo) scanSavedPlace(row pgx.Row) (*domain.SavedPlace, error) {
	p := &domain.SavedPlace{}
	err := row.Scan(
		&p.ID, &p.UserID, &p.Name, &p.Address, &p.Latitude, &p.Longitude, &p.Type, &p.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return p, err
}
