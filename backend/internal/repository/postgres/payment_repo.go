package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/displayid"
)

type paymentRepo struct{ db *pgxpool.Pool }

func NewPaymentRepo(db *pgxpool.Pool) domain.PaymentRepository {
	return &paymentRepo{db: db}
}

// ListTransactions returns paginated rows from ride_payments enriched with
// rider + driver names and the commission rate matched against
// commission_settings for the ride's vehicle type.
//
// Note (2026-04-23): the ride_payments.method ENUM is currently ('cash','card').
// E-wallet flows (gcash, paymaya) write to a separate gateway pipeline and do
// not yet land in this table. Until that integration is wired, the admin
// transaction list will only surface cash + card.
func (r *paymentRepo) ListTransactions(ctx context.Context, page, limit int) ([]*domain.Transaction, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit

	const countQ = `SELECT COUNT(*) FROM ride_payments`
	var total int
	if err := r.db.QueryRow(ctx, countQ).Scan(&total); err != nil {
		return nil, 0, err
	}

	const q = `
		SELECT
			p.id, p.seq, p.ride_id, COALESCE(r.seq, 0) AS ride_seq,
			p.amount, p.method::text, p.status::text, p.created_at,
			COALESCE(rider.name, '') AS rider_name,
			COALESCE(driver.name, '') AS driver_name,
			COALESCE(cs.rate_percent, 0) AS rate_percent,
			COALESCE(cs.min_commission, 0) AS min_commission
		FROM ride_payments p
		JOIN rides r ON r.id = p.ride_id
		LEFT JOIN users rider  ON rider.id  = r.passenger_id
		LEFT JOIN users driver ON driver.id = r.driver_id
		LEFT JOIN commission_settings cs ON cs.vehicle_type = r.ride_type
		ORDER BY p.created_at DESC
		LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, q, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var out []*domain.Transaction
	for rows.Next() {
		var (
			t             = &domain.Transaction{}
			rideSeq       int64
			ratePercent   float64
			minCommission float64
		)
		if err := rows.Scan(
			&t.ID, &t.Seq, &t.RideID, &rideSeq,
			&t.Amount, &t.PaymentMethod, &t.Status, &t.CreatedAt,
			&t.RiderName, &t.DriverName, &ratePercent, &minCommission,
		); err != nil {
			return nil, 0, err
		}
		t.DisplayID = displayid.Transaction(t.Seq)
		t.RideDisplayID = displayid.Ride(rideSeq)
		t.Commission = t.Amount * ratePercent / 100.0
		if t.Commission < minCommission {
			t.Commission = minCommission
		}
		out = append(out, t)
	}
	return out, total, rows.Err()
}

// GetPaymentSummary aggregates lifetime financial KPIs from ride_payments,
// driver_earnings, and the driver_payouts pipeline.
func (r *paymentRepo) GetPaymentSummary(ctx context.Context) (*domain.PaymentSummary, error) {
	const q = `
		SELECT
			COALESCE((SELECT SUM(amount) FROM ride_payments WHERE status = 'completed'), 0)              AS total_revenue,
			COALESCE((SELECT SUM(total_amount) FROM driver_earnings), 0)                                  AS payouts,
			COALESCE((SELECT SUM(amount) FROM ride_payments WHERE status = 'completed'), 0) -
			  COALESCE((SELECT SUM(total_amount) FROM driver_earnings), 0)                                AS commission,
			COALESCE((SELECT SUM(total_amount) FROM driver_payouts WHERE status IN ('pending','approved')), 0) AS pending_settlements`
	s := &domain.PaymentSummary{}
	if err := r.db.QueryRow(ctx, q).Scan(&s.TotalRevenue, &s.Payouts, &s.Commission, &s.PendingSettlements); err != nil {
		return nil, err
	}
	if s.Commission < 0 {
		// Earnings outpacing revenue means a tip-only / refund edge case —
		// surface as zero rather than a negative commission KPI.
		s.Commission = 0
	}
	return s, nil
}

func (r *paymentRepo) ListPayouts(ctx context.Context) ([]*domain.DriverPayout, error) {
	const q = `
		SELECT id, batch, driver_count, total_amount, period_label, status
		FROM driver_payouts
		ORDER BY created_at DESC
		LIMIT 200`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []*domain.DriverPayout
	for rows.Next() {
		p := &domain.DriverPayout{}
		if err := rows.Scan(&p.ID, &p.Batch, &p.DriverCount, &p.TotalAmount, &p.Period, &p.Status); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (r *paymentRepo) ApprovePayout(ctx context.Context, id uuid.UUID) error {
	const q = `
		UPDATE driver_payouts
		SET status = 'approved', approved_at = NOW()
		WHERE id = $1 AND status = 'pending'`
	tag, err := r.db.Exec(ctx, q, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("payout %s not found or not pending", id)
	}
	return nil
}

// Compile-time assertion that pgx imports stay in use even if some method
// flow is refactored; keeps the build error close to the cause.
var _ = pgx.ErrNoRows

func (r *paymentRepo) GetGatewayConfigs(ctx context.Context) ([]*domain.PaymentGatewayConfig, error) {
	const q = `SELECT id, provider, config_fields, is_active, updated_at, updated_by FROM payment_gateway_configs ORDER BY provider`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var configs []*domain.PaymentGatewayConfig
	for rows.Next() {
		c := &domain.PaymentGatewayConfig{}
		var raw []byte
		if err := rows.Scan(&c.ID, &c.Provider, &raw, &c.IsActive, &c.UpdatedAt, &c.UpdatedBy); err != nil {
			return nil, err
		}
		fields := map[string]string{}
		if len(raw) > 0 {
			if err := json.Unmarshal(raw, &fields); err != nil {
				return nil, fmt.Errorf("payment_gateway_configs[%s]: %w", c.Provider, err)
			}
		}
		c.ConfigFields = maskGatewaySecrets(fields)
		configs = append(configs, c)
	}
	return configs, nil
}

func (r *paymentRepo) UpdateGatewayConfig(ctx context.Context, c *domain.PaymentGatewayConfig) error {
	// Drop masked values so a save round-trip does not overwrite real secrets
	// with the "****" placeholder we returned to the UI.
	clean := map[string]string{}
	for k, v := range c.ConfigFields {
		if !isMaskedGatewayValue(v) {
			clean[k] = v
		}
	}
	raw, err := json.Marshal(clean)
	if err != nil {
		return err
	}
	const q = `
		INSERT INTO payment_gateway_configs (provider, config_fields, is_active, updated_at, updated_by)
		VALUES ($1, $2, $3, NOW(), $4)
		ON CONFLICT (provider) DO UPDATE SET
			config_fields = payment_gateway_configs.config_fields || EXCLUDED.config_fields,
			is_active = EXCLUDED.is_active,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	_, err = r.db.Exec(ctx, q, c.Provider, raw, c.IsActive, c.UpdatedBy)
	return err
}

// maskGatewaySecrets mirrors system_repo.maskSecrets — keys ending in common
// secret suffixes are reduced to "****"+last4 so the UI can still tell rows
// apart but never sees raw credentials.
func maskGatewaySecrets(in map[string]string) map[string]string {
	out := make(map[string]string, len(in))
	for k, v := range in {
		if isGatewaySecretKey(k) {
			if len(v) > 4 {
				out[k] = "****" + v[len(v)-4:]
			} else if v != "" {
				out[k] = "****"
			} else {
				out[k] = ""
			}
		} else {
			out[k] = v
		}
	}
	return out
}

func isGatewaySecretKey(k string) bool {
	lk := strings.ToLower(k)
	for _, suf := range []string{"_key", "_secret", "_token", "auth_token", "private_key", "api_key", "webhook_secret"} {
		if strings.HasSuffix(lk, suf) || lk == suf {
			return true
		}
	}
	return false
}

func isMaskedGatewayValue(v string) bool {
	return strings.HasPrefix(v, "****")
}

func (r *paymentRepo) GetCommissionSettings(ctx context.Context) ([]*domain.CommissionSettings, error) {
	const q = `SELECT id, vehicle_type, rate_percent, min_commission, updated_at, updated_by FROM commission_settings ORDER BY vehicle_type`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var settings []*domain.CommissionSettings
	for rows.Next() {
		s := &domain.CommissionSettings{}
		if err := rows.Scan(&s.ID, &s.VehicleType, &s.RatePercent, &s.MinCommission, &s.UpdatedAt, &s.UpdatedBy); err != nil {
			return nil, err
		}
		settings = append(settings, s)
	}
	return settings, nil
}

func (r *paymentRepo) UpdateCommissionSettings(ctx context.Context, s *domain.CommissionSettings) error {
	const q = `
		INSERT INTO commission_settings (vehicle_type, rate_percent, min_commission, updated_at, updated_by)
		VALUES ($1, $2, $3, NOW(), $4)
		ON CONFLICT (vehicle_type) DO UPDATE SET
			rate_percent = EXCLUDED.rate_percent,
			min_commission = EXCLUDED.min_commission,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	_, err := r.db.Exec(ctx, q, s.VehicleType, s.RatePercent, s.MinCommission, s.UpdatedBy)
	return err
}
