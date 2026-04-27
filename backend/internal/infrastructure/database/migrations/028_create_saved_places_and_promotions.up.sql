CREATE TABLE IF NOT EXISTS saved_places (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_saved_places_user_id ON saved_places(user_id);

CREATE TABLE IF NOT EXISTS promotions (
    id UUID PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    discount_value DOUBLE PRECISION NOT NULL,
    discount_type TEXT NOT NULL,
    max_discount DOUBLE PRECISION,
    min_ride_amount DOUBLE PRECISION,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    terms TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_promotions_code ON promotions(code);
