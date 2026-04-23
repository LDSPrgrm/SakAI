-- Persistent system-wide configuration replacing the hardcoded stubs in
-- system_repo.go. Each table is small (< 100 rows) and read-heavy.

CREATE TABLE IF NOT EXISTS feature_flags (
    key         TEXT        PRIMARY KEY,
    enabled     BOOLEAN     NOT NULL DEFAULT false,
    description TEXT,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by  UUID        REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notification_templates (
    event       TEXT        PRIMARY KEY,
    channel     TEXT        NOT NULL CHECK (channel IN ('sms', 'email', 'push')),
    subject     TEXT,
    body        TEXT        NOT NULL,
    variables   TEXT[]      NOT NULL DEFAULT '{}',
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by  UUID        REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS integration_configs (
    service            TEXT        PRIMARY KEY,
    config_fields      JSONB       NOT NULL DEFAULT '{}',
    is_active          BOOLEAN     NOT NULL DEFAULT false,
    last_tested_at     TIMESTAMPTZ,
    last_test_ok       BOOLEAN,
    last_test_message  TEXT,
    last_test_latency_ms INTEGER,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by         UUID        REFERENCES users(id) ON DELETE SET NULL
);

-- Seed rows match the previously-hardcoded lists in system_repo.go so the UI
-- keeps its initial content on first boot. Idempotent for re-runs.
INSERT INTO feature_flags (key, enabled, description) VALUES
    ('surge_pricing',    true,  'Enable surge pricing during high demand'),
    ('motorcycle_rides', true,  'Allow motorcycle ride bookings'),
    ('tricycle_rides',   true,  'Allow tricycle ride bookings'),
    ('car_rides',        true,  'Allow 4-seater car bookings'),
    ('gcash_payments',   true,  'Accept GCash as a payment method'),
    ('paymaya_payments', true,  'Accept PayMaya as a payment method'),
    ('card_payments',    true,  'Accept credit/debit card payments'),
    ('cash_payments',    true,  'Accept cash payments'),
    ('maintenance_mode', false, 'Block all non-admin traffic')
ON CONFLICT (key) DO NOTHING;

INSERT INTO notification_templates (event, channel, subject, body, variables) VALUES
    ('ride_confirmed',   'sms',   NULL,                   'Your ride with {{driver_name}} ({{plate}}) is on the way.',              ARRAY['driver_name', 'plate']),
    ('ride_cancelled',   'sms',   NULL,                   'Your ride has been cancelled. Reason: {{reason}}.',                      ARRAY['reason']),
    ('kyc_approved',     'email', 'KYC approved',         'Hi {{driver_name}}, your documents are approved. You can start driving.', ARRAY['driver_name']),
    ('kyc_rejected',     'email', 'KYC needs attention',  'Hi {{driver_name}}, please re-upload: {{reason}}.',                      ARRAY['driver_name', 'reason']),
    ('payout_processed', 'email', 'Payout processed',     'Hi {{driver_name}}, {{amount}} was sent to your account for {{period}}.', ARRAY['driver_name', 'amount', 'period'])
ON CONFLICT (event) DO NOTHING;

INSERT INTO integration_configs (service, config_fields, is_active) VALUES
    ('gcash',   '{}'::jsonb, false),
    ('paymaya', '{}'::jsonb, false),
    ('stripe',  '{}'::jsonb, false),
    ('twilio',  '{}'::jsonb, false),
    ('mapbox',  '{}'::jsonb, false),
    ('firebase','{}'::jsonb, false)
ON CONFLICT (service) DO NOTHING;
