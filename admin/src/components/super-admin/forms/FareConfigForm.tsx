// Base fare settings form — spec superadmin.md §4.4 Fare Configuration
// One row per vehicle type with all configurable parameters.
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import type { FareConfig } from '@/types/super-admin';
import { DEFAULT_FARE_BY_VEHICLE, type VehicleType } from '@/constants/fareDefaults';

const fareSchema = z.object({
  vehicle_type:      z.enum(['motorcycle', 'tricycle', 'car']),
  base_fare:         z.number().min(0),
  per_km_rate:       z.number().min(0),
  per_min_rate:      z.number().min(0),
  minimum_fare:      z.number().min(0),
  booking_fee:       z.number().min(0),
  cancellation_fee:  z.number().min(0),
});
type FareFormValues = z.infer<typeof fareSchema>;

interface FareConfigFormProps {
  defaultValues: Partial<FareConfig>;
  loading?: boolean;
  onSubmit: (data: FareFormValues) => void;
  onCancel: () => void;
}

const FIELDS: { key: keyof FareFormValues; label: string }[] = [
  { key: 'base_fare',        label: 'Base Fare (₱)' },
  { key: 'per_km_rate',      label: 'Per-KM Rate (₱/km)' },
  { key: 'per_min_rate',     label: 'Per-Minute Rate (₱/min)' },
  { key: 'minimum_fare',     label: 'Minimum Fare (₱)' },
  { key: 'booking_fee',      label: 'Booking Fee (₱)' },
  { key: 'cancellation_fee', label: 'Cancellation Fee (₱)' },
];

export function FareConfigForm({ defaultValues, loading, onSubmit, onCancel }: FareConfigFormProps) {
  const vehicleType = (defaultValues.vehicle_type as VehicleType) ?? 'motorcycle';
  const d = DEFAULT_FARE_BY_VEHICLE[vehicleType];
  const { register, handleSubmit, formState: { errors } } = useForm<FareFormValues>({
    resolver: zodResolver(fareSchema),
    defaultValues: {
      vehicle_type:     vehicleType,
      base_fare:        defaultValues.base_fare        ?? d.base_fare,
      per_km_rate:      defaultValues.per_km_rate      ?? d.per_km_rate,
      per_min_rate:     defaultValues.per_min_rate     ?? d.per_min_rate,
      minimum_fare:     defaultValues.minimum_fare     ?? d.minimum_fare,
      booking_fee:      defaultValues.booking_fee      ?? d.booking_fee,
      cancellation_fee: defaultValues.cancellation_fee ?? d.cancellation_fee,
    },
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div>
        <label className="text-xs font-medium text-text-muted block mb-1">Vehicle Type</label>
        <select {...register('vehicle_type')} className={inputCls}>
          <option value="motorcycle">Motorcycle</option>
          <option value="tricycle">Tricycle</option>
          <option value="car">Car (4-seater)</option>
        </select>
      </div>

      <div className="grid grid-cols-2 gap-4">
        {FIELDS.map(({ key, label }) => (
          <div key={key}>
            <label className="text-xs font-medium text-text-muted block mb-1">{label}</label>
            <input {...register(key, { valueAsNumber: true })} type="number" step="0.01" className={inputCls} />
            {errors[key] && <p className="text-xs text-danger mt-1">{errors[key]?.message}</p>}
          </div>
        ))}
      </div>

      <div className="flex justify-end gap-3">
        <button type="button" onClick={onCancel} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">
          Cancel
        </button>
        <button type="submit" disabled={loading} className="px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
          {loading ? 'Saving…' : 'Save'}
        </button>
      </div>
    </form>
  );
}

const inputCls = 'bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary';
