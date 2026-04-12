package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// ratingRepo implements domain.RatingRepository using PostgreSQL.
type ratingRepo struct{ db *pgxpool.Pool }

// NewRatingRepo creates a new Postgres-backed RatingRepository.
func NewRatingRepo(db *pgxpool.Pool) domain.RatingRepository {
	return &ratingRepo{db: db}
}

func (r *ratingRepo) Create(ctx context.Context, rating *domain.Rating) error {
	const q = `
		INSERT INTO ratings (
			id, ride_id, rater_id, ratee_id, stars, feedback, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.db.Exec(ctx, q,
		rating.ID, rating.RideID, rating.RaterID, rating.RateeID,
		rating.Stars, rating.Feedback, rating.CreatedAt,
	)
	return err
}

func (r *ratingRepo) GetByRideAndRater(ctx context.Context, rideID, raterID uuid.UUID) (*domain.Rating, error) {
	const q = `
		SELECT id, ride_id, rater_id, ratee_id, stars, feedback, created_at
		FROM ratings
		WHERE ride_id = $1 AND rater_id = $2`
	return r.scanRating(r.db.QueryRow(ctx, q, rideID, raterID))
}

func (r *ratingRepo) GetAverageByUserID(ctx context.Context, userID uuid.UUID) (*domain.RatingSummary, error) {
	const q = `
		SELECT ratee_id,
		       COALESCE(AVG(stars), 0) AS average_rating,
		       COUNT(*) AS rating_count,
		       MAX(created_at) AS last_updated
		FROM ratings
		WHERE ratee_id = $1
		GROUP BY ratee_id`

	summary := &domain.RatingSummary{}
	err := r.db.QueryRow(ctx, q, userID).Scan(
		&summary.UserID, &summary.AverageRating, &summary.RatingCount, &summary.LastUpdated,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		// User has no ratings yet — return zero summary.
		return &domain.RatingSummary{
			UserID:        userID,
			AverageRating: 0,
			RatingCount:   0,
		}, nil
	}
	if err != nil {
		return nil, err
	}
	return summary, nil
}

func (r *ratingRepo) scanRating(row pgx.Row) (*domain.Rating, error) {
	rating := &domain.Rating{}
	err := row.Scan(
		&rating.ID, &rating.RideID, &rating.RaterID, &rating.RateeID,
		&rating.Stars, &rating.Feedback, &rating.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return rating, err
}
