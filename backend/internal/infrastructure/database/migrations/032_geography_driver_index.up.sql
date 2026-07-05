-- 032_geography_driver_index.up.sql
-- FindNearbyOnline* now cast location to geography so ST_DWithin/ST_Distance
-- operate in meters (geometry-4326 units are degrees — the old 5000 "meter"
-- radius matched every driver on the planet). This functional index lets the
-- planner prune the cast form; the old geometry index no longer matches any
-- query and is dropped.
CREATE INDEX IF NOT EXISTS idx_drivers_online_location_geog
    ON drivers USING GIST ((location::geography))
    WHERE status = 'online';

DROP INDEX IF EXISTS idx_drivers_online_location;
