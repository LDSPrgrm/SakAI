ALTER TABLE rides
  DROP COLUMN IF EXISTS estimated_fare,
  DROP COLUMN IF EXISTS actual_fare,
  DROP COLUMN IF EXISTS fare_breakdown,
  DROP COLUMN IF EXISTS ride_type,
  DROP COLUMN IF EXISTS cancellation_reason,
  DROP COLUMN IF EXISTS cancellation_reason_text,
  DROP COLUMN IF EXISTS decline_count;
