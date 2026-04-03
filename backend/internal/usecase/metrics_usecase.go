package usecase

import (
	"context"

	"github.com/sakai/backend/internal/domain"
)

type metricsUseCase struct {
	metricsRepo domain.MetricsRepository
}

func NewMetricsUseCase(metricsRepo domain.MetricsRepository) domain.MetricsUseCase {
	return &metricsUseCase{metricsRepo: metricsRepo}
}

func (uc *metricsUseCase) GetRiderMetrics(ctx context.Context) (*domain.MetricResponse, error) {
	return uc.metricsRepo.GetRiderMetrics(ctx)
}

func (uc *metricsUseCase) GetDriverMetrics(ctx context.Context) (*domain.MetricResponse, error) {
	return uc.metricsRepo.GetDriverMetrics(ctx)
}

func (uc *metricsUseCase) GetRideMetrics(ctx context.Context, period string) (*domain.MetricResponse, error) {
	return uc.metricsRepo.GetRideMetrics(ctx, period)
}

func (uc *metricsUseCase) GetRevenueMetrics(ctx context.Context, period string) (*domain.MetricResponse, error) {
	return uc.metricsRepo.GetRevenueMetrics(ctx, period)
}

func (uc *metricsUseCase) GetWaitTimeMetrics(ctx context.Context) (*domain.MetricResponse, error) {
	return uc.metricsRepo.GetWaitTimeMetrics(ctx)
}
