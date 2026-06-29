package handler

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/sakai/backend/internal/delivery/ws"
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
	dispatcher   ws.Dispatcher
	jwtSecret    string
	accessExpiry time.Duration
	seedToken    string
}

// NewE2EHandler wires the dependencies. The seedToken value comes from
// configs.E2ESeedToken; an empty string disables the endpoint outright
// (the handler returns 503 so a misconfigured deploy is loud).
//
// The dispatcher is optional — only PublishEvent uses it. Pass nil if
// the deploy wants the seed/delete endpoints but not the publish path.
func NewE2EHandler(
	userRepo domain.UserRepository,
	driverRepo domain.DriverRepository,
	rideRepo domain.RideRepository,
	dispatcher ws.Dispatcher,
	jwtSecret string,
	accessExpiry time.Duration,
	seedToken string,
) *E2EHandler {
	return &E2EHandler{
		userRepo:     userRepo,
		driverRepo:   driverRepo,
		rideRepo:     rideRepo,
		dispatcher:   dispatcher,
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
	suite := normalizeSuite(c.Query("suite"))
	passenger, err := h.upsertUser(ctx, seedEmail(suite, "passenger"), "E2E Passenger", domain.RolePassenger)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "SEED_FAILED", "message": err.Error()})
		return
	}
	driver, err := h.upsertUser(ctx, seedEmail(suite, "driver"), "E2E Driver", domain.RoleDriver)
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

// E2EPublishEventRequest is the body of POST /api/e2e/publish-event.
//
// Only `ride.*` events are routable through the ride dispatcher path; for
// user-targeted events use TargetUserID instead of RideID. Exactly one of
// the two MUST be set — the handler returns 400 otherwise.
type E2EPublishEventRequest struct {
	RideID       *uuid.UUID     `json:"ride_id,omitempty"`
	TargetUserID *uuid.UUID     `json:"target_user_id,omitempty"`
	Event        string         `json:"event" binding:"required"`
	Payload      map[string]any `json:"payload"`
}

// PublishEvent fans out an arbitrary WS envelope for the integration test
// suite. The handler does NOT validate payload shape against the event
// type — callers are expected to send valid v2-shape payloads. Server-
// side typed payload structs (e.g. RideCompletedPayload) are not used here
// because the test wants to send malformed/edge-case envelopes too.
func (h *E2EHandler) PublishEvent(c *gin.Context) {
	if h.seedToken == "" {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": "E2E_DISABLED"})
		return
	}
	if !h.bearerMatches(c.GetHeader("Authorization")) {
		c.JSON(http.StatusUnauthorized, gin.H{"code": "INVALID_SEED_TOKEN"})
		return
	}
	if h.dispatcher == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"code":    "DISPATCHER_UNAVAILABLE",
			"message": "publish-event requires a wired ws.Dispatcher",
		})
		return
	}
	var req E2EPublishEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if (req.RideID == nil) == (req.TargetUserID == nil) {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    "VALIDATION_ERROR",
			"message": "exactly one of ride_id, target_user_id required",
		})
		return
	}

	ctx := c.Request.Context()
	payload := req.Payload
	if payload == nil {
		payload = map[string]any{}
	}
	if req.RideID != nil {
		ride, err := h.rideRepo.GetByID(ctx, *req.RideID)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"code": "RIDE_NOT_FOUND"})
			return
		}
		if err := h.dispatcher.PublishToRide(ctx, ride, ws.EventType(req.Event), payload); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": "PUBLISH_FAILED", "message": err.Error()})
			return
		}
	} else {
		if err := h.dispatcher.PublishToUser(ctx, *req.TargetUserID, ws.EventType(req.Event), payload); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": "PUBLISH_FAILED", "message": err.Error()})
			return
		}
	}
	c.JSON(http.StatusAccepted, gin.H{"event": req.Event})
}

// CleanupSeed hard-deletes the seeded passenger + driver for a given
// suite namespace (or the default unsuffixed one). Used by long-running
// staging environments so test data doesn't accumulate across CI weeks.
// Idempotent — missing rows do not error.
func (h *E2EHandler) CleanupSeed(c *gin.Context) {
	if h.seedToken == "" {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": "E2E_DISABLED"})
		return
	}
	if !h.bearerMatches(c.GetHeader("Authorization")) {
		c.JSON(http.StatusUnauthorized, gin.H{"code": "INVALID_SEED_TOKEN"})
		return
	}
	ctx := c.Request.Context()
	suite := normalizeSuite(c.Query("suite"))
	deleted := []string{}
	for _, who := range []string{"passenger", "driver"} {
		email := seedEmail(suite, who)
		user, err := h.userRepo.GetByEmail(ctx, email)
		if err != nil {
			if errors.Is(err, domain.ErrNotFound) {
				continue
			}
			c.JSON(http.StatusInternalServerError, gin.H{"code": "CLEANUP_FAILED", "message": err.Error()})
			return
		}
		if err := h.userRepo.Delete(ctx, user.ID); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": "CLEANUP_FAILED", "message": err.Error()})
			return
		}
		deleted = append(deleted, email)
	}
	c.JSON(http.StatusOK, gin.H{"deleted": deleted, "suite": suite})
}

// normalizeSuite folds an empty suite name to the literal "default" so
// the seed emails are stable + URL-safe. Disallowed characters are
// stripped so a hostile caller can't smuggle SQL fragments via the param.
func normalizeSuite(raw string) string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "default"
	}
	var out strings.Builder
	for _, r := range raw {
		switch {
		case r >= 'a' && r <= 'z':
			out.WriteRune(r)
		case r >= 'A' && r <= 'Z':
			out.WriteRune(r + 32)
		case r >= '0' && r <= '9':
			out.WriteRune(r)
		case r == '-' || r == '_':
			out.WriteRune(r)
		}
	}
	if out.Len() == 0 {
		return "default"
	}
	return out.String()
}

// seedEmail builds the canonical seed email for a suite + role combo.
// Format: e2e-<role>-<suite>@sakai.test. The default suite still gets
// the suffix so cleanup-by-suite is unambiguous.
func seedEmail(suite, role string) string {
	return "e2e-" + role + "-" + suite + "@sakai.test"
}
