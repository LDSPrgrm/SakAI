package domain

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// AlertRuleType is the closed enum of rule kinds. Adding a new type means
// adding a branch in the evaluator — no generic expression language.
type AlertRuleType string

const (
	AlertLowRating        AlertRuleType = "low_rating"
	AlertHighCancellation AlertRuleType = "high_cancellation"
	AlertFraudVelocity    AlertRuleType = "fraud_velocity"
	AlertKYCExpiry        AlertRuleType = "kyc_expiry"
)

// AlertRule is a superadmin-authored rule evaluated on a periodic tick.
type AlertRule struct {
	ID        uuid.UUID       `json:"id"`
	Name      string          `json:"name"`
	Type      AlertRuleType   `json:"type"`
	Enabled   bool            `json:"enabled"`
	Config    json.RawMessage `json:"config"`
	CreatedBy *uuid.UUID      `json:"created_by,omitempty"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`
}

// AlertEvent is one firing of a rule.
type AlertEvent struct {
	ID          uuid.UUID       `json:"id"`
	RuleID      *uuid.UUID      `json:"rule_id,omitempty"`
	FiredAt     time.Time       `json:"fired_at"`
	SubjectType string          `json:"subject_type,omitempty"`
	SubjectID   *uuid.UUID      `json:"subject_id,omitempty"`
	Payload     json.RawMessage `json:"payload"`
}

// AlertRepository persists rules + event rows.
type AlertRepository interface {
	ListRules(ctx context.Context) ([]*AlertRule, error)
	GetRule(ctx context.Context, id uuid.UUID) (*AlertRule, error)
	CreateRule(ctx context.Context, rule *AlertRule) error
	UpdateRule(ctx context.Context, rule *AlertRule) error
	DeleteRule(ctx context.Context, id uuid.UUID) error
	ListEvents(ctx context.Context, limit int) ([]*AlertEvent, error)
	RecordEvent(ctx context.Context, ev *AlertEvent) error
}

// AlertUseCase wraps persistence with audit + validation.
type AlertUseCase interface {
	ListRules(ctx context.Context) ([]*AlertRule, error)
	CreateRule(ctx context.Context, actorID uuid.UUID, rule *AlertRule) error
	UpdateRule(ctx context.Context, actorID uuid.UUID, rule *AlertRule) error
	DeleteRule(ctx context.Context, actorID, id uuid.UUID) error
	ListEvents(ctx context.Context, limit int) ([]*AlertEvent, error)
}
