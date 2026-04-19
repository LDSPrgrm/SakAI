// Surge pricing controls form — spec superadmin.md §4.4 Surge Pricing Controls
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import type { SurgeConfig } from '@/types/super-admin';

const surgeSchema = z.object({
  enabled:       z.boolean(),
  max_multiplier: z.number().min(1.0).max(10.0),
  trigger_ratio:  z.number().min(0.1).max(100),
});
type SurgeFormValues = z.infer<typeof surgeSchema>;

interface SurgeConfigFormProps {
  defaultValues: Partial<SurgeConfig>;
  loading?: boolean;
  onSubmit: (data: SurgeFormValues) => void;
}

export function SurgeConfigForm({ defaultValues, loading, onSubmit }: SurgeConfigFormProps) {
  const { register, handleSubmit, watch, formState: { errors } } = useForm<SurgeFormValues>({
    resolver: zodResolver(surgeSchema),
    defaultValues: {
      enabled:        defaultValues.enabled        ?? false,
      max_multiplier: defaultValues.max_multiplier ?? 3.0,
      trigger_ratio:  defaultValues.trigger_ratio  ?? 2.0,
    },
  });

  const enabled = watch('enabled');

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <label className="flex items-center gap-3 cursor-pointer">
        <input {...register('enabled')} type="checkbox" className="w-4 h-4 accent-primary" />
        <span className="text-sm font-medium text-text-main">Enable Surge Pricing</span>
      </label>

      <div className={enabled ? 'grid grid-cols-2 gap-4' : 'grid grid-cols-2 gap-4 opacity-40 pointer-events-none'}>
        <div>
          <label className="text-xs font-medium text-text-muted block mb-1">Max Multiplier (×)</label>
          <input {...register('max_multiplier', { valueAsNumber: true })} type="number" step="0.1" min="1" max="10" className={inputCls} />
          {errors.max_multiplier && <p className="text-xs text-danger mt-1">{errors.max_multiplier.message}</p>}
        </div>
        <div>
          <label className="text-xs font-medium text-text-muted block mb-1">Trigger Demand/Supply Ratio</label>
          <input {...register('trigger_ratio', { valueAsNumber: true })} type="number" step="0.1" min="0.1" className={inputCls} />
          {errors.trigger_ratio && <p className="text-xs text-danger mt-1">{errors.trigger_ratio.message}</p>}
        </div>
      </div>

      <button type="submit" disabled={loading} className="self-end px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
        {loading ? 'Saving…' : 'Save Surge Config'}
      </button>
    </form>
  );
}

const inputCls = 'bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary';
