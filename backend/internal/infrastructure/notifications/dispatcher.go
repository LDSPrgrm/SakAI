// Package notifications is the durable outbound pipe for alert fires and
// other platform notifications. The evaluator enqueues rows via AlertNotifier;
// the Dispatcher goroutine drains them.
//
// Scope is deliberately minimal — no real SMS/email/push provider is wired
// yet. "Sending" means logging the row and marking it sent. Once a real
// channel client is plugged in, only send() needs to change.
package notifications

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// AlertNotifier renders + enqueues notification rows for an alert fire.
type AlertNotifier interface {
	NotifyAlertFire(ctx context.Context, rule *domain.AlertRule, subjectType, subjectID string, payload []byte) error
}

type notifier struct {
	pool *pgxpool.Pool
}

// NewNotifier wires the alert evaluator's dispatch path. Used by cmd/api/main.
func NewNotifier(pool *pgxpool.Pool) AlertNotifier {
	return &notifier{pool: pool}
}

// NotifyAlertFire looks up the `alert.<type>` notification template, renders
// it with the rule + payload variables, and writes one outbox row per
// recipient (admins with role in superadmin/operations). Rows land in
// `notification_outbox` for the Dispatcher to ship.
func (n *notifier) NotifyAlertFire(ctx context.Context, rule *domain.AlertRule, subjectType, subjectID string, payload []byte) error {
	event := "alert." + string(rule.Type)

	var (
		channel string
		subject *string
		body    string
	)
	const qTpl = `SELECT channel, subject, body FROM notification_templates WHERE event = $1`
	if err := n.pool.QueryRow(ctx, qTpl, event).Scan(&channel, &subject, &body); err != nil {
		return fmt.Errorf("template %s: %w", event, err)
	}

	vars := map[string]string{
		"rule_name":    rule.Name,
		"subject_type": subjectType,
		"subject_id":   subjectID,
	}
	var payloadMap map[string]any
	_ = json.Unmarshal(payload, &payloadMap)
	for k, v := range payloadMap {
		vars[k] = fmt.Sprint(v)
	}

	renderedSubject := ""
	if subject != nil {
		renderedSubject = renderTemplate(*subject, vars)
	}
	renderedBody := renderTemplate(body, vars)

	const qAdmins = `SELECT email FROM users WHERE role IN ('superadmin', 'operations') AND email <> ''`
	rows, err := n.pool.Query(ctx, qAdmins)
	if err != nil {
		return fmt.Errorf("admin lookup: %w", err)
	}
	defer rows.Close()

	var recipients []string
	for rows.Next() {
		var email string
		if err := rows.Scan(&email); err != nil {
			return err
		}
		recipients = append(recipients, email)
	}
	if len(recipients) == 0 {
		log.Printf("notifications: no admin recipients for %s — skipping outbox write", event)
		return nil
	}

	const qEnqueue = `
		INSERT INTO notification_outbox (channel, recipient, subject, body)
		VALUES ($1, $2, NULLIF($3, ''), $4)`
	for _, r := range recipients {
		if _, err := n.pool.Exec(ctx, qEnqueue, channel, r, renderedSubject, renderedBody); err != nil {
			return fmt.Errorf("enqueue %s: %w", r, err)
		}
	}
	return nil
}

// renderTemplate does straight-ahead `{{key}}` substitution. Unreplaced
// placeholders are left in place so the recipient still sees the raw string
// rather than an empty value.
func renderTemplate(tpl string, vars map[string]string) string {
	out := tpl
	for k, v := range vars {
		out = strings.ReplaceAll(out, "{{"+k+"}}", v)
	}
	return out
}

// Dispatcher drains the notification_outbox. Currently "sending" means
// logging the row and flipping status to 'sent'. Plug a real provider into
// send() once one exists.
type Dispatcher struct {
	pool     *pgxpool.Pool
	interval time.Duration
	batch    int
}

// NewDispatcher returns a dispatcher. interval defaults to 30s, batch to 20.
func NewDispatcher(pool *pgxpool.Pool, interval time.Duration, batch int) *Dispatcher {
	if interval <= 0 {
		interval = 30 * time.Second
	}
	if batch <= 0 {
		batch = 20
	}
	return &Dispatcher{pool: pool, interval: interval, batch: batch}
}

func (d *Dispatcher) Run(ctx context.Context) {
	t := time.NewTicker(d.interval)
	defer t.Stop()
	d.tickOnce(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			d.tickOnce(ctx)
		}
	}
}

func (d *Dispatcher) tickOnce(ctx context.Context) {
	const q = `
		SELECT id, channel, recipient, COALESCE(subject,''), body, attempts
		FROM notification_outbox
		WHERE status = 'pending'
		ORDER BY created_at ASC
		LIMIT $1`
	rows, err := d.pool.Query(ctx, q, d.batch)
	if err != nil {
		log.Printf("notifications dispatcher: list pending: %v", err)
		return
	}
	type row struct {
		id                                    uuid.UUID
		channel, recipient, subject, body     string
		attempts                              int
	}
	var batch []row
	for rows.Next() {
		var r row
		if err := rows.Scan(&r.id, &r.channel, &r.recipient, &r.subject, &r.body, &r.attempts); err != nil {
			log.Printf("notifications dispatcher: scan: %v", err)
			rows.Close()
			return
		}
		batch = append(batch, r)
	}
	rows.Close()

	for _, r := range batch {
		if err := d.send(ctx, r.channel, r.recipient, r.subject, r.body); err != nil {
			d.markFailed(ctx, r.id, r.attempts+1, err.Error())
			continue
		}
		d.markSent(ctx, r.id)
	}
}

// send is the outbound channel. No provider wired yet — emit a log line that
// ops can grep for and treat the row as dispatched.
func (d *Dispatcher) send(_ context.Context, channel, recipient, subject, body string) error {
	log.Printf("[NOTIFY] channel=%s to=%s subject=%q body=%s", channel, recipient, subject, body)
	return nil
}

func (d *Dispatcher) markSent(ctx context.Context, id uuid.UUID) {
	const q = `UPDATE notification_outbox SET status='sent', sent_at=NOW(), attempts = attempts + 1 WHERE id = $1`
	if _, err := d.pool.Exec(ctx, q, id); err != nil {
		log.Printf("notifications dispatcher: mark sent %s: %v", id, err)
	}
}

// markFailed bumps the attempt counter and flips to 'failed' after 5 tries.
func (d *Dispatcher) markFailed(ctx context.Context, id uuid.UUID, attempts int, errMsg string) {
	const maxAttempts = 5
	status := "pending"
	if attempts >= maxAttempts {
		status = "failed"
	}
	const q = `UPDATE notification_outbox SET status=$2, attempts=$3, last_error=$4 WHERE id=$1`
	if _, err := d.pool.Exec(ctx, q, id, status, attempts, errMsg); err != nil {
		log.Printf("notifications dispatcher: mark failed %s: %v", id, err)
	}
}
