package usecase

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type alertUseCase struct {
	repo      domain.AlertRepository
	auditRepo domain.AuditRepository
}

func NewAlertUseCase(repo domain.AlertRepository, auditRepo domain.AuditRepository) domain.AlertUseCase {
	return &alertUseCase{repo: repo, auditRepo: auditRepo}
}

func (uc *alertUseCase) ListRules(ctx context.Context) ([]*domain.AlertRule, error) {
	return uc.repo.ListRules(ctx)
}

func (uc *alertUseCase) ListEvents(ctx context.Context, limit int) ([]*domain.AlertEvent, error) {
	return uc.repo.ListEvents(ctx, limit)
}

func (uc *alertUseCase) CreateRule(ctx context.Context, actorID uuid.UUID, rule *domain.AlertRule) error {
	if err := validateRule(rule); err != nil {
		return err
	}
	rule.CreatedBy = &actorID
	if err := uc.repo.CreateRule(ctx, rule); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "CREATE_ALERT_RULE",
		ResourceType: "alert_rule", ResourceID: rule.ID.String(),
		IPAddress: "internal",
	})
	return nil
}

func (uc *alertUseCase) UpdateRule(ctx context.Context, actorID uuid.UUID, rule *domain.AlertRule) error {
	if rule.ID == uuid.Nil {
		return errors.New("id is required")
	}
	if err := validateRule(rule); err != nil {
		return err
	}
	if err := uc.repo.UpdateRule(ctx, rule); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE_ALERT_RULE",
		ResourceType: "alert_rule", ResourceID: rule.ID.String(),
		IPAddress: "internal",
	})
	return nil
}

func (uc *alertUseCase) DeleteRule(ctx context.Context, actorID, id uuid.UUID) error {
	if err := uc.repo.DeleteRule(ctx, id); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "DELETE_ALERT_RULE",
		ResourceType: "alert_rule", ResourceID: id.String(),
		IPAddress: "internal",
	})
	return nil
}

func validateRule(rule *domain.AlertRule) error {
	if rule.Name == "" {
		return errors.New("name is required")
	}
	switch rule.Type {
	case domain.AlertLowRating, domain.AlertHighCancellation,
		domain.AlertFraudVelocity, domain.AlertKYCExpiry:
		// ok
	default:
		return errors.New("invalid alert rule type")
	}
	if len(rule.Config) > 0 && !json.Valid(rule.Config) {
		return errors.New("config must be valid JSON")
	}
	return nil
}
