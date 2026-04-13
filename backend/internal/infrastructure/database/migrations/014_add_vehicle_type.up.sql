ALTER TABLE vehicles
  ADD COLUMN vehicle_type TEXT NOT NULL DEFAULT 'car' CHECK (vehicle_type IN ('motorcycle', 'car', 'tricycle'));
