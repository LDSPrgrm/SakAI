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
	"github.com/sakai/backend/internal/domain/displayid"
)

// adminRepo handles admin user management and system settings.
type adminRepo struct{ db *pgxpool.Pool }

func NewAdminRepo(db *pgxpool.Pool) domain.AdminRepository {
	return &adminRepo{db: db}
}

func (r *adminRepo) GetAdmins(ctx context.Context) ([]*domain.User, error) {
	const q = `
		SELECT id, seq, name, email, role, role_id, created_at
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
		if err := rows.Scan(&u.ID, &u.Seq, &u.Name, &u.Email, &u.Role, &u.RoleID, &u.CreatedAt); err != nil {
			return nil, err
		}
		u.DisplayID = displayid.User(u.Seq)
		admins = append(admins, u)
	}
	return admins, nil
}

func (r *adminRepo) UpdateAdminProfile(ctx context.Context, id uuid.UUID, name, email string, role domain.UserRole, roleID uuid.UUID) error {
	const q = `UPDATE users SET name = $1, email = $2, role = $3, role_id = $4 WHERE id = $5`
	_, err := r.db.Exec(ctx, q, name, email, string(role), roleID, id)
	return err
}

func (r *adminRepo) DeactivateAdmin(ctx context.Context, id uuid.UUID) error {
	const q = `UPDATE users SET role = 'deactivated' WHERE id = $1`
	_, err := r.db.Exec(ctx, q, id)
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
	const q = `
		SELECT f.id, f.vehicle_type, f.base_fare, f.per_km_rate, f.per_min_rate,
		       f.minimum_fare, f.booking_fee, f.cancellation_fee,
		       f.updated_at, f.updated_by, COALESCE(u.name, '')
		FROM fare_configs f
		LEFT JOIN users u ON u.id = f.updated_by`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var configs []*domain.FareConfig
	for rows.Next() {
		c := &domain.FareConfig{}
		if err := rows.Scan(&c.ID, &c.VehicleType, &c.BaseFare, &c.PerKmRate, &c.PerMinRate, &c.MinimumFare, &c.BookingFee, &c.CancellationFee, &c.UpdatedAt, &c.UpdatedBy, &c.UpdatedByName); err != nil {
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
	const q = `
		SELECT s.id, s.enabled, s.max_multiplier, s.trigger_ratio, s.zones, s.blackout_hours,
		       s.updated_at, s.updated_by, COALESCE(u.name, '')
		FROM surge_configs s
		LEFT JOIN users u ON u.id = s.updated_by
		LIMIT 1`
	c := &domain.SurgeConfig{}
	err := r.db.QueryRow(ctx, q).Scan(&c.ID, &c.Enabled, &c.MaxMultiplier, &c.TriggerRatio, &c.Zones, &c.BlackoutHours, &c.UpdatedAt, &c.UpdatedBy, &c.UpdatedByName)
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
		SELECT a.id, a.seq, a.timestamp, a.actor_id, COALESCE(u.seq, 0) AS actor_seq,
		       a.ip_address, a.action, a.resource_type, a.resource_id,
		       a.before_state, a.after_state, a.reason
		FROM audit_log_entries a
		LEFT JOIN users u ON u.id = a.actor_id
		%s
		ORDER BY a.timestamp DESC
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
		var actorSeq int64
		if err := rows.Scan(&e.ID, &e.Seq, &e.Timestamp, &e.ActorID, &actorSeq, &e.IPAddress, &e.Action, &e.ResourceType, &e.ResourceID, &e.BeforeState, &e.AfterState, &e.Reason); err != nil {
			return nil, 0, err
		}
		e.DisplayID = displayid.AuditLog(e.Seq)
		e.ActorDisplayID = displayid.User(actorSeq)
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
	q := `SELECT i.id, i.seq, i.ride_id, COALESCE(rd.seq, 0) AS ride_seq, i.triggered_by, i.rider_id, i.driver_id, i.type, i.status, i.assigned_to, COALESCE(u.name, ''), COALESCE(i.resolution_notes, ''), i.created_at, i.resolved_at FROM incidents i LEFT JOIN users u ON u.id = i.assigned_to LEFT JOIN rides rd ON rd.id = i.ride_id`
	var args []any
	if status != nil {
		q += " WHERE i.status = $1"
		args = append(args, *status)
	}
	q += " ORDER BY i.created_at DESC"

	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var incidents []*domain.Incident
	for rows.Next() {
		i := &domain.Incident{}
		var rideSeq int64
		if err := rows.Scan(&i.ID, &i.Seq, &i.RideID, &rideSeq, &i.TriggeredBy, &i.RiderID, &i.DriverID, &i.Type, &i.Status, &i.AssignedTo, &i.AssignedToName, &i.ResolutionNotes, &i.CreatedAt, &i.ResolvedAt); err != nil {
			return nil, err
		}
		i.DisplayID = displayid.Incident(i.Seq)
		i.RideDisplayID = displayid.Ride(rideSeq)
		incidents = append(incidents, i)
	}
	return incidents, nil
}

func (r *incidentRepo) GetIncidentByID(ctx context.Context, id uuid.UUID) (*domain.Incident, error) {
	const q = `SELECT i.id, i.seq, i.ride_id, COALESCE(rd.seq, 0) AS ride_seq, i.triggered_by, i.rider_id, i.driver_id, i.type, i.status, i.assigned_to, COALESCE(u.name, ''), COALESCE(i.resolution_notes, ''), i.created_at, i.resolved_at FROM incidents i LEFT JOIN users u ON u.id = i.assigned_to LEFT JOIN rides rd ON rd.id = i.ride_id WHERE i.id = $1`
	i := &domain.Incident{}
	var rideSeq int64
	err := r.db.QueryRow(ctx, q, id).Scan(&i.ID, &i.Seq, &i.RideID, &rideSeq, &i.TriggeredBy, &i.RiderID, &i.DriverID, &i.Type, &i.Status, &i.AssignedTo, &i.AssignedToName, &i.ResolutionNotes, &i.CreatedAt, &i.ResolvedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	i.DisplayID = displayid.Incident(i.Seq)
	i.RideDisplayID = displayid.Ride(rideSeq)
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

// ListStatusHistory returns timeline events for an incident, oldest first.
// actor_name is best-effort joined from users; null when the actor was a DB
// trigger (INSERT/UPDATE not forwarded through the use case).
func (r *incidentRepo) ListStatusHistory(ctx context.Context, id uuid.UUID) ([]*domain.IncidentStatusEvent, error) {
	const q = `
		SELECT h.id, h.incident_id, h.from_status, h.to_status,
		       h.from_assignee, h.to_assignee, h.actor_id,
		       COALESCE(u.name, ''),
		       COALESCE(h.note, ''), h.occurred_at
		FROM incident_status_history h
		LEFT JOIN users u ON u.id = h.actor_id
		WHERE h.incident_id = $1
		ORDER BY h.occurred_at ASC`

	rows, err := r.db.Query(ctx, q, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	events := make([]*domain.IncidentStatusEvent, 0)
	for rows.Next() {
		e := &domain.IncidentStatusEvent{}
		if err := rows.Scan(&e.ID, &e.IncidentID, &e.FromStatus, &e.ToStatus,
			&e.FromAssignee, &e.ToAssignee, &e.ActorID,
			&e.ActorName, &e.Note, &e.OccurredAt); err != nil {
			return nil, err
		}
		events = append(events, e)
	}
	return events, rows.Err()
}

func (r *incidentRepo) AssignIncident(ctx context.Context, id uuid.UUID, assigneeID *uuid.UUID) error {
	const q = `UPDATE incidents SET assigned_to = $1 WHERE id = $2`
	tag, err := r.db.Exec(ctx, q, assigneeID, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// ListLocationTrail returns incident-scoped GPS pings oldest-first.
func (r *incidentRepo) ListLocationTrail(ctx context.Context, id uuid.UUID) ([]*domain.IncidentLocationPoint, error) {
	const q = `
		SELECT lat, lng, recorded_at
		FROM driver_location_history
		WHERE incident_id = $1
		ORDER BY recorded_at ASC`
	rows, err := r.db.Query(ctx, q, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	trail := make([]*domain.IncidentLocationPoint, 0)
	for rows.Next() {
		p := &domain.IncidentLocationPoint{}
		if err := rows.Scan(&p.Lat, &p.Lng, &p.RecordedAt); err != nil {
			return nil, err
		}
		trail = append(trail, p)
	}
	return trail, rows.Err()
}

// FindActiveByDriver hits the partial index idx_incidents_active_driver so the
// empty case (driver has no open incident) reads a single index tuple. Callers
// on the driver location hot path depend on this staying cheap.
func (r *incidentRepo) FindActiveByDriver(ctx context.Context, driverID uuid.UUID) ([]uuid.UUID, error) {
	const q = `
		SELECT id FROM incidents
		WHERE driver_id = $1 AND resolved_at IS NULL`
	rows, err := r.db.Query(ctx, q, driverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

func (r *incidentRepo) RecordLocationPing(ctx context.Context, incidentID, driverID uuid.UUID, lat, lng float64) error {
	const q = `
		INSERT INTO driver_location_history (incident_id, driver_id, lat, lng)
		VALUES ($1, $2, $3, $4)`
	_, err := r.db.Exec(ctx, q, incidentID, driverID, lat, lng)
	return err
}

func (r *incidentRepo) Create(ctx context.Context, i *domain.Incident) error {
	const q = `
		INSERT INTO incidents (id, ride_id, triggered_by, rider_id, driver_id, type, status, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(ctx, q, i.ID, i.RideID, i.TriggeredBy, i.RiderID, i.DriverID, i.Type, i.Status, i.CreatedAt)
	return err
}

// --- System Metrics Repository ---

type systemMetricsRepo struct{ db *pgxpool.Pool }

func NewSystemMetricsRepo(db *pgxpool.Pool) domain.SystemMetricsRepository {
	return &systemMetricsRepo{db: db}
}

func (r *systemMetricsRepo) GetDashboardMetrics(ctx context.Context) (*domain.DashboardMetrics, error) {
	m := &domain.DashboardMetrics{}

	const qTotalRiders = `SELECT COUNT(*) FROM users WHERE role = 'passenger'`
	if err := r.db.QueryRow(ctx, qTotalRiders).Scan(&m.TotalRiders); err != nil {
		return nil, err
	}

	const qTotalDrivers = `SELECT COUNT(*) FROM users WHERE role = 'driver'`
	if err := r.db.QueryRow(ctx, qTotalDrivers).Scan(&m.TotalDrivers); err != nil {
		return nil, err
	}

	const qRiders = `SELECT COUNT(DISTINCT passenger_id) FROM rides WHERE created_at > NOW() - INTERVAL '30 days'`
	if err := r.db.QueryRow(ctx, qRiders).Scan(&m.ActiveRiders); err != nil {
		return nil, err
	}

	const qDrivers = `SELECT COUNT(DISTINCT driver_id) FROM rides WHERE driver_id IS NOT NULL AND created_at > NOW() - INTERVAL '30 days'`
	if err := r.db.QueryRow(ctx, qDrivers).Scan(&m.ActiveDrivers); err != nil {
		return nil, err
	}

	const qRides = `SELECT COUNT(*) FROM rides WHERE created_at >= CURRENT_DATE`
	if err := r.db.QueryRow(ctx, qRides).Scan(&m.RidesToday); err != nil {
		return nil, err
	}

	const qRevenue = `
		SELECT COALESCE(SUM(amount), 0)
		FROM ride_payments
		WHERE status = 'completed' AND processed_at::date = CURRENT_DATE`
	if err := r.db.QueryRow(ctx, qRevenue).Scan(&m.RevenueToday); err != nil {
		return nil, err
	}

	// Avg wait = accepted_at - created_at for rides accepted in the last 24h.
	// NULL when there are no rides yet; scan into a nullable float.
	const qWait = `
		SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (accepted_at - created_at))), 0)
		FROM rides
		WHERE accepted_at IS NOT NULL AND created_at >= NOW() - INTERVAL '24 hours'`
	if err := r.db.QueryRow(ctx, qWait).Scan(&m.AvgWaitTimeSeconds); err != nil {
		return nil, err
	}

	// Uptime = fraction of 'ok' probes over the last 24h across all services.
	// If no probes have been recorded yet, leave NULL → UI can render '—'.
	const qUptime = `
		SELECT CASE WHEN COUNT(*) = 0 THEN NULL
		            ELSE 100.0 * COUNT(*) FILTER (WHERE status = 'ok') / COUNT(*)
		       END
		FROM system_health_probes
		WHERE checked_at >= NOW() - INTERVAL '24 hours'`
	var uptime *float64
	if err := r.db.QueryRow(ctx, qUptime).Scan(&uptime); err != nil {
		return nil, err
	}
	if uptime != nil {
		m.SystemUptime = *uptime
	}
	return m, nil
}
