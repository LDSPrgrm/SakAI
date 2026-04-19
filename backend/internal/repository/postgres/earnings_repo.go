package postgres

import (
	"context"
	"log"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// earningsRepo implements domain.EarningsRepository using PostgreSQL.
type earningsRepo struct{ db *pgxpool.Pool }

// NewEarningsRepo creates a new Postgres-backed EarningsRepository.
func NewEarningsRepo(db *pgxpool.Pool) domain.EarningsRepository {
	return &earningsRepo{db: db}
}

func (r *earningsRepo) Create(ctx context.Context, earnings *domain.DriverEarnings) error {
	const q = `
		INSERT INTO driver_earnings (
			id, driver_id, ride_id, fare_amount, tip_amount, currency, completed_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.db.Exec(ctx, q,
		earnings.ID, earnings.DriverID, earnings.RideID,
		earnings.FareAmount, earnings.TipAmount, earnings.Currency, earnings.CompletedAt,
	)
	if err != nil {
		log.Printf("[EARNINGS_REPO] Error creating earnings for ride %s: %v", earnings.RideID, err)
	}
	return err
}

func (r *earningsRepo) ListByDriverID(ctx context.Context, driverID uuid.UUID, from, to *time.Time, page, limit int) ([]*domain.DriverEarnings, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 20
	}
	offset := (page - 1) * limit

	// Build query with optional date filters.
	args := []any{driverID}
	where := "WHERE driver_id = $1"
	argIdx := 2

	if from != nil {
		where += " AND completed_at >= $" + strconv.Itoa(argIdx)
		args = append(args, *from)
		argIdx++
	}
	if to != nil {
		where += " AND completed_at <= $" + strconv.Itoa(argIdx)
		args = append(args, *to)
		argIdx++
	}

	const countBase = `SELECT COUNT(*) FROM driver_earnings %s`
	countQ := countBase + " " + where
	var total int
	if err := r.db.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	const dataBase = `SELECT id, driver_id, ride_id, fare_amount, tip_amount, total_amount, currency, completed_at FROM driver_earnings %s ORDER BY completed_at DESC LIMIT $%d OFFSET $%d`
	dataQ := dataBase + " " + where
	dataQ = dataQ + " ORDER BY completed_at DESC"
	// Append limit and offset.
	args = append(args, limit, offset)
	dataQ += " LIMIT $" + strconv.Itoa(argIdx) + " OFFSET $" + strconv.Itoa(argIdx+1)

	rows, err := r.db.Query(ctx, dataQ, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var results []*domain.DriverEarnings
	for rows.Next() {
		e := &domain.DriverEarnings{}
		if err := rows.Scan(&e.ID, &e.DriverID, &e.RideID, &e.FareAmount, &e.TipAmount, &e.TotalAmount, &e.Currency, &e.CompletedAt); err != nil {
			return nil, 0, err
		}
		results = append(results, e)
	}
	return results, total, rows.Err()
}

var _ = domain.EarningsRepository(&earningsRepo{}) // compile-time assertion
