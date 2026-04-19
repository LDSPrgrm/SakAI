-- 015_add_payment_earnings_columns.sql
-- Adds passenger_id, idempotency_key, stripe_charge_id to ride_payments,
-- and creates the driver_earnings table.

-- ─── Ride Payments Extensions ────────────────────────────────────────────────

-- Link payment to passenger for unpaid block check.
ALTER TABLE ride_payments
    ADD COLUMN IF NOT EXISTS passenger_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- Idempotency key for Stripe retry safety.
ALTER TABLE ride_payments
    ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(100) UNIQUE;

-- Explicit Stripe charge ID (alias for gateway_transaction_id).
ALTER TABLE ride_payments
    ADD COLUMN IF NOT EXISTS stripe_charge_id VARCHAR(100);

-- Index for 24-hour unpaid block check:
-- SELECT COUNT(*) FROM ride_payments WHERE passenger_id = $1 AND status = 'failed' AND created_at < $2
CREATE INDEX IF NOT EXISTS idx_payments_passenger_unpaid
    ON ride_payments (passenger_id, status, created_at DESC)
    WHERE status = 'failed';

-- ─── Driver Earnings ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS driver_earnings (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id       UUID            NOT NULL REFERENCES drivers(user_id) ON DELETE CASCADE,
    ride_id         UUID            NOT NULL UNIQUE REFERENCES rides(id) ON DELETE CASCADE,
    fare_amount     NUMERIC(10, 2)  NOT NULL CHECK (fare_amount >= 0),
    tip_amount      NUMERIC(10, 2)  NOT NULL DEFAULT 0 CHECK (tip_amount >= 0),
    total_amount    NUMERIC(10, 2)  NOT NULL GENERATED ALWAYS AS (fare_amount + tip_amount) STORED,
    currency        CHAR(3)         NOT NULL DEFAULT 'USD',
    completed_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Fast earnings history query by driver, ordered by most recent.
CREATE INDEX IF NOT EXISTS idx_earnings_driver_date
    ON driver_earnings (driver_id, completed_at DESC);
