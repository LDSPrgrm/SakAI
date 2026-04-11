package database

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"

	"github.com/golang-migrate/migrate/v4"
	// Register the pgx/v5 driver for golang-migrate.
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	// source/iofs provides the go:embed compatible source driver.
	"github.com/golang-migrate/migrate/v4/source/iofs"
)

//go:embed migrations/*.sql
var migrationFS embed.FS

// Migrate runs all pending UP migrations from the embedded file system.
// It is safe to call on every startup — already-applied migrations are skipped.
//
// dsn must be a valid pgx DSN (postgres://...).
func Migrate(dsn string) error {
	sub, err := fs.Sub(migrationFS, "migrations")
	if err != nil {
		return fmt.Errorf("migrate: open embedded fs: %w", err)
	}
	src, err := iofs.New(sub, ".")
	if err != nil {
		return fmt.Errorf("migrate: open iofs source: %w", err)
	}
	// golang-migrate expects the pgx/v5 scheme explicitly.
	m, err := migrate.NewWithSourceInstance("iofs", src, "pgx5://"+stripScheme(dsn))
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
