-- 010_add_role_id_to_users.up.sql
-- Link admin users to their dynamic role in the roles table.

ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id UUID REFERENCES roles(id) ON DELETE SET NULL;

-- Backfill: connect existing admins to their matching system role by name.
-- The roles table names use underscores (super_admin) while the ENUM uses
-- no underscore (superadmin), so we handle that mapping explicitly.
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000001' WHERE role = 'superadmin';
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000002' WHERE role = 'operations';
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000003' WHERE role = 'finance';
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000004' WHERE role = 'support';
-- Generic 'admin' users are left with role_id = NULL until manually reassigned.
