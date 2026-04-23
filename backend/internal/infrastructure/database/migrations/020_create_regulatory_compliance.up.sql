-- Singleton row holding platform-wide regulatory (LTFRB) compliance state.
-- SASafetyCompliance.tsx previously read this from a hardcoded handler stub.
CREATE TABLE IF NOT EXISTS regulatory_compliance (
    id                    SMALLINT     PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    accreditation_status  TEXT         NOT NULL DEFAULT 'pending',
    accreditation_expiry  DATE,
    compliance_rate       NUMERIC(5,2),
    violations_open       INTEGER      NOT NULL DEFAULT 0,
    violations_resolved   INTEGER      NOT NULL DEFAULT 0,
    last_audit_at         TIMESTAMPTZ,
    notes                 TEXT,
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by            UUID         REFERENCES users(id) ON DELETE SET NULL
);

-- Guarantee the singleton row exists so SELECT never misses.
INSERT INTO regulatory_compliance (id, accreditation_status)
VALUES (1, 'pending')
ON CONFLICT (id) DO NOTHING;
