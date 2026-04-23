-- 027_extend_payment_method_enum.sql
-- Extend payment_method ENUM with gcash + paymaya so e-wallet rides land in
-- ride_payments and surface in the admin transaction list. Prior to this
-- migration, payment_method allowed only ('cash', 'card'); any e-wallet
-- transaction would fail the column CHECK and be silently dropped.
--
-- Requires PostgreSQL 12+: ALTER TYPE ... ADD VALUE IF NOT EXISTS is
-- transaction-safe since PG12. New values cannot be used in the same
-- transaction that added them, but that's fine — this migration only extends
-- the type.

ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'gcash';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'paymaya';
