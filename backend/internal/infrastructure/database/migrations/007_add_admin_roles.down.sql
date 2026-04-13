-- 007_add_admin_roles.down.sql
-- Note: PostgreSQL does not support removing ENUM values directly.
-- This migration is a no-op for safety. If you truly need to revert,
-- you must recreate the ENUM type without the unwanted values.

-- No-op: ENUM values 'admin' and 'superadmin' remain in user_role.
