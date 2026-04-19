-- 007_add_admin_roles.up.sql
-- Extend user_role ENUM with all admin role values.
-- Uses IF NOT EXISTS (PG 9.6+) so this migration is safe to re-run.

ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'superadmin';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'operations';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'finance';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'support';
