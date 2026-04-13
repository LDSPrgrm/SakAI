-- 003_create_drivers.down.sql

DROP INDEX IF EXISTS idx_drivers_online_location;
DROP TABLE IF EXISTS drivers;
DROP TYPE IF EXISTS driver_status;
