import React, { useState } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { formatPHP } from '@/lib/utils';
import type { FareConfig } from '@/types/super-admin';

type VehicleType = 'motorcycle' | 'tricycle' | 'car';

const schema = z.object({
  distance: z.number().positive('Enter a valid distance.'),
  time: z.number().min(0, 'Time cannot be negative.'),
  vehicle: z.enum(['motorcycle', 'tricycle', 'car']),
});

type SimulatorValues = z.infer<typeof schema>;

export interface FareSimulatorFormProps {
  /** Local fare configs keyed by vehicle type — used for the fallback calculation. */
  configs: Record<VehicleType, FareConfig>;
  /** API-backed simulator; returns the total fare. Falls back to local calc on error. */
  simulate: (args: {
    vehicle: VehicleType;
    origin: { lat: number; lng: number };
    destination: { lat: number; lng: number };
  }) => Promise<number>;
}

export function FareSimulatorForm({ configs, simulate }: FareSimulatorFormProps) {
  const { control, handleSubmit, watch, formState: { errors } } = useForm<SimulatorValues>({
    resolver: zodResolver(schema),
    defaultValues: { distance: 0, time: 0, vehicle: 'motorcycle' },
  });

  const [result, setResult] = useState<number | null>(null);
  const [computedFor, setComputedFor] = useState<SimulatorValues | null>(null);

  async function onSubmit(values: SimulatorValues) {
    setResult(null);
    setComputedFor(null);
    try {
      const fare = await simulate({
        vehicle: values.vehicle,
        origin: { lat: 14.5995, lng: 120.9842 },
        destination: { lat: 14.5995 + values.distance * 0.01, lng: 120.9842 },
      });
      setResult(fare);
    } catch {
      const cfg = configs[values.vehicle];
      const fare = Math.max(
        cfg.minimum_fare ?? 0,
        (cfg.base_fare ?? 0) + values.distance * (cfg.per_km_rate ?? 0) + values.time * (cfg.per_min_rate ?? 0),
      );
      setResult(fare);
    }
    setComputedFor(values);
  }

  const currentVehicle = watch('vehicle');

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-3">
      <Controller
        name="distance"
        control={control}
        render={({ field }) => (
          <Input
            placeholder="Distance (km)"
            type="number"
            min={0}
            value={field.value || ''}
            onChange={(e) => field.onChange(e.target.value === '' ? 0 : parseFloat(e.target.value))}
            className={errors.distance ? 'border-danger' : ''}
          />
        )}
      />
      {errors.distance && <p className="text-xs text-danger">{errors.distance.message}</p>}

      <Controller
        name="time"
        control={control}
        render={({ field }) => (
          <Input
            placeholder="Estimated Time (mins)"
            type="number"
            min={0}
            value={field.value || ''}
            onChange={(e) => field.onChange(e.target.value === '' ? 0 : parseFloat(e.target.value))}
            className={errors.time ? 'border-danger' : ''}
          />
        )}
      />
      {errors.time && <p className="text-xs text-danger">{errors.time.message}</p>}

      <Controller
        name="vehicle"
        control={control}
        render={({ field }) => (
          <select
            {...field}
            aria-label="Vehicle type"
            className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="motorcycle">Motorcycle</option>
            <option value="tricycle">Tricycle</option>
            <option value="car">Car (4-seater)</option>
          </select>
        )}
      />

      <Button type="submit" className="w-full">Calculate Estimate</Button>

      <div className="mt-4 p-3 bg-surface-hover rounded-lg border border-border text-center">
        <p className="text-xs text-text-muted">Estimated Fare</p>
        <p className="text-2xl font-bold text-text-main">
          {result !== null ? formatPHP(result) : '—'}
        </p>
        {result !== null && computedFor && (
          <p className="text-xs text-text-muted mt-1">
            Base {formatPHP(configs[currentVehicle].base_fare)} + {computedFor.distance}km + {computedFor.time}min
          </p>
        )}
      </div>
    </form>
  );
}
