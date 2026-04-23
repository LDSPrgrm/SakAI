-- 021_create_incident_status_history.up.sql
-- Append-only audit trail of incident status transitions plus an assign-change
-- row so the SOS timeline in SASafetyCompliance can render the full chain.
-- A DB trigger captures status + assigned_to changes automatically so code
-- paths that forget to call the use case still leave a breadcrumb.

CREATE TABLE IF NOT EXISTS incident_status_history (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id  UUID        NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    from_status  TEXT,
    to_status    TEXT        NOT NULL,
    from_assignee UUID       REFERENCES users(id) ON DELETE SET NULL,
    to_assignee   UUID       REFERENCES users(id) ON DELETE SET NULL,
    actor_id      UUID       REFERENCES users(id) ON DELETE SET NULL,
    note          TEXT,
    occurred_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_incident_history_incident
    ON incident_status_history (incident_id, occurred_at);

-- Trigger: on insert, record the initial 'open' row so the timeline has a
-- starting point. On update, record any status or assignee change.
CREATE OR REPLACE FUNCTION trg_incident_status_history() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO incident_status_history
            (incident_id, from_status, to_status, to_assignee, actor_id, occurred_at)
        VALUES
            (NEW.id, NULL, NEW.status, NEW.assigned_to, NULL, NEW.created_at);
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.status IS DISTINCT FROM OLD.status
            OR NEW.assigned_to IS DISTINCT FROM OLD.assigned_to THEN
            INSERT INTO incident_status_history
                (incident_id, from_status, to_status,
                 from_assignee, to_assignee, actor_id,
                 note, occurred_at)
            VALUES
                (NEW.id, OLD.status, NEW.status,
                 OLD.assigned_to, NEW.assigned_to, NULL,
                 NULLIF(NEW.resolution_notes, OLD.resolution_notes),
                 NOW());
        END IF;
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS incident_status_history_trg ON incidents;
CREATE TRIGGER incident_status_history_trg
    AFTER INSERT OR UPDATE ON incidents
    FOR EACH ROW EXECUTE FUNCTION trg_incident_status_history();

-- Backfill one row per existing incident so pre-trigger rows still render.
INSERT INTO incident_status_history
    (incident_id, from_status, to_status, to_assignee, occurred_at)
SELECT i.id, NULL, i.status, i.assigned_to, i.created_at
FROM incidents i
WHERE NOT EXISTS (
    SELECT 1 FROM incident_status_history h WHERE h.incident_id = i.id
);
