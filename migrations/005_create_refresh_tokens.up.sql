-- 005_create_refresh_tokens.sql
-- Server-side refresh token store. Tokens are opaque random strings.
-- Rotation: old token is deleted and a new one is issued on every /auth/refresh call.
-- All tokens for a user are purged on logout.

CREATE TABLE IF NOT EXISTS refresh_tokens (
    token      TEXT        PRIMARY KEY,
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Fast lookup by user for logout (delete all tokens for a user).
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens (user_id);
