// Package alerting runs a periodic evaluator goroutine that walks enabled
// alert_rules and emits rows into alert_events when a rule's threshold is
// tripped. Four rule types, four branches — no DSL, no expression parser.
//
// Scope is deliberately minimal: each evaluation is a single SQL aggregate
// against the relevant table over the last N minutes/days. Bigger strategies
// (e.g. rolling windows, per-driver dedupe) are out of scope for this first
// cut; add them alongside the type branch when needed.
package alerting

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type Evaluator struct {
	repo     domain.AlertRepository
	pool     *pgxpool.Pool
	interval time.Duration
}

func New(repo domain.AlertRepository, pool *pgxpool.Pool, interval time.Duration) *Evaluator {
	if interval <= 0 {
		interval = 5 * time.Minute
	}
	return &Evaluator{repo: repo, pool: pool, interval: interval}
}

// Run blocks until ctx is cancelled, evaluating all enabled rules each tick.
// Failures from a single rule do not abort the loop — every tick is a fresh
// pass so a transient DB error corrects on the next iteration.
func (e *Evaluator) Run(ctx context.Context) {
	t := time.NewTicker(e.interval)
	defer t.Stop()
	e.tickOnce(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			e.tickOnce(ctx)
		}
	}
}

func (e *Evaluator) tickOnce(ctx context.Context) {
	rules, err := e.repo.ListRules(ctx)
	if err != nil {
		log.Printf("alerting: list rules: %v", err)
		return
	}
	for _, rule := range rules {
		if !rule.Enabled {
			continue
		}
		if err := e.evaluate(ctx, rule); err != nil {
			log.Printf("alerting: rule %s (%s): %v", rule.ID, rule.Type, err)
		}
	}
}

func (e *Evaluator) evaluate(ctx context.Context, rule *domain.AlertRule) error {
	switch rule.Type {
	case domain.AlertLowRating:
		return e.evalLowRating(ctx, rule)
	case domain.AlertHighCancellation:
		return e.evalHighCancellation(ctx, rule)
	case domain.AlertFraudVelocity:
		return e.evalFraudVelocity(ctx, rule)
	case domain.AlertKYCExpiry:
		return e.evalKYCExpiry(ctx, rule)
	}
	return nil
}

// cooldownMinutes returns the per-rule suppression window from config, or
// 60min default. Used by record() to skip duplicate events for the same
// (rule, subject) inside the window — without it the evaluator emits ~288
// rows/day per still-tripping subject (one per 5min tick).
func cooldownMinutes(raw json.RawMessage) int {
	var cfg struct {
		CooldownMinutes int `json:"cooldown_minutes"`
	}
	_ = json.Unmarshal(raw, &cfg)
	if cfg.CooldownMinutes <= 0 {
		return 60
	}
	return cfg.CooldownMinutes
}

// low_rating config: { "threshold": 3.5, "window_days": 7, "cooldown_minutes": 60 }
func (e *Evaluator) evalLowRating(ctx context.Context, rule *domain.AlertRule) error {
	cfg := struct {
		Threshold  float64 `json:"threshold"`
		WindowDays int     `json:"window_days"`
	}{Threshold: 3.0, WindowDays: 7}
	_ = json.Unmarshal(rule.Config, &cfg)

	const q = `
		SELECT ratee_id::text, AVG(stars)
		FROM ratings
		WHERE created_at >= NOW() - ($1 || ' days')::interval
		GROUP BY ratee_id
		HAVING AVG(stars) < $2`
	rows, err := e.pool.Query(ctx, q, fmt.Sprintf("%d", cfg.WindowDays), cfg.Threshold)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var subject string
		var avg float64
		if err := rows.Scan(&subject, &avg); err != nil {
			continue
		}
		payload, _ := json.Marshal(map[string]any{"avg_rating": avg, "threshold": cfg.Threshold})
		e.record(ctx, rule, "user", subject, payload)
	}
	return nil
}

// high_cancellation config: { "threshold_pct": 20, "window_days": 7 }
func (e *Evaluator) evalHighCancellation(ctx context.Context, rule *domain.AlertRule) error {
	cfg := struct {
		ThresholdPct float64 `json:"threshold_pct"`
		WindowDays   int     `json:"window_days"`
	}{ThresholdPct: 20, WindowDays: 7}
	_ = json.Unmarshal(rule.Config, &cfg)

	const q = `
		SELECT driver_id::text,
		       COUNT(*) FILTER (WHERE status='cancelled')::float * 100 / NULLIF(COUNT(*),0) AS pct,
		       COUNT(*) AS total
		FROM rides
		WHERE driver_id IS NOT NULL AND created_at >= NOW() - ($1 || ' days')::interval
		GROUP BY driver_id
		HAVING COUNT(*) >= 5
		   AND COUNT(*) FILTER (WHERE status='cancelled')::float * 100 / NULLIF(COUNT(*),0) > $2`
	rows, err := e.pool.Query(ctx, q, fmt.Sprintf("%d", cfg.WindowDays), cfg.ThresholdPct)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var subject string
		var pct float64
		var total int
		if err := rows.Scan(&subject, &pct, &total); err != nil {
			continue
		}
		payload, _ := json.Marshal(map[string]any{"cancellation_pct": pct, "total": total, "threshold_pct": cfg.ThresholdPct})
		e.record(ctx, rule, "driver", subject, payload)
	}
	return nil
}

// fraud_velocity config: { "rides_per_hour": 8, "window_hours": 1 }
func (e *Evaluator) evalFraudVelocity(ctx context.Context, rule *domain.AlertRule) error {
	cfg := struct {
		RidesPerHour int `json:"rides_per_hour"`
		WindowHours  int `json:"window_hours"`
	}{RidesPerHour: 10, WindowHours: 1}
	_ = json.Unmarshal(rule.Config, &cfg)

	const q = `
		SELECT passenger_id::text, COUNT(*)
		FROM rides
		WHERE created_at >= NOW() - ($1 || ' hours')::interval
		GROUP BY passenger_id
		HAVING COUNT(*) > $2`
	rows, err := e.pool.Query(ctx, q, fmt.Sprintf("%d", cfg.WindowHours), cfg.RidesPerHour)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var subject string
		var count int
		if err := rows.Scan(&subject, &count); err != nil {
			continue
		}
		payload, _ := json.Marshal(map[string]any{"ride_count": count, "threshold": cfg.RidesPerHour})
		e.record(ctx, rule, "passenger", subject, payload)
	}
	return nil
}

// kyc_expiry config: { "days_before_expiry": 30 }
func (e *Evaluator) evalKYCExpiry(ctx context.Context, rule *domain.AlertRule) error {
	cfg := struct {
		DaysBeforeExpiry int `json:"days_before_expiry"`
	}{DaysBeforeExpiry: 30}
	_ = json.Unmarshal(rule.Config, &cfg)

	const q = `
		SELECT driver_id::text, document_type, expiry_date
		FROM driver_documents
		WHERE expiry_date IS NOT NULL
		  AND expiry_date <= CURRENT_DATE + ($1 || ' days')::interval
		  AND expiry_date > CURRENT_DATE - INTERVAL '1 day'`
	rows, err := e.pool.Query(ctx, q, fmt.Sprintf("%d", cfg.DaysBeforeExpiry))
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var subject, docType string
		var expiry time.Time
		if err := rows.Scan(&subject, &docType, &expiry); err != nil {
			continue
		}
		payload, _ := json.Marshal(map[string]any{
			"document_type": docType,
			"expiry_date":   expiry.Format("2006-01-02"),
		})
		e.record(ctx, rule, "driver", subject, payload)
	}
	return nil
}

// record inserts an alert_events row only when no event for the same
// (rule_id, subject_id) has fired inside the per-rule cooldown window.
// The conditional INSERT runs server-side so concurrent ticks can't both
// slip a duplicate past a Go-side check.
func (e *Evaluator) record(ctx context.Context, rule *domain.AlertRule, subjectType, subjectID string, payload []byte) {
	var sid *uuid.UUID
	if u, err := uuid.Parse(subjectID); err == nil {
		sid = &u
	}
	cooldown := cooldownMinutes(rule.Config)
	const q = `
		INSERT INTO alert_events (rule_id, subject_type, subject_id, payload)
		SELECT $1, $2, $3, $4
		WHERE NOT EXISTS (
		    SELECT 1 FROM alert_events
		    WHERE rule_id = $1
		      AND ((subject_id IS NULL AND $3::uuid IS NULL) OR subject_id = $3)
		      AND fired_at >= NOW() - ($5 || ' minutes')::interval
		)`
	if _, err := e.pool.Exec(ctx, q, rule.ID, subjectType, sid, payload, fmt.Sprintf("%d", cooldown)); err != nil {
		log.Printf("alerting: record event for rule %s: %v", rule.ID, err)
	}
}
