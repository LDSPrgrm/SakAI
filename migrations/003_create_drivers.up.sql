-- 003_create_drivers.sql
-- Tracks real-time driver availability and last known location.
-- Intentionally decoupled from the users table so identity and
-- operational state can evolve independently.

CREATE TYPE driver_status AS ENUM ('online', 'offline');

CREATE TABLE IF NOT EXISTS drivers (
    user_id    UUID          PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    status     driver_status NOT NULL DEFAULT 'offline',
    location   GEOMETRY(Point, 4326),      -- PostGIS point for lat/lng
    heading    DOUBLE PRECISION,           -- compass bearing in degrees, nullable
    updated_at TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Spatial query: find nearby online drivers efficiently.
-- A partial GiST index on online drivers makes ST_DWithin lightning fast.
CREATE INDEX IF NOT EXISTS idx_drivers_online_location
    ON drivers USING GIST (location)
    WHERE status = 'online';
