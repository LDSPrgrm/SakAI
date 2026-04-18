-- =============================================================================
-- reset_admin_accounts.sql
-- Removes all admin-class users and re-seeds the system roles.
-- Run this before re-running the seed-admin tool.
--
-- WARNING: This permanently deletes all accounts whose role is NOT
--          'passenger' or 'driver'. Passenger/driver data is untouched.
--
-- Usage:
--   psql -h localhost -p 5433 -U postgres -d sakai -f scripts/reset_admin_accounts.sql
--
-- Docker alternative:
--   docker exec -i sakai-postgres psql -U postgres -d sakai \
--     < scripts/reset_admin_accounts.sql
-- =============================================================================

BEGIN;

-- 1. Delete all admin-class users
DELETE FROM users
WHERE role NOT IN ('passenger', 'driver');

-- 2. Reset system role permissions (clear + re-seed from migration 009)
DELETE FROM role_permissions
WHERE role_id IN (
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000004'
);

-- 3. Re-seed system roles (idempotent)
INSERT INTO roles (id, name, description, is_system) VALUES
    ('10000000-0000-0000-0000-000000000001', 'super_admin', 'Full platform access',               TRUE),
    ('10000000-0000-0000-0000-000000000002', 'operations',  'Users, rides, KYC, safety',          TRUE),
    ('10000000-0000-0000-0000-000000000003', 'finance',     'Payments and reports',               TRUE),
    ('10000000-0000-0000-0000-000000000004', 'support',     'Read-only: users, rides, incidents', TRUE)
ON CONFLICT (id) DO UPDATE
    SET name = EXCLUDED.name, description = EXCLUDED.description, is_system = EXCLUDED.is_system;

-- 4. Re-seed super_admin permissions
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000001', 'dashboard',        TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000001', 'admin_management', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'role_management',  TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'fare_config',      TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'payments',         TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'payouts',          TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'user_management',  TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'kyc_verification', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'safety_incidents', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'reports',          TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'system_config',    TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000001', 'system_health',    TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000001', 'audit_log',        TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000001', 'ltfrb_compliance', TRUE, TRUE);

-- 5. Re-seed operations permissions
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000002', 'dashboard',        TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000002', 'user_management',  TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000002', 'kyc_verification', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000002', 'safety_incidents', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000002', 'reports',          TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000002', 'ltfrb_compliance', TRUE, TRUE);

-- 6. Re-seed finance permissions
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000003', 'dashboard',   TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000003', 'payments',    TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000003', 'payouts',     TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000003', 'fare_config', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000003', 'reports',     TRUE, TRUE);

-- 7. Re-seed support permissions (read-only)
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000004', 'dashboard',        TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000004', 'user_management',  TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000004', 'safety_incidents', TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000004', 'reports',          TRUE, FALSE);

COMMIT;

-- Verify: should show 0 admin users and 4 system roles
SELECT 'admin users remaining' AS check, COUNT(*) AS count
FROM users WHERE role NOT IN ('passenger', 'driver')
UNION ALL
SELECT 'system roles', COUNT(*) FROM roles WHERE is_system = TRUE;
