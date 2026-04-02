-- 007_add_admin_roles.up.sql
-- Add the admin and superadmin roles to the user_role ENUM.
-- In PostgreSQL 12+ this is safe to do inside a transaction without IF NOT EXISTS.
-- (For earlier versions we would need COMMIT; first, but SakAI uses PG 15 so this is fine.)

ALTER TYPE user_role ADD VALUE 'admin';
ALTER TYPE user_role ADD VALUE 'superadmin';
