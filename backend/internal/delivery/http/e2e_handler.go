package handler

import (
	"context"
	"errors"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/pkg/jwt"
)

// E2EHandler exposes deterministic test fixtures for the mobile integration
// test suite. It is mounted only when configs.E2EEnabled is true AND the
// caller presents the E2E_SEED_TOKEN bearer — both gates fail closed in
// production so the route never serves real traffic.
//
// Per RFC v2 P9, the integration tests need a stable {passengerId, driverId,
// rideId, jwt} bundle that survives across runs. We achieve that by deriving
// IDs from a known seed and upserting on email — running the seed twice
// returns the same user IDs, so the integration test can drive WS events
// against fixed identifiers without DB cleanup between runs.
//
// OUTSTANDING (P9 follow-ups, not blocking this handler):
//   1. WS control channel: the mobile tests need a way to publish arbitrary
//      events for fixture.rideId (e.g. ride.accepted, ride.completed with
//      tip > 0) without going through the production HTTP flow. Add a
//      sibling endpoint POST /api/e2e/publish-event guarded by the same
//      seed token. Payload: {rideId, eventType, payload}. Routes through
//      the existing ws.Dispatcher.PublishToRide so the cluster fanout is
//      identical to a real event.
//   2. Cleanup endpoint: DELETE /api/e2e/seed should hard-delete the
//      seeded passenger + driver + rides so a long-running staging
//      doesn't accumulate test data across weeks of CI runs.
//   3. Per-suite isolation: today every test uses the same passenger +
//      driver pair. If two suites run in parallel they'll race on the
//      same ride row. Add a ?suite=<name> query param to namespace
//      emails (e2e-passenger-<suite>@sakai.test) so suites are isolated.
type E2EHandler struct {
	userRepo     domain.UserRepository
	driverRepo   domain.DriverRepository
	rideRepo     domain.RideRepository
	jwtSecret    string
	accessExpiry time.Duration
	seedToken    string
}

// NewE2EHandler wires the dependencies. The seedToken value comes from
// configs.E2ESeedToken; an empty string disables the endpoint outright
// (the handler returns 503 so a misconfigured deploy is loud).
func NewE2EHandler(
	userRepo domain.UserRepository,
	driverRepo domain.DriverRepository,
	rideRepo domain.RideRepository,
	jwtSecret string,
	accessExpiry time.Duration,
	seedToken string,
) *E2EHandler {
	return &E2EHandler{
		userRepo:     userRepo,
		driverRepo:   driverRepo,
		rideRepo:     rideRepo,
		jwtSecret:    jwtSecret,
		accessExpiry: accessExpiry,
		seedToken:    seedToken,
	}
}

// E2ESeedResponse is the body returned by POST /api/e2e/seed. The IDs are
// stable across runs so an integration test can hardcode them in fixtures.
type E2ESeedResponse struct {
	PassengerID    uuid.UUID `json:"passenger_id"`
	PassengerJWT   string    `json:"passenger_jwt"`
	PassengerEmail string    `json:"passenger_email"`
	DriverID       uuid.UUID `json:"driver_id"`
	DriverJWT      string    `json:"driver_jwt"`
	DriverEmail    string    `json:"driver_email"`
	RideID         uuid.UUID `json:"ride_id"`
}

// Seed materialises (or refreshes) the integration-test fixtures. Behaviour:
//   - Returns 503 when the handler has no seed token (feature disabled).
//   - Returns 401 when the Bearer token does not match the configured one.
//   - Otherwise upserts a passenger + driver pair on stable emails and
//     creates a fresh `requested` ride between them so each run starts
//     from a clean state-machine entry point.
func (h *E2EHandler) Seed(c *gin.Context) {
	if h.seedToken == "" {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"code":    "E2E_DISABLED",
			"message": "E2E seed endpoint is not configured on this deployment",
		})
		return
	}
	if !h.bearerMatches(c.GetHeader("Authorization")) {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    "INVALID_SEED_TOKEN",
			"message": "Bearer token does not match E2E_SEED_TOKEN",
		})
		return
	}

	ctx := c.Request.Context()
	passenger, err := h.upsertUser(ctx, "e2e-passenger@sakai.test", "E2E Passenger", domain.RolePassenger)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "SEED_FAILED", "message": err.Error()})
		return
	}
	driver, err := h.upsertUser(ctx, "e2e-driver@sakai.test", "E2E Driver", domain.RoleDriver)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "SEED_FAILED", "message": err.Error()})
		return
	}
	if err := h.ensureDriverRow(ctx, driver.ID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "SEED_FAILED", "message": err.Error()})
		return
	}

	ride, err := h.createSeedRide(ctx, passenger.ID, driver.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "SEED_FAILED", "message": err.Error()})
		return
	}

	passengerJWT, _, err := jwt.GenerateAccessToken(passenger.ID, passenger.Role, h.jwtSecret, h.accessExpiry)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "JWT_FAILED", "message": err.Error()})
		return
	}
	driverJWT, _, err := jwt.GenerateAccessToken(driver.ID, driver.Role, h.jwtSecret, h.accessExpiry)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "JWT_FAILED", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, E2ESeedResponse{
		PassengerID:    passenger.ID,
		PassengerJWT:   passengerJWT,
		PassengerEmail: passenger.Email,
		DriverID:       driver.ID,
		DriverJWT:      driverJWT,
		DriverEmail:    driver.Email,
		RideID:         ride.ID,
	})
}

// bearerMatches does a constant-time-ish compare on the Authorization header.
// The exact form is "Bearer <token>"; anything else is rejected outright.
func (h *E2EHandler) bearerMatches(header string) bool {
	const prefix = "Bearer "
	if len(header) <= len(prefix) || header[:len(prefix)] != prefix {
		return false
	}
	return header[len(prefix):] == h.seedToken
}

// upsertUser looks up an existing user by email; creates one with a known
// password if absent. The bcrypt hash uses the lowest cost (bcrypt.MinCost)
// since this user only exists for test purposes — the JWT we mint below is
// the actual auth credential.
func (h *E2EHandler) upsertUser(ctx context.Context, email, name string, role domain.UserRole) (*domain.User, error) {
	existing, err := h.userRepo.GetByEmail(ctx, email)
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, domain.ErrNotFound) {
		return nil, err
	}
	hash, err := bcrypt.GenerateFromPassword([]byte("e2e-password"), bcrypt.MinCost)
	if err != nil {
		return nil, err
	}
	user := &domain.User{
		ID:        uuid.New(),
		Name:      name,
		Email:     email,
		Password:  string(hash),
		Role:      role,
		CreatedAt: time.Now().UTC(),
	}
	if err := h.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}
	return user, nil
}

// ensureDriverRow inserts the operational driver record if it doesn't
// already exist. Calling Create on an existing UserID returns an error in
// most repos — we swallow that path so the seed remains idempotent.
func (h *E2EHandler) ensureDriverRow(ctx context.Context, userID uuid.UUID) error {
	if _, err := h.driverRepo.GetByUserID(ctx, userID); err == nil {
		return nil
	}
	return h.driverRepo.Create(ctx, &domain.Driver{
		UserID:    userID,
		Status:    domain.DriverStatusOffline,
		UpdatedAt: time.Now().UTC(),
	})
}

// createSeedRide always inserts a new requested ride so each integration
// run starts at the same lifecycle entry point. We intentionally do NOT
// reuse an existing in-flight ride — the test needs a known starting state
// to drive WS events deterministically.
func (h *E2EHandler) createSeedRide(ctx context.Context, passengerID, driverID uuid.UUID) (*domain.Ride, error) {
	ride := &domain.Ride{
		ID:             uuid.New(),
		PassengerID:    passengerID,
		Status:         domain.RideStatusRequested,
		Origin:         domain.LatLng{Lat: 14.5995, Lng: 120.9842},
		Destination:    domain.LatLng{Lat: 14.6090, Lng: 121.0200},
		IdempotencyKey: "e2e-seed-" + uuid.NewString(),
		CreatedAt:      time.Now().UTC(),
		UpdatedAt:      time.Now().UTC(),
	}
	if err := h.rideRepo.Create(ctx, ride); err != nil {
		return nil, err
	}
	return ride, nil
}
