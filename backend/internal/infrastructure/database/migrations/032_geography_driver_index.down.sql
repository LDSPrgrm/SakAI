-- 032_geography_driver_index.down.sql
CREATE INDEX IF NOT EXISTS idx_drivers_online_location
    ON drivers USING GIST (location)
    WHERE status = 'online';

DROP INDEX IF EXISTS idx_drivers_online_location_geog;
