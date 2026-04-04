package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type systemRepo struct {
	db *pgxpool.Pool //nolint:unused
}

func NewSystemRepo(db *pgxpool.Pool) domain.SystemRepository {
	return &systemRepo{db: db}
}

func (r *systemRepo) ListServices(_ context.Context) ([]*domain.SystemService, error) {
	now := time.Now()
	return []*domain.SystemService{
		{Name: "api", Status: "ok", LatencyMs: 42, UptimePct: 99.99, LastChecked: now},
		{Name: "database", Status: "ok", LatencyMs: 18, UptimePct: 99.98, LastChecked: now},
		{Name: "redis", Status: "ok", LatencyMs: 3, UptimePct: 100.0, LastChecked: now},
		{Name: "nats", Status: "ok", LatencyMs: 6, UptimePct: 99.95, LastChecked: now},
		{Name: "gcash", Status: "ok", LatencyMs: 210, UptimePct: 99.80, LastChecked: now},
		{Name: "paymaya", Status: "ok", LatencyMs: 190, UptimePct: 99.75, LastChecked: now},
		{Name: "twilio", Status: "ok", LatencyMs: 150, UptimePct: 99.90, LastChecked: now},
	}, nil
}

func (r *systemRepo) ListFeatureFlags(_ context.Context) ([]*domain.FeatureFlag, error) {
	return []*domain.FeatureFlag{
		{Key: "surge_pricing", Label: "Surge Pricing", Description: "Enable dynamic surge multiplier", Enabled: true},
		{Key: "vehicle_type_motorcycle", Label: "Motorcycle", Description: "Allow motorcycle rides", Enabled: true},
		{Key: "vehicle_type_tricycle", Label: "Tricycle", Description: "Allow tricycle rides", Enabled: true},
		{Key: "vehicle_type_car", Label: "Car (4-seater)", Description: "Allow car rides", Enabled: false},
		{Key: "payment_method_gcash", Label: "GCash", Description: "Accept GCash payments", Enabled: true},
		{Key: "payment_method_paymaya", Label: "PayMaya", Description: "Accept PayMaya payments", Enabled: true},
		{Key: "payment_method_card", Label: "Credit/Debit Card", Description: "Accept card payments", Enabled: false},
		{Key: "maintenance_mode", Label: "Maintenance Mode", Description: "Disable ride booking with custom message", Enabled: false},
		{Key: "driver_onboarding", Label: "Driver Onboarding", Description: "Open new driver registrations", Enabled: true},
	}, nil
}

func (r *systemRepo) UpdateFeatureFlag(_ context.Context, _ string, _ bool) error {
	// Stub: feature_flags table pending system config schema
	return nil
}

func (r *systemRepo) ListIntegrations(_ context.Context) ([]*domain.Integration, error) {
	now := time.Now()
	return []*domain.Integration{
		{Service: "gcash", Status: "active", LastSync: now.Add(-5 * time.Minute), Config: map[string]string{"api_key": "****1234", "env": "production"}},
		{Service: "paymaya", Status: "active", LastSync: now.Add(-5 * time.Minute), Config: map[string]string{"public_key": "****5678", "env": "production"}},
		{Service: "twilio", Status: "active", LastSync: now.Add(-10 * time.Minute), Config: map[string]string{"account_sid": "****abcd", "from": "+1415XXXXXXX"}},
		{Service: "mapbox", Status: "active", LastSync: now.Add(-1 * time.Minute), Config: map[string]string{"access_token": "****xyz9"}},
	}, nil
}

func (r *systemRepo) UpdateIntegration(_ context.Context, _ string, _ map[string]string) error {
	return nil
}

func (r *systemRepo) ListNotificationTemplates(_ context.Context) ([]*domain.NotificationTemplate, error) {
	return []*domain.NotificationTemplate{
		{Event: "ride_confirmed", Channel: "push", Subject: "Ride Confirmed", Body: "Your ride has been confirmed. Driver {{driver_name}} is on the way."},
		{Event: "ride_cancelled", Channel: "sms", Subject: "Ride Cancelled", Body: "Your ride has been cancelled. Reason: {{reason}}."},
		{Event: "kyc_approved", Channel: "email", Subject: "KYC Approved", Body: "Congratulations {{driver_name}}! Your documents have been approved."},
		{Event: "kyc_rejected", Channel: "email", Subject: "KYC Rejected", Body: "Your submission was rejected. Reason: {{reason}}. Please resubmit."},
		{Event: "payout_processed", Channel: "sms", Subject: "Payout Processed", Body: "Your payout of ₱{{amount}} for {{period}} has been processed."},
	}, nil
}

func (r *systemRepo) UpdateNotificationTemplate(_ context.Context, _, _, _ string) error {
	return nil
}
