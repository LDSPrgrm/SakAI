package router_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/router"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/pkg/jwt"
)

const testSecret = "test-secret"

type dummyDispatcher struct{}

func (d *dummyDispatcher) PublishToUser(ctx context.Context, userID uuid.UUID, event ws.EventType, payload any) error {
	return nil
}

func (d *dummyDispatcher) PublishToRide(ctx context.Context, ride *domain.Ride, event ws.EventType, payload any) error {
	return nil
}

// generateTestToken creates a valid JWT for the given user role to bypass the Auth middleware.
func generateTestToken(t *testing.T, userID uuid.UUID, role domain.UserRole) string {
	token, _, err := jwt.GenerateAccessToken(userID, role, testSecret, time.Hour)
	if err != nil {
		t.Fatalf("failed to generate test token: %v", err)
	}
	return token
}

// performRequest executes an HTTP request against the router with an optional JSON body and Auth token.
func performRequest(r http.Handler, method, path string, token string, body interface{}) *httptest.ResponseRecorder {
	var buf bytes.Buffer
	if body != nil {
		json.NewEncoder(&buf).Encode(body)
	}
	req, _ := http.NewRequest(method, path, &buf)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Idempotency-Key", "test-idem-key")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

func TestE2ECrossAppFlow(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	// Mock UseCases
	mockRideUC := mocks.NewMockRideUseCase(ctrl)
	mockRatingUC := mocks.NewMockRatingUseCase(ctrl)
	mockAdminUC := mocks.NewMockAdminUseCase(ctrl)
	mockMetricsUC := mocks.NewMockMetricsUseCase(ctrl)
	mockAuthUC := mocks.NewMockAuthUseCase(ctrl)
	mockRoleUC := mocks.NewMockRoleUseCase(ctrl)
	
	// Extra Mocks for Handlers
	mockAuditUC := mocks.NewMockAuditUseCase(ctrl)
	
	// Extra Repos for RideHandler
	mockRideRepo := mocks.NewMockRideRepository(ctrl)
	mockUserRepo := mocks.NewMockUserRepository(ctrl)
	mockDriverRepo := mocks.NewMockDriverRepository(ctrl)
	mockPaymentRepo := mocks.NewMockRidePaymentRepository(ctrl)

	// Build Deps
	deps := router.Deps{
		Ride:       handler.NewRideHandler(mockRideUC, nil, &dummyDispatcher{}, mockRideRepo, mockUserRepo, mockDriverRepo, mockPaymentRepo),
		Rating:     handler.NewRatingHandler(mockRatingUC),
		Admin:      handler.NewAdminHandler(mockAdminUC, mockAuditUC, &dummyDispatcher{}, mockRideRepo),
		Metrics:    handler.NewMetricsHandler(mockMetricsUC),
		PayProcess: handler.NewRidePaymentHandler(nil, nil, nil),
		AuthUC:     mockAuthUC,
		RoleUC:     mockRoleUC,
	}

	// Setup Router
	r := router.New(testSecret, deps)

	// Test Data
	passengerID := uuid.New()
	driverID := uuid.New()
	adminID := uuid.New()
	rideID := uuid.New()

	passengerToken := generateTestToken(t, passengerID, domain.RolePassenger)
	driverToken := generateTestToken(t, driverID, domain.RoleDriver)
	adminToken := generateTestToken(t, adminID, domain.RoleSuperadmin)

	// Generic mock expectations applied to all sub-tests
	mockUserRepo.EXPECT().GetByID(gomock.Any(), gomock.Any()).Return(&domain.User{ID: uuid.New()}, nil).AnyTimes()
	mockPaymentRepo.EXPECT().GetByRideID(gomock.Any(), gomock.Any()).Return(&domain.Payment{}, nil).AnyTimes()
	mockDriverRepo.EXPECT().GetByUserID(gomock.Any(), gomock.Any()).Return(&domain.Driver{UserID: driverID}, nil).AnyTimes()

	// Step 1: Passenger requests a ride
	t.Run("Passenger Requests Ride", func(t *testing.T) {
		reqBody := map[string]interface{}{
			"origin":         map[string]float64{"lat": 14.5, "lng": 120.9},
			"destination":    map[string]float64{"lat": 14.6, "lng": 121.0},
			"ride_type":      "car",
			"payment_method": "cash",
		}
		
		mockRideUC.EXPECT().
			RequestRide(gomock.Any(), passengerID, domain.LatLng{Lat: 14.5, Lng: 120.9}, domain.LatLng{Lat: 14.6, Lng: 121.0}, "", "", "", "test-idem-key", domain.RideType("car"), domain.PaymentMethod("cash")).
			Return(&domain.Ride{
				ID:          rideID,
				Status:      domain.RideStatusRequested,
				PassengerID: passengerID,
			}, nil)

		w := performRequest(r, "POST", "/api/rides", passengerToken, reqBody)
		assert.Equal(t, http.StatusCreated, w.Code)
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.Equal(t, rideID.String(), resp["id"])
		assert.Equal(t, string(domain.RideStatusRequested), resp["status"])
	})

	// Step 2: Driver accepts the ride
	t.Run("Driver Accepts Ride", func(t *testing.T) {
		mockRideUC.EXPECT().
			Accept(gomock.Any(), driverID, rideID).
			Return(&domain.Ride{
				ID:       rideID,
				Status:   domain.RideStatusAccepted,
				DriverID: &driverID,
				PassengerID: passengerID,
			}, nil)

		w := performRequest(r, "POST", "/api/rides/"+rideID.String()+"/accept", driverToken, nil)
		assert.Equal(t, http.StatusOK, w.Code)
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.Equal(t, string(domain.RideStatusAccepted), resp["status"])
	})

	// Step 3: Driver arrives
	t.Run("Driver Arrives", func(t *testing.T) {
		loc := domain.LatLng{Lat: 14.5, Lng: 120.9}
		mockRideUC.EXPECT().
			Arrive(gomock.Any(), driverID, rideID, loc).
			Return(&domain.Ride{
				ID:       rideID,
				Status:   domain.RideStatusArrived,
				DriverID: &driverID,
				PassengerID: passengerID,
			}, nil)

		body := map[string]interface{}{"driver_location": map[string]interface{}{"lat": 14.5, "lng": 120.9}}
		w := performRequest(r, "POST", "/api/rides/"+rideID.String()+"/arrive", driverToken, body)
		assert.Equal(t, http.StatusOK, w.Code)
	})

	// Step 4: Driver completes the ride
	t.Run("Driver Completes Ride", func(t *testing.T) {
		loc := domain.LatLng{Lat: 14.6, Lng: 121.0}
		mockRideUC.EXPECT().
			Complete(gomock.Any(), driverID, rideID, loc).
			Return(&domain.Ride{
				ID:       rideID,
				Status:   domain.RideStatusCompleted,
				DriverID: &driverID,
				PassengerID: passengerID,
			}, nil)

		body := map[string]interface{}{"driver_location": map[string]interface{}{"lat": 14.6, "lng": 121.0}}
		w := performRequest(r, "POST", "/api/rides/"+rideID.String()+"/complete", driverToken, body)
		assert.Equal(t, http.StatusOK, w.Code)
	})

	// Step 5: Passenger submits rating
	t.Run("Passenger Submits Rating", func(t *testing.T) {
		reqBody := map[string]interface{}{
			"stars":    5,
			"feedback": "Excellent driver",
		}
		mockRatingUC.EXPECT().
			SubmitRating(gomock.Any(), passengerID, rideID, 5, gomock.Any()).
			Return(&domain.Rating{
				ID:      uuid.New(),
				RideID:  rideID,
				RaterID: passengerID,
				RateeID: driverID,
				Stars:   5,
			}, nil)

		w := performRequest(r, "POST", "/api/rides/"+rideID.String()+"/rating", passengerToken, reqBody)
		assert.Equal(t, http.StatusCreated, w.Code)
	})

	// Step 6: Admin fetches dashboard metrics
	t.Run("Admin Fetches Dashboard", func(t *testing.T) {
		mockAdminUC.EXPECT().
			GetDashboard(gomock.Any()).
			Return(&domain.DashboardMetrics{
				ActiveRiders: 0,
				RidesToday: 1,
			}, nil)

		w := performRequest(r, "GET", "/api/admin/dashboard", adminToken, nil)
		assert.Equal(t, http.StatusOK, w.Code)
		
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.Equal(t, float64(1), resp["rides_today"])
	})
}
