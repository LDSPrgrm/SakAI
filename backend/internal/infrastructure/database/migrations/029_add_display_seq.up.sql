-- 029_add_display_seq.up.sql
-- Add a Postgres-assigned sequential number to entities that need a
-- human-readable display reference (e.g. INC-0042, RIDE-000123). The
-- formatted string is composed in the Go layer; the DB only owns the
-- monotonic counter.

ALTER TABLE incidents
    ADD COLUMN IF NOT EXISTS seq BIGSERIAL;

ALTER TABLE rides
    ADD COLUMN IF NOT EXISTS seq BIGSERIAL;

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS seq BIGSERIAL;

ALTER TABLE ride_payments
    ADD COLUMN IF NOT EXISTS seq BIGSERIAL;

ALTER TABLE audit_log_entries
    ADD COLUMN IF NOT EXISTS seq BIGSERIAL;

-- BIGSERIAL implicitly creates a sequence and a NOT NULL DEFAULT, but
-- does NOT add a UNIQUE constraint. Add one explicitly so duplicates are
-- caught at insert time.
ALTER TABLE incidents          ADD CONSTRAINT incidents_seq_key          UNIQUE (seq);
ALTER TABLE rides              ADD CONSTRAINT rides_seq_key              UNIQUE (seq);
ALTER TABLE users              ADD CONSTRAINT users_seq_key              UNIQUE (seq);
ALTER TABLE ride_payments      ADD CONSTRAINT ride_payments_seq_key      UNIQUE (seq);
ALTER TABLE audit_log_entries  ADD CONSTRAINT audit_log_entries_seq_key  UNIQUE (seq);
