-- 011_add_documents_ratings_payments.sql (down)

DROP INDEX IF EXISTS idx_payments_ride;
DROP UNIQUE INDEX IF EXISTS idx_payments_ride_unique;
DROP TABLE IF EXISTS ride_payments;

DROP INDEX IF EXISTS idx_ratings_ratee;
DROP UNIQUE INDEX IF EXISTS idx_ratings_ride_rater_unique;
DROP TABLE IF EXISTS ratings;

DROP INDEX IF EXISTS idx_documents_driver_type_unique;
DROP INDEX IF EXISTS idx_documents_driver;
DROP TABLE IF EXISTS driver_documents;

DROP TYPE IF EXISTS payment_status;
DROP TYPE IF EXISTS payment_method;
DROP TYPE IF EXISTS upload_status;
DROP TYPE IF EXISTS document_type;
