-- Driver KYC review queue. Each submission collects 1+ driver_documents and
-- carries a single review decision. Previously stubbed with mock rows in
-- safety_repo.go.
CREATE TABLE IF NOT EXISTS kyc_submissions (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id         UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status            TEXT        NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'needs_more_info')),
    submitted_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at       TIMESTAMPTZ,
    reviewed_by       UUID        REFERENCES users(id) ON DELETE SET NULL,
    rejection_reason  TEXT,
    notes             TEXT
);

CREATE INDEX IF NOT EXISTS idx_kyc_submissions_status_time
    ON kyc_submissions (status, submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_kyc_submissions_driver
    ON kyc_submissions (driver_id);

-- Bind each uploaded document to its submission. Existing docs get a NULL
-- submission until drivers re-submit.
ALTER TABLE driver_documents
    ADD COLUMN IF NOT EXISTS submission_id UUID REFERENCES kyc_submissions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_driver_documents_submission
    ON driver_documents (submission_id);
