ALTER TABLE audit_log_entries  DROP CONSTRAINT IF EXISTS audit_log_entries_seq_key;
ALTER TABLE ride_payments      DROP CONSTRAINT IF EXISTS ride_payments_seq_key;
ALTER TABLE users              DROP CONSTRAINT IF EXISTS users_seq_key;
ALTER TABLE rides              DROP CONSTRAINT IF EXISTS rides_seq_key;
ALTER TABLE incidents          DROP CONSTRAINT IF EXISTS incidents_seq_key;

ALTER TABLE audit_log_entries  DROP COLUMN IF EXISTS seq;
ALTER TABLE ride_payments      DROP COLUMN IF EXISTS seq;
ALTER TABLE users              DROP COLUMN IF EXISTS seq;
ALTER TABLE rides              DROP COLUMN IF EXISTS seq;
ALTER TABLE incidents          DROP COLUMN IF EXISTS seq;

DROP SEQUENCE IF EXISTS incidents_seq_seq;
DROP SEQUENCE IF EXISTS rides_seq_seq;
DROP SEQUENCE IF EXISTS users_seq_seq;
DROP SEQUENCE IF EXISTS ride_payments_seq_seq;
DROP SEQUENCE IF EXISTS audit_log_entries_seq_seq;
