import type { FareConfig } from '@/types/super-admin';

export type VehicleType = 'motorcycle' | 'tricycle' | 'car';

// PH-context fare defaults. Mirrors src/mocks/admin/fares.ts so mock data
// and new-config fallbacks stay aligned.
export const DEFAULT_FARE_BY_VEHICLE: Record<VehicleType, FareConfig> = {
  motorcycle: {
    vehicle_type: 'motorcycle',
    base_fare: 50,
    per_km_rate: 10,
    per_min_rate: 2,
    minimum_fare: 50,
    booking_fee: 10,
    cancellation_fee: 25,
  },
  tricycle: {
    vehicle_type: 'tricycle',
    base_fare: 40,
    per_km_rate: 8,
    per_min_rate: 1.5,
    minimum_fare: 40,
    booking_fee: 8,
    cancellation_fee: 20,
  },
  car: {
    vehicle_type: 'car',
    base_fare: 80,
    per_km_rate: 15,
    per_min_rate: 3,
    minimum_fare: 80,
    booking_fee: 15,
    cancellation_fee: 40,
  },
};
