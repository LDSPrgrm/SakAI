-- 030_create_ws_event_log.down.sql
-- Drop the audit log table. The Redis replay stream is unaffected.

DROP INDEX IF EXISTS idx_ws_event_log_event_type;
DROP INDEX IF EXISTS idx_ws_event_log_occurred_at;
DROP INDEX IF EXISTS idx_ws_event_log_ride_id;
DROP INDEX IF EXISTS idx_ws_event_log_corr_id;
DROP INDEX IF EXISTS idx_ws_event_log_event_id;
DROP TABLE IF EXISTS ws_event_log;
