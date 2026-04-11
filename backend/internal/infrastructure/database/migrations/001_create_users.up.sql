-- 001_create_users.sql
-- Core identity table. Both passengers and drivers are stored here,
-- distinguished by the role column.

CREATE TYPE user_role AS ENUM ('passenger', 'driver');

CREATE TABLE IF NOT EXISTS users (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT        NOT NULL,
    email      TEXT        NOT NULL UNIQUE,
    password_hash TEXT     NOT NULL,  -- bcrypt hash
    role       user_role   NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Fast lookup for login (email uniqueness is enforced above).
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
