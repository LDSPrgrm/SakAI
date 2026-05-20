package handler_test

import (
	"bytes"
	"context"
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
	"github.com/sakai/backend/internal/delivery/ws"
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
	r.DELETE("/api/e2e/seed", h.CleanupSeed)
	r.POST("/api/e2e/publish-event", h.PublishEvent)
	return r
}

func TestE2EHandler_DisabledWhenSeedTokenEmpty(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	h := handler.NewE2EHandler(
		mocks.NewMockUserRepository(ctrl),
		mocks.NewMockDriverRepository(ctrl),
		mocks.NewMockRideRepository(ctrl),
		nil,
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
		nil,
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
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-passenger-default@sakai.test").
		Return(nil, domain.ErrNotFound)
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-driver-default@sakai.test").
		Return(nil, domain.ErrNotFound)
	users.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil).Times(2)

	// Driver row absent — ensure it gets created.
	drivers.EXPECT().GetByUserID(gomock.Any(), gomock.Any()).
		Return(nil, domain.ErrNotFound)
	drivers.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	// Fresh ride per seed call.
	rides.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	h := handler.NewE2EHandler(users, drivers, rides, nil, e2eTestSecret, time.Hour, e2eSeedToken)
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
	assert.Equal(t, "e2e-passenger-default@sakai.test", body.PassengerEmail)
	assert.Equal(t, "e2e-driver-default@sakai.test", body.DriverEmail)
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
		ID: uuid.New(), Email: "e2e-passenger-default@sakai.test",
		Name: "E2E Passenger", Role: domain.RolePassenger,
	}
	existingDriver := &domain.User{
		ID: uuid.New(), Email: "e2e-driver-default@sakai.test",
		Name: "E2E Driver", Role: domain.RoleDriver,
	}
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-passenger-default@sakai.test").
		Return(existingPassenger, nil)
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-driver-default@sakai.test").
		Return(existingDriver, nil)
	// NB: no Create calls — existing users are reused.
	drivers.EXPECT().GetByUserID(gomock.Any(), existingDriver.ID).
		Return(&domain.Driver{UserID: existingDriver.ID}, nil)
	rides.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	h := handler.NewE2EHandler(users, drivers, rides, nil, e2eTestSecret, time.Hour, e2eSeedToken)
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

// fakeDispatcher captures publish calls so the publish-event handler test
// can assert the routing decision without standing up a real Hub.
type fakeDispatcher struct {
	users []struct {
		userID uuid.UUID
		event  string
	}
	rides []struct {
		rideID uuid.UUID
		event  string
	}
}

func (f *fakeDispatcher) PublishToUser(_ context.Context, userID uuid.UUID, event ws.EventType, _ any) error {
	f.users = append(f.users, struct {
		userID uuid.UUID
		event  string
	}{userID, string(event)})
	return nil
}

func (f *fakeDispatcher) PublishToRide(_ context.Context, ride *domain.Ride, event ws.EventType, _ any) error {
	f.rides = append(f.rides, struct {
		rideID uuid.UUID
		event  string
	}{ride.ID, string(event)})
	return nil
}

func TestE2EHandler_PublishEvent_RequiresExactlyOneTarget(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	h := handler.NewE2EHandler(
		mocks.NewMockUserRepository(ctrl),
		mocks.NewMockDriverRepository(ctrl),
		mocks.NewMockRideRepository(ctrl),
		&fakeDispatcher{},
		e2eTestSecret, time.Hour, e2eSeedToken,
	)
	r := newE2ERouter(h)

	body := bytes.NewBufferString(`{"event":"ride.accepted","payload":{}}`)
	req, _ := http.NewRequest("POST", "/api/e2e/publish-event", body)
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code,
		"neither ride_id nor target_user_id provided must reject")
}

func TestE2EHandler_PublishEvent_RoutesToRide(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	rides := mocks.NewMockRideRepository(ctrl)
	rideID := uuid.New()
	rides.EXPECT().GetByID(gomock.Any(), rideID).
		Return(&domain.Ride{ID: rideID, PassengerID: uuid.New()}, nil)
	dispatcher := &fakeDispatcher{}
	h := handler.NewE2EHandler(
		mocks.NewMockUserRepository(ctrl),
		mocks.NewMockDriverRepository(ctrl),
		rides,
		dispatcher,
		e2eTestSecret, time.Hour, e2eSeedToken,
	)
	r := newE2ERouter(h)

	payload := `{"ride_id":"` + rideID.String() + `","event":"ride.completed","payload":{"fare":120.0}}`
	req, _ := http.NewRequest("POST", "/api/e2e/publish-event", bytes.NewBufferString(payload))
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusAccepted, w.Code)
	if assert.Len(t, dispatcher.rides, 1) {
		assert.Equal(t, rideID, dispatcher.rides[0].rideID)
		assert.Equal(t, "ride.completed", dispatcher.rides[0].event)
	}
}

func TestE2EHandler_CleanupSeed_DeletesByEmail(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	users := mocks.NewMockUserRepository(ctrl)
	passenger := &domain.User{ID: uuid.New(), Email: "e2e-passenger-default@sakai.test"}
	driver := &domain.User{ID: uuid.New(), Email: "e2e-driver-default@sakai.test"}
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-passenger-default@sakai.test").Return(passenger, nil)
	users.EXPECT().Delete(gomock.Any(), passenger.ID).Return(nil)
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-driver-default@sakai.test").Return(driver, nil)
	users.EXPECT().Delete(gomock.Any(), driver.ID).Return(nil)

	h := handler.NewE2EHandler(
		users,
		mocks.NewMockDriverRepository(ctrl),
		mocks.NewMockRideRepository(ctrl),
		nil,
		e2eTestSecret, time.Hour, e2eSeedToken,
	)
	r := newE2ERouter(h)

	req, _ := http.NewRequest("DELETE", "/api/e2e/seed", nil)
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestE2EHandler_CleanupSeed_IdempotentOnMissing(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	users := mocks.NewMockUserRepository(ctrl)
	users.EXPECT().GetByEmail(gomock.Any(), gomock.Any()).Return(nil, domain.ErrNotFound).Times(2)

	h := handler.NewE2EHandler(
		users,
		mocks.NewMockDriverRepository(ctrl),
		mocks.NewMockRideRepository(ctrl),
		nil,
		e2eTestSecret, time.Hour, e2eSeedToken,
	)
	r := newE2ERouter(h)

	req, _ := http.NewRequest("DELETE", "/api/e2e/seed", nil)
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code,
		"missing rows must NOT error — cleanup is idempotent")
}

func TestE2EHandler_Seed_SuiteParamNamespacesEmail(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	users := mocks.NewMockUserRepository(ctrl)
	drivers := mocks.NewMockDriverRepository(ctrl)
	rides := mocks.NewMockRideRepository(ctrl)

	users.EXPECT().GetByEmail(gomock.Any(), "e2e-passenger-foo@sakai.test").
		Return(nil, domain.ErrNotFound)
	users.EXPECT().GetByEmail(gomock.Any(), "e2e-driver-foo@sakai.test").
		Return(nil, domain.ErrNotFound)
	users.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil).Times(2)
	drivers.EXPECT().GetByUserID(gomock.Any(), gomock.Any()).Return(nil, domain.ErrNotFound)
	drivers.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)
	rides.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

	h := handler.NewE2EHandler(users, drivers, rides, nil, e2eTestSecret, time.Hour, e2eSeedToken)
	r := newE2ERouter(h)

	req, _ := http.NewRequest("POST", "/api/e2e/seed?suite=foo", nil)
	req.Header.Set("Authorization", "Bearer "+e2eSeedToken)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}
