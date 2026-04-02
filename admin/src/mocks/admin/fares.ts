import { FareConfig, SurgeConfig } from '@/lib/admin-api';

export const fareConfigs: FareConfig[] = [
  {
    id: 'fare-moto-001',
    vehicle_type: 'motorcycle',
    base_fare: 50,
    per_km_rate: 10,
    per_min_rate: 2,
    minimum_fare: 50,
    booking_fee: 10,
    cancellation_fee: 25,
    updated_by: 'Eduardo Reyes',
    updated_at: '2026-03-15T10:00:00Z',
  },
  {
    id: 'fare-tric-001',
    vehicle_type: 'tricycle',
    base_fare: 40,
    per_km_rate: 8,
    per_min_rate: 1.5,
    minimum_fare: 40,
    booking_fee: 8,
    cancellation_fee: 20,
    updated_by: 'Eduardo Reyes',
    updated_at: '2026-03-15T10:00:00Z',
  },
  {
    id: 'fare-car-001',
    vehicle_type: 'car',
    base_fare: 80,
    per_km_rate: 15,
    per_min_rate: 3,
    minimum_fare: 80,
    booking_fee: 15,
    cancellation_fee: 40,
    updated_by: 'Eduardo Reyes',
    updated_at: '2026-03-15T10:00:00Z',
  },
];

export const surgeConfig: SurgeConfig = {
  id: 'surge-001',
  enabled: true,
  max_multiplier: 2.5,
  trigger_ratio: 1.5,
  blackout_hours: [
    { day: 0, start: '00:00', end: '05:00' },
    { day: 6, start: '23:00', end: '23:59' },
  ],
};
