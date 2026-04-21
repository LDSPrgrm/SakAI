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
	"github.com/sakai/backend/internal/infrastructure/stripe"
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
	// Runs all pending UP migrations at startup from embedded files.
	// Already-applied migrations are skipped.
	if err := database.Migrate(cfg.DatabaseURL); err != nil {
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
	// New repositories for documents, ratings, and ride payments.
	docRepo := postgres.NewDocumentRepo(pool)
	ratingRepo := postgres.NewRatingRepo(pool)
	ridePaymentRepo := postgres.NewRidePaymentRepo(pool)

	// ── Use cases ─────────────────────────────────────────────────────────────
	authUC := usecase.NewAuthUseCase(
		userRepo, tokenRepo,
		cfg.JWTSecret,
		cfg.AccessTokenExpiry,
		cfg.RefreshTokenExpiry,
	)
	driverUC := usecase.NewDriverUseCase(driverRepo, rideRepo)
	fareCalc := usecase.NewFareCalculator()
	rideUC := usecase.NewRideUseCase(rideRepo, driverRepo, fareCalc)
	adminUC := usecase.NewAdminUseCase(adminRepo, userRepo, rideRepo, incidentRepo, metricsRepo, auditRepo, roleRepo)
	fareUC := usecase.NewFareUseCase(fareRepo, auditRepo)
	auditUC := usecase.NewAuditUseCase(auditRepo)
	roleUC := usecase.NewRoleUseCase(roleRepo, auditRepo)
	paymentUC := usecase.NewPaymentUseCase(paymentRepo, auditRepo)
	safetyUC := usecase.NewSafetyUseCase(safetyRepo, auditRepo)
	systemUC := usecase.NewSystemUseCase(systemRepo, auditRepo)
	reportUC := usecase.NewReportUseCase(reportRepo)
	metricsUC := usecase.NewMetricsUseCase(metricsIndividualRepo)
	// New use cases for documents, ratings, and payment processing.
	documentUC := usecase.NewDocumentUseCase(docRepo, rideRepo)
	ratingUC := usecase.NewRatingUseCase(ratingRepo, rideRepo)

	// Stripe client — real SDK replaces the stub.
	stripeClient := stripe.New(cfg.StripeSecretKey)

	paymentProcessingUC := usecase.NewPaymentProcessingUsecase(ridePaymentRepo, stripeClient, rideRepo, userRepo, postgres.NewEarningsRepo(pool))
	// Tip use case.
	tipRepo := postgres.NewTipRepo(pool)
	tipUC := usecase.NewTipUseCase(tipRepo, rideRepo, stripeClient)

	// Payment method repository and usecase
	pmRepo := postgres.NewPaymentMethodRepo(pool)
	pmUC := usecase.NewPaymentMethodUseCase(pmRepo, stripeClient)

	// User ride history usecase
	userRideUC := usecase.NewUserRideUseCase(rideRepo)

	// ── WebSocket hub ─────────────────────────────────────────────────────────
	hub := ws.NewHub(cfg.WSPingInterval)

	// In a real clustered setup, workerCtx is cancelled on shutdown causing Run to gracefully exit.
	workerCtx, workerCancel := context.WithCancel(context.Background())
	defer workerCancel()

	dispatcher := ws.NewRedisDispatcher(rdb, hub)
	go dispatcher.Run(workerCtx)

	// ── HTTP handlers ─────────────────────────────────────────────────────────
	deps := router.Deps{
		Auth:           handler.NewAuthHandler(authUC),
		Driver:         handler.NewDriverHandler(driverUC, dispatcher),
		Ride:           handler.NewRideHandler(rideUC, userRideUC, dispatcher, rideRepo, userRepo, driverRepo, ridePaymentRepo),
		Admin:          handler.NewAdminHandler(adminUC, auditUC),
		Fare:           handler.NewFareHandler(fareUC),
		Audit:          handler.NewAuditHandler(auditUC),
		Role:           handler.NewRoleHandler(roleUC, authUC),
		Payment:        handler.NewPaymentHandler(paymentUC),
		Safety:         handler.NewSafetyHandler(safetyUC),
		System:         handler.NewSystemHandler(systemUC),
		Report:         handler.NewReportHandler(reportUC),
		Metrics:        handler.NewMetricsHandler(metricsUC),
		Document:       handler.NewDocumentHandler(documentUC),
		Rating:         handler.NewRatingHandler(ratingUC),
		PayProcess:     handler.NewRidePaymentHandler(paymentProcessingUC, rideRepo, userRepo),
		Tip:            handler.NewTipHandler(tipUC),
		PaymentMethod:  handler.NewPaymentMethodHandler(pmUC),
		WS:             ws.NewHandler(hub),
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
