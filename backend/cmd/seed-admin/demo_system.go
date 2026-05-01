package main

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
)

// Phase 4 — system config, audit log, areas, LGUs, alert rules, health probes.
//
// Layout:
//   2000000a-...001..002  service_areas (2 rows)
//   2000000b-...001..002  lgu_partnerships (2 rows)
//   2000000c-...001..002  alert_rules (2 rows)
//   2000000d-...001..008  audit_log_entries (8 rows)
//   2000000e-...001..005  system_health_probes (5 rows, 1 per service)
//
// Plus a stamp on feature_flags.maintenance_mode (existing row from mig 018) so
// /super-admin/system-config has a non-NULL `updated_by` to render.
//
// Preconditions: superadmin@sakai.com must exist (for FKs + audit actor) and
// Phase 1–3 demo rows should ideally exist so the audit references real
// resources — but Phase 4 is independent of Phase 1–3 row counts (it only
// names IDs in audit text, which is unconstrained).

type demoServiceArea struct {
	id       string
	name     string
	lguCode  string
	boundary string // JSONB literal
}

var demoServiceAreas = []demoServiceArea{
	{
		"2000000a-0000-0000-0000-000000000001",
		"Metro Manila Core",
		"NCR-MMC",
		`{"name":"Metro Manila Core","polygon":[[14.6760,121.0437],[14.6760,121.0700],[14.5547,121.0700],[14.5547,121.0437],[14.6760,121.0437]]}`,
	},
	{
		"2000000a-0000-0000-0000-000000000002",
		"BGC-Makati CBD",
		"NCR-BGC",
		`{"name":"BGC-Makati CBD","polygon":[[14.5618,121.0269],[14.5618,121.0606],[14.5314,121.0606],[14.5314,121.0269],[14.5618,121.0269]]}`,
	},
}

type demoLGU struct {
	id              string
	serviceAreaIdx  int // 0-based index into demoServiceAreas
	lguName         string
	contactName     string
	contactEmail    string
	contactPhone    string
	agreementStart  string // YYYY-MM-DD or empty
	agreementEnd    string
	status          string // active|pending|expired|terminated
	notes           string
}

var demoLGUs = []demoLGU{
	{
		"2000000b-0000-0000-0000-000000000001", 1,
		"Makati LGU",
		"Atty. Lourdes Reyes",
		"partnerships@makati.gov.ph",
		"+63 2 8870 1000",
		"2026-01-15", "2027-01-14",
		"active",
		"Active MOA covering BGC-Makati CBD coverage. Quarterly compliance reports due to LGU.",
	},
	{
		"2000000b-0000-0000-0000-000000000002", 0,
		"Quezon City LGU",
		"Engr. Marcos delos Santos",
		"transport@quezoncity.gov.ph",
		"+63 2 8988 4242",
		"", "",
		"pending",
		"Draft MOA pending LGU council review. Coverage: Metro Manila Core (Quezon City segment).",
	},
}

type demoAlertRule struct {
	id      string
	name    string
	ruleType string // low_rating|high_cancellation|fraud_velocity|kyc_expiry
	enabled bool
	config  string // JSONB literal
}

var demoAlertRules = []demoAlertRule{
	{
		"2000000c-0000-0000-0000-000000000001",
		"Low rating alert",
		"low_rating",
		true,
		`{"threshold":3.5,"window_days":7}`,
	},
	{
		"2000000c-0000-0000-0000-000000000002",
		"KYC expiry warning",
		"kyc_expiry",
		true,
		`{"warn_days":14}`,
	},
}

type demoAuditEntry struct {
	id           string
	createdAgo   string // SQL INTERVAL
	action       string // CREATE|UPDATE|DELETE|APPROVE|REJECT|LOGIN|LOGOUT
	resourceType string
	resourceID   string // text — can be UUID or key
	beforeState  string // JSONB literal or empty for NULL
	afterState   string // JSONB literal or empty for NULL
	reason       string
}

// 8 audit entries spanning the last 15 days. resource_id values reference real
// rows seeded by earlier phases / runReset (kyc, incident, payout, role,
// feature flag, finance user). The finance + operations role IDs are stable
// system-role constants from runReset.
var demoAuditEntries = []demoAuditEntry{
	{
		"2000000d-0000-0000-0000-000000000001",
		"15 days", "LOGIN", "session", "", "", "", "Initial superadmin login",
	},
	{
		"2000000d-0000-0000-0000-000000000002",
		"14 days", "CREATE", "admin_user", "", "",
		`{"role":"finance","email":"finance@sakai.com"}`,
		"Onboarded finance team member",
	},
	{
		"2000000d-0000-0000-0000-000000000003",
		"12 days", "UPDATE", "role",
		"10000000-0000-0000-0000-000000000002",
		`{"permissions":{"reports":{"read":true,"write":false}}}`,
		`{"permissions":{"reports":{"read":true,"write":false},"ltfrb_compliance":{"read":true,"write":true}}}`,
		"Granted operations team LTFRB compliance access",
	},
	{
		"2000000d-0000-0000-0000-000000000004",
		"12 days", "APPROVE", "kyc_submission",
		"20000008-0000-0000-0000-000000000003",
		`{"status":"pending"}`,
		`{"status":"approved"}`,
		"All documents verified against LTFRB registry",
	},
	{
		"2000000d-0000-0000-0000-000000000005",
		"7 days", "REJECT", "kyc_submission",
		"20000008-0000-0000-0000-000000000004",
		`{"status":"pending"}`,
		`{"status":"rejected"}`,
		"License image blurred; registration expired",
	},
	{
		"2000000d-0000-0000-0000-000000000006",
		"4 days", "UPDATE", "incident",
		"20000007-0000-0000-0000-000000000004",
		`{"status":"open","assigned_to":null}`,
		`{"status":"investigating","assigned_to":"superadmin"}`,
		"Assigned to safety queue for review",
	},
	{
		"2000000d-0000-0000-0000-000000000007",
		"3 days", "UPDATE", "feature_flag",
		"maintenance_mode",
		`{"enabled":true}`,
		`{"enabled":false}`,
		"Maintenance window ended",
	},
	{
		"2000000d-0000-0000-0000-000000000008",
		"2 days", "APPROVE", "driver_payout",
		"20000005-0000-0000-0000-000000000001",
		`{"status":"pending"}`,
		`{"status":"completed"}`,
		"Weekly payout batch released",
	},
}

type demoHealthProbe struct {
	id           string
	serviceName  string
	status       string // ok|degraded|down
	latencyMs    int
	errorMessage string // empty → NULL
}

var demoHealthProbes = []demoHealthProbe{
	{"2000000e-0000-0000-0000-000000000001", "api", "ok", 12, ""},
	{"2000000e-0000-0000-0000-000000000002", "db", "ok", 8, ""},
	{"2000000e-0000-0000-0000-000000000003", "redis", "degraded", 850, "Latency above 500ms threshold"},
	{"2000000e-0000-0000-0000-000000000004", "mapbox", "ok", 145, ""},
	{"2000000e-0000-0000-0000-000000000005", "twilio", "ok", 220, ""},
}

func seedPhase4System(ctx context.Context, tx pgx.Tx) error {
	superadminID, err := resolveSuperadminID(ctx, tx)
	if err != nil {
		return err
	}

	// ─── Service areas ─────────────────────────────────────────────────────────
	const insertArea = `
		INSERT INTO service_areas (id, name, lgu_code, boundary, active)
		VALUES ($1, $2, $3, $4::jsonb, true)
		ON CONFLICT (id) DO NOTHING`
	for _, a := range demoServiceAreas {
		if _, err := tx.Exec(ctx, insertArea, a.id, a.name, a.lguCode, a.boundary); err != nil {
			return fmt.Errorf("insert service_area %s: %w", a.id, err)
		}
	}
	fmt.Printf("  ✅ %d service_areas (Metro Manila Core, BGC-Makati CBD)\n", len(demoServiceAreas))

	// ─── LGU partnerships ──────────────────────────────────────────────────────
	for _, l := range demoLGUs {
		areaID := demoServiceAreas[l.serviceAreaIdx].id
		var startExpr, endExpr string
		args := []any{
			l.id, areaID, l.lguName, l.contactName, l.contactEmail, l.contactPhone,
			l.status, l.notes,
		}
		if l.agreementStart != "" {
			startExpr = fmt.Sprintf("DATE '%s'", l.agreementStart)
		} else {
			startExpr = "NULL"
		}
		if l.agreementEnd != "" {
			endExpr = fmt.Sprintf("DATE '%s'", l.agreementEnd)
		} else {
			endExpr = "NULL"
		}
		query := fmt.Sprintf(`
			INSERT INTO lgu_partnerships (
				id, service_area_id, lgu_name, contact_name, contact_email, contact_phone,
				agreement_start, agreement_end, status, notes
			) VALUES (
				$1, $2, $3, $4, $5, $6,
				%s, %s, $7, $8
			)
			ON CONFLICT (id) DO NOTHING`, startExpr, endExpr)
		if _, err := tx.Exec(ctx, query, args...); err != nil {
			return fmt.Errorf("insert lgu_partnership %s: %w", l.id, err)
		}
	}
	fmt.Printf("  ✅ %d lgu_partnerships (Makati active, Quezon City pending)\n", len(demoLGUs))

	// ─── Alert rules ───────────────────────────────────────────────────────────
	const insertRule = `
		INSERT INTO alert_rules (id, name, type, enabled, config, created_by)
		VALUES ($1, $2, $3, $4, $5::jsonb, $6)
		ON CONFLICT (id) DO NOTHING`
	for _, r := range demoAlertRules {
		if _, err := tx.Exec(ctx, insertRule,
			r.id, r.name, r.ruleType, r.enabled, r.config, superadminID,
		); err != nil {
			return fmt.Errorf("insert alert_rule %s: %w", r.id, err)
		}
	}
	fmt.Printf("  ✅ %d alert_rules (low_rating, kyc_expiry — both enabled)\n", len(demoAlertRules))

	// ─── Audit log entries ─────────────────────────────────────────────────────
	// Resolve finance user id for the CREATE admin_user audit entry; fall back
	// to the superadmin if finance hasn't been seeded (legacy reset pre-Phase 4).
	var financeID string
	err = tx.QueryRow(ctx,
		`SELECT id FROM users WHERE email='finance@sakai.com' LIMIT 1`,
	).Scan(&financeID)
	if err != nil {
		financeID = superadminID
	}

	const insertAudit = `
		INSERT INTO audit_log_entries (
			id, timestamp, actor_id, ip_address,
			action, resource_type, resource_id,
			before_state, after_state, reason
		) VALUES (
			$1, NOW() - $2::interval, $3, '127.0.0.1',
			$4, $5, $6,
			%s, %s, $7
		)
		ON CONFLICT (id) DO NOTHING`

	for _, a := range demoAuditEntries {
		resourceID := a.resourceID
		switch a.resourceType {
		case "session":
			resourceID = superadminID
		case "admin_user":
			resourceID = financeID
		}

		beforeExpr := "NULL"
		afterExpr := "NULL"
		args := []any{a.id, a.createdAgo, superadminID, a.action, a.resourceType, resourceID, a.reason}
		argIdx := 8
		if a.beforeState != "" {
			beforeExpr = fmt.Sprintf("$%d::jsonb", argIdx)
			args = append(args, a.beforeState)
			argIdx++
		}
		if a.afterState != "" {
			afterExpr = fmt.Sprintf("$%d::jsonb", argIdx)
			args = append(args, a.afterState)
		}

		query := fmt.Sprintf(insertAudit, beforeExpr, afterExpr)
		if _, err := tx.Exec(ctx, query, args...); err != nil {
			return fmt.Errorf("insert audit_log_entry %s: %w", a.id, err)
		}
	}
	fmt.Printf("  ✅ %d audit_log_entries (LOGIN, CREATE, UPDATE×3, APPROVE×2, REJECT)\n", len(demoAuditEntries))

	// ─── System health probes ─────────────────────────────────────────────────
	const insertProbe = `
		INSERT INTO system_health_probes (
			id, service_name, status, latency_ms, checked_at, error_message
		) VALUES (
			$1, $2, $3, $4, NOW(), $5
		)
		ON CONFLICT (id) DO NOTHING`
	for _, p := range demoHealthProbes {
		var errMsg any
		if p.errorMessage != "" {
			errMsg = p.errorMessage
		} else {
			errMsg = nil
		}
		if _, err := tx.Exec(ctx, insertProbe,
			p.id, p.serviceName, p.status, p.latencyMs, errMsg,
		); err != nil {
			return fmt.Errorf("insert system_health_probe %s: %w", p.id, err)
		}
	}
	fmt.Printf("  ✅ %d system_health_probes (4 ok, 1 degraded — redis)\n", len(demoHealthProbes))

	// ─── Feature flag stamp ───────────────────────────────────────────────────
	// Re-upsert maintenance_mode so updated_by is non-NULL — gives the audit
	// page provenance and matches the "UPDATE feature_flag" entry above.
	const stampFlag = `
		INSERT INTO feature_flags (key, enabled, description, updated_by, updated_at)
		VALUES ('maintenance_mode', false, 'Block all non-admin traffic', $1, NOW() - INTERVAL '3 days')
		ON CONFLICT (key) DO UPDATE SET
			enabled    = EXCLUDED.enabled,
			updated_by = EXCLUDED.updated_by,
			updated_at = EXCLUDED.updated_at`
	if _, err := tx.Exec(ctx, stampFlag, superadminID); err != nil {
		return fmt.Errorf("stamp feature_flag maintenance_mode: %w", err)
	}
	fmt.Printf("  ✅ feature_flags.maintenance_mode stamped with superadmin updated_by\n")

	return nil
}
