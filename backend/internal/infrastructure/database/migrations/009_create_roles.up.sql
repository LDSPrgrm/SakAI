-- 009_create_roles.up.sql
-- RBAC: persistent roles and per-role permission rows.

-- 1. Roles table
CREATE TABLE IF NOT EXISTS roles (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL UNIQUE,
    description TEXT        NOT NULL DEFAULT '',
    is_system   BOOLEAN     NOT NULL DEFAULT FALSE,
    created_by  UUID        REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Role permissions (1:N, cascades on role delete)
CREATE TABLE IF NOT EXISTS role_permissions (
    id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id        UUID    NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_key TEXT    NOT NULL,
    read           BOOLEAN NOT NULL DEFAULT FALSE,
    write          BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (role_id, permission_key)
);

-- 3. Seed built-in system roles (fixed UUIDs for stable FK references in code)
INSERT INTO roles (id, name, description, is_system) VALUES
    ('10000000-0000-0000-0000-000000000001', 'super_admin', 'Full platform access',               TRUE),
    ('10000000-0000-0000-0000-000000000002', 'operations',  'Users, rides, KYC, safety',          TRUE),
    ('10000000-0000-0000-0000-000000000003', 'finance',     'Payments and reports',               TRUE),
    ('10000000-0000-0000-0000-000000000004', 'support',     'Read-only: users, rides, incidents', TRUE)
ON CONFLICT (id) DO NOTHING;

-- 4. super_admin permissions (all modules, read + write where applicable)
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
    ('10000000-0000-0000-0000-000000000001', 'ltfrb_compliance', TRUE, TRUE)
ON CONFLICT (role_id, permission_key) DO NOTHING;

-- 5. operations permissions
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000002', 'dashboard',        TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000002', 'user_management',  TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000002', 'kyc_verification', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000002', 'safety_incidents', TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000002', 'reports',          TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000002', 'ltfrb_compliance', TRUE, TRUE)
ON CONFLICT (role_id, permission_key) DO NOTHING;

-- 6. finance permissions
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000003', 'dashboard',  TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000003', 'payments',   TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000003', 'payouts',    TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000003', 'fare_config',TRUE, TRUE),
    ('10000000-0000-0000-0000-000000000003', 'reports',    TRUE, TRUE)
ON CONFLICT (role_id, permission_key) DO NOTHING;

-- 7. support permissions (read-only)
INSERT INTO role_permissions (role_id, permission_key, read, write) VALUES
    ('10000000-0000-0000-0000-000000000004', 'dashboard',        TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000004', 'user_management',  TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000004', 'safety_incidents', TRUE, FALSE),
    ('10000000-0000-0000-0000-000000000004', 'reports',          TRUE, FALSE)
ON CONFLICT (role_id, permission_key) DO NOTHING;
