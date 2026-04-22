package postgres

import (
	"bytes"
	"context"
	"encoding/csv"
	"fmt"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type reportRepo struct{ db *pgxpool.Pool }

func NewReportRepo(db *pgxpool.Pool) domain.ReportRepository {
	return &reportRepo{db: db}
}

// reportCatalog is the static list of report definitions the UI can render.
// It describes what's available, not what the data contains — data comes from
// GetChartData against real tables.
var reportCatalog = []*domain.ReportDefinition{
	{ID: "weekly-financial", Title: "Weekly Financial Summary", Description: "Revenue, payouts, and commission breakdown by day"},
	{ID: "driver-performance", Title: "Driver Performance", Description: "Completion rates and trip counts per day"},
	{ID: "rider-retention", Title: "Rider Retention", Description: "New vs returning rider counts per day"},
	{ID: "ride-volume", Title: "Ride Volume", Description: "Total rides per day"},
	{ID: "vehicle-distribution", Title: "Vehicle Type Distribution", Description: "Ride share by vehicle type"},
	{ID: "payment-methods", Title: "Payment Method Distribution", Description: "Completed payments by method"},
	{ID: "safety-incident", Title: "Safety Incident Report", Description: "Incidents per day by type"},
	{ID: "kyc-processing", Title: "KYC Processing Report", Description: "Approvals and rejections per day"},
}

func (r *reportRepo) ListReports(_ context.Context) ([]*domain.ReportDefinition, error) {
	out := make([]*domain.ReportDefinition, len(reportCatalog))
	copy(out, reportCatalog)
	return out, nil
}

func (r *reportRepo) GetChartData(ctx context.Context, reportType string, from, to *time.Time) ([]map[string]interface{}, error) {
	return r.getChartDataRange(ctx, reportType, from, to)
}

func (r *reportRepo) getChartDataRange(ctx context.Context, reportType string, from, to *time.Time) ([]map[string]interface{}, error) {
	start, end := defaultRange(from, to)

	switch reportType {
	case "weekly-financial":
		return r.queryFinancial(ctx, start, end)
	case "driver-performance":
		return r.queryDriverPerformance(ctx, start, end)
	case "rider-retention":
		return r.queryRiderRetention(ctx, start, end)
	case "ride-volume":
		return r.queryRideVolume(ctx, start, end)
	case "vehicle-distribution":
		return r.queryVehicleDistribution(ctx, start, end)
	case "payment-methods":
		return r.queryPaymentMethods(ctx, start, end)
	case "safety-incident":
		return r.querySafetyIncidents(ctx, start, end)
	case "kyc-processing":
		return r.queryKycProcessing(ctx, start, end)
	default:
		return nil, fmt.Errorf("unknown report type %q", reportType)
	}
}

func (r *reportRepo) ExportReport(ctx context.Context, reportType string, from, to *time.Time) ([]byte, error) {
	data, err := r.getChartDataRange(ctx, reportType, from, to)
	if err != nil {
		return nil, err
	}

	var buf bytes.Buffer
	w := csv.NewWriter(&buf)

	// Header row derived from the keys of the first row; guarantees order by
	// listing "label" first when present.
	var headers []string
	if len(data) > 0 {
		if _, ok := data[0]["label"]; ok {
			headers = append(headers, "label")
		}
		for k := range data[0] {
			if k == "label" {
				continue
			}
			headers = append(headers, k)
		}
	}
	if err := w.Write(headers); err != nil {
		return nil, err
	}

	for _, row := range data {
		rec := make([]string, len(headers))
		for i, h := range headers {
			rec[i] = fmt.Sprintf("%v", row[h])
		}
		if err := w.Write(rec); err != nil {
			return nil, err
		}
	}
	w.Flush()
	return buf.Bytes(), nil
}

// --- queries -----------------------------------------------------------------

func (r *reportRepo) queryFinancial(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		WITH days AS (
			SELECT generate_series($1::date, $2::date, '1 day')::date AS d
		),
		daily_revenue AS (
			SELECT processed_at::date AS d, SUM(amount) AS revenue
			FROM ride_payments
			WHERE status = 'completed' AND processed_at::date BETWEEN $1 AND $2
			GROUP BY 1
		),
		daily_payouts AS (
			SELECT completed_at::date AS d, SUM(total_amount) AS payouts
			FROM driver_earnings
			WHERE completed_at::date BETWEEN $1 AND $2
			GROUP BY 1
		)
		SELECT to_char(days.d, 'Dy') AS label,
		       COALESCE(r.revenue, 0)::float AS revenue,
		       COALESCE(p.payouts, 0)::float AS payouts,
		       COALESCE(r.revenue, 0)::float - COALESCE(p.payouts, 0)::float AS commission
		FROM days
		LEFT JOIN daily_revenue r ON r.d = days.d
		LEFT JOIN daily_payouts p ON p.d = days.d
		ORDER BY days.d`
	return r.scanKV(ctx, q, []string{"label", "revenue", "payouts", "commission"}, start, end)
}

func (r *reportRepo) queryDriverPerformance(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		WITH days AS (
			SELECT generate_series($1::date, $2::date, '1 day')::date AS d
		),
		per_day AS (
			SELECT created_at::date AS d,
			       COUNT(*) FILTER (WHERE status = 'completed') AS completed,
			       COUNT(*) AS total
			FROM rides
			WHERE created_at::date BETWEEN $1 AND $2
			GROUP BY 1
		)
		SELECT to_char(days.d, 'Dy') AS label,
		       CASE WHEN p.total IS NULL OR p.total = 0 THEN 0
		            ELSE ROUND(100.0 * p.completed / p.total) END AS value
		FROM days
		LEFT JOIN per_day p ON p.d = days.d
		ORDER BY days.d`
	return r.scanKV(ctx, q, []string{"label", "value"}, start, end)
}

func (r *reportRepo) queryRiderRetention(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		WITH days AS (
			SELECT generate_series($1::date, $2::date, '1 day')::date AS d
		),
		per_day AS (
			SELECT r.created_at::date AS d,
			       COUNT(DISTINCT r.passenger_id) FILTER (
			           WHERE NOT EXISTS (
			               SELECT 1 FROM rides r2
			               WHERE r2.passenger_id = r.passenger_id AND r2.created_at < r.created_at::date
			           )
			       ) AS new_riders,
			       COUNT(DISTINCT r.passenger_id) FILTER (
			           WHERE EXISTS (
			               SELECT 1 FROM rides r2
			               WHERE r2.passenger_id = r.passenger_id AND r2.created_at < r.created_at::date
			           )
			       ) AS returning_riders
			FROM rides r
			WHERE r.created_at::date BETWEEN $1 AND $2
			GROUP BY 1
		)
		SELECT to_char(days.d, 'Dy') AS label,
		       COALESCE(p.new_riders, 0) AS new_riders,
		       COALESCE(p.returning_riders, 0) AS returning_riders
		FROM days
		LEFT JOIN per_day p ON p.d = days.d
		ORDER BY days.d`
	return r.scanKV(ctx, q, []string{"label", "new_riders", "returning_riders"}, start, end)
}

func (r *reportRepo) queryRideVolume(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		WITH days AS (
			SELECT generate_series($1::date, $2::date, '1 day')::date AS d
		),
		per_day AS (
			SELECT created_at::date AS d, COUNT(*) AS cnt
			FROM rides
			WHERE created_at::date BETWEEN $1 AND $2
			GROUP BY 1
		)
		SELECT to_char(days.d, 'Dy') AS label, COALESCE(p.cnt, 0) AS value
		FROM days
		LEFT JOIN per_day p ON p.d = days.d
		ORDER BY days.d`
	return r.scanKV(ctx, q, []string{"label", "value"}, start, end)
}

func (r *reportRepo) queryVehicleDistribution(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		SELECT COALESCE(vehicle_type, 'unknown') AS label, COUNT(*) AS value
		FROM rides
		WHERE created_at::date BETWEEN $1 AND $2
		GROUP BY 1
		ORDER BY value DESC`
	return r.scanKV(ctx, q, []string{"label", "value"}, start, end)
}

func (r *reportRepo) queryPaymentMethods(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		SELECT method AS label, COUNT(*) AS value, COALESCE(SUM(amount), 0)::float AS amount
		FROM ride_payments
		WHERE status = 'completed' AND processed_at::date BETWEEN $1 AND $2
		GROUP BY method
		ORDER BY value DESC`
	return r.scanKV(ctx, q, []string{"label", "value", "amount"}, start, end)
}

func (r *reportRepo) querySafetyIncidents(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		WITH days AS (
			SELECT generate_series($1::date, $2::date, '1 day')::date AS d
		),
		per_day AS (
			SELECT created_at::date AS d, COUNT(*) AS cnt
			FROM incidents
			WHERE created_at::date BETWEEN $1 AND $2
			GROUP BY 1
		)
		SELECT to_char(days.d, 'Dy') AS label, COALESCE(p.cnt, 0) AS value
		FROM days
		LEFT JOIN per_day p ON p.d = days.d
		ORDER BY days.d`
	return r.scanKV(ctx, q, []string{"label", "value"}, start, end)
}

func (r *reportRepo) queryKycProcessing(ctx context.Context, start, end time.Time) ([]map[string]interface{}, error) {
	const q = `
		WITH days AS (
			SELECT generate_series($1::date, $2::date, '1 day')::date AS d
		),
		per_day AS (
			SELECT submitted_at::date AS d,
			       COUNT(*) FILTER (WHERE status = 'approved') AS approved,
			       COUNT(*) FILTER (WHERE status = 'rejected') AS rejected
			FROM kyc_submissions
			WHERE submitted_at::date BETWEEN $1 AND $2
			GROUP BY 1
		)
		SELECT to_char(days.d, 'Dy') AS label,
		       COALESCE(p.approved, 0) AS approved,
		       COALESCE(p.rejected, 0) AS rejected
		FROM days
		LEFT JOIN per_day p ON p.d = days.d
		ORDER BY days.d`
	return r.scanKV(ctx, q, []string{"label", "approved", "rejected"}, start, end)
}

// --- helpers -----------------------------------------------------------------

func defaultRange(from, to *time.Time) (time.Time, time.Time) {
	now := time.Now()
	end := now
	if to != nil {
		end = *to
	}
	start := end.AddDate(0, 0, -29)
	if from != nil {
		start = *from
	}
	if end.Before(start) {
		start, end = end, start
	}
	return start, end
}

// scanKV runs a query and maps each row into a []map[string]interface{} using
// the provided column names in order. Numeric values are returned as float64
// or int64 based on the destination column for easier JSON serialization.
func (r *reportRepo) scanKV(ctx context.Context, q string, cols []string, args ...any) ([]map[string]interface{}, error) {
	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []map[string]interface{}
	vals := make([]any, len(cols))
	ptrs := make([]any, len(cols))
	for i := range vals {
		ptrs[i] = &vals[i]
	}

	for rows.Next() {
		if err := rows.Scan(ptrs...); err != nil {
			return nil, err
		}
		row := make(map[string]interface{}, len(cols))
		for i, c := range cols {
			row[c] = normalizeValue(vals[i])
		}
		out = append(out, row)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	if out == nil {
		out = []map[string]interface{}{}
	}
	return out, nil
}

func normalizeValue(v any) any {
	switch t := v.(type) {
	case nil:
		return nil
	case []byte:
		if n, err := strconv.ParseFloat(string(t), 64); err == nil {
			return n
		}
		return string(t)
	default:
		return v
	}
}
