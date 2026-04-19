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
			id, passenger_id, driver_id, status,
			origin_lat, origin_lng,
			destination_lat, destination_lng,
			origin_address, destination_address,
			notes, idempotency_key, created_at, updated_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`
	_, err := r.db.Exec(ctx, q,
		ride.ID, ride.PassengerID, ride.DriverID, ride.Status,
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

func (r *rideRepo) SetCancelled(ctx context.Context, id uuid.UUID, by domain.CancelledBy, reasonCode *string, reasonText *string, cancellationFee *float64) error {
	const q = `UPDATE rides SET status = 'cancelled', cancelled_by = $1, cancellation_reason = $2, cancellation_reason_text = $3, fare = COALESCE($4, fare), updated_at = NOW() WHERE id = $5`
	_, err := r.db.Exec(ctx, q, by, reasonCode, reasonText, cancellationFee, id)
	return err
}

func (r *rideRepo) CancelExpiredOffers(ctx context.Context, timeout time.Duration) ([]domain.ExpiredOffer, error) {
	// A single atomic UPDATE is far cheaper than SELECT + per-row UPDATE.
	// cutoff is the oldest updated_at timestamp we still consider "live".
	const q = `
		UPDATE rides
		SET    status       = 'cancelled',
		       cancelled_by = $1,
		       updated_at   = NOW()
		WHERE  status     = 'requested'
		  AND  updated_at < NOW() - $2::interval
		RETURNING id, passenger_id, driver_id`

	intervalStr := fmt.Sprintf("%d seconds", int(timeout.Seconds()))
	rows, err := r.db.Query(ctx, q, domain.CancelledBySystem, intervalStr)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var expired []domain.ExpiredOffer
	for rows.Next() {
		var offer domain.ExpiredOffer
		if err := rows.Scan(&offer.RideID, &offer.PassengerID, &offer.DriverID); err != nil {
			return nil, err
		}
		expired = append(expired, offer)
	}
	return expired, rows.Err()
}

// ListAll returns a paginated list of all rides for admin browsing.
// An optional Status filter is applied; Page and Limit follow standard
// 1-based pagination. Zero values are replaced with sensible defaults.
func (r *rideRepo) ListAll(ctx context.Context, f domain.AdminRideFilter) ([]*domain.Ride, int, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.Limit < 1 {
		f.Limit = 20
	}
	offset := (f.Page - 1) * f.Limit

	// Build the base WHERE clause and args dynamically.
	// We track the parameter index manually to keep the query safe.
	args := []any{}
	where := ""
	if f.Status != nil {
		args = append(args, *f.Status)
		where = "WHERE status = $1"
	}

	// Count query (paginate against the same filter).
	countQ := "SELECT COUNT(*) FROM rides " + where
	var total int
	if err := r.db.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}
	if total == 0 {
		return nil, 0, nil
	}

	// Append LIMIT / OFFSET params after optional status param.
	limitIdx := len(args) + 1
	offsetIdx := limitIdx + 1
	args = append(args, f.Limit, offset)

	dataQ := fmt.Sprintf(`
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides
		%s
		ORDER BY created_at DESC
		LIMIT $%d OFFSET $%d`, where, limitIdx, offsetIdx)

	rows, err := r.db.Query(ctx, dataQ, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var rides []*domain.Ride
	for rows.Next() {
		ride, err := r.scanRide(rows)
		if err != nil {
			return nil, 0, err
		}
		rides = append(rides, ride)
	}
	return rides, total, rows.Err()
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

// ListByPassengerID returns a paginated list of rides for a specific passenger.
func (r *rideRepo) ListByPassengerID(ctx context.Context, passengerID uuid.UUID, f domain.UserRideFilter) ([]*domain.Ride, int, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.Limit < 1 {
		f.Limit = 20
	}
	offset := (f.Page - 1) * f.Limit

	// Build WHERE clause dynamically.
	args := []any{passengerID}
	where := "WHERE passenger_id = $1"
	if len(f.Statuses) > 0 {
		where += " AND status = ANY($2)"
		// Convert []RideStatus to []string for pgx
		statusStrs := make([]string, len(f.Statuses))
		for i, s := range f.Statuses {
			statusStrs[i] = string(s)
		}
		args = append(args, statusStrs)
	}

	// Count query
	countQ := "SELECT COUNT(*) FROM rides " + where
	var total int
	if err := r.db.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}
	if total == 0 {
		return nil, 0, nil
	}

	// Append LIMIT / OFFSET
	limitIdx := len(args) + 1
	offsetIdx := limitIdx + 1
	args = append(args, f.Limit, offset)

	dataQ := fmt.Sprintf(`
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides
		%s
		ORDER BY created_at DESC
		LIMIT $%d OFFSET $%d`, where, limitIdx, offsetIdx)

	rows, err := r.db.Query(ctx, dataQ, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var rides []*domain.Ride
	for rows.Next() {
		ride, err := r.scanRide(rows)
		if err != nil {
			return nil, 0, err
		}
		rides = append(rides, ride)
	}
	return rides, total, rows.Err()
}

// ListByDriverID returns a paginated list of rides for a specific driver.
func (r *rideRepo) ListByDriverID(ctx context.Context, driverID uuid.UUID, f domain.UserRideFilter) ([]*domain.Ride, int, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.Limit < 1 {
		f.Limit = 20
	}
	offset := (f.Page - 1) * f.Limit

	// Build WHERE clause dynamically.
	args := []any{driverID}
	where := "WHERE driver_id = $1"
	if len(f.Statuses) > 0 {
		where += " AND status = ANY($2)"
		// Convert []RideStatus to []string for pgx
		statusStrs := make([]string, len(f.Statuses))
		for i, s := range f.Statuses {
			statusStrs[i] = string(s)
		}
		args = append(args, statusStrs)
	}

	// Count query
	countQ := "SELECT COUNT(*) FROM rides " + where
	var total int
	if err := r.db.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}
	if total == 0 {
		return nil, 0, nil
	}

	// Append LIMIT / OFFSET
	limitIdx := len(args) + 1
	offsetIdx := limitIdx + 1
	args = append(args, f.Limit, offset)

	dataQ := fmt.Sprintf(`
		SELECT id, passenger_id, driver_id, status,
		       origin_lat, origin_lng, destination_lat, destination_lng,
		       origin_address, destination_address, notes,
		       cancelled_by, created_at, updated_at
		FROM rides
		%s
		ORDER BY created_at DESC
		LIMIT $%d OFFSET $%d`, where, limitIdx, offsetIdx)

	rows, err := r.db.Query(ctx, dataQ, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var rides []*domain.Ride
	for rows.Next() {
		ride, err := r.scanRide(rows)
		if err != nil {
			return nil, 0, err
		}
		rides = append(rides, ride)
	}
	return rides, total, rows.Err()
}

func (r *rideRepo) UpdateRideFare(ctx context.Context, rideID uuid.UUID, actualFare float64, breakdown domain.JSONMap) error {
	const q = `UPDATE rides SET actual_fare = $1, fare_breakdown = $2, updated_at = NOW() WHERE id = $3`
	_, err := r.db.Exec(ctx, q, actualFare, breakdown, rideID)
	return err
}

func (r *rideRepo) IncrementDeclineCount(ctx context.Context, rideID uuid.UUID) error {
	const q = `UPDATE rides SET decline_count = decline_count + 1, updated_at = NOW() WHERE id = $1`
	_, err := r.db.Exec(ctx, q, rideID)
	return err
}
