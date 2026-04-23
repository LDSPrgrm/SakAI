-- Add lifecycle timestamps to rides so dashboard can compute real wait times
-- and reports can join on ride state transitions.
ALTER TABLE rides
    ADD COLUMN IF NOT EXISTS accepted_at  TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS arrived_at   TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS started_at   TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_rides_started_at ON rides (started_at);
CREATE INDEX IF NOT EXISTS idx_rides_completed_at ON rides (completed_at);

-- Best-effort backfill from audit log so wait-time queries aren't empty on
-- day one. Actions were recorded by the admin audit handler and by ride flow.
UPDATE rides r
SET accepted_at = a.timestamp
FROM (
    SELECT DISTINCT ON (resource_id) resource_id, timestamp
    FROM audit_log_entries
    WHERE resource_type = 'ride' AND action IN ('ride.accept', 'ride.accepted')
    ORDER BY resource_id, timestamp ASC
) a
WHERE r.id::text = a.resource_id AND r.accepted_at IS NULL;

UPDATE rides r
SET started_at = a.timestamp
FROM (
    SELECT DISTINCT ON (resource_id) resource_id, timestamp
    FROM audit_log_entries
    WHERE resource_type = 'ride' AND action IN ('ride.start', 'ride.started')
    ORDER BY resource_id, timestamp ASC
) a
WHERE r.id::text = a.resource_id AND r.started_at IS NULL;

UPDATE rides r
SET completed_at = a.timestamp
FROM (
    SELECT DISTINCT ON (resource_id) resource_id, timestamp
    FROM audit_log_entries
    WHERE resource_type = 'ride' AND action IN ('ride.complete', 'ride.completed')
    ORDER BY resource_id, timestamp ASC
) a
WHERE r.id::text = a.resource_id AND r.completed_at IS NULL;
