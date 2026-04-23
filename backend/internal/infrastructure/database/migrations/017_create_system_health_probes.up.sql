-- Health probe records written by a background goroutine in cmd/server.
-- One row per probe execution per service; SystemHandler.ListServices selects
-- the latest row per service. Dashboard.SystemUptime aggregates the last 24h.
CREATE TABLE IF NOT EXISTS system_health_probes (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name  TEXT        NOT NULL,
    status        TEXT        NOT NULL CHECK (status IN ('ok', 'degraded', 'down')),
    latency_ms    INTEGER,
    checked_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_system_health_probes_service_time
    ON system_health_probes (service_name, checked_at DESC);

-- HTTP request timings. Populated by the perf middleware; SASystemHealth
-- reads p50/p95 from the last N minutes.
CREATE TABLE IF NOT EXISTS http_request_timings (
    id           BIGSERIAL   PRIMARY KEY,
    method       TEXT        NOT NULL,
    path         TEXT        NOT NULL,
    status_code  INTEGER     NOT NULL,
    duration_ms  NUMERIC(10, 2) NOT NULL,
    occurred_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_http_request_timings_occurred
    ON http_request_timings (occurred_at DESC);
