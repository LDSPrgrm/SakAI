-- 025_create_driver_location_history.sql
-- Captures driver GPS pings during active SOS / safety incidents so the SOS
-- timeline on SASafetyCompliance can render a location trail (plan §3.1
-- sub-bullet that Phase 3/4a deferred). Rows are only written when the driver
-- has an unresolved incident, keeping the table scoped and append-only.
--
-- Hot path: driver_usecase.UpdateLocation does an index-only EXISTS check
-- against the partial index below. Negative case (99% of pings) is O(1).
-- Positive case inserts one row bound to the incident_id so the trail read
-- path is a simple `WHERE incident_id = $1 ORDER BY recorded_at`.

CREATE TABLE IF NOT EXISTS driver_location_history (
    id           UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id    UUID             NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    incident_id  UUID             NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    lat          DOUBLE PRECISION NOT NULL,
    lng          DOUBLE PRECISION NOT NULL,
    recorded_at  TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- Render-path index: one sorted scan per incident.
CREATE INDEX IF NOT EXISTS idx_driver_location_history_incident
    ON driver_location_history (incident_id, recorded_at);

-- Capture-path optimization: O(1) lookup of "does this driver have an active
-- incident right now?" — partial index so only unresolved rows are stored.
CREATE INDEX IF NOT EXISTS idx_incidents_active_driver
    ON incidents (driver_id)
    WHERE resolved_at IS NULL;
