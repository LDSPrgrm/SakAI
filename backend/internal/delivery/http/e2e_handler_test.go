package handler_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
)

const e2eTestSecret = "e2e-jwt-secret"
const e2eSeedToken = "e2e-seed-correct-horse"

// newE2ERouter wires the handler in isolation under a minimal Gin engine so
// the tests don't depend on the production router (which would drag in
// dozens of repo/use-case mocks just to mount one route).
func newE2ERouter(h *handler.E2EHandler) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.POST("/api/e2e/seed", h.Seed)
	return r
}

func TestE2EHandler_DisabledWhenSeedTokenEmpty(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	h := handler.NewE2EHandler(
		mocks.NewMockUserRepository(ctrl),
		mocks.NewMockDriverRepository(ctrl),
		mocks.NewMockRideRepository(ctrl),
		e2eTestSecret,
		time.Hour,
		"", // empty seed token disables the route
	)
	r := newE2ERouter(h)

	req, _ := http.NewRequest("POST", "/api/e2e/seed", nil)
	req.Header.Set("Authorization", "Bearer anything")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusServiceUnavailable, w.Code,
		"empty seed token must hard-disable the endpoint")
}

func TestE2EHandler_RejectsMismatchedBearer(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	h := handler.NewE2EHandler(
		mocks.NewMockUserRepository(ctrl),
		mocks.NewMockDriverRepository(ctrl),
		mocks.NewMockRideRepository(ctrl),
		e2eTestSecret,
		time.Hour,
		e2eSeedToken,
	)
	r := newE2ERouter(h)

	for _, header := range []string{"", "wrong", "Bearer wrong"} {
		req, _ := http.NewRequest("POST", "/api/e2e/seed", nil)
		if header != "" {
			req.Header.Set("Authorization", header)
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		assert.Equal(t, http.StatusUnauthorized, w.Code,
			"header %q must fail auth", header)
	}
}

func TestE2EHandler_SeedCreatesFreshFixturesAndMintsJWTs(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	users := mocks.NewMockUserRepository(ctrl)
	drivers := mocks.NewMockDriverRepository(ctrl)
	rides := mocks.NewMockRideRepository(ctrl)

	// Both users are absent — handler hits Create for each.
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-passenger@sakai.test").
		Return(nil, domain.ErrNotFound)
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-driver@sakai.test").
		Return(nil, domain.ErrNotFound)
	users.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil).Times(2)

	// Driver row absent — ensure it gets created.
	drivers.EXPECT().GetByUserID(gomock.Any(), gomock.Any()).
		Return(nil, domain.ErrNotFound)
	drivers.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	// Fresh ride per seed call.
	rides.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	h := handler.NewE2EHandler(users, drivers, rides, e2eTestSecret, time.Hour, e2eSeedToken)
	r := newE2ERouter(h)

	req, _ := http.NewRequest("POST", "/api/e2e/seed", nil)
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	var body handler.E2ESeedResponse
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("unmarshal response: %v", err)
	}
	assert.NotEqual(t, uuid.Nil, body.PassengerID)
	assert.NotEqual(t, uuid.Nil, body.DriverID)
	assert.NotEqual(t, uuid.Nil, body.RideID)
	assert.NotEmpty(t, body.PassengerJWT)
	assert.NotEmpty(t, body.DriverJWT)
	assert.Equal(t, "e2e-passenger@sakai.test", body.PassengerEmail)
	assert.Equal(t, "e2e-driver@sakai.test", body.DriverEmail)
}

// Idempotency contract: re-running the seed must reuse the existing user
// rows so the integration test fixtures stay stable across runs.
func TestE2EHandler_SeedReusesExistingUsers(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	users := mocks.NewMockUserRepository(ctrl)
	drivers := mocks.NewMockDriverRepository(ctrl)
	rides := mocks.NewMockRideRepository(ctrl)

	existingPassenger := &domain.User{
		ID: uuid.New(), Email: "e2e-passenger@sakai.test",
		Name: "E2E Passenger", Role: domain.RolePassenger,
	}
	existingDriver := &domain.User{
		ID: uuid.New(), Email: "e2e-driver@sakai.test",
		Name: "E2E Driver", Role: domain.RoleDriver,
	}
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-passenger@sakai.test").
		Return(existingPassenger, nil)
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-driver@sakai.test").
		Return(existingDriver, nil)
	// NB: no Create calls — existing users are reused.
	drivers.EXPECT().GetByUserID(gomock.Any(), existingDriver.ID).
		Return(&domain.Driver{UserID: existingDriver.ID}, nil)
	rides.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	h := handler.NewE2EHandler(users, drivers, rides, e2eTestSecret, time.Hour, e2eSeedToken)
	r := newE2ERouter(h)

	req, _ := http.NewRequest("POST", "/api/e2e/seed", nil)
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	var body handler.E2ESeedResponse
	_ = json.Unmarshal(w.Body.Bytes(), &body)
	assert.Equal(t, existingPassenger.ID, body.PassengerID,
		"second seed must return the same passenger ID")
	assert.Equal(t, existingDriver.ID, body.DriverID,
		"second seed must return the same driver ID")
}
