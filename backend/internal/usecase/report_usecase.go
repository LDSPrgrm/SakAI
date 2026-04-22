package usecase

import (
	"context"
	"time"

	"github.com/sakai/backend/internal/domain"
)

type reportUseCase struct {
	reportRepo domain.ReportRepository
}

func NewReportUseCase(reportRepo domain.ReportRepository) domain.ReportUseCase {
	return &reportUseCase{reportRepo: reportRepo}
}

func (uc *reportUseCase) ListReports(ctx context.Context) ([]*domain.ReportDefinition, error) {
	return uc.reportRepo.ListReports(ctx)
}

func (uc *reportUseCase) GetChartData(ctx context.Context, reportType string, from, to *time.Time) ([]map[string]interface{}, error) {
	return uc.reportRepo.GetChartData(ctx, reportType, from, to)
}

func (uc *reportUseCase) ExportReport(ctx context.Context, reportType string, from, to *time.Time) ([]byte, error) {
	return uc.reportRepo.ExportReport(ctx, reportType, from, to)
}
