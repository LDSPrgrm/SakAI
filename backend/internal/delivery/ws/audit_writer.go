package ws

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// AuditEvent is the row written to ws_event_log for every dispatched
// envelope. PIISafe is true by default — payload_hash carries a SHA-256
// summary so analysts can correlate events across pods without persisting
// the raw payload (which may include phone numbers, exact locations, etc).
// RFC v2 §12.4.
type AuditEvent struct {
	EventID     uuid.UUID
	CorrID      string
	RideID      *uuid.UUID
	ActorUserID *uuid.UUID
	EventType   EventType
	OccurredAt  time.Time
	PayloadHash string
	AckRequired bool
	Seq         *uint64
	PIISafe     bool
}

// AuditWriter persists envelope metadata to a long-term store (Postgres in
// production, in-memory for tests). Errors are non-fatal at the caller —
// the dispatcher logs them and continues.
type AuditWriter interface {
	Write(ctx context.Context, e AuditEvent) error
}

// NoopAuditWriter discards every event. Default when nothing is wired.
type NoopAuditWriter struct{}

func (NoopAuditWriter) Write(_ context.Context, _ AuditEvent) error { return nil }

// PostgresAuditWriter inserts into ws_event_log. The schema is created by
// migration 030_create_ws_event_log.
type PostgresAuditWriter struct {
	db *sql.DB
}

func NewPostgresAuditWriter(db *sql.DB) *PostgresAuditWriter {
	return &PostgresAuditWriter{db: db}
}

func (w *PostgresAuditWriter) Write(ctx context.Context, e AuditEvent) error {
	var corrIDArg any
	if e.CorrID != "" {
		corrIDArg = e.CorrID
	}
	var seqArg any
	if e.Seq != nil {
		seqArg = *e.Seq
	}
	_, err := w.db.ExecContext(ctx, `
		INSERT INTO ws_event_log (
			id, event_id, corr_id, ride_id, actor_user_id,
			event_type, occurred_at, payload_hash, ack_required, seq, pii_safe
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`,
		uuid.New(), e.EventID, corrIDArg, e.RideID, e.ActorUserID,
		string(e.EventType), e.OccurredAt, e.PayloadHash,
		e.AckRequired, seqArg, e.PIISafe,
	)
	return err
}

// MemAuditWriter accumulates events in memory; tests assert on it.
type MemAuditWriter struct {
	Events []AuditEvent
}

func (w *MemAuditWriter) Write(_ context.Context, e AuditEvent) error {
	w.Events = append(w.Events, e)
	return nil
}

// EnvelopeAuditEvent builds an AuditEvent from an Envelope and optional
// routing IDs (target user for direct sends, ride for ride-scoped sends).
// The payload is SHA-256 hashed; the raw bytes never enter the audit row.
func EnvelopeAuditEvent(env Envelope, actorUserID, rideID *uuid.UUID) AuditEvent {
	payloadJSON, _ := json.Marshal(env.Payload)
	sum := sha256.Sum256(payloadJSON)
	var seqPtr *uint64
	if env.Seq != 0 {
		s := env.Seq
		seqPtr = &s
	}
	ack := env.AckRequired != nil && *env.AckRequired
	return AuditEvent{
		EventID:     env.EventID,
		CorrID:      env.CorrID,
		RideID:      rideID,
		ActorUserID: actorUserID,
		EventType:   env.Event,
		OccurredAt:  env.Timestamp,
		PayloadHash: hex.EncodeToString(sum[:]),
		AckRequired: ack,
		Seq:         seqPtr,
		PIISafe:     true,
	}
}
