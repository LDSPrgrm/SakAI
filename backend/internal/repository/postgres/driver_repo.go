package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

const defaultSearchRadiusMeters = 5000.0

// driverRepo implements repository.DriverRepository using PostgreSQL + PostGIS.
type driverRepo struct{ db *pgxpool.Pool }

// NewDriverRepo creates a new Postgres-backed DriverRepository.
func NewDriverRepo(db *pgxpool.Pool) domain.DriverRepository {
	return &driverRepo{db: db}
}

func (r *driverRepo) Create(ctx context.Context, d *domain.Driver) error {
	const q = `
		INSERT INTO drivers (user_id, status, updated_at)
		VALUES ($1, $2, NOW())`
	_, err := r.db.Exec(ctx, q, d.UserID, d.Status)
	return err
}

func (r *driverRepo) GetByUserID(ctx context.Context, userID uuid.UUID) (*domain.Driver, error) {
	const q = `
		SELECT user_id, status,
		       ST_Y(location::geometry) AS lat,
		       ST_X(location::geometry) AS lng,
		       updated_at
		FROM drivers WHERE user_id = $1`

	d := &domain.Driver{}
	var lat, lng *float64
	err := r.db.QueryRow(ctx, q, userID).Scan(&d.UserID, &d.Status, &lat, &lng, &d.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if lat != nil && lng != nil {
		d.Location = &domain.DriverLocation{LatLng: domain.LatLng{Lat: *lat, Lng: *lng}}
	}
	return d, nil
}

func (r *driverRepo) UpdateStatus(ctx context.Context, userID uuid.UUID, status domain.DriverStatus) error {
	const q = `UPDATE drivers SET status = $1, updated_at = NOW() WHERE user_id = $2`
	_, err := r.db.Exec(ctx, q, status, userID)
	return err
}

func (r *driverRepo) UpdateLocation(ctx context.Context, userID uuid.UUID, loc domain.DriverLocation) error {
	// ST_SetSRID(ST_MakePoint(lng, lat), 4326) stores as PostGIS geography point.
	const q = `
		UPDATE drivers
		SET location  = ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography,
		    updated_at = NOW()
		WHERE user_id = $1`
	_, err := r.db.Exec(ctx, q, userID, loc.Lng, loc.Lat)
	return err
}

func (r *driverRepo) FindNearbyOnline(ctx context.Context, origin domain.LatLng, radiusMeters float64) ([]*domain.Driver, error) {
	if radiusMeters <= 0 {
		radiusMeters = defaultSearchRadiusMeters
	}
	const q = `
		SELECT user_id, status,
		       ST_Y(location::geometry) AS lat,
		       ST_X(location::geometry) AS lng,
		       updated_at
		FROM drivers
		WHERE status = 'online'
		  AND NOT EXISTS (
		        SELECT 1 FROM rides 
		        WHERE driver_id = drivers.user_id 
		          AND status NOT IN ('completed', 'cancelled')
		      )
		  AND ST_DWithin(
		        location,
		        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
		        $3
		      )
		ORDER BY ST_Distance(location, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography)
		LIMIT 1`

	rows, err := r.db.Query(ctx, q, origin.Lat, origin.Lng, radiusMeters)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var drivers []*domain.Driver
	for rows.Next() {
		d := &domain.Driver{}
		var lat, lng float64
		if err := rows.Scan(&d.UserID, &d.Status, &lat, &lng, &d.UpdatedAt); err != nil {
			return nil, err
		}
		d.Location = &domain.DriverLocation{LatLng: domain.LatLng{Lat: lat, Lng: lng}}
		drivers = append(drivers, d)
	}
	return drivers, rows.Err()
}
