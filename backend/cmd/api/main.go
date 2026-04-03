// cmd/api/main.go is the application entry point.
// It wires the dependency graph, starts the HTTP server, and handles
// graceful shutdown on SIGINT / SIGTERM.
package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"
	"github.com/sakai/backend/configs"
	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/router"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/infrastructure/database"
	"github.com/sakai/backend/internal/infrastructure/expiry"
	"github.com/sakai/backend/internal/repository/postgres"
	"github.com/sakai/backend/internal/usecase"
)

func main() {
	// Load .env if present. In production the real env vars take precedence,
	// so this is silently ignored when the file does not exist.
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found — using environment variables")
	}

	cfg := configs.Load()

	// ── Migrations ────────────────────────────────────────────────────────────
	// Runs all pending UP migrations at startup. Already-applied migrations are
	// skipped. The path is relative to where the binary is executed.
	if err := database.Migrate(cfg.DatabaseURL, cfg.MigrationsDir); err != nil {
		log.Fatalf("migrations: %v", err)
	}
	log.Println("migrations: up to date")

	// ── Database ──────────────────────────────────────────────────────────────
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := database.Connect(ctx, database.Config{
		DSN:             cfg.DatabaseURL,
		MaxConns:        20,
		MinConns:        2,
		MaxConnLifetime: 30 * time.Minute,
		MaxConnIdleTime: 5 * time.Minute,
	})
	if err != nil {
		log.Fatalf("database: %v", err)
	}
	defer pool.Close()

	opts, err := redis.ParseURL(cfg.RedisURL)
	if err != nil {
		log.Fatalf("redis: %v", err)
	}
	rdb := redis.NewClient(opts)
	defer func() {
		if err := rdb.Close(); err != nil {
			log.Printf("redis close: %v", err)
		}
	}()
	if err := rdb.Ping(ctx).Err(); err != nil {
		log.Fatalf("redis ping: %v", err)
	}

	// ── Repositories ─────────────────────────────────────────────────────────
	userRepo := postgres.NewUserRepo(pool)
	tokenRepo := postgres.NewTokenRepo(pool)
	driverRepo := postgres.NewDriverRepo(pool)
	rideRepo := postgres.NewRideRepo(pool)
	adminRepo := postgres.NewAdminRepo(pool)
	fareRepo := postgres.NewFareRepo(pool)
	auditRepo := postgres.NewAuditRepo(pool)
	incidentRepo := postgres.NewIncidentRepo(pool)
	metricsRepo := postgres.NewSystemMetricsRepo(pool)
	roleRepo := postgres.NewRoleRepo(pool)
	paymentRepo := postgres.NewPaymentRepo(pool)
	safetyRepo := postgres.NewSafetyRepo(pool)
	systemRepo := postgres.NewSystemRepo(pool)
	reportRepo := postgres.NewReportRepo(pool)
	metricsIndividualRepo := postgres.NewMetricsRepo(pool)

	// ── Use cases ─────────────────────────────────────────────────────────────
	authUC := usecase.NewAuthUseCase(
		userRepo, tokenRepo,
		cfg.JWTSecret,
		cfg.AccessTokenExpiry,
		cfg.RefreshTokenExpiry,
	)
	driverUC := usecase.NewDriverUseCase(driverRepo, rideRepo)
	rideUC := usecase.NewRideUseCase(rideRepo, driverRepo)
	adminUC := usecase.NewAdminUseCase(adminRepo, userRepo, rideRepo, incidentRepo, metricsRepo, auditRepo)
	fareUC := usecase.NewFareUseCase(fareRepo, auditRepo)
	auditUC := usecase.NewAuditUseCase(auditRepo)
	roleUC := usecase.NewRoleUseCase(roleRepo, auditRepo)
	paymentUC := usecase.NewPaymentUseCase(paymentRepo, auditRepo)
	safetyUC := usecase.NewSafetyUseCase(safetyRepo, auditRepo)
	systemUC := usecase.NewSystemUseCase(systemRepo, auditRepo)
	reportUC := usecase.NewReportUseCase(reportRepo)
	metricsUC := usecase.NewMetricsUseCase(metricsIndividualRepo)

	// ── WebSocket hub ─────────────────────────────────────────────────────────
	hub := ws.NewHub(cfg.WSPingInterval)

	// In a real clustered setup, workerCtx is cancelled on shutdown causing Run to gracefully exit.
	workerCtx, workerCancel := context.WithCancel(context.Background())
	defer workerCancel()

	dispatcher := ws.NewRedisDispatcher(rdb, hub)
	go dispatcher.Run(workerCtx)

	// ── HTTP handlers ─────────────────────────────────────────────────────────
	deps := router.Deps{
		Auth:    handler.NewAuthHandler(authUC),
		Driver:  handler.NewDriverHandler(driverUC, dispatcher),
		Ride:    handler.NewRideHandler(rideUC, dispatcher),
		Admin:   handler.NewAdminHandler(adminUC, auditUC),
		Fare:    handler.NewFareHandler(fareUC),
		Audit:   handler.NewAuditHandler(auditUC),
		Role:    handler.NewRoleHandler(roleUC),
		Payment: handler.NewPaymentHandler(paymentUC),
		Safety:  handler.NewSafetyHandler(safetyUC),
		System:  handler.NewSystemHandler(systemUC),
		Report:  handler.NewReportHandler(reportUC),
		Metrics: handler.NewMetricsHandler(metricsUC),
		WS:      ws.NewHandler(hub),
	}

	engine := router.New(cfg.JWTSecret, deps)

	// ── Background workers ───────────────────────────────────────────────────
	// workerCtx is cancelled when the process receives SIGINT/SIGTERM. Workers
	// must honour this context and exit cleanly within the shutdown window.
	go expiry.New(rideRepo, dispatcher).Run(workerCtx)

	// ── HTTP server with graceful shutdown ────────────────────────────────────
	srv := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      engine,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in background.
	go func() {
		log.Printf("sakai-api listening on :%s", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server: %v", err)
		}
	}()

	// Block until SIGINT or SIGTERM.
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("shutting down…")

	shutCtx, shutCancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer shutCancel()
	if err := srv.Shutdown(shutCtx); err != nil {
		log.Printf("graceful shutdown error: %v", err)
	}
	log.Println("server stopped")
}
