package configs

import (
	"os"
	"strconv"
	"time"
)

// Config holds all runtime configuration loaded from environment variables.
type Config struct {
	// Server
	Port string

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
}

// Load reads configuration from environment variables with sensible defaults.
// In production, all defaults (especially JWTSecret) must be overridden.
// Load panics if JWT_SECRET is still the insecure default and APP_ENV != "development".
func Load() *Config {
	cfg := &Config{
		Port:                    getEnv("PORT", "8080"),
		DatabaseURL:             getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/sakai?sslmode=disable"),
		MigrationsDir:           getEnv("MIGRATIONS_DIR", "../migrations"),
		RedisURL:                getEnv("REDIS_URL", "redis://localhost:6379/0"),
		JWTSecret:               getEnv("JWT_SECRET", "change-me-in-production"),
		AccessTokenExpiry:       getDuration("ACCESS_TOKEN_EXPIRY", 60*time.Minute),
		RefreshTokenExpiry:      getDuration("REFRESH_TOKEN_EXPIRY", 30*24*time.Hour),
		WSPingInterval:          getDuration("WS_PING_INTERVAL", 30*time.Second),
		LocationRateLimitPerMin: getInt("LOCATION_RATE_LIMIT_PER_MIN", 30),
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
