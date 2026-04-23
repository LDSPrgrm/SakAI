-- 023_create_alert_rules.up.sql
-- Configurable alerting rules for the superadmin console. `type` is a closed
-- enum so the evaluator stays a switch statement — no DSL, no expression
-- parser. Per-type thresholds + windows live in `config` JSONB.

CREATE TABLE IF NOT EXISTS alert_rules (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL,
    type        TEXT        NOT NULL
                    CHECK (type IN ('low_rating','high_cancellation','fraud_velocity','kyc_expiry')),
    enabled     BOOLEAN     NOT NULL DEFAULT true,
    config      JSONB       NOT NULL DEFAULT '{}',
    created_by  UUID        REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alert_rules_enabled_type
    ON alert_rules (type)
    WHERE enabled = true;

CREATE TABLE IF NOT EXISTS alert_events (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_id      UUID        REFERENCES alert_rules(id) ON DELETE SET NULL,
    fired_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    subject_type TEXT,
    subject_id   UUID,
    payload      JSONB       NOT NULL DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_alert_events_rule_fired
    ON alert_events (rule_id, fired_at DESC);
