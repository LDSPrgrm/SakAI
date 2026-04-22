DROP INDEX IF EXISTS idx_driver_documents_submission;
ALTER TABLE driver_documents DROP COLUMN IF EXISTS submission_id;

DROP INDEX IF EXISTS idx_kyc_submissions_driver;
DROP INDEX IF EXISTS idx_kyc_submissions_status_time;
DROP TABLE IF EXISTS kyc_submissions;
