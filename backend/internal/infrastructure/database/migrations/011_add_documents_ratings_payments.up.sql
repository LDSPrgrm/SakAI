-- 011_add_documents_ratings_payments.sql
-- Adds tables for driver document verification, ride ratings, and ride payment processing.

-- ─── Driver Documents ────────────────────────────────────────────────────────

CREATE TYPE document_type AS ENUM ('license', 'registration', 'insurance');
CREATE TYPE upload_status AS ENUM ('uploaded', 'under_review', 'approved', 'rejected');

CREATE TABLE IF NOT EXISTS driver_documents (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id           UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type       document_type   NOT NULL,
    document_number     VARCHAR(50)     NOT NULL,
    image_url           TEXT            NOT NULL,
    expiry_date         DATE,
    upload_status       upload_status   NOT NULL DEFAULT 'uploaded',
    rejection_reason    VARCHAR(500),
    uploaded_at         TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    reviewed_at         TIMESTAMPTZ,
    reviewed_by         UUID            REFERENCES users(id)
);

-- Fast lookup of documents by driver.
CREATE INDEX IF NOT EXISTS idx_documents_driver
    ON driver_documents (driver_id, upload_status);

-- Prevent duplicate document types per driver (only one active per type).
CREATE UNIQUE INDEX IF NOT EXISTS idx_documents_driver_type_unique
    ON driver_documents (driver_id, document_type)
    WHERE upload_status NOT IN ('rejected');

-- ─── Ratings ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS ratings (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id             UUID        NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    rater_id            UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ratee_id            UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stars               INTEGER     NOT NULL CHECK (stars BETWEEN 1 AND 5),
    feedback            VARCHAR(500),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enforce: one rating per user per ride.
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_ride_rater_unique
    ON ratings (ride_id, rater_id);

-- Fast average rating computation by user.
CREATE INDEX IF NOT EXISTS idx_ratings_ratee
    ON ratings (ratee_id);

-- ─── Ride Payments ───────────────────────────────────────────────────────────

CREATE TYPE payment_method AS ENUM ('cash', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

CREATE TABLE IF NOT EXISTS ride_payments (
    id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id                 UUID            NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    amount                  NUMERIC(10, 2)  NOT NULL CHECK (amount >= 0),
    currency                CHAR(3)         NOT NULL DEFAULT 'USD',
    method                  payment_method  NOT NULL,
    status                  payment_status  NOT NULL DEFAULT 'pending',
    gateway_transaction_id  VARCHAR(100),
    gateway_response        TEXT,
    processed_at            TIMESTAMPTZ,
    failure_reason          VARCHAR(500),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- One payment per ride.
CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_ride_unique
    ON ride_payments (ride_id);

-- Fast receipt lookup by ride.
CREATE INDEX IF NOT EXISTS idx_payments_ride
    ON ride_payments (ride_id, status);
