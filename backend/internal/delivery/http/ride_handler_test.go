package handler_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
)

// setupIncidentLocationTest builds a RideHandler wired with mock incident and
// SOS-prefs repos and an Engine that injects the given actor as the
// authenticated user, mirroring the auth middleware in production.
func setupIncidentLocationTest(t *testing.T, actorID uuid.UUID) (
	*gin.Engine,
	*mocks.MockIncidentRepository,
	*mocks.MockSosPrefsRepository,
) {
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	incidentRepo := mocks.NewMockIncidentRepository(ctrl)
	sosPrefs := mocks.NewMockSosPrefsRepository(ctrl)
	disp := &recordingDispatcher{}

	// Unused collaborators for this path are nil — AppendIncidentLocation does
	// not touch the use case, ride/user/driver/payment repos before the opt-in
	// gate, and the opt-out path returns before any of them are reached.
	h := handler.NewRideHandler(nil, nil, disp, nil, nil, nil, nil).
		WithIncidentRepo(incidentRepo).
		WithSosPrefsRepo(sosPrefs)

	r := gin.New()
	grp := r.Group("/")
	grp.Use(func(c *gin.Context) {
		c.Set("userID", actorID)
		c.Next()
	})
	grp.POST("/incidents/:incidentId/location", h.AppendIncidentLocation)

	return r, incidentRepo, sosPrefs
}

// TestAppendIncidentLocation_OptOut_Forbidden proves the server-side privacy
// invariant: a ride participant who has NOT opted in to live-location sharing
// is rejected with 403 and no GPS ping is recorded.
func TestAppendIncidentLocation_OptOut_Forbidden(t *testing.T) {
	riderID := uuid.New()
	r, incidentRepo, sosPrefs := setupIncidentLocationTest(t, riderID)

	incidentID := uuid.New()
	incidentRepo.EXPECT().
		GetIncidentByID(gomock.Any(), incidentID).
		Return(&domain.Incident{
			ID:       incidentID,
			RideID:   uuid.New(),
			RiderID:  riderID,
			DriverID: uuid.New(),
		}, nil)

	// Actor is a participant but has opted out → fail closed.
	sosPrefs.EXPECT().
		GetLiveLocationOptIn(gomock.Any(), riderID).
		Return(false, nil)

	// The ping must NOT be recorded for an opted-out participant.
	incidentRepo.EXPECT().
		RecordIncidentLocation(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).
		Times(0)

	body, _ := json.Marshal(map[string]any{"lat": 14.5995, "lng": 120.9842})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPost, "/incidents/"+incidentID.String()+"/location", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusForbidden, w.Code)
}

// TestAppendIncidentLocation_OptIn_Recorded confirms an opted-in participant
// proceeds past the gate and the ping is recorded (202 Accepted). The success
// path also looks up the ride to fan out a WS event, so a ride repo is wired
// here (the opt-out path never reaches it, hence the lighter helper above).
func TestAppendIncidentLocation_OptIn_Recorded(t *testing.T) {
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	incidentRepo := mocks.NewMockIncidentRepository(ctrl)
	sosPrefs := mocks.NewMockSosPrefsRepository(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)

	riderID := uuid.New()
	incidentID := uuid.New()
	rideID := uuid.New()

	incidentRepo.EXPECT().
		GetIncidentByID(gomock.Any(), incidentID).
		Return(&domain.Incident{
			ID:       incidentID,
			RideID:   rideID,
			RiderID:  riderID,
			DriverID: uuid.New(),
		}, nil)

	sosPrefs.EXPECT().
		GetLiveLocationOptIn(gomock.Any(), riderID).
		Return(true, nil)

	incidentRepo.EXPECT().
		RecordIncidentLocation(gomock.Any(), incidentID, riderID, gomock.Any(), gomock.Any()).
		Return(&domain.IncidentLocationPoint{Lat: 14.5995, Lng: 120.9842}, nil)

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{ID: rideID}, nil)

	h := handler.NewRideHandler(nil, nil, &recordingDispatcher{}, rideRepo, nil, nil, nil).
		WithIncidentRepo(incidentRepo).
		WithSosPrefsRepo(sosPrefs)

	r := gin.New()
	grp := r.Group("/")
	grp.Use(func(c *gin.Context) {
		c.Set("userID", riderID)
		c.Next()
	})
	grp.POST("/incidents/:incidentId/location", h.AppendIncidentLocation)

	body, _ := json.Marshal(map[string]any{"lat": 14.5995, "lng": 120.9842})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPost, "/incidents/"+incidentID.String()+"/location", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusAccepted, w.Code)
}
