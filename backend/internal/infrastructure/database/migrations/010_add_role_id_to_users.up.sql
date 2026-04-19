-- 010_add_role_id_to_users.up.sql
-- Add a FK from users to roles so admin accounts reference their dynamic RBAC role.

ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id UUID REFERENCES roles(id) ON DELETE SET NULL;

-- Backfill: map existing users whose ENUM role matches a system role.
-- ENUM value 'superadmin' → role name 'super_admin' (underscore differs intentionally).
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000001' WHERE role = 'superadmin';
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000002' WHERE role = 'operations';
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000003' WHERE role = 'finance';
UPDATE users SET role_id = '10000000-0000-0000-0000-000000000004' WHERE role = 'support';
-- Generic 'admin' users remain role_id = NULL until manually assigned a custom role.
