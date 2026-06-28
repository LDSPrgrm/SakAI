package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/sakai/backend/configs"
	"github.com/sakai/backend/internal/domain"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	roleFlag     := flag.String("role", string(domain.RoleAdmin), "Role to create (admin, superadmin, operations, finance, support)")
	nameFlag     := flag.String("name", "Admin", "Name of the admin user")
	emailFlag    := flag.String("email", "admin@sakai.com", "Email of the admin user")
	passwordFlag := flag.String("password", "admin123", "Password for the admin user")
	resetFlag    := flag.Bool("reset", false, "Delete all admin users, reseed system roles/permissions and 4 test accounts in one transaction")

	demoFlag       := flag.Bool("demo", false, "Run the demo data populator (passengers, drivers, rides, etc.)")
	demoPhasesFlag := flag.String("demo-phases", "", "Comma list of phases to run: users,rides,safety,system (or 1,2,3,4). Default: all registered phases.")
	demoWipeFlag   := flag.Bool("demo-wipe", false, "Before insert, delete only demo rows (id LIKE '2000%') for the requested phases")

	flag.Parse()

	_ = godotenv.Load("../../.env")
	_ = godotenv.Load()

	cfg := configs.Load()
	if cfg.DatabaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("Database ping failed: %v", err)
	}

	// -------------------------------------------------------------------------
	// RESET PATH: full admin wipe + reseed in a single transaction
	// -------------------------------------------------------------------------
	if *resetFlag {
		if err := runReset(ctx, pool); err != nil {
			log.Fatalf("Reset failed (transaction rolled back): %v", err)
		}
		os.Exit(0)
	}

	// -------------------------------------------------------------------------
	// DEMO PATH: populate demo data (passengers, drivers, rides, ...) in one txn
	// -------------------------------------------------------------------------
	if *demoFlag {
		phases := parsePhases(*demoPhasesFlag)
		if err := runDemo(ctx, pool, phases, *demoWipeFlag); err != nil {
			log.Fatalf("Demo seed failed (transaction rolled back): %v", err)
		}
		os.Exit(0)
	}

	// -------------------------------------------------------------------------
	// SINGLE-USER PATH (unchanged)
	// -------------------------------------------------------------------------
	role := domain.UserRole(*roleFlag)
	validRoles := map[domain.UserRole]bool{
		domain.RoleAdmin:      true,
		domain.RoleSuperadmin: true,
		domain.RoleOperations: true,
		domain.RoleFinance:    true,
		domain.RoleSupport:    true,
	}
	if !validRoles[role] {
		log.Fatalf("Invalid role: %s. Must be one of: admin, superadmin, operations, finance, support", *roleFlag)
	}

	roleIDByEnum := map[domain.UserRole]string{
		domain.RoleSuperadmin: "10000000-0000-0000-0000-000000000001",
		domain.RoleOperations: "10000000-0000-0000-0000-000000000002",
		domain.RoleFinance:    "10000000-0000-0000-0000-000000000003",
		domain.RoleSupport:    "10000000-0000-0000-0000-000000000004",
	}
	roleID, hasRoleID := roleIDByEnum[role]

	hash, err := bcrypt.GenerateFromPassword([]byte(*passwordFlag), bcrypt.DefaultCost)
	if err != nil {
		log.Fatalf("Failed to hash password: %v", err)
	}

	userID := uuid.New()

	var insertErr error
	if hasRoleID {
		const q = `
			INSERT INTO users (id, name, email, password_hash, role, role_id)
			VALUES ($1, $2, $3, $4, $5, $6)`
		_, insertErr = pool.Exec(ctx, q, userID, *nameFlag, *emailFlag, string(hash), role, roleID)
	} else {
		const q = `
			INSERT INTO users (id, name, email, password_hash, role)
			VALUES ($1, $2, $3, $4, $5)`
		_, insertErr = pool.Exec(ctx, q, userID, *nameFlag, *emailFlag, string(hash), role)
	}
	if insertErr != nil {
		log.Fatalf("Failed to insert admin user: %v", insertErr)
	}

	fmt.Printf("✅ Successfully created %s account!\n", role)
	fmt.Printf("   ID:    %s\n", userID)
	fmt.Printf("   Name:  %s\n", *nameFlag)
	fmt.Printf("   Email: %s\n", *emailFlag)
	os.Exit(0)
}

// runReset wipes all admin users, reseeds system roles + permissions, and
// inserts the 4 default test accounts — all in a single transaction.
func runReset(ctx context.Context, pool *pgxpool.Pool) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck — no-op after Commit

	// 1a. Delete audit log entries that reference admin users (actor_id FK is NOT NULL, no cascade)
	const deleteAuditLogs = `
		DELETE FROM audit_log_entries
		WHERE actor_id IN (SELECT id FROM users WHERE role NOT IN ('passenger', 'driver'))`
	if _, err := tx.Exec(ctx, deleteAuditLogs); err != nil {
		return fmt.Errorf("delete audit_log_entries: %w", err)
	}

	// 1b. Remove all admin-class users
	if _, err := tx.Exec(ctx, `DELETE FROM users WHERE role NOT IN ('passenger', 'driver')`); err != nil {
		return fmt.Errorf("delete admin users: %w", err)
	}

	// 2. Clear permissions for system roles before upserting
	const deletePerms = `
		DELETE FROM role_permissions
		WHERE role_id IN (
			'10000000-0000-0000-0000-000000000001',
			'10000000-0000-0000-0000-000000000002',
			'10000000-0000-0000-0000-000000000003',
			'10000000-0000-0000-0000-000000000004'
		)`
	if _, err := tx.Exec(ctx, deletePerms); err != nil {
		return fmt.Errorf("delete role_permissions: %w", err)
	}

	// 3. Upsert system roles (idempotent — safe to run twice)
	// NOTE: roles.name uses 'super_admin' (underscore); users.role ENUM uses
	//       'superadmin' (no underscore). This asymmetry is intentional.
	const upsertRoles = `
		INSERT INTO roles (id, name, description, is_system) VALUES
			('10000000-0000-0000-0000-000000000001', 'super_admin', 'Full platform access',               TRUE),
			('10000000-0000-0000-0000-000000000002', 'operations',  'Users, rides, KYC, safety',          TRUE),
			('10000000-0000-0000-0000-000000000003', 'finance',     'Payments and reports',               TRUE),
			('10000000-0000-0000-0000-000000000004', 'support',     'Read-only: users, rides, incidents', TRUE)
		ON CONFLICT (id) DO UPDATE SET
			name        = EXCLUDED.name,
			description = EXCLUDED.description,
			is_system   = EXCLUDED.is_system,
			updated_at  = NOW()`
	if _, err := tx.Exec(ctx, upsertRoles); err != nil {
		return fmt.Errorf("upsert roles: %w", err)
	}

	// 4. Insert all role permissions
	const insertPerms = `
		INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
			-- super_admin: full access
			('10000000-0000-0000-0000-000000000001', 'dashboard',        TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000001', 'admin_management', TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'role_management',  TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'fare_config',      TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'payments',         TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'payouts',          TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'user_management',  TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'kyc_verification', TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'safety_incidents', TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'reports',          TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'system_config',    TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000001', 'system_health',    TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000001', 'audit_log',        TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000001', 'ltfrb_compliance', TRUE,  TRUE),
			-- operations
			('10000000-0000-0000-0000-000000000002', 'dashboard',        TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000002', 'user_management',  TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000002', 'kyc_verification', TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000002', 'safety_incidents', TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000002', 'reports',          TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000002', 'ltfrb_compliance', TRUE,  TRUE),
			-- finance
			('10000000-0000-0000-0000-000000000003', 'dashboard',        TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000003', 'payments',         TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000003', 'payouts',          TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000003', 'fare_config',      TRUE,  TRUE),
			('10000000-0000-0000-0000-000000000003', 'reports',          TRUE,  TRUE),
			-- support (read-only)
			('10000000-0000-0000-0000-000000000004', 'dashboard',        TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000004', 'user_management',  TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000004', 'safety_incidents', TRUE,  FALSE),
			('10000000-0000-0000-0000-000000000004', 'reports',          TRUE,  FALSE)
		ON CONFLICT (role_id, permission_key) DO NOTHING`
	if _, err := tx.Exec(ctx, insertPerms); err != nil {
		return fmt.Errorf("insert role_permissions: %w", err)
	}

	// 5. Insert the 4 test accounts
	type seedAccount struct {
		name   string
		email  string
		role   domain.UserRole
		roleID string
	}
	accounts := []seedAccount{
		{"Super Admin", "superadmin@sakai.com", domain.RoleSuperadmin, "10000000-0000-0000-0000-000000000001"},
		{"Operations",  "operations@sakai.com", domain.RoleOperations, "10000000-0000-0000-0000-000000000002"},
		{"Finance",     "finance@sakai.com",    domain.RoleFinance,    "10000000-0000-0000-0000-000000000003"},
		{"Support",     "support@sakai.com",    domain.RoleSupport,    "10000000-0000-0000-0000-000000000004"},
	}
	const insertUser = `
		INSERT INTO users (id, name, email, password_hash, role, role_id)
		VALUES ($1, $2, $3, $4, $5, $6)`

	for _, acct := range accounts {
		hash, err := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)
		if err != nil {
			return fmt.Errorf("hash password for %s: %w", acct.email, err)
		}
		if _, err := tx.Exec(ctx, insertUser, uuid.New(), acct.name, acct.email, string(hash), acct.role, acct.roleID); err != nil {
			return fmt.Errorf("insert user %s: %w", acct.email, err)
		}
		fmt.Printf("  ✅ %-12s  %s\n", acct.role, acct.email)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}

	fmt.Println("\nAll 4 admin accounts seeded. Password for all: admin123")
	return nil
}
