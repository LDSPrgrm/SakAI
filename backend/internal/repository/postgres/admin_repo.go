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

// adminRepo handles admin user management and system settings.
type adminRepo struct{ db *pgxpool.Pool }

func NewAdminRepo(db *pgxpool.Pool) domain.AdminRepository {
	return &adminRepo{db: db}
}

func (r *adminRepo) GetAdmins(ctx context.Context) ([]*domain.User, error) {
	const q = `
		SELECT id, name, email, role, created_at 
		FROM users 
		WHERE role IN ('admin', 'superadmin', 'operations', 'finance', 'support')
		ORDER BY created_at DESC`
	
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var admins []*domain.User
	for rows.Next() {
		u := &domain.User{}
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.Role, &u.CreatedAt); err != nil {
			return nil, err
		}
		admins = append(admins, u)
	}
	return admins, nil
}

func (r *adminRepo) UpdateAdminStatus(ctx context.Context, id uuid.UUID, role domain.UserRole) error {
	const q = `UPDATE users SET role = $1 WHERE id = $2`
	_, err := r.db.Exec(ctx, q, string(role), id)
	return err
}

func (r *adminRepo) GetPaymentConfigs(ctx context.Context) ([]*domain.PaymentGatewayConfig, error) {
	const q = `SELECT id, provider, config_fields, is_active, updated_at, updated_by FROM payment_gateway_configs`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var configs []*domain.PaymentGatewayConfig
	for rows.Next() {
		c := &domain.PaymentGatewayConfig{}
		if err := rows.Scan(&c.ID, &c.Provider, &c.ConfigFields, &c.IsActive, &c.UpdatedAt, &c.UpdatedBy); err != nil {
			return nil, err
		}
		configs = append(configs, c)
	}
	return configs, nil
}

func (r *adminRepo) UpdatePaymentConfig(ctx context.Context, c *domain.PaymentGatewayConfig) error {
	const q = `
		INSERT INTO payment_gateway_configs (provider, config_fields, is_active, updated_at, updated_by)
		VALUES ($1, $2, $3, NOW(), $4)
		ON CONFLICT (provider) DO UPDATE SET
			config_fields = EXCLUDED.config_fields,
			is_active = EXCLUDED.is_active,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	_, err := r.db.Exec(ctx, q, c.Provider, c.ConfigFields, c.IsActive, c.UpdatedBy)
	return err
}

func (r *adminRepo) GetCommissionSettings(ctx context.Context) ([]*domain.CommissionSettings, error) {
	const q = `SELECT id, vehicle_type, rate_percent, min_commission, updated_at, updated_by FROM commission_settings`
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

func (r *adminRepo) UpdateCommissionSettings(ctx context.Context, s *domain.CommissionSettings) error {
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

// --- Fare Repository ---

type fareRepo struct{ db *pgxpool.Pool }

func NewFareRepo(db *pgxpool.Pool) domain.FareRepository {
	return &fareRepo{db: db}
}

func (r *fareRepo) GetFareConfigs(ctx context.Context) ([]*domain.FareConfig, error) {
	const q = `SELECT id, vehicle_type, base_fare, per_km_rate, per_min_rate, minimum_fare, booking_fee, cancellation_fee, updated_at, updated_by FROM fare_configs`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var configs []*domain.FareConfig
	for rows.Next() {
		c := &domain.FareConfig{}
		if err := rows.Scan(&c.ID, &c.VehicleType, &c.BaseFare, &c.PerKmRate, &c.PerMinRate, &c.MinimumFare, &c.BookingFee, &c.CancellationFee, &c.UpdatedAt, &c.UpdatedBy); err != nil {
			return nil, err
		}
		configs = append(configs, c)
	}
	return configs, nil
}

func (r *fareRepo) UpdateFareConfig(ctx context.Context, c *domain.FareConfig) error {
	const q = `
		INSERT INTO fare_configs (vehicle_type, base_fare, per_km_rate, per_min_rate, minimum_fare, booking_fee, cancellation_fee, updated_at, updated_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), $8)
		ON CONFLICT (vehicle_type) DO UPDATE SET
			base_fare = EXCLUDED.base_fare,
			per_km_rate = EXCLUDED.per_km_rate,
			per_min_rate = EXCLUDED.per_min_rate,
			minimum_fare = EXCLUDED.minimum_fare,
			booking_fee = EXCLUDED.booking_fee,
			cancellation_fee = EXCLUDED.cancellation_fee,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	_, err := r.db.Exec(ctx, q, c.VehicleType, c.BaseFare, c.PerKmRate, c.PerMinRate, c.MinimumFare, c.BookingFee, c.CancellationFee, c.UpdatedBy)
	return err
}

func (r *fareRepo) GetSurgeConfig(ctx context.Context) (*domain.SurgeConfig, error) {
	const q = `SELECT id, enabled, max_multiplier, trigger_ratio, zones, blackout_hours, updated_at, updated_by FROM surge_configs LIMIT 1`
	c := &domain.SurgeConfig{}
	err := r.db.QueryRow(ctx, q).Scan(&c.ID, &c.Enabled, &c.MaxMultiplier, &c.TriggerRatio, &c.Zones, &c.BlackoutHours, &c.UpdatedAt, &c.UpdatedBy)
	if errors.Is(err, pgx.ErrNoRows) {
		return &domain.SurgeConfig{Enabled: false, MaxMultiplier: 1.0, TriggerRatio: 1.5}, nil
	}
	return c, err
}

func (r *fareRepo) UpdateSurgeConfig(ctx context.Context, c *domain.SurgeConfig) error {
	const q = `
		INSERT INTO surge_configs (id, enabled, max_multiplier, trigger_ratio, zones, blackout_hours, updated_at, updated_by)
		VALUES ($1, $2, $3, $4, $5, $6, NOW(), $7)
		ON CONFLICT (id) DO UPDATE SET
			enabled = EXCLUDED.enabled,
			max_multiplier = EXCLUDED.max_multiplier,
			trigger_ratio = EXCLUDED.trigger_ratio,
			zones = EXCLUDED.zones,
			blackout_hours = EXCLUDED.blackout_hours,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	// Use a fixed ID for global surge config if not provided
	if c.ID == uuid.Nil {
		c.ID = uuid.MustParse("00000000-0000-0000-0000-000000000001")
	}
	_, err := r.db.Exec(ctx, q, c.ID, c.Enabled, c.MaxMultiplier, c.TriggerRatio, c.Zones, c.BlackoutHours, c.UpdatedBy)
	return err
}

// --- Audit Repository ---

type auditRepo struct{ db *pgxpool.Pool }

func NewAuditRepo(db *pgxpool.Pool) domain.AuditRepository {
	return &auditRepo{db: db}
}

func (r *auditRepo) Store(ctx context.Context, e *domain.AuditLogEntry) error {
	const q = `
		INSERT INTO audit_log_entries (actor_id, ip_address, action, resource_type, resource_id, before_state, after_state, reason)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(ctx, q, e.ActorID, e.IPAddress, e.Action, e.ResourceType, e.ResourceID, e.BeforeState, e.AfterState, e.Reason)
	return err
}

func (r *auditRepo) List(ctx context.Context, q domain.AuditQuery) ([]*domain.AuditLogEntry, int, error) {
	var whereClauses []string
	var args []any
	argID := 1

	if q.ActorID != nil {
		whereClauses = append(whereClauses, fmt.Sprintf("actor_id = $%d", argID))
		args = append(args, *q.ActorID)
		argID++
	}
	if q.ResourceType != nil {
		whereClauses = append(whereClauses, fmt.Sprintf("resource_type = $%d", argID))
		args = append(args, *q.ResourceType)
		argID++
	}
	if q.Action != nil {
		whereClauses = append(whereClauses, fmt.Sprintf("action = $%d", argID))
		args = append(args, *q.Action)
		argID++
	}

	whereSQL := ""
	if len(whereClauses) > 0 {
		whereSQL = " WHERE "
		for i, v := range whereClauses {
			if i > 0 {
				whereSQL += " AND "
			}
			whereSQL += v
		}
	}

	const countQ = "SELECT COUNT(*) FROM audit_log_entries"
	var total int
	if err := r.db.QueryRow(ctx, countQ+whereSQL, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	limit := q.Limit
	if limit <= 0 {
		limit = 20
	}
	offset := q.Page * limit

	selectQ := fmt.Sprintf(`
		SELECT id, timestamp, actor_id, ip_address, action, resource_type, resource_id, before_state, after_state, reason
		FROM audit_log_entries %s
		ORDER BY timestamp DESC
		LIMIT $%d OFFSET $%d`, whereSQL, argID, argID+1)
	
	args = append(args, limit, offset)
	rows, err := r.db.Query(ctx, selectQ, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var logs []*domain.AuditLogEntry
	for rows.Next() {
		e := &domain.AuditLogEntry{}
		if err := rows.Scan(&e.ID, &e.Timestamp, &e.ActorID, &e.IPAddress, &e.Action, &e.ResourceType, &e.ResourceID, &e.BeforeState, &e.AfterState, &e.Reason); err != nil {
			return nil, 0, err
		}
		logs = append(logs, e)
	}
	return logs, total, nil
}

// --- Incident Repository ---

type incidentRepo struct{ db *pgxpool.Pool }

func NewIncidentRepo(db *pgxpool.Pool) domain.IncidentRepository {
	return &incidentRepo{db: db}
}

func (r *incidentRepo) ListIncidents(ctx context.Context, status *string) ([]*domain.Incident, error) {
	q := `SELECT id, ride_id, triggered_by, rider_id, driver_id, type, status, assigned_to, resolution_notes, created_at, resolved_at FROM incidents`
	var args []any
	if status != nil {
		q += " WHERE status = $1"
		args = append(args, *status)
	}
	q += " ORDER BY created_at DESC"

	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var incidents []*domain.Incident
	for rows.Next() {
		i := &domain.Incident{}
		if err := rows.Scan(&i.ID, &i.RideID, &i.TriggeredBy, &i.RiderID, &i.DriverID, &i.Type, &i.Status, &i.AssignedTo, &i.ResolutionNotes, &i.CreatedAt, &i.ResolvedAt); err != nil {
			return nil, err
		}
		incidents = append(incidents, i)
	}
	return incidents, nil
}

func (r *incidentRepo) GetIncidentByID(ctx context.Context, id uuid.UUID) (*domain.Incident, error) {
	const q = `SELECT id, ride_id, triggered_by, rider_id, driver_id, type, status, assigned_to, resolution_notes, created_at, resolved_at FROM incidents WHERE id = $1`
	i := &domain.Incident{}
	err := r.db.QueryRow(ctx, q, id).Scan(&i.ID, &i.RideID, &i.TriggeredBy, &i.RiderID, &i.DriverID, &i.Type, &i.Status, &i.AssignedTo, &i.ResolutionNotes, &i.CreatedAt, &i.ResolvedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return i, err
}

func (r *incidentRepo) UpdateIncident(ctx context.Context, id uuid.UUID, status string, notes string, assignedTo *uuid.UUID) error {
	var resolvedAt *time.Time
	if status == "resolved" {
		t := time.Now()
		resolvedAt = &t
	}
	const q = `UPDATE incidents SET status = $1, resolution_notes = $2, assigned_to = $3, resolved_at = $4 WHERE id = $5`
	_, err := r.db.Exec(ctx, q, status, notes, assignedTo, resolvedAt, id)
	return err
}

// --- System Metrics Repository ---

type systemMetricsRepo struct{ db *pgxpool.Pool }

func NewSystemMetricsRepo(db *pgxpool.Pool) domain.SystemMetricsRepository {
	return &systemMetricsRepo{db: db}
}

func (r *systemMetricsRepo) GetDashboardMetrics(ctx context.Context) (*domain.DashboardMetrics, error) {
	m := &domain.DashboardMetrics{}

	// Active Riders (at least 1 ride in past 30 days)
	const qRiders = `SELECT COUNT(DISTINCT passenger_id) FROM rides WHERE created_at > NOW() - INTERVAL '30 days'`
	if err := r.db.QueryRow(ctx, qRiders).Scan(&m.ActiveRiders); err != nil {
		return nil, err
	}

	// Active Drivers (online or with a ride in past 30 days)
	const qDrivers = `SELECT COUNT(DISTINCT driver_id) FROM rides WHERE driver_id IS NOT NULL AND created_at > NOW() - INTERVAL '30 days'`
	if err := r.db.QueryRow(ctx, qDrivers).Scan(&m.ActiveDrivers); err != nil {
		return nil, err
	}

	// Rides Today
	const qRides = `SELECT COUNT(*) FROM rides WHERE created_at >= CURRENT_DATE`
	if err := r.db.QueryRow(ctx, qRides).Scan(&m.RidesToday); err != nil {
		return nil, err
	}

	// Revenue Today (Mock 0 since billing schema is pending)
	m.RevenueToday = 0

	// Avg Wait Time Today (Mock 0 since accepted_at schema is pending)
	m.AvgWaitTimeSeconds = 0

	m.SystemUptime = 99.99 // Hardcoded mock for now as per spec target
	return m, nil
}
