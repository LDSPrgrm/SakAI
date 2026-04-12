-- 012_add_ride_tips.sql (down)

DROP INDEX IF EXISTS idx_tips_ride;
DROP INDEX IF EXISTS idx_tips_ride_unique;
DROP TABLE IF EXISTS ride_tips;
