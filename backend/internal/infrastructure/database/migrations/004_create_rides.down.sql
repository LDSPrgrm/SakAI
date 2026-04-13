-- 004_create_rides.down.sql

DROP INDEX IF EXISTS idx_rides_passenger_active;
DROP INDEX IF EXISTS idx_rides_driver_active;
DROP TABLE IF EXISTS rides;
DROP TYPE IF EXISTS ride_status;
DROP TYPE IF EXISTS cancelled_by;
