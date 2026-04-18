-- 007_add_admin_roles.down.sql
-- PostgreSQL does not support removing ENUM values; a full type recreation is required.
-- Recreate user_role without the admin values, migrating existing data first.

-- Drop dependent objects temporarily to allow type swap
ALTER TABLE users ALTER COLUMN role TYPE TEXT;

DROP TYPE user_role;

CREATE TYPE user_role AS ENUM ('passenger', 'driver');

ALTER TABLE users ALTER COLUMN role TYPE user_role USING role::user_role;
