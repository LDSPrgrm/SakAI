package router

import (
	"testing"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/ws"
)

// Sanity: router registration must not panic under Gin's radix tree. Catches
// path-conflict regressions (e.g. /:id catching a sibling literal segment).
func TestRouterRegistersWithoutPanic(t *testing.T) {
	defer func() {
		if r := recover(); r != nil {
			t.Fatalf("router.New panicked: %v", r)
		}
	}()

	deps := Deps{
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
	}
	_ = New("test-secret", deps)
}
