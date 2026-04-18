-- 008_super_admin_schema.up.sql
-- Create all tables that support the Super Admin panel.

-- 1. Fare Configuration
CREATE TABLE IF NOT EXISTS fare_configs (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_type     TEXT          NOT NULL UNIQUE, -- 'motorcycle', 'tricycle', 'car'
    base_fare        NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    per_km_rate      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    per_min_rate     NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    minimum_fare     NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    booking_fee      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    cancellation_fee NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by       UUID          REFERENCES users(id) ON DELETE SET NULL
);

-- 2. Surge Pricing Configuration
CREATE TABLE IF NOT EXISTS surge_configs (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    enabled        BOOLEAN      NOT NULL DEFAULT FALSE,
    max_multiplier NUMERIC(3,1) NOT NULL DEFAULT 1.0,
    trigger_ratio  NUMERIC(4,2) NOT NULL DEFAULT 1.5,
    zones          JSONB        NOT NULL DEFAULT '[]', -- GeoJSON polygons
    blackout_hours JSONB        NOT NULL DEFAULT '[]',
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by     UUID         REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Audit Log (immutable, append-only)
CREATE TABLE IF NOT EXISTS audit_log_entries (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actor_id      UUID        NOT NULL REFERENCES users(id),
    ip_address    TEXT        NOT NULL,
    action        TEXT        NOT NULL, -- CREATE/UPDATE/DELETE/APPROVE/REJECT/LOGIN/LOGOUT
    resource_type TEXT        NOT NULL, -- e.g. fare_config, admin_user, driver_payout
    resource_id   TEXT        NOT NULL,
    before_state  JSONB,
    after_state   JSONB,
    reason        TEXT
);

CREATE INDEX IF NOT EXISTS idx_audit_log_actor    ON audit_log_entries (actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_resource ON audit_log_entries (resource_type, resource_id);

-- 4. Emergency Incidents
CREATE TABLE IF NOT EXISTS incidents (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id          UUID        NOT NULL REFERENCES rides(id),
    triggered_by     TEXT        NOT NULL, -- 'rider' | 'driver'
    rider_id         UUID        NOT NULL REFERENCES users(id),
    driver_id        UUID        NOT NULL REFERENCES users(id),
    type             TEXT        NOT NULL, -- 'sos_triggered' | 'reported_incident' | 'safety_complaint'
    status           TEXT        NOT NULL DEFAULT 'open', -- 'open' | 'investigating' | 'resolved' | 'escalated'
    assigned_to      UUID        REFERENCES users(id) ON DELETE SET NULL,
    resolution_notes TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_incidents_status ON incidents (status);

-- 5. Payment Gateway Configuration
CREATE TABLE IF NOT EXISTS payment_gateway_configs (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    provider      TEXT        NOT NULL UNIQUE, -- 'gcash' | 'paymaya' | 'card' | 'cash'
    config_fields JSONB       NOT NULL DEFAULT '{}',
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by    UUID        REFERENCES users(id) ON DELETE SET NULL
);

-- 6. Commission Settings
CREATE TABLE IF NOT EXISTS commission_settings (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_type   TEXT          NOT NULL UNIQUE,
    rate_percent   NUMERIC(5,2)  NOT NULL DEFAULT 0.00,
    min_commission NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by     UUID          REFERENCES users(id) ON DELETE SET NULL
);
