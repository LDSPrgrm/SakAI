package postgres

import (
	"bytes"
	"context"
	"encoding/csv"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type reportRepo struct {
	db *pgxpool.Pool //nolint:unused
}

func NewReportRepo(db *pgxpool.Pool) domain.ReportRepository {
	return &reportRepo{db: db}
}

func (r *reportRepo) ListReports(_ context.Context) ([]*domain.ReportDefinition, error) {
	return []*domain.ReportDefinition{
		{ID: "weekly-financial", Title: "Weekly Financial Summary", Description: "Revenue, payouts, and commission breakdown by week"},
		{ID: "driver-performance", Title: "Driver Performance", Description: "Completion rates, ratings, and trip counts per driver"},
		{ID: "rider-retention", Title: "Rider Retention", Description: "New vs returning rider analysis and churn indicators"},
		{ID: "ride-volume", Title: "Ride Volume by Area", Description: "Heatmap data for rides per barangay or district"},
		{ID: "vehicle-type", Title: "Vehicle Type Analysis", Description: "Demand and revenue split by vehicle type"},
		{ID: "safety-incident", Title: "Safety Incident Report", Description: "Incident trends, types, and resolution times"},
		{ID: "kyc-processing", Title: "KYC Processing Report", Description: "Approval rates, rejection reasons, and turnaround time"},
	}, nil
}

func (r *reportRepo) GetChartData(_ context.Context, reportType string) ([]map[string]interface{}, error) {
	switch reportType {
	case "weekly-financial":
		return []map[string]interface{}{
			{"label": "Mon", "revenue": 8400.0, "payouts": 6720.0, "commission": 840.0},
			{"label": "Tue", "revenue": 9200.0, "payouts": 7360.0, "commission": 920.0},
			{"label": "Wed", "revenue": 7800.0, "payouts": 6240.0, "commission": 780.0},
			{"label": "Thu", "revenue": 10500.0, "payouts": 8400.0, "commission": 1050.0},
			{"label": "Fri", "revenue": 12300.0, "payouts": 9840.0, "commission": 1230.0},
			{"label": "Sat", "revenue": 15600.0, "payouts": 12480.0, "commission": 1560.0},
			{"label": "Sun", "revenue": 14200.0, "payouts": 11360.0, "commission": 1420.0},
		}, nil
	case "driver-performance":
		return []map[string]interface{}{
			{"label": "Mon", "value": 88},
			{"label": "Tue", "value": 91},
			{"label": "Wed", "value": 87},
			{"label": "Thu", "value": 93},
			{"label": "Fri", "value": 95},
			{"label": "Sat", "value": 89},
			{"label": "Sun", "value": 92},
		}, nil
	default:
		return []map[string]interface{}{
			{"label": "Mon", "value": 10},
			{"label": "Tue", "value": 20},
			{"label": "Wed", "value": 15},
			{"label": "Thu", "value": 25},
			{"label": "Fri", "value": 30},
			{"label": "Sat", "value": 40},
			{"label": "Sun", "value": 35},
		}, nil
	}
}

func (r *reportRepo) ExportReport(_ context.Context, reportType string) ([]byte, error) {
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)

	_ = w.Write([]string{"report_type", "label", "value"})
	rows := [][]string{
		{reportType, "Mon", "10"},
		{reportType, "Tue", "20"},
		{reportType, "Wed", "15"},
		{reportType, "Thu", "25"},
		{reportType, "Fri", "30"},
		{reportType, "Sat", "40"},
		{reportType, "Sun", "35"},
	}
	for _, row := range rows {
		_ = w.Write(row)
	}
	w.Flush()
	return buf.Bytes(), nil
}
