package database

import (
	"errors"
	"fmt"

	"github.com/golang-migrate/migrate/v4"
	// Register the pgx/v5 driver for golang-migrate.
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	// Register the "file://" source driver.
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

// Migrate runs all pending UP migrations from the given directory.
// It is safe to call on every startup — already-applied migrations are skipped.
//
// migrationsDir should be an absolute or relative path to the folder containing
// numbered .sql files (e.g. "../../migrations" or "/app/migrations").
// dsn must be a valid pgx DSN (postgres://...).
func Migrate(dsn, migrationsDir string) error {
	// golang-migrate expects the pgx/v5 scheme explicitly.
	m, err := migrate.New(
		"file://"+migrationsDir,
		"pgx5://"+stripScheme(dsn),
	)
	if err != nil {
		return fmt.Errorf("migrate: init: %w", err)
	}
	defer m.Close()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return fmt.Errorf("migrate: up: %w", err)
	}
	return nil
}

// stripScheme removes a leading "postgres://" or "postgresql://" prefix so the
// DSN can be re-prefixed with the driver-specific scheme ("pgx5://").
func stripScheme(dsn string) string {
	for _, prefix := range []string{"postgres://", "postgresql://"} {
		if len(dsn) > len(prefix) && dsn[:len(prefix)] == prefix {
			return dsn[len(prefix):]
		}
	}
	return dsn
}
