package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type metricsRepo struct{ db *pgxpool.Pool }

func NewMetricsRepo(db *pgxpool.Pool) domain.MetricsRepository {
	return &metricsRepo{db: db}
}

func (r *metricsRepo) GetRiderMetrics(ctx context.Context) (*domain.MetricResponse, error) {
	var current, previous float64
	const qCurrent = `SELECT COUNT(DISTINCT passenger_id) FROM rides WHERE created_at >= CURRENT_DATE`
	const qPrevious = `SELECT COUNT(DISTINCT passenger_id) FROM rides WHERE created_at >= CURRENT_DATE - INTERVAL '1 day' AND created_at < CURRENT_DATE`
	if err := r.db.QueryRow(ctx, qCurrent).Scan(&current); err != nil {
		return nil, err
	}
	if err := r.db.QueryRow(ctx, qPrevious).Scan(&previous); err != nil {
		previous = 0
	}
	return buildMetric(current, previous), nil
}

func (r *metricsRepo) GetDriverMetrics(ctx context.Context) (*domain.MetricResponse, error) {
	var current, previous float64
	const qCurrent = `SELECT COUNT(DISTINCT driver_id) FROM rides WHERE driver_id IS NOT NULL AND created_at >= CURRENT_DATE`
	const qPrevious = `SELECT COUNT(DISTINCT driver_id) FROM rides WHERE driver_id IS NOT NULL AND created_at >= CURRENT_DATE - INTERVAL '1 day' AND created_at < CURRENT_DATE`
	if err := r.db.QueryRow(ctx, qCurrent).Scan(&current); err != nil {
		return nil, err
	}
	if err := r.db.QueryRow(ctx, qPrevious).Scan(&previous); err != nil {
		previous = 0
	}
	return buildMetric(current, previous), nil
}

func (r *metricsRepo) GetRideMetrics(ctx context.Context, _ string) (*domain.MetricResponse, error) {
	var current, previous float64
	const qCurrent = `SELECT COUNT(*) FROM rides WHERE created_at >= CURRENT_DATE`
	const qPrevious = `SELECT COUNT(*) FROM rides WHERE created_at >= CURRENT_DATE - INTERVAL '1 day' AND created_at < CURRENT_DATE`
	if err := r.db.QueryRow(ctx, qCurrent).Scan(&current); err != nil {
		return nil, err
	}
	if err := r.db.QueryRow(ctx, qPrevious).Scan(&previous); err != nil {
		previous = 0
	}
	return buildMetric(current, previous), nil
}

func (r *metricsRepo) GetRevenueMetrics(_ context.Context, _ string) (*domain.MetricResponse, error) {
	// Stub: revenue requires billing schema
	return buildMetric(48250.75, 42100.00), nil
}

func (r *metricsRepo) GetWaitTimeMetrics(_ context.Context) (*domain.MetricResponse, error) {
	// Stub: requires accepted_at timestamp in rides
	return buildMetric(240, 280), nil // seconds
}

// metroManilaBounds is the fallback bounding box served when no online drivers
// have a recorded location yet.
var metroManilaBounds = domain.HeatmapBounds{North: 14.78, South: 14.40, East: 121.13, West: 120.93}

func (r *metricsRepo) GetDriverHeatmap(ctx context.Context) (*domain.DriverHeatmap, error) {
	const q = `
		SELECT d.user_id,
		       ST_Y(d.location) AS lat,
		       ST_X(d.location) AS lng,
		       COALESCE(v.vehicle_type::text, '') AS vehicle_type,
		       NOT EXISTS (
		           SELECT 1 FROM rides
		           WHERE driver_id = d.user_id
		             AND status NOT IN ('completed', 'cancelled')
		       ) AS is_available,
		       d.updated_at
		FROM drivers d
		LEFT JOIN vehicles v ON v.driver_id = d.user_id
		WHERE d.status = 'online' AND d.location IS NOT NULL
		LIMIT 500`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := &domain.DriverHeatmap{
		Positions:   []domain.HeatmapPosition{},
		Bounds:      metroManilaBounds,
		GeneratedAt: time.Now().UTC(),
	}
	var north, south, east, west float64
	first := true
	for rows.Next() {
		p := domain.HeatmapPosition{}
		if err := rows.Scan(&p.DriverID, &p.Lat, &p.Lng, &p.VehicleType, &p.IsAvailable, &p.UpdatedAt); err != nil {
			return nil, err
		}
		out.Positions = append(out.Positions, p)
		if first {
			north, south, east, west = p.Lat, p.Lat, p.Lng, p.Lng
			first = false
			continue
		}
		if p.Lat > north {
			north = p.Lat
		}
		if p.Lat < south {
			south = p.Lat
		}
		if p.Lng > east {
			east = p.Lng
		}
		if p.Lng < west {
			west = p.Lng
		}
	}
	if !first {
		out.Bounds = domain.HeatmapBounds{North: north, South: south, East: east, West: west}
	}
	return out, rows.Err()
}

func buildMetric(current, previous float64) *domain.MetricResponse {
	var changePct float64
	trend := "flat"
	if previous > 0 {
		changePct = ((current - previous) / previous) * 100
	}
	if changePct > 0.5 {
		trend = "up"
	} else if changePct < -0.5 {
		trend = "down"
	}
	return &domain.MetricResponse{
		Current:       current,
		Previous:      previous,
		ChangePercent: changePct,
		Trend:         trend,
	}
}
