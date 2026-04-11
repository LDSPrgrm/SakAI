-- 006_add_active_ride_constraints.sql
-- DB-level enforcement of business invariants to prevent race conditions
-- that the application layer alone cannot guarantee.

-- Invariant 1: A passenger may only have one active ride at a time.
-- Prevents duplicate ride creation when two requests race past the app-layer guard.
CREATE UNIQUE INDEX IF NOT EXISTS idx_rides_one_active_per_passenger
    ON rides (passenger_id)
    WHERE status NOT IN ('completed', 'cancelled');

-- Invariant 2: A driver may only be assigned to one active ride at a time.
-- Prevents a driver being dispatched to a new ride while already serving one.
CREATE UNIQUE INDEX IF NOT EXISTS idx_rides_one_active_per_driver
    ON rides (driver_id)
    WHERE driver_id IS NOT NULL
      AND status NOT IN ('completed', 'cancelled');
