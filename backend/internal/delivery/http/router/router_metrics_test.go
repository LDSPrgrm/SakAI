package router

import (
	"net/http"
	"net/http/httptest"
	"testing"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/ws"
)

// baseMetricsDeps returns a minimally-populated Deps sufficient for New() to
// register routes without panicking, mirroring TestRouterRegistersWithoutPanic.
func baseMetricsDeps(metricsToken string) Deps {
	return Deps{
		Auth:           &handler.AuthHandler{},
		Driver:         &handler.DriverHandler{},
		Ride:           &handler.RideHandler{},
		Admin:          &handler.AdminHandler{},
		Fare:           &handler.FareHandler{},
		Audit:          &handler.AuditHandler{},
		Role:           &handler.RoleHandler{},
		Payment:        &handler.PaymentHandler{},
		Safety:         &handler.SafetyHandler{},
		System:         &handler.SystemHandler{},
		Report:         &handler.ReportHandler{},
		Metrics:        &handler.MetricsHandler{},
		Document:       &handler.DocumentHandler{},
		Rating:         &handler.RatingHandler{},
		PayProcess:     &handler.RidePaymentHandler{},
		Tip:            &handler.TipHandler{},
		PaymentMethod:  &handler.PaymentMethodHandler{},
		ServiceArea:    &handler.ServiceAreaHandler{},
		LGUPartnership: &handler.LGUPartnershipHandler{},
		Alert:          &handler.AlertHandler{},
		WS:             &ws.Handler{},
		MetricsToken:   metricsToken,
	}
}

// TestMetricsNotMountedWhenTokenEmpty verifies that /metrics is not
// registered at all when METRICS_TOKEN is unset (fail closed).
func TestMetricsNotMountedWhenTokenEmpty(t *testing.T) {
	r := New("test-secret", baseMetricsDeps(""))

	req := httptest.NewRequest(http.MethodGet, "/metrics", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404 when METRICS_TOKEN empty, got %d", w.Code)
	}
}

// TestMetricsAuthorizedWithCorrectBearer verifies that a correct bearer
// token is accepted when METRICS_TOKEN is set.
func TestMetricsAuthorizedWithCorrectBearer(t *testing.T) {
	r := New("test-secret", baseMetricsDeps("s3cret"))

	req := httptest.NewRequest(http.MethodGet, "/metrics", nil)
	req.Header.Set("Authorization", "Bearer s3cret")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 with correct bearer token, got %d", w.Code)
	}
}

// TestMetricsRejectsMissingOrWrongBearer verifies that requests without the
// correct bearer token are rejected with 401 when METRICS_TOKEN is set.
func TestMetricsRejectsMissingOrWrongBearer(t *testing.T) {
	r := New("test-secret", baseMetricsDeps("s3cret"))

	cases := []struct {
		name   string
		header string
	}{
		{"missing header", ""},
		{"wrong token", "Bearer wrong"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, "/metrics", nil)
			if tc.header != "" {
				req.Header.Set("Authorization", tc.header)
			}
			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)

			if w.Code != http.StatusUnauthorized {
				t.Fatalf("expected 401, got %d", w.Code)
			}
		})
	}
}
