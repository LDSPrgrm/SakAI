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
)

// rideRepo implements repository.RideRepository using PostgreSQL.
type rideRepo struct{ db *pgxpool.Pool }

// NewRideRepo creates a new Postgres-backed RideRepository.
func NewRideRepo(db *pgxpool.Pool) domain.RideRepository {
	return &rideRepo{db: db}
}

func (r *rideRepo) Create(ctx context.Context, ride *domain.Ride) error {
	const q = `
		INSERT INTO rides (
			id, passenger_id, status,
			origin_lat, origin_lng,
			destination_lat, destination_lng,
			origin_address, destination_address,
			notes, idempotency_key, created_at, updated_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`
	_, err := r.db.Exec(ctx, q,
		ride.ID, ride.PassengerID, ride.Status,
		ride.Origin.Lat, ride.Origin.Lng,
		ride.Destination.Lat, ride.Destination.Lng,
		ride.OriginAddress, ride.DestinationAddress,
		ride.Notes, ride.IdempotencyKey, ride.CreatedAt, ride.UpdatedAt,
	)
	return err
}

func (r *rideRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Ride, error) {
	const q = `
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides WHERE id = $1`
	return r.scanRide(r.db.QueryRow(ctx, q, id))
}

func (r *rideRepo) GetByIdempotencyKey(ctx context.Context, key string) (*domain.Ride, error) {
	const q = `
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides WHERE idempotency_key = $1`
	return r.scanRide(r.db.QueryRow(ctx, q, key))
}

func (r *rideRepo) GetActiveByPassengerID(ctx context.Context, pID uuid.UUID) (*domain.Ride, error) {
	const q = `
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides
		WHERE passenger_id = $1
		  AND status NOT IN ('completed','cancelled')
		LIMIT 1`
	return r.scanRide(r.db.QueryRow(ctx, q, pID))
}

func (r *rideRepo) GetActiveByDriverID(ctx context.Context, dID uuid.UUID) (*domain.Ride, error) {
	const q = `
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides
		WHERE driver_id = $1
		  AND status NOT IN ('completed','cancelled')
		LIMIT 1`
	return r.scanRide(r.db.QueryRow(ctx, q, dID))
}

func (r *rideRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.RideStatus) error {
	const q = `UPDATE rides SET status = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.Exec(ctx, q, status, time.Now(), id)
	return err
}

func (r *rideRepo) AssignDriver(ctx context.Context, rideID, driverID uuid.UUID) error {
	const q = `UPDATE rides SET driver_id = $1, status = 'accepted', updated_at = NOW() WHERE id = $2`
	_, err := r.db.Exec(ctx, q, driverID, rideID)
	return err
}

func (r *rideRepo) ClearDriver(ctx context.Context, rideID uuid.UUID) error {
	const q = `UPDATE rides SET driver_id = NULL, updated_at = NOW() WHERE id = $1`
	_, err := r.db.Exec(ctx, q, rideID)
	return err
}

func (r *rideRepo) SetCancelled(ctx context.Context, id uuid.UUID, by domain.CancelledBy) error {
	const q = `UPDATE rides SET status = 'cancelled', cancelled_by = $1, updated_at = NOW() WHERE id = $2`
	_, err := r.db.Exec(ctx, q, by, id)
	return err
}

func (r *rideRepo) CancelExpiredOffers(ctx context.Context, timeout time.Duration) (int64, error) {
	// A single atomic UPDATE is far cheaper than SELECT + per-row UPDATE.
	// cutoff is the oldest updated_at timestamp we still consider "live".
	const q = `
		UPDATE rides
		SET    status       = 'cancelled',
		       cancelled_by = $1,
		       updated_at   = NOW()
		WHERE  status     = 'requested'
		  AND  updated_at < NOW() - $2::interval`

	intervalStr := fmt.Sprintf("%d seconds", int(timeout.Seconds()))
	tag, err := r.db.Exec(ctx, q, domain.CancelledBySystem, intervalStr)
	if err != nil {
		return 0, err
	}
	return tag.RowsAffected(), nil
}

// scanRide is a shared row scanner for ride queries.
func (r *rideRepo) scanRide(row pgx.Row) (*domain.Ride, error) {
	ride := &domain.Ride{}
	var cancelledBy *domain.CancelledBy
	err := row.Scan(
		&ride.ID, &ride.PassengerID, &ride.DriverID, &ride.Status,
		&ride.Origin.Lat, &ride.Origin.Lng,
		&ride.Destination.Lat, &ride.Destination.Lng,
		&ride.OriginAddress, &ride.DestinationAddress, &ride.Notes,
		&cancelledBy, &ride.CreatedAt, &ride.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	ride.CancelledBy = cancelledBy
	return ride, err
}
