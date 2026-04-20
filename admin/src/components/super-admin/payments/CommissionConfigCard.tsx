import React, { useEffect, useRef } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import type { CommissionConfig } from '@/api/super-admin/payments';

const schema = z.object({
  rates: z.object({
    motorcycle: z.number().min(0).max(100),
    tricycle: z.number().min(0).max(100),
    car: z.number().min(0).max(100),
    other: z.number().min(0).max(100),
  }),
  minimum_commission: z.number().min(0),
  promotional_override: z.number().min(0).max(100),
});

type Values = z.infer<typeof schema>;

const DEFAULTS: Values = {
  rates: { motorcycle: 0, tricycle: 0, car: 0, other: 0 },
  minimum_commission: 0,
  promotional_override: 0,
};

export interface CommissionConfigCardProps {
  config: CommissionConfig | null | undefined;
  onSave: (values: Values) => Promise<void> | void;
  saving: boolean;
}

export function CommissionConfigCard({ config, onSave, saving }: CommissionConfigCardProps) {
  const { control, handleSubmit, reset } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: DEFAULTS,
  });

  // Seed form once when server data first arrives. Subsequent refetches (window
  // focus, polling) must NOT clobber user edits in progress — only a successful
  // save or a remount should reset the form.
  const seeded = useRef(false);
  useEffect(() => {
    if (seeded.current || !config) return;
    seeded.current = true;
    reset({
      ...DEFAULTS,
      ...config,
      rates: { ...DEFAULTS.rates, ...(config.rates ?? {}) },
    } as Values);
  }, [config, reset]);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Commission Settings</CardTitle>
      </CardHeader>
      <CardContent>
        {!config ? (
          <div className="text-sm text-text-muted text-center py-6">Loading config...</div>
        ) : (
          <form onSubmit={handleSubmit(onSave)} className="space-y-4">
            <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
              <h4 className="text-sm font-semibold text-text-main">Platform Commission Rate</h4>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {(['motorcycle', 'tricycle', 'other'] as const).map((key) => (
                  <Controller
                    key={key}
                    name={`rates.${key}` as const}
                    control={control}
                    render={({ field }) => (
                      <div>
                        <label className="block text-xs text-text-muted mb-1 capitalize">{key} (%)</label>
                        <Input
                          type="number"
                          value={field.value}
                          onChange={(e) => field.onChange(Number(e.target.value))}
                        />
                      </div>
                    )}
                  />
                ))}
              </div>
            </div>

            <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
              <h4 className="text-sm font-semibold text-text-main">Pricing Floors & Promos</h4>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <Controller
                  name="minimum_commission"
                  control={control}
                  render={({ field }) => (
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Minimum Commission (₱)</label>
                      <Input
                        type="number"
                        value={field.value}
                        onChange={(e) => field.onChange(Number(e.target.value))}
                      />
                    </div>
                  )}
                />
                <Controller
                  name="promotional_override"
                  control={control}
                  render={({ field }) => (
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Promotional Override (%)</label>
                      <Input
                        type="number"
                        value={field.value}
                        onChange={(e) => field.onChange(Number(e.target.value))}
                      />
                    </div>
                  )}
                />
              </div>
            </div>

            <div className="flex justify-end pt-2">
              <Button type="submit" variant="primary" disabled={saving}>
                {saving ? 'Saving...' : 'Save Commission Settings'}
              </Button>
            </div>
          </form>
        )}
      </CardContent>
    </Card>
  );
}
