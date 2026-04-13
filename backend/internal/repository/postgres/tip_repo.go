package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// tipRepo implements domain.TipRepository using PostgreSQL.
type tipRepo struct{ db *pgxpool.Pool }

// NewTipRepo creates a new Postgres-backed TipRepository.
func NewTipRepo(db *pgxpool.Pool) domain.TipRepository {
	return &tipRepo{db: db}
}

func (r *tipRepo) AddTip(ctx context.Context, rideID uuid.UUID, tipAmount float64) (*domain.TipOutput, error) {
	// Fetch the base fare from the rides table.
	var baseFare float64
	if err := r.db.QueryRow(ctx, `SELECT fare FROM rides WHERE id = $1`, rideID).Scan(&baseFare); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}

	now := time.Now()
	id := uuid.New()
	currency := "USD"
	method := "card" // Tips are always card-based.

	const q = `
		INSERT INTO ride_tips (
			id, ride_id, tip_amount, base_fare, currency, method,
			processed_at, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	if _, err := r.db.Exec(ctx, q, id, rideID, tipAmount, baseFare, currency, method, now, now); err != nil {
		return nil, err
	}

	return &domain.TipOutput{
		RideID:        rideID,
		BaseFare:      baseFare,
		TipAmount:     tipAmount,
		FinalTotal:    baseFare + tipAmount,
		Currency:      currency,
		PaymentMethod: method,
		ProcessedAt:   now,
	}, nil
}

func (r *tipRepo) GetByRideID(ctx context.Context, rideID uuid.UUID) (*domain.TipOutput, error) {
	const q = `
		SELECT id, ride_id, tip_amount, base_fare, currency, method,
		       processed_at, created_at
		FROM ride_tips
		WHERE ride_id = $1`
	return r.scanTip(r.db.QueryRow(ctx, q, rideID))
}

func (r *tipRepo) scanTip(row pgx.Row) (*domain.TipOutput, error) {
	var id uuid.UUID
	var rideID uuid.UUID
	var tipAmount, baseFare float64
	var currency, method string
	var processedAt, createdAt time.Time

	err := row.Scan(&id, &rideID, &tipAmount, &baseFare, &currency, &method, &processedAt, &createdAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	return &domain.TipOutput{
		RideID:        rideID,
		BaseFare:      baseFare,
		TipAmount:     tipAmount,
		FinalTotal:    baseFare + tipAmount,
		Currency:      currency,
		PaymentMethod: method,
		ProcessedAt:   processedAt,
	}, nil
}
