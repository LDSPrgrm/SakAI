-- 025_create_driver_location_history.down.sql

DROP INDEX IF EXISTS idx_incidents_active_driver;
DROP INDEX IF EXISTS idx_driver_location_history_incident;
DROP TABLE IF EXISTS driver_location_history;
