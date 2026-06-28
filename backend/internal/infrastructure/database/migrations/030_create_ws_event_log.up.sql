-- 030_create_ws_event_log.up.sql
-- Durable audit log of every WebSocket envelope dispatched by the cluster.
-- Drives RFC v2 §12 observability: trace event_id from publish → fanout →
-- ack and reconcile state when replay/state_sync paths surface anomalies.
--
-- payload_hash (sha256 hex) is stored instead of the raw payload so PII
-- (passenger phone numbers, exact locations) does NOT land in the audit
-- store; the original envelope still lives in the Redis replay stream
-- with its 24h TTL for short-window debugging.

CREATE TABLE IF NOT EXISTS ws_event_log (
    id              UUID        PRIMARY KEY,
    event_id        UUID        NOT NULL,
    corr_id         UUID,
    ride_id         UUID,
    actor_user_id   UUID,
    event_type      TEXT        NOT NULL,
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    payload_hash    TEXT        NOT NULL,
    ack_required    BOOLEAN     NOT NULL DEFAULT FALSE,
    seq             BIGINT,
    pii_safe        BOOLEAN     NOT NULL DEFAULT TRUE
);

-- Indices follow the access patterns from RFC §16.2 (e2e tracing) and
-- §16.5 (operator forensics on a specific ride).
CREATE INDEX IF NOT EXISTS idx_ws_event_log_event_id    ON ws_event_log (event_id);
CREATE INDEX IF NOT EXISTS idx_ws_event_log_corr_id     ON ws_event_log (corr_id) WHERE corr_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ws_event_log_ride_id     ON ws_event_log (ride_id) WHERE ride_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ws_event_log_occurred_at ON ws_event_log (occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_ws_event_log_event_type  ON ws_event_log (event_type, occurred_at DESC);
