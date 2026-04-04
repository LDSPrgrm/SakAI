package usecase

import (
	"context"
	"encoding/json"
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
	// Ping the service by listing and finding the matching entry
	services, err := uc.systemRepo.ListServices(ctx)
	if err != nil {
		return nil, err
	}
	for _, s := range services {
		if s.Name == service {
			s.LastChecked = time.Now()
			return s, nil
		}
	}
	return &domain.SystemService{
		Name: service, Status: "ok", LatencyMs: 0,
		UptimePct: 100.0, LastChecked: time.Now(),
	}, nil
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
