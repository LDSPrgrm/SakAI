-- 008_super_admin_schema.up.sql
-- Add roles and tables supporting the Super Admin Panel.

-- 1. Extend user_role ENUM (if not already added)
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'operations';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'finance';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'support';

-- 2. Fare Configuration
CREATE TABLE IF NOT EXISTS fare_configs (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_type      TEXT        NOT NULL UNIQUE, -- 'motorcycle', 'tricycle', 'other'
    base_fare         NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    per_km_rate       NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    per_min_rate      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    minimum_fare      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    booking_fee       NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    cancellation_fee  NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        UUID        REFERENCES users(id) -- track which admin made the change
);

-- 3. Surge Pricing Configuration
CREATE TABLE IF NOT EXISTS surge_configs (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    enabled           BOOLEAN     NOT NULL DEFAULT FALSE,
    max_multiplier    NUMERIC(3,1) NOT NULL DEFAULT 1.0, -- e.g., 3.0
    trigger_ratio     NUMERIC(4,2) NOT NULL DEFAULT 1.5, -- e.g., Demand/Supply
    zones             JSONB       DEFAULT '[]', -- GeoJSON polygons
    blackout_hours    JSONB       DEFAULT '[]', -- Hours when surge is disabled
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        UUID        REFERENCES users(id)
);

-- 4. Audit Log Entries (Immutable, append-only)
CREATE TABLE IF NOT EXISTS audit_log_entries (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actor_id          UUID        NOT NULL REFERENCES users(id),
    ip_address        TEXT        NOT NULL,
    action            TEXT        NOT NULL, -- CREATE/UPDATE/DELETE/APPROVE/REJECT/LOGIN/LOGOUT
    resource_type     TEXT        NOT NULL, -- e.g., fare_config, admin_user, driver_payout
    resource_id       TEXT        NOT NULL,
    before_state      JSONB, -- Nullable for CREATE
    after_state       JSONB, -- Nullable for DELETE
    reason            TEXT
);

-- 5. Emergency Incidents Log
CREATE TABLE IF NOT EXISTS incidents (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id           UUID        NOT NULL REFERENCES rides(id),
    triggered_by      TEXT        NOT NULL, -- 'rider', 'driver'
    rider_id          UUID        NOT NULL REFERENCES users(id),
    driver_id         UUID        NOT NULL REFERENCES users(id),
    type              TEXT        NOT NULL, -- 'sos_triggered', 'reported_incident', 'safety_complaint'
    status            TEXT        NOT NULL DEFAULT 'open', -- 'open', 'investigating', 'resolved', 'escalated'
    assigned_to       UUID        REFERENCES users(id),
    resolution_notes  TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at       TIMESTAMPTZ
);

-- 6. Payment Gateway Configuration
CREATE TABLE IF NOT EXISTS payment_gateway_configs (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    provider          TEXT        NOT NULL UNIQUE, -- 'gcash', 'paymaya', 'card'
    config_fields     JSONB       NOT NULL, -- Encrypted/masked/raw config fields
    is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        UUID        REFERENCES users(id)
);

-- 7. Commission Settings
CREATE TABLE IF NOT EXISTS commission_settings (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_type      TEXT        NOT NULL UNIQUE, -- 'motorcycle', 'tricycle', 'other'
    rate_percent      NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    min_commission    NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        UUID        REFERENCES users(id)
);
