package database

import (
	"embed"
	"io/fs"
	"testing"
)

//go:embed migrations/*.sql
var testMigrationFS embed.FS

func TestMigrations_EmbeddedFilesExist(t *testing.T) {
	// Verify that all expected migration files are embedded.
	expected := []string{
		"001_create_users.up.sql",
		"001_create_users.down.sql",
		"002_create_vehicles.up.sql",
		"002_create_vehicles.down.sql",
		"003_create_drivers.up.sql",
		"003_create_drivers.down.sql",
		"004_create_rides.up.sql",
		"004_create_rides.down.sql",
		"005_create_refresh_tokens.up.sql",
		"005_create_refresh_tokens.down.sql",
		"006_add_active_ride_constraints.up.sql",
		"006_add_active_ride_constraints.down.sql",
		"007_add_admin_roles.up.sql",
		"007_add_admin_roles.down.sql",
		"008_super_admin_schema.up.sql",
		"008_super_admin_schema.down.sql",
		"009_create_roles.up.sql",
		"009_create_roles.down.sql",
		"010_add_role_id_to_users.up.sql",
		"010_add_role_id_to_users.down.sql",
		"011_add_documents_ratings_payments.up.sql",
		"011_add_documents_ratings_payments.down.sql",
		"012_add_ride_tips.up.sql",
		"012_add_ride_tips.down.sql",
		"013_add_ride_fare_columns.up.sql",
		"013_add_ride_fare_columns.down.sql",
		"014_add_vehicle_type.up.sql",
		"014_add_vehicle_type.down.sql",
		"015_add_payment_earnings_columns.up.sql",
		"015_add_payment_earnings_columns.down.sql",
	}

	sub, err := fs.Sub(testMigrationFS, "migrations")
	if err != nil {
		t.Fatalf("failed to open embedded fs: %v", err)
	}

	for _, name := range expected {
		_, err := fs.ReadFile(sub, name)
		if err != nil {
			t.Errorf("migration file %q not found in embedded fs: %v", name, err)
		}
	}
}

func TestMigrations_Count(t *testing.T) {
	// Verify we have the correct number of migration files.
	sub, err := fs.Sub(testMigrationFS, "migrations")
	if err != nil {
		t.Fatalf("failed to open embedded fs: %v", err)
	}

	entries, err := fs.ReadDir(sub, ".")
	if err != nil {
		t.Fatalf("failed to read embedded dir: %v", err)
	}

	// Every migration ships a paired up/down file.
	if len(entries)%2 != 0 {
		t.Errorf("expected paired up/down migrations, got odd count %d", len(entries))
	}
	if len(entries) < 30 {
		t.Errorf("expected at least 30 migration files, got %d", len(entries))
	}
}

func TestMigrations_NonEmptyContent(t *testing.T) {
	// Verify that each migration file has non-empty content.
	sub, err := fs.Sub(testMigrationFS, "migrations")
	if err != nil {
		t.Fatalf("failed to open embedded fs: %v", err)
	}

	entries, err := fs.ReadDir(sub, ".")
	if err != nil {
		t.Fatalf("failed to read embedded dir: %v", err)
	}

	if len(entries) == 0 {
		t.Fatal("no migration files found in embedded fs")
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		content, err := fs.ReadFile(sub, entry.Name())
		if err != nil {
			t.Errorf("failed to read %q: %v", entry.Name(), err)
			continue
		}
		if len(content) == 0 {
			t.Errorf("migration file %q is empty", entry.Name())
		}
	}
}
