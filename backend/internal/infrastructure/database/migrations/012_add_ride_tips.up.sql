-- 012_add_ride_tips.sql
-- Adds table for ride tipping (separate from base fare payment).

CREATE TABLE IF NOT EXISTS ride_tips (
    id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id                 UUID            NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    tip_amount              NUMERIC(10, 2)  NOT NULL CHECK (tip_amount > 0),
    base_fare               NUMERIC(10, 2)  NOT NULL,
    currency                CHAR(3)         NOT NULL DEFAULT 'USD',
    method                  payment_method  NOT NULL DEFAULT 'card',
    gateway_transaction_id  VARCHAR(100),
    processed_at            TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- One tip per ride.
CREATE UNIQUE INDEX IF NOT EXISTS idx_tips_ride_unique
    ON ride_tips (ride_id);

-- Fast lookup by ride.
CREATE INDEX IF NOT EXISTS idx_tips_ride
    ON ride_tips (ride_id);
