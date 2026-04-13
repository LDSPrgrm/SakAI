-- 006_add_active_ride_constraints.down.sql

DROP INDEX IF EXISTS idx_rides_one_active_per_passenger;
DROP INDEX IF EXISTS idx_rides_one_active_per_driver;
