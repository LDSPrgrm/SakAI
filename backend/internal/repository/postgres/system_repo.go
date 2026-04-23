package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type systemRepo struct{ db *pgxpool.Pool }

func NewSystemRepo(db *pgxpool.Pool) domain.SystemRepository {
	return &systemRepo{db: db}
}

// ListServices returns the latest probe result per registered service. Probes
// are written by the background health goroutine in cmd/server. The websocket
// probe stores the live hub connection count in the latency_ms column so
// GetInfraMetrics can expose it without a second table — we zero it here so
// the service tile shows "0ms" (synthetic probe, no outbound I/O) instead of
// mistakenly rendering the connection count as latency in red.
func (r *systemRepo) ListServices(ctx context.Context) ([]*domain.SystemService, error) {
	const q = `
		SELECT DISTINCT ON (service_name)
		       service_name, status,
		       CASE WHEN service_name = 'websocket' THEN 0 ELSE COALESCE(latency_ms, 0) END,
		       checked_at
		FROM system_health_probes
		ORDER BY service_name, checked_at DESC`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Uptime per service over the last 24 hours.
	services := make(map[string]*domain.SystemService)
	var order []string
	for rows.Next() {
		s := &domain.SystemService{}
		if err := rows.Scan(&s.Name, &s.Status, &s.LatencyMs, &s.LastChecked); err != nil {
			return nil, err
		}
		services[s.Name] = s
		order = append(order, s.Name)
	}

	const qUptime = `
		SELECT service_name,
		       100.0 * COUNT(*) FILTER (WHERE status = 'ok') / GREATEST(COUNT(*), 1) AS uptime_pct
		FROM system_health_probes
		WHERE checked_at >= NOW() - INTERVAL '24 hours'
		GROUP BY service_name`
	uRows, err := r.db.Query(ctx, qUptime)
	if err != nil {
		return nil, err
	}
	defer uRows.Close()
	for uRows.Next() {
		var name string
		var pct float64
		if err := uRows.Scan(&name, &pct); err != nil {
			return nil, err
		}
		if s, ok := services[name]; ok {
			s.UptimePct = pct
		}
	}

	out := make([]*domain.SystemService, 0, len(order))
	for _, n := range order {
		out = append(out, services[n])
	}
	return out, nil
}

// RecordProbe inserts a new probe row. Called by cmd/server's health goroutine.
func (r *systemRepo) RecordProbe(ctx context.Context, name, status string, latencyMs int, errMsg string) error {
	const q = `
		INSERT INTO system_health_probes (service_name, status, latency_ms, error_message)
		VALUES ($1, $2, $3, NULLIF($4, ''))`
	_, err := r.db.Exec(ctx, q, name, status, latencyMs, errMsg)
	return err
}

func (r *systemRepo) ListFeatureFlags(ctx context.Context) ([]*domain.FeatureFlag, error) {
	const q = `SELECT key, COALESCE(description, ''), enabled FROM feature_flags ORDER BY key`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var flags []*domain.FeatureFlag
	for rows.Next() {
		f := &domain.FeatureFlag{}
		if err := rows.Scan(&f.Key, &f.Description, &f.Enabled); err != nil {
			return nil, err
		}
		f.Label = prettifyFlagKey(f.Key)
		flags = append(flags, f)
	}
	return flags, nil
}

func (r *systemRepo) UpdateFeatureFlag(ctx context.Context, key string, enabled bool) error {
	const q = `
		INSERT INTO feature_flags (key, enabled, updated_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (key) DO UPDATE
			SET enabled = EXCLUDED.enabled,
			    updated_at = NOW()`
	_, err := r.db.Exec(ctx, q, key, enabled)
	return err
}

func (r *systemRepo) ListIntegrations(ctx context.Context) ([]*domain.Integration, error) {
	const q = `
		SELECT service, config_fields, is_active,
		       COALESCE(last_tested_at, updated_at), COALESCE(last_test_ok, false)
		FROM integration_configs
		ORDER BY service`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []*domain.Integration
	for rows.Next() {
		var (
			svc     string
			raw     []byte
			active  bool
			lastSec time.Time
			lastOK  bool
		)
		if err := rows.Scan(&svc, &raw, &active, &lastSec, &lastOK); err != nil {
			return nil, err
		}
		cfg := map[string]string{}
		if len(raw) > 0 {
			_ = json.Unmarshal(raw, &cfg)
		}
		list = append(list, &domain.Integration{
			Service:  svc,
			Status:   integrationStatus(active, lastOK),
			LastSync: lastSec,
			Config:   maskSecrets(cfg),
		})
	}
	return list, nil
}

func (r *systemRepo) UpdateIntegration(ctx context.Context, service string, config map[string]string) error {
	raw, err := json.Marshal(config)
	if err != nil {
		return err
	}
	const q = `
		INSERT INTO integration_configs (service, config_fields, is_active, updated_at)
		VALUES ($1, $2, COALESCE((SELECT is_active FROM integration_configs WHERE service = $1), true), NOW())
		ON CONFLICT (service) DO UPDATE
			SET config_fields = EXCLUDED.config_fields,
			    updated_at = NOW()`
	_, err = r.db.Exec(ctx, q, service, raw)
	return err
}

// RecordIntegrationTest writes the outcome of a connection test. Called by the
// usecase layer after TestIntegration pings the external service.
func (r *systemRepo) RecordIntegrationTest(ctx context.Context, service string, ok bool, latencyMs int, message string) error {
	const q = `
		UPDATE integration_configs
		SET last_tested_at      = NOW(),
		    last_test_ok        = $2,
		    last_test_latency_ms= $3,
		    last_test_message   = $4
		WHERE service = $1`
	_, err := r.db.Exec(ctx, q, service, ok, latencyMs, message)
	return err
}

// GetIntegration returns the raw config (no masking) for outbound API calls.
// Caller must not return this to the frontend without masking.
func (r *systemRepo) GetIntegrationRaw(ctx context.Context, service string) (map[string]string, error) {
	const q = `SELECT config_fields FROM integration_configs WHERE service = $1`
	var raw []byte
	if err := r.db.QueryRow(ctx, q, service).Scan(&raw); err != nil {
		if err == pgx.ErrNoRows {
			return map[string]string{}, nil
		}
		return nil, err
	}
	out := map[string]string{}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &out)
	}
	return out, nil
}

func (r *systemRepo) ListNotificationTemplates(ctx context.Context) ([]*domain.NotificationTemplate, error) {
	const q = `
		SELECT event, channel, COALESCE(subject, ''), body
		FROM notification_templates
		ORDER BY event`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []*domain.NotificationTemplate
	for rows.Next() {
		t := &domain.NotificationTemplate{}
		if err := rows.Scan(&t.Event, &t.Channel, &t.Subject, &t.Body); err != nil {
			return nil, err
		}
		list = append(list, t)
	}
	return list, nil
}

func (r *systemRepo) UpdateNotificationTemplate(ctx context.Context, event, subject, body string) error {
	const q = `
		UPDATE notification_templates
		SET subject = NULLIF($2, ''),
		    body = $3,
		    updated_at = NOW()
		WHERE event = $1`
	tag, err := r.db.Exec(ctx, q, event, subject, body)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("notification template %q not found", event)
	}
	return nil
}

// RecordHTTPTiming appends a single request duration sample used to compute
// p50/p95 latency on the SystemHealth dashboard.
func (r *systemRepo) RecordHTTPTiming(ctx context.Context, method, path string, statusCode int, durationMs float64) error {
	const q = `
		INSERT INTO http_request_timings (method, path, status_code, duration_ms)
		VALUES ($1, $2, $3, $4)`
	_, err := r.db.Exec(ctx, q, method, path, statusCode, durationMs)
	return err
}

// GetInfraMetrics returns aggregated stats over the last 15 minutes. The window
// is intentionally narrow so operators see current load, not historical drift.
func (r *systemRepo) GetInfraMetrics(ctx context.Context) (*domain.InfraMetrics, error) {
	const windowMin = 15
	const q = `
		SELECT
		  COALESCE(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration_ms), 0)::float8 AS p50,
		  COALESCE(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms), 0)::float8 AS p95,
		  COUNT(*)::int AS samples
		FROM http_request_timings
		WHERE occurred_at >= NOW() - make_interval(mins => $1)`
	m := &domain.InfraMetrics{WindowMinutes: windowMin}
	if err := r.db.QueryRow(ctx, q, windowMin).Scan(&m.APIP50Ms, &m.APIP95Ms, &m.SampleCount); err != nil {
		return nil, err
	}
	// DB query latency p99 reuses the database probe latency samples over the
	// last 24h. It is a coarser approximation than query-level tracing but
	// adequate for the overview dashboard.
	const qDB = `
		SELECT COALESCE(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY latency_ms), 0)::float8
		FROM system_health_probes
		WHERE service_name = 'database' AND checked_at >= NOW() - INTERVAL '24 hours'`
	if err := r.db.QueryRow(ctx, qDB).Scan(&m.DBQueryP99Ms); err != nil {
		return nil, err
	}
	const qWS = `
		SELECT COALESCE(latency_ms, 0)
		FROM system_health_probes
		WHERE service_name = 'websocket'
		ORDER BY checked_at DESC LIMIT 1`
	// ws_connections is stored in latency_ms by the prober (0 or positive).
	// A missing row just leaves the default 0.
	_ = r.db.QueryRow(ctx, qWS).Scan(&m.WSConnections)
	return m, nil
}

// --- helpers -----------------------------------------------------------------

func prettifyFlagKey(k string) string {
	parts := strings.Split(k, "_")
	for i, p := range parts {
		if p == "" {
			continue
		}
		parts[i] = strings.ToUpper(p[:1]) + p[1:]
	}
	return strings.Join(parts, " ")
}

func integrationStatus(active, lastOK bool) string {
	if !active {
		return "disabled"
	}
	if lastOK {
		return "active"
	}
	return "degraded"
}

// maskSecrets redacts values for any key whose name ends with common secret
// suffixes. Only the last 4 characters are preserved so the UI can still
// differentiate between entries.
func maskSecrets(in map[string]string) map[string]string {
	out := make(map[string]string, len(in))
	for k, v := range in {
		if isSecretKey(k) && len(v) > 4 {
			out[k] = "****" + v[len(v)-4:]
		} else if isSecretKey(k) {
			out[k] = "****"
		} else {
			out[k] = v
		}
	}
	return out
}

func isSecretKey(k string) bool {
	lk := strings.ToLower(k)
	for _, suf := range []string{"_key", "_secret", "_token", "auth_token", "private_key", "api_key", "webhook_secret"} {
		if strings.HasSuffix(lk, suf) || lk == suf {
			return true
		}
	}
	return false
}
