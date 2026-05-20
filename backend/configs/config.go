// Package configs provides centralized configuration management for the SakAI backend.
package configs

import (
	"os"
	"strconv"
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
	UploadDir           string
	UploadPublicBaseURL string

	// Regional
	Currency string

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
		DatabaseURL:             getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/sakai?sslmode=disable"),
		MigrationsDir:           getEnv("MIGRATIONS_DIR", "../migrations"),
		RedisURL:                getEnv("REDIS_URL", "redis://localhost:6379/0"),
		JWTSecret:               getEnv("JWT_SECRET", "change-me-in-production"),
		AccessTokenExpiry:       getDuration("ACCESS_TOKEN_EXPIRY", 60*time.Minute),
		RefreshTokenExpiry:      getDuration("REFRESH_TOKEN_EXPIRY", 30*24*time.Hour),
		WSPingInterval:          getDuration("WS_PING_INTERVAL", 30*time.Second),
		LocationRateLimitPerMin: getInt("LOCATION_RATE_LIMIT_PER_MIN", 30),
		StripeSecretKey:         getEnv("STRIPE_SECRET_KEY", ""),
		UploadDir:               getEnv("UPLOAD_DIR", "./uploads"),
		UploadPublicBaseURL:     getEnv("UPLOAD_PUBLIC_BASE_URL", "/api/files"),
		Currency:                getEnv("CURRENCY", "USD"),
		E2EEnabled:              getEnv("E2E_ENABLED", "false") == "true",
		E2ESeedToken:            getEnv("E2E_SEED_TOKEN", ""),
	}

	// Security: refuse to start with the default JWT secret outside of local dev.
	// A leaked or guessable secret allows any client to forge valid JWTs.
	if cfg.JWTSecret == "change-me-in-production" && getEnv("APP_ENV", "development") != "development" {
		panic("JWT_SECRET must be set to a strong secret value in non-development environments")
	}

	return cfg
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
