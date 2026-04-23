-- 026_create_notification_outbox.sql
-- Append-only queue consumed by the notifications dispatcher goroutine. The
-- alert evaluator enqueues one row per recipient when a rule fires; the
-- dispatcher tails the queue and pretends to send (logs for now — no SMS /
-- email / push provider is wired yet). Makes alert notifications durable
-- even while the outbound channel is still a stub.

CREATE TABLE IF NOT EXISTS notification_outbox (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    channel       TEXT         NOT NULL CHECK (channel IN ('email', 'sms', 'push')),
    recipient     TEXT         NOT NULL,
    subject       TEXT,
    body          TEXT         NOT NULL,
    status        TEXT         NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'sent', 'failed')),
    attempts      INT          NOT NULL DEFAULT 0,
    last_error    TEXT,
    sent_at       TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Dispatcher reads pending rows oldest-first; index covers that query.
CREATE INDEX IF NOT EXISTS idx_notification_outbox_pending
    ON notification_outbox (created_at)
    WHERE status = 'pending';

-- Alert-specific notification templates. Events use the `alert.<type>` naming
-- so the evaluator can look them up by rule.Type without a separate table.
INSERT INTO notification_templates (event, channel, subject, body, variables) VALUES
    ('alert.low_rating',        'email', 'Low rating alert',
     'Rule {{rule_name}} tripped for {{subject_type}} {{subject_id}}. Avg rating {{avg_rating}} below threshold {{threshold}}.',
     ARRAY['rule_name', 'subject_type', 'subject_id', 'avg_rating', 'threshold']),
    ('alert.high_cancellation', 'email', 'High cancellation alert',
     'Rule {{rule_name}} tripped for driver {{subject_id}}. Cancellation rate {{cancellation_pct}}% over {{total}} rides exceeds {{threshold_pct}}%.',
     ARRAY['rule_name', 'subject_id', 'cancellation_pct', 'total', 'threshold_pct']),
    ('alert.fraud_velocity',    'email', 'Fraud velocity alert',
     'Rule {{rule_name}} tripped for passenger {{subject_id}}. Ride count {{ride_count}} exceeds threshold {{threshold}}.',
     ARRAY['rule_name', 'subject_id', 'ride_count', 'threshold']),
    ('alert.kyc_expiry',        'email', 'KYC expiry alert',
     'Rule {{rule_name}} tripped for driver {{subject_id}}. Document {{document_type}} expires on {{expiry_date}}.',
     ARRAY['rule_name', 'subject_id', 'document_type', 'expiry_date'])
ON CONFLICT (event) DO NOTHING;
