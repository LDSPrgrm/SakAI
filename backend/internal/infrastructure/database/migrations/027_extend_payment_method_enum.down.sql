-- 027_extend_payment_method_enum.down.sql
-- Postgres has no DROP VALUE on ENUM types. Rolling this back requires
-- creating a replacement type, coercing the column, and dropping the old one.
-- Rows using the removed values are coerced to 'cash' (data-loss edge, but
-- safer than failing the rebuild). Prefer a forward-only policy here — only
-- run this in a dev reset where the lost method mapping doesn't matter.

ALTER TABLE ride_payments
    ALTER COLUMN method DROP DEFAULT;

-- Coerce any gcash/paymaya rows to cash so the new type can hold them.
UPDATE ride_payments SET method = 'cash'
WHERE method::text IN ('gcash', 'paymaya');

ALTER TYPE payment_method RENAME TO payment_method_old;
CREATE TYPE payment_method AS ENUM ('cash', 'card');

ALTER TABLE ride_payments
    ALTER COLUMN method TYPE payment_method
    USING method::text::payment_method;

DROP TYPE payment_method_old;
