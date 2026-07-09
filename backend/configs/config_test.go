package configs

import (
	"strings"
	"testing"
)

// panics reports whether validateJWTSecret panicked for the given inputs.
func panics(secret, appEnv string) (panicked bool) {
	defer func() {
		if r := recover(); r != nil {
			panicked = true
		}
	}()
	validateJWTSecret(secret, appEnv)
	return false
}

func TestLoad_DBPoolSizing(t *testing.T) {
	cases := []struct {
		name         string
		maxConnsEnv  string
		minConnsEnv  string
		wantMaxConns int
		wantMinConns int
	}{
		{"defaults when unset", "", "", 20, 2},
		{"reads DB_MAX_CONNS", "50", "", 50, 2},
		{"reads DB_MIN_CONNS", "", "5", 20, 5},
		{"reads both", "100", "10", 100, 10},
		{"defaults on invalid", "invalid", "bad", 20, 2},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			// Set development mode to avoid JWT_SECRET validation panic
			t.Setenv("APP_ENV", "development")
			// Always set (even to "") so ambient env vars from the runner's
			// shell (e.g. a locally exported DB_MAX_CONNS) can't leak in and
			// break cases that expect the fallback default.
			t.Setenv("DB_MAX_CONNS", tc.maxConnsEnv)
			t.Setenv("DB_MIN_CONNS", tc.minConnsEnv)
			cfg := Load()
			if cfg.DBMaxConns != tc.wantMaxConns {
				t.Errorf("DBMaxConns: got %d, want %d", cfg.DBMaxConns, tc.wantMaxConns)
			}
			if cfg.DBMinConns != tc.wantMinConns {
				t.Errorf("DBMinConns: got %d, want %d", cfg.DBMinConns, tc.wantMinConns)
			}
		})
	}
}

func TestValidateJWTSecret(t *testing.T) {
	strong := strings.Repeat("a", 40) // 40 chars, not denylisted

	cases := []struct {
		name      string
		secret    string
		appEnv    string
		wantPanic bool
	}{
		{"dev allows weak default", "change-me-in-production", "development", false},
		{"dev allows short", "x", "development", false},
		{"prod rejects sentinel", "change-me-in-production", "production", true},
		{"prod rejects committed long value", "change-me-in-production-use-a-long-random-string", "production", true},
		{"prod rejects short", "tooshort", "production", true},
		{"prod rejects empty", "", "production", true},
		{"prod accepts strong", strong, "production", false},
		{"unset env treated as non-dev, rejects weak", "change-me-in-production", "", true},
		{"unset env accepts strong", strong, "", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := panics(tc.secret, tc.appEnv); got != tc.wantPanic {
				t.Fatalf("validateJWTSecret(%q,%q): panic=%v want %v", tc.secret, tc.appEnv, got, tc.wantPanic)
			}
		})
	}
}
