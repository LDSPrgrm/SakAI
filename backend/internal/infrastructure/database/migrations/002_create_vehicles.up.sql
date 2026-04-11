-- 002_create_vehicles.sql
-- Vehicle details for driver users (1:1 relationship).
-- Kept separate from users to cleanly model drivers without polluting
-- the core identity table with driver-specific fields.

CREATE TABLE IF NOT EXISTS vehicles (
    user_id UUID  PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    make    TEXT  NOT NULL,
    model   TEXT  NOT NULL,
    color   TEXT  NOT NULL,
    plate   TEXT  NOT NULL
);
