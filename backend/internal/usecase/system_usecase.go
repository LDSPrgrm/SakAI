package usecase

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type systemUseCase struct {
	systemRepo domain.SystemRepository
	auditRepo  domain.AuditRepository
}

func NewSystemUseCase(systemRepo domain.SystemRepository, auditRepo domain.AuditRepository) domain.SystemUseCase {
	return &systemUseCase{systemRepo: systemRepo, auditRepo: auditRepo}
}

func (uc *systemUseCase) ListServices(ctx context.Context) ([]*domain.SystemService, error) {
	return uc.systemRepo.ListServices(ctx)
}

func (uc *systemUseCase) ListFeatureFlags(ctx context.Context) ([]*domain.FeatureFlag, error) {
	return uc.systemRepo.ListFeatureFlags(ctx)
}

func (uc *systemUseCase) UpdateFeatureFlag(ctx context.Context, actorID uuid.UUID, key string, enabled bool) error {
	if err := uc.systemRepo.UpdateFeatureFlag(ctx, key, enabled); err != nil {
		return err
	}
	after, _ := json.Marshal(map[string]interface{}{"key": key, "enabled": enabled})
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "feature_flag",
		ResourceID: key, AfterState: after, IPAddress: "internal",
	})
	return nil
}

func (uc *systemUseCase) ListIntegrations(ctx context.Context) ([]*domain.Integration, error) {
	return uc.systemRepo.ListIntegrations(ctx)
}

func (uc *systemUseCase) UpdateIntegration(ctx context.Context, actorID uuid.UUID, service string, config map[string]string) error {
	if err := uc.systemRepo.UpdateIntegration(ctx, service, config); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "integration",
		ResourceID: service, IPAddress: "internal",
	})
	return nil
}

func (uc *systemUseCase) TestIntegration(ctx context.Context, service string) (*domain.SystemService, error) {
	cfg, err := uc.systemRepo.GetIntegrationRaw(ctx, service)
	if err != nil {
		return nil, err
	}

	// SKIP_EXTERNAL_PINGS short-circuits the outbound HTTP call in CI / dev so
	// tests don't need network access. Still records a row so the UI shows a
	// recent last-tested timestamp.
	var (
		ok      bool
		latency int
		msg     string
	)
	if strings.EqualFold(os.Getenv("SKIP_EXTERNAL_PINGS"), "true") {
		ok, latency, msg = true, 0, "skipped (SKIP_EXTERNAL_PINGS=true)"
	} else {
		ok, latency, msg = pingIntegration(ctx, service, cfg)
	}

	if err := uc.systemRepo.RecordIntegrationTest(ctx, service, ok, latency, msg); err != nil {
		return nil, err
	}

	status := "degraded"
	if ok {
		status = "ok"
	}
	return &domain.SystemService{
		Name: service, Status: status, LatencyMs: latency,
		UptimePct: 100.0, LastChecked: time.Now(),
	}, nil
}

// pingIntegration dials out to the matching external provider and returns
// (ok, latencyMs, message). Every call uses a 5s overall budget via ctx
// deadline so a slow provider never stalls the admin UI.
func pingIntegration(ctx context.Context, service string, cfg map[string]string) (bool, int, string) {
	cctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	url, headers, err := integrationProbeTarget(service, cfg)
	if err != nil {
		return false, 0, err.Error()
	}

	req, err := http.NewRequestWithContext(cctx, http.MethodGet, url, nil)
	if err != nil {
		return false, 0, err.Error()
	}
	for k, v := range headers {
		req.Header.Set(k, v)
	}

	start := time.Now()
	resp, err := http.DefaultClient.Do(req)
	latency := int(time.Since(start).Milliseconds())
	if err != nil {
		return false, latency, err.Error()
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 400 {
		return true, latency, fmt.Sprintf("HTTP %d", resp.StatusCode)
	}
	return false, latency, fmt.Sprintf("HTTP %d", resp.StatusCode)
}

// integrationProbeTarget returns the URL + headers used to ping each supported
// provider. Providers not on the list return an explanatory error so the UI
// can still render "unknown service".
func integrationProbeTarget(service string, cfg map[string]string) (string, map[string]string, error) {
	h := map[string]string{"User-Agent": "sakai-health/1.0"}
	switch service {
	case "stripe":
		key := cfg["api_key"]
		if key == "" {
			return "", nil, fmt.Errorf("api_key not configured")
		}
		h["Authorization"] = "Bearer " + key
		return "https://api.stripe.com/v1/balance", h, nil
	case "twilio":
		sid, token := cfg["account_sid"], cfg["auth_token"]
		if sid == "" || token == "" {
			return "", nil, fmt.Errorf("account_sid or auth_token not configured")
		}
		// Basic auth via URL is brittle; use header variant.
		h["Authorization"] = basicAuth(sid, token)
		return fmt.Sprintf("https://api.twilio.com/2010-04-01/Accounts/%s.json", sid), h, nil
	case "mapbox":
		token := cfg["access_token"]
		if token == "" {
			return "", nil, fmt.Errorf("access_token not configured")
		}
		return "https://api.mapbox.com/tokens/v2?access_token=" + token, h, nil
	case "gcash":
		h["Authorization"] = "Bearer " + cfg["api_key"]
		return "https://api.gcash.com/ping", h, nil
	case "paymaya":
		h["Authorization"] = "Bearer " + cfg["api_key"]
		return "https://pg-sandbox.paymaya.com/payments/v1/health", h, nil
	case "firebase":
		pid := cfg["project_id"]
		if pid == "" {
			return "", nil, fmt.Errorf("project_id not configured")
		}
		return "https://firebase.googleapis.com/v1beta1/projects/" + pid, h, nil
	default:
		return "", nil, fmt.Errorf("no probe target for service %q", service)
	}
}

// basicAuth encodes credentials for an HTTP Basic Authorization header.
func basicAuth(user, pass string) string {
	return "Basic " + base64.StdEncoding.EncodeToString([]byte(user+":"+pass))
}

func (uc *systemUseCase) GetInfraMetrics(ctx context.Context) (*domain.InfraMetrics, error) {
	return uc.systemRepo.GetInfraMetrics(ctx)
}

func (uc *systemUseCase) ListNotificationTemplates(ctx context.Context) ([]*domain.NotificationTemplate, error) {
	return uc.systemRepo.ListNotificationTemplates(ctx)
}

func (uc *systemUseCase) UpdateNotificationTemplate(ctx context.Context, actorID uuid.UUID, event, subject, body string) error {
	if err := uc.systemRepo.UpdateNotificationTemplate(ctx, event, subject, body); err != nil {
		return err
	}
	after, _ := json.Marshal(map[string]string{"event": event, "subject": subject})
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "notification_template",
		ResourceID: event, AfterState: after, IPAddress: "internal",
	})
	return nil
}
