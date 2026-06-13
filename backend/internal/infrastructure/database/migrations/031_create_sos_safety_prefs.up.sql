-- Per-user SOS live-location opt-in. Enforces the privacy invariant
-- server-side: a participant who has not explicitly opted in cannot stream
-- GPS coordinates during an open incident. Opt-in defaults to FALSE so the
-- system fails closed — absence of a row means "no consent".
CREATE TABLE sos_safety_prefs (
    user_id              UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    live_location_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
