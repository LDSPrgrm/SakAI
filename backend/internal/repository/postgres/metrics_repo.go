package postgres

import (
	"context"

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
