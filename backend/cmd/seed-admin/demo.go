package main

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

// Demo data UUID prefix map (see admin/PLAN_MOCK_DATA.md):
//   20000001-... passenger users
//   20000002-... driver users
//   20000003-... rides
//   20000004-... ride_payments
//   20000005-... driver_payouts
//   20000006-... driver_payout_lines
//   20000007-... incidents
//   20000008-... kyc_submissions
//   20000009-... driver_documents
//   2000000A-... service_areas
//   2000000B-... lgu_partnerships
//   2000000C-... alert_rules
//   2000000d-... audit_log_entries
//   2000000f-... ratings
//
// NOTE: Postgres stores UUIDs in lowercase canonical form. LIKE filters MUST
// use lowercase hex letters even when the seeder code uses uppercase literals
// (Postgres normalizes them on insert). Always lowercase letters in wipe SQL.

type seederFn func(ctx context.Context, tx pgx.Tx) error

// phaseSeeders is the registry of implemented demo phases. Adding a new phase
// is two lines: drop a `demo_<name>.go` file with a `seedPhaseN` function, then
// register it here.
var phaseSeeders = map[string]seederFn{
	"users": seedPhase1Users,
	"rides": seedPhase2Rides,
}

// canonicalPhaseOrder defines the order phases must run in to satisfy
// foreign-key dependencies. Unimplemented entries are skipped at dispatch time.
var canonicalPhaseOrder = []string{"users", "rides", "safety", "system"}

func runDemo(ctx context.Context, pool *pgxpool.Pool, phases []string, wipe bool) error {
	if len(phases) == 0 {
		return fmt.Errorf("no phases selected (registered: %s)", knownPhases())
	}
	for _, p := range phases {
		if _, ok := phaseSeeders[p]; !ok {
			return fmt.Errorf("unknown or unimplemented demo phase: %q (registered: %s)", p, knownPhases())
		}
	}

	tx, err := pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck — no-op after Commit

	if wipe {
		fmt.Println("→ Wiping demo rows for selected phases...")
		if err := wipeDemoRows(ctx, tx, phases); err != nil {
			return fmt.Errorf("wipe demo rows: %w", err)
		}
	}

	for _, phase := range phases {
		fmt.Printf("→ Seeding phase: %s\n", phase)
		if err := phaseSeeders[phase](ctx, tx); err != nil {
			return fmt.Errorf("phase %q: %w", phase, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}
	fmt.Println("✅ Demo seed committed.")
	return nil
}

func knownPhases() string {
	keys := make([]string, 0, len(phaseSeeders))
	for _, p := range canonicalPhaseOrder {
		if _, ok := phaseSeeders[p]; ok {
			keys = append(keys, p)
		}
	}
	return strings.Join(keys, ",")
}

// parsePhases accepts a comma-separated list of phase names ("users,rides")
// or numeric ids ("1,2"). Empty input returns all *registered* phases in
// canonical order, so adding new phase files automatically expands defaults.
func parsePhases(s string) []string {
	numToName := map[string]string{
		"1": "users",
		"2": "rides",
		"3": "safety",
		"4": "system",
	}
	if strings.TrimSpace(s) == "" {
		out := make([]string, 0, len(canonicalPhaseOrder))
		for _, p := range canonicalPhaseOrder {
			if _, ok := phaseSeeders[p]; ok {
				out = append(out, p)
			}
		}
		return out
	}

	out := make([]string, 0, 4)
	seen := map[string]bool{}
	for _, raw := range strings.Split(s, ",") {
		token := strings.TrimSpace(strings.ToLower(raw))
		if token == "" {
			continue
		}
		if mapped, ok := numToName[token]; ok {
			token = mapped
		}
		if !seen[token] {
			out = append(out, token)
			seen[token] = true
		}
	}

	// Re-order to canonical so FK ordering is correct regardless of input.
	ordered := make([]string, 0, len(out))
	for _, p := range canonicalPhaseOrder {
		if seen[p] {
			ordered = append(ordered, p)
		}
	}
	return ordered
}

// wipeDemoRows deletes only demo-prefixed rows from tables touched by the
// requested phases, in reverse-FK order. Safe to run before reseed.
func wipeDemoRows(ctx context.Context, tx pgx.Tx, phases []string) error {
	want := map[string]bool{}
	for _, p := range phases {
		want[p] = true
	}

	// Phase 2 (rides) must wipe before users because ride_payments / ratings /
	// payouts FK back to demo users. If both phases are wiped, rides goes first.
	if want["rides"] {
		stmts := []string{
			`DELETE FROM driver_payout_lines WHERE id::text LIKE '20000006-%'`,
			`DELETE FROM driver_payouts      WHERE id::text LIKE '20000005-%'`,
			`DELETE FROM ratings             WHERE id::text LIKE '2000000f-%'`,
			`DELETE FROM ride_payments       WHERE id::text LIKE '20000004-%'`,
			`DELETE FROM rides               WHERE id::text LIKE '20000003-%'`,
		}
		for _, q := range stmts {
			if _, err := tx.Exec(ctx, q); err != nil {
				return fmt.Errorf("wipe rides-phase: %w", err)
			}
		}
	}

	if want["users"] {
		// drivers + vehicles cascade from users (ON DELETE CASCADE), but be
		// explicit so partial-state reseeds are predictable.
		stmts := []string{
			`DELETE FROM drivers   WHERE user_id::text LIKE '20000002-%'`,
			`DELETE FROM vehicles  WHERE user_id::text LIKE '20000002-%'`,
			`DELETE FROM users     WHERE id::text LIKE '20000001-%' OR id::text LIKE '20000002-%'`,
		}
		for _, q := range stmts {
			if _, err := tx.Exec(ctx, q); err != nil {
				return fmt.Errorf("wipe users-phase: %w", err)
			}
		}
	}

	return nil
}

// demoBcrypt hashes the demo password once at MinCost. ~5ms per hash vs ~80ms
// at DefaultCost — meaningful when seeding ten users in one phase.
func demoBcrypt(password string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.MinCost)
	if err != nil {
		return "", fmt.Errorf("bcrypt: %w", err)
	}
	return string(hash), nil
}

// resolveSuperadminID returns the UUID of the seeded superadmin account, or an
// error directing the caller to run -reset first. Used as a default actor for
// audit/KYC rows whose admin FK is non-nullable.
//
//nolint:unused — used by future phases (safety, system).
func resolveSuperadminID(ctx context.Context, tx pgx.Tx) (string, error) {
	var id string
	err := tx.QueryRow(ctx, `SELECT id FROM users WHERE email='superadmin@sakai.com' LIMIT 1`).Scan(&id)
	if err != nil {
		return "", fmt.Errorf("superadmin not found — run `./seed-admin -reset` first: %w", err)
	}
	return id, nil
}
