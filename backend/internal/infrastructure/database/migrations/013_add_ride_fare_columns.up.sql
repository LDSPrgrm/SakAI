ALTER TABLE rides
  ADD COLUMN estimated_fare NUMERIC(10,2) DEFAULT NULL,
  ADD COLUMN actual_fare NUMERIC(10,2) DEFAULT NULL,
  ADD COLUMN fare_breakdown JSONB DEFAULT NULL,
  ADD COLUMN ride_type TEXT NOT NULL DEFAULT 'car' CHECK (ride_type IN ('motorcycle', 'car', 'tricycle')),
  ADD COLUMN cancellation_reason TEXT DEFAULT NULL,
  ADD COLUMN cancellation_reason_text TEXT DEFAULT NULL,
  ADD COLUMN decline_count INTEGER NOT NULL DEFAULT 0;
