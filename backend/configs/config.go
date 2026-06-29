// Package configs provides centralized configuration management for the SakAI backend.
package configs

import (
	"os"
	"strconv"
	"strings"
	"time"
)

// Config holds all runtime configuration loaded from environment variables.
type Config struct {
	// Server
	Port       string
	AppVersion string

	// Database
	DatabaseURL   string
	MigrationsDir string

	// Redis
	RedisURL string

	// JWT
	JWTSecret          string
	AccessTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration

	// WebSocket
	WSPingInterval time.Duration

	// Rate Limiting
	LocationRateLimitPerMin int

	// Stripe (Payments)
	StripeSecretKey string

	// Storage (driver documents)
	// Set STORAGE_PROVIDER=s3 to use S3-compatible storage (Supabase, R2, etc.)
	// Leave unset or "local" to use local disk (dev only).
	StorageProvider     string
	UploadDir           string
	UploadPublicBaseURL string

	// S3-compatible storage (used when StorageProvider=s3)
	StorageEndpoint      string
	StorageRegion        string
	StorageAccessKey     string
	StorageSecretKey     string
	StorageBucket        string
	StoragePublicBaseURL string

	// Regional
	Currency string

	// CORS — comma-separated list of allowed browser origins for CORS / WS.
	// Reflects ONLY these origins in Access-Control-Allow-Origin.
	// Empty means no origin is allowed (correct for non-browser API consumers).
	AllowedOrigins []string

	// E2E (integration test harness). When true, the /api/e2e/* routes are
	// mounted; they let the staging integration tests seed deterministic
	// fixtures and mint short-lived JWTs without touching production data.
	// MUST be false in production — the route block is unauthenticated and
	// the seed token is the only gate. Default is "false" so a missing env
	// fails closed.
	//
	// OUTSTANDING (RFC v2 P9 live execution):
	//   1. Staging deploy: set E2E_ENABLED=true + E2E_SEED_TOKEN=<rotating-secret>
	//      so /api/e2e/seed is reachable from the integration test runner.
	//      The token should rotate at least weekly and live in the same
	//      secret manager as other staging-only credentials.
	//   2. NEVER set E2E_ENABLED=true on production. The router defence-in-
	//      depth check still keeps the route off the mux, but the env should
	//      remain blank to avoid surprise.
	E2EEnabled  bool
	E2ESeedToken string
}

// Load reads configuration from environment variables with sensible defaults.
// In production, all defaults (especially JWTSecret) must be overridden.
// Load panics if JWT_SECRET is still the insecure default and APP_ENV != "development".
func Load() *Config {
	cfg := &Config{
		Port:                    getEnv("PORT", "8080"),
		AppVersion:              getEnv("APP_VERSION", "1.0.0"),
		DatabaseURL:             getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/sakai?sslmode=require"),
		MigrationsDir:           getEnv("MIGRATIONS_DIR", "../migrations"),
		RedisURL:                getEnv("REDIS_URL", "redis://localhost:6379/0"),
		JWTSecret:               getEnv("JWT_SECRET", "change-me-in-production"),
		AccessTokenExpiry:       getDuration("ACCESS_TOKEN_EXPIRY", 60*time.Minute),
		RefreshTokenExpiry:      getDuration("REFRESH_TOKEN_EXPIRY", 30*24*time.Hour),
		WSPingInterval:          getDuration("WS_PING_INTERVAL", 30*time.Second),
		LocationRateLimitPerMin: getInt("LOCATION_RATE_LIMIT_PER_MIN", 30),
		StripeSecretKey:         getEnv("STRIPE_SECRET_KEY", ""),
		StorageProvider:         getEnv("STORAGE_PROVIDER", "local"),
		UploadDir:               getEnv("UPLOAD_DIR", "./uploads"),
		UploadPublicBaseURL:     getEnv("UPLOAD_PUBLIC_BASE_URL", "/api/files"),
		StorageEndpoint:         getEnv("STORAGE_ENDPOINT", ""),
		StorageRegion:           getEnv("STORAGE_REGION", "us-east-1"),
		StorageAccessKey:        getEnv("STORAGE_ACCESS_KEY", ""),
		StorageSecretKey:        getEnv("STORAGE_SECRET_KEY", ""),
		StorageBucket:           getEnv("STORAGE_BUCKET", ""),
		StoragePublicBaseURL:    getEnv("STORAGE_PUBLIC_BASE_URL", ""),
		Currency:                getEnv("CURRENCY", "USD"),
		AllowedOrigins:          splitAndTrim(getEnv("ALLOWED_ORIGINS", "")),
		E2EEnabled:              getEnv("E2E_ENABLED", "false") == "true",
		E2ESeedToken:            getEnv("E2E_SEED_TOKEN", ""),
	}

	// Security: fail closed on weak/default JWT secrets outside local dev.
	// Note the empty-string default for APP_ENV: an unset APP_ENV must NOT
	// silence the guard (that was the original bypass).
	validateJWTSecret(cfg.JWTSecret, getEnv("APP_ENV", ""))

	return cfg
}

// validateJWTSecret fails closed: in any non-development environment it panics
// when the secret is a known weak/default value or shorter than 32 chars.
// An unset APP_ENV (empty string) is treated as non-development.
func validateJWTSecret(secret, appEnv string) {
	if appEnv == "development" {
		return
	}
	weak := map[string]bool{
		"change-me-in-production":                           true,
		"change-me-in-production-use-a-long-random-string": true,
	}
	if weak[secret] || len(secret) < 32 {
		panic("JWT_SECRET must be a strong (>=32 char, non-default) secret in non-development environments")
	}
}

// splitAndTrim splits a comma-separated string and trims whitespace from each
// element, skipping empty entries. Returns nil for an empty input string.
func splitAndTrim(s string) []string {
	if s == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	out := parts[:0]
	for _, p := range parts {
		if t := strings.TrimSpace(p); t != "" {
			out = append(out, t)
		}
	}
	return out
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getDuration(key string, fallback time.Duration) time.Duration {
	if v := os.Getenv(key); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			return d
		}
	}
	return fallback
}

func getInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}
