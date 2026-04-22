package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type alertRepo struct{ db *pgxpool.Pool }

func NewAlertRepo(db *pgxpool.Pool) domain.AlertRepository {
	return &alertRepo{db: db}
}

func (r *alertRepo) ListRules(ctx context.Context) ([]*domain.AlertRule, error) {
	const q = `
		SELECT id, name, type, enabled, config, created_by, created_at, updated_at
		FROM alert_rules
		ORDER BY created_at DESC`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]*domain.AlertRule, 0)
	for rows.Next() {
		rule := &domain.AlertRule{}
		var t string
		if err := rows.Scan(&rule.ID, &rule.Name, &t, &rule.Enabled, &rule.Config,
			&rule.CreatedBy, &rule.CreatedAt, &rule.UpdatedAt); err != nil {
			return nil, err
		}
		rule.Type = domain.AlertRuleType(t)
		out = append(out, rule)
	}
	return out, rows.Err()
}

func (r *alertRepo) GetRule(ctx context.Context, id uuid.UUID) (*domain.AlertRule, error) {
	const q = `
		SELECT id, name, type, enabled, config, created_by, created_at, updated_at
		FROM alert_rules WHERE id = $1`
	rule := &domain.AlertRule{}
	var t string
	err := r.db.QueryRow(ctx, q, id).Scan(&rule.ID, &rule.Name, &t, &rule.Enabled, &rule.Config,
		&rule.CreatedBy, &rule.CreatedAt, &rule.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	rule.Type = domain.AlertRuleType(t)
	return rule, nil
}

func (r *alertRepo) CreateRule(ctx context.Context, rule *domain.AlertRule) error {
	if rule.ID == uuid.Nil {
		rule.ID = uuid.New()
	}
	if len(rule.Config) == 0 {
		rule.Config = []byte(`{}`)
	}
	const q = `
		INSERT INTO alert_rules (id, name, type, enabled, config, created_by, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())`
	_, err := r.db.Exec(ctx, q, rule.ID, rule.Name, string(rule.Type), rule.Enabled, rule.Config, rule.CreatedBy)
	return err
}

func (r *alertRepo) UpdateRule(ctx context.Context, rule *domain.AlertRule) error {
	if len(rule.Config) == 0 {
		rule.Config = []byte(`{}`)
	}
	const q = `
		UPDATE alert_rules
		SET name = $2, type = $3, enabled = $4, config = $5, updated_at = NOW()
		WHERE id = $1`
	tag, err := r.db.Exec(ctx, q, rule.ID, rule.Name, string(rule.Type), rule.Enabled, rule.Config)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *alertRepo) DeleteRule(ctx context.Context, id uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM alert_rules WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *alertRepo) ListEvents(ctx context.Context, limit int) ([]*domain.AlertEvent, error) {
	if limit <= 0 || limit > 500 {
		limit = 100
	}
	const q = `
		SELECT id, rule_id, fired_at, COALESCE(subject_type,''), subject_id, payload
		FROM alert_events
		ORDER BY fired_at DESC
		LIMIT $1`
	rows, err := r.db.Query(ctx, q, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]*domain.AlertEvent, 0)
	for rows.Next() {
		ev := &domain.AlertEvent{}
		if err := rows.Scan(&ev.ID, &ev.RuleID, &ev.FiredAt, &ev.SubjectType,
			&ev.SubjectID, &ev.Payload); err != nil {
			return nil, err
		}
		out = append(out, ev)
	}
	return out, rows.Err()
}

func (r *alertRepo) RecordEvent(ctx context.Context, ev *domain.AlertEvent) error {
	if ev.ID == uuid.Nil {
		ev.ID = uuid.New()
	}
	if len(ev.Payload) == 0 {
		ev.Payload = []byte(`{}`)
	}
	const q = `
		INSERT INTO alert_events (id, rule_id, fired_at, subject_type, subject_id, payload)
		VALUES ($1, $2, NOW(), NULLIF($3,''), $4, $5)`
	_, err := r.db.Exec(ctx, q, ev.ID, ev.RuleID, ev.SubjectType, ev.SubjectID, ev.Payload)
	return err
}
