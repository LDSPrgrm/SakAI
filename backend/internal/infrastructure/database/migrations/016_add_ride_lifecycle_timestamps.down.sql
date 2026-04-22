DROP INDEX IF EXISTS idx_rides_completed_at;
DROP INDEX IF EXISTS idx_rides_started_at;

ALTER TABLE rides
    DROP COLUMN IF EXISTS cancelled_at,
    DROP COLUMN IF EXISTS completed_at,
    DROP COLUMN IF EXISTS started_at,
    DROP COLUMN IF EXISTS arrived_at,
    DROP COLUMN IF EXISTS accepted_at;
