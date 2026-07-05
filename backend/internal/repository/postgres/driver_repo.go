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

func (r *driverRepo) UpdateStatus(ctx context.Context, userID uuid.UUID, status domain.DriverStatus) (*domain.Driver, error) {
	const q = `
		INSERT INTO drivers (user_id, status, updated_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (user_id) DO UPDATE SET status = $2, updated_at = NOW()
		RETURNING user_id, status,
		          ST_Y(location::geometry) AS lat,
		          ST_X(location::geometry) AS lng,
		          updated_at`

	d := &domain.Driver{}
	var lat, lng *float64
	err := r.db.QueryRow(ctx, q, userID, status).Scan(&d.UserID, &d.Status, &lat, &lng, &d.UpdatedAt)
	if err != nil {
		return nil, err
	}
	if lat != nil && lng != nil {
		d.Location = &domain.DriverLocation{LatLng: domain.LatLng{Lat: *lat, Lng: *lng}}
	}
	return d, nil
}

// UpdateLocation writes the driver's position only while they are online —
// the status predicate replaces a separate SELECT on the GPS hot path.
// Zero rows affected means offline (or no driver row): ErrForbidden.
func (r *driverRepo) UpdateLocation(ctx context.Context, userID uuid.UUID, loc domain.DriverLocation) error {
	const q = `
		UPDATE drivers
		SET location  = ST_SetSRID(ST_MakePoint($2, $3), 4326),
		    updated_at = NOW()
		WHERE user_id = $1
		  AND status  = 'online'`
	tag, err := r.db.Exec(ctx, q, userID, loc.Lng, loc.Lat)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrForbidden
	}
	return nil
}

func (r *driverRepo) FindNearbyOnline(ctx context.Context, origin domain.LatLng, radiusMeters float64) ([]*domain.Driver, error) {
	if radiusMeters <= 0 {
		radiusMeters = defaultSearchRadiusMeters
	}
	const q = `
		SELECT user_id, status,
		       ST_Y(location) AS lat,
		       ST_X(location) AS lng,
		       updated_at
		FROM drivers
		WHERE status = 'online'
		  AND NOT EXISTS (
		        SELECT 1 FROM rides
		        WHERE driver_id = drivers.user_id
		          AND status NOT IN ('completed', 'cancelled')
		      )
		  AND ST_DWithin(
		        location::geography,
		        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
		        $3
		      )
		ORDER BY ST_Distance(location::geography, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography)
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

func (r *driverRepo) FindNearbyOnlineByType(ctx context.Context, lat, lng float64, radiusM float64, rideType domain.RideType) ([]domain.NearbyDriver, error) {
	if radiusM <= 0 {
		radiusM = defaultSearchRadiusMeters
	}
	// Query joins drivers with vehicles to filter by vehicle_type and enrich response.
	const q = `
		SELECT d.user_id, d.status,
		       ST_Y(d.location) AS lat,
		       ST_X(d.location) AS lng,
		       v.make, v.model, v.plate, v.vehicle_type,
		       COALESCE(AVG(rt.stars), 0) AS rating,
		       ST_Distance(d.location::geography, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography) AS distance_m
		FROM drivers d
		INNER JOIN vehicles v ON v.user_id = d.user_id
		LEFT JOIN ratings rt ON rt.ratee_id = d.user_id
		WHERE d.status = 'online'
		  AND NOT EXISTS (
		        SELECT 1 FROM rides
		        WHERE driver_id = d.user_id
		          AND status NOT IN ('completed', 'cancelled')
		      )
		  AND v.vehicle_type = $4
		  AND ST_DWithin(
		        d.location::geography,
		        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
		        $3
		      )
		GROUP BY d.user_id, d.status, d.location, v.make, v.model, v.plate, v.vehicle_type
		ORDER BY distance_m
		LIMIT 20`

	rows, err := r.db.Query(ctx, q, lat, lng, radiusM, rideType)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []domain.NearbyDriver
	for rows.Next() {
		var nd domain.NearbyDriver
		var userID uuid.UUID
		var status string
		var make, model, plate, vehicleType *string
		var rating *float64
		if err := rows.Scan(&userID, &status, &nd.Lat, &nd.Lng, &make, &model, &plate, &vehicleType, &rating, &nd.DistanceM); err != nil {
			return nil, err
		}
		nd.ID = userID.String()
		if make != nil {
			nd.VehicleMake = *make
		}
		if model != nil {
			nd.VehicleModel = *model
		}
		if plate != nil {
			nd.VehiclePlate = *plate
		}
		if vehicleType != nil {
			nd.VehicleType = *vehicleType
		}
		if rating != nil && *rating > 0 {
			nd.Rating = rating
		}
		results = append(results, nd)
	}
	return results, rows.Err()
}
