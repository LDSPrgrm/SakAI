-- 015_add_payment_earnings_columns.down.sql

DROP INDEX IF EXISTS idx_earnings_driver_date;
DROP TABLE IF EXISTS driver_earnings;

DROP INDEX IF EXISTS idx_payments_passenger_unpaid;
ALTER TABLE ride_payments DROP COLUMN IF EXISTS stripe_charge_id;
ALTER TABLE ride_payments DROP COLUMN IF EXISTS idempotency_key;
ALTER TABLE ride_payments DROP COLUMN IF EXISTS passenger_id;
