-- 024_create_driver_payouts.sql
-- Creates the driver_payouts table that backs admin /payments/payouts.
-- Replaces the prior in-memory stub in payment_repo.go.

CREATE TABLE IF NOT EXISTS driver_payouts (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    batch           TEXT            NOT NULL UNIQUE,            -- e.g. "2026-W14"
    period_start    DATE            NOT NULL,
    period_end      DATE            NOT NULL,
    period_label    TEXT            NOT NULL,                   -- e.g. "Apr 1–7 2026"
    driver_count    INT             NOT NULL DEFAULT 0,
    total_amount    NUMERIC(12, 2)  NOT NULL DEFAULT 0,
    status          TEXT            NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending','approved','paid','cancelled')),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    approved_at     TIMESTAMPTZ,
    approved_by     UUID            REFERENCES users(id) ON DELETE SET NULL,
    notes           TEXT
);

CREATE INDEX IF NOT EXISTS idx_driver_payouts_status_created
    ON driver_payouts (status, created_at DESC);

-- Junction so a payout batch lists which drivers + how much each got.
CREATE TABLE IF NOT EXISTS driver_payout_lines (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    payout_id       UUID            NOT NULL REFERENCES driver_payouts(id) ON DELETE CASCADE,
    driver_id       UUID            NOT NULL REFERENCES drivers(user_id) ON DELETE RESTRICT,
    amount          NUMERIC(12, 2)  NOT NULL CHECK (amount >= 0),
    ride_count      INT             NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    UNIQUE (payout_id, driver_id)
);

CREATE INDEX IF NOT EXISTS idx_driver_payout_lines_payout
    ON driver_payout_lines (payout_id);
