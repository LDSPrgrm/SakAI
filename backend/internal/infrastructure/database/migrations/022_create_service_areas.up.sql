-- 022_create_service_areas.up.sql
-- Per-LGU service coverage polygons + partnership tracking. Backs GET
-- /service-area (public discovery) and /admin/lgu-partnerships CRUD.
--
-- service_areas.boundary follows the same {name, multiplier, polygon} shape
-- used by surge_configs.zones so the SurgeZoneEditor drawer can be reused
-- for boundary editing. multiplier is unused here (polygon only) but the
-- shape is kept consistent to avoid a second editor component.

CREATE TABLE IF NOT EXISTS service_areas (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL,
    lgu_code    TEXT,
    boundary    JSONB       NOT NULL,  -- {name, polygon: [[lat,lng]...]}
    active      BOOLEAN     NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_service_areas_active
    ON service_areas (active)
    WHERE active = true;

CREATE TABLE IF NOT EXISTS lgu_partnerships (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    service_area_id   UUID        REFERENCES service_areas(id) ON DELETE SET NULL,
    lgu_name          TEXT        NOT NULL,
    contact_name      TEXT,
    contact_email     TEXT,
    contact_phone     TEXT,
    agreement_start   DATE,
    agreement_end     DATE,
    status            TEXT        NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('active','pending','expired','terminated')),
    notes             TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lgu_partnerships_status
    ON lgu_partnerships (status);
