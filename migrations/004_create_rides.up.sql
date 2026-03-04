-- 004_create_rides.sql
-- Central aggregate for a single trip lifecycle.
-- An idempotency_key prevents duplicate ride creation from retried requests.

CREATE TYPE ride_status   AS ENUM ('requested', 'accepted', 'arrived', 'in_progress', 'completed', 'cancelled');
CREATE TYPE cancelled_by  AS ENUM ('passenger', 'driver', 'system');

CREATE TABLE IF NOT EXISTS rides (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id        UUID        NOT NULL REFERENCES users(id),
    driver_id           UUID        REFERENCES users(id),   -- null until accepted
    status              ride_status NOT NULL DEFAULT 'requested',
    origin_lat          DOUBLE PRECISION NOT NULL,
    origin_lng          DOUBLE PRECISION NOT NULL,
    destination_lat     DOUBLE PRECISION NOT NULL,
    destination_lng     DOUBLE PRECISION NOT NULL,
    origin_address      TEXT,
    destination_address TEXT,
    notes               TEXT,
    cancelled_by        cancelled_by,   -- null unless status = 'cancelled'
    idempotency_key     TEXT        UNIQUE,  -- prevents duplicate ride requests
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Fast passenger active-ride lookup (used on app open / session recovery).
CREATE INDEX IF NOT EXISTS idx_rides_passenger_active
    ON rides (passenger_id, status)
    WHERE status NOT IN ('completed', 'cancelled');

-- Fast driver active-ride lookup (used in driver use-case guards).
CREATE INDEX IF NOT EXISTS idx_rides_driver_active
    ON rides (driver_id, status)
    WHERE status NOT IN ('completed', 'cancelled');
