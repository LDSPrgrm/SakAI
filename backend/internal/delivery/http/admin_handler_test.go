package handler_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
)

// recordingDispatcher captures every PublishTo* call so tests can assert the
// admin lifecycle handlers emit the correct WS event + payload.
type recordingDispatcher struct {
	mu    sync.Mutex
	rides []recordedRideCall
	users []recordedUserCall
}

type recordedRideCall struct {
	Ride    *domain.Ride
	Event   ws.EventType
	Payload any
}

type recordedUserCall struct {
	UserID  uuid.UUID
	Event   ws.EventType
	Payload any
}

func (d *recordingDispatcher) PublishToUser(_ context.Context, userID uuid.UUID, event ws.EventType, payload any) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.users = append(d.users, recordedUserCall{UserID: userID, Event: event, Payload: payload})
	return nil
}

func (d *recordingDispatcher) PublishToRide(_ context.Context, ride *domain.Ride, event ws.EventType, payload any) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.rides = append(d.rides, recordedRideCall{Ride: ride, Event: event, Payload: payload})
	return nil
}

func setupAdminTest(t *testing.T) (
	*gin.Engine,
	*mocks.MockAdminUseCase,
	*mocks.MockRideRepository,
	*recordingDispatcher,
	uuid.UUID,
) {
	gin.SetMode(gin.TestMode)
	ctrl := gomock.NewController(t)
	adminUC := mocks.NewMockAdminUseCase(ctrl)
	auditUC := mocks.NewMockAuditUseCase(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	disp := &recordingDispatcher{}

	h := handler.NewAdminHandler(adminUC, auditUC, disp, rideRepo)

	actorID := uuid.MustParse("00000000-0000-0000-0000-000000000099")
	r := gin.New()
	admin := r.Group("/admin")
	admin.Use(func(c *gin.Context) {
		c.Set("userID", actorID)
		c.Next()
	})
	admin.PUT("/incidents/:id/assign", h.AssignIncident)
	admin.PUT("/incidents/:id/resolve", h.ResolveIncident)

	return r, adminUC, rideRepo, disp, actorID
}

func TestAdminHandler_AssignIncident_PublishesEvent(t *testing.T) {
	r, adminUC, rideRepo, disp, actorID := setupAdminTest(t)

	incidentID := uuid.New()
	rideID := uuid.New()
	assigneeID := uuid.New()
	passengerID := uuid.New()
	driverID := uuid.New()

	adminUC.EXPECT().
		AssignIncident(gomock.Any(), actorID, incidentID, gomock.Any()).
		Return(nil)
	adminUC.EXPECT().
		GetIncident(gomock.Any(), incidentID).
		Return(&domain.IncidentDetail{
			Incident: &domain.Incident{
				ID:             incidentID,
				RideID:         rideID,
				AssignedTo:     &assigneeID,
				AssignedToName: "Op Center 01",
			},
		}, nil)
	rideRepo.EXPECT().
		GetByID(gomock.Any(), rideID).
		Return(&domain.Ride{ID: rideID, PassengerID: passengerID, DriverID: &driverID}, nil)

	body, _ := json.Marshal(map[string]any{"assignee_id": assigneeID.String()})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPut, "/admin/incidents/"+incidentID.String()+"/assign", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNoContent, w.Code)
	if assert.Len(t, disp.rides, 1, "expected one ride-scoped publish") {
		call := disp.rides[0]
		assert.Equal(t, ws.EventIncidentAssigned, call.Event)
		assert.Equal(t, rideID, call.Ride.ID)
		payload, ok := call.Payload.(ws.IncidentAssignedPayload)
		if assert.True(t, ok, "payload should be ws.IncidentAssignedPayload, got %T", call.Payload) {
			assert.Equal(t, incidentID, payload.IncidentID)
			assert.Equal(t, rideID, payload.RideID)
			if assert.NotNil(t, payload.AssigneeID) {
				assert.Equal(t, assigneeID, *payload.AssigneeID)
			}
			assert.Equal(t, "Op Center 01", payload.AssigneeName)
			assert.False(t, payload.AssignedAt.IsZero())
		}
	}
}

func TestAdminHandler_ResolveIncident_PublishesEvent(t *testing.T) {
	r, adminUC, rideRepo, disp, actorID := setupAdminTest(t)

	incidentID := uuid.New()
	rideID := uuid.New()
	passengerID := uuid.New()

	adminUC.EXPECT().
		ResolveIncident(gomock.Any(), actorID, incidentID, "all good").
		Return(nil)
	adminUC.EXPECT().
		GetIncident(gomock.Any(), incidentID).
		Return(&domain.IncidentDetail{
			Incident: &domain.Incident{ID: incidentID, RideID: rideID},
		}, nil)
	rideRepo.EXPECT().
		GetByID(gomock.Any(), rideID).
		Return(&domain.Ride{ID: rideID, PassengerID: passengerID}, nil)

	body, _ := json.Marshal(map[string]any{"notes": "all good"})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPut, "/admin/incidents/"+incidentID.String()+"/resolve", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNoContent, w.Code)
	if assert.Len(t, disp.rides, 1) {
		call := disp.rides[0]
		assert.Equal(t, ws.EventIncidentResolved, call.Event)
		payload, ok := call.Payload.(ws.IncidentResolvedPayload)
		if assert.True(t, ok) {
			assert.Equal(t, incidentID, payload.IncidentID)
			assert.Equal(t, rideID, payload.RideID)
			assert.Equal(t, "all good", payload.ResolutionNotes)
			assert.False(t, payload.ResolvedAt.IsZero())
		}
	}
}

// When the underlying usecase fails, no WS publish should fire — the publish
// path is gated on REST success.
func TestAdminHandler_ResolveIncident_UsecaseError_NoPublish(t *testing.T) {
	r, adminUC, _, disp, actorID := setupAdminTest(t)

	incidentID := uuid.New()
	adminUC.EXPECT().
		ResolveIncident(gomock.Any(), actorID, incidentID, "fail").
		Return(assert.AnError)

	body, _ := json.Marshal(map[string]any{"notes": "fail"})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPut, "/admin/incidents/"+incidentID.String()+"/resolve", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	assert.NotEqual(t, http.StatusNoContent, w.Code)
	assert.Empty(t, disp.rides, "no publish on usecase error")
}
