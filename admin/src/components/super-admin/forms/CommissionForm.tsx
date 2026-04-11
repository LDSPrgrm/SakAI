// Platform commission rate form — spec superadmin.md §4.5 Commission Settings
// Finance can propose; super_admin must approve.
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  motorcycle:           z.number().min(0).max(100),
  tricycle:             z.number().min(0).max(100),
  car:                  z.number().min(0).max(100),
  minimum_commission:   z.number().min(0),
  promotional_override: z.number().min(0).max(100).optional(),
});
type CommissionFormValues = z.infer<typeof schema>;

interface CommissionFormProps {
  defaultValues?: Partial<CommissionFormValues>;
  /** Finance can only propose; super_admin can directly save */
  isProposeOnly?: boolean;
  loading?: boolean;
  onSubmit: (data: CommissionFormValues) => void;
}

export function CommissionForm({ defaultValues, isProposeOnly, loading, onSubmit }: CommissionFormProps) {
  const { register, handleSubmit, formState: { errors } } = useForm<CommissionFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      motorcycle:           defaultValues?.motorcycle           ?? 15,
      tricycle:             defaultValues?.tricycle             ?? 12,
      car:                  defaultValues?.car                  ?? 18,
      minimum_commission:   defaultValues?.minimum_commission   ?? 20,
      promotional_override: defaultValues?.promotional_override,
    },
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="grid grid-cols-3 gap-4">
        {(['motorcycle', 'tricycle', 'car'] as const).map((vt) => (
          <div key={vt}>
            <label className="text-xs font-medium text-text-muted block mb-1 capitalize">{vt} Commission (%)</label>
            <input {...register(vt, { valueAsNumber: true })} type="number" step="0.5" min="0" max="100" className={inputCls} />
            {errors[vt] && <p className="text-xs text-danger mt-1">{errors[vt]?.message}</p>}
          </div>
        ))}
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="text-xs font-medium text-text-muted block mb-1">Minimum Commission (₱)</label>
          <input {...register('minimum_commission', { valueAsNumber: true })} type="number" step="1" min="0" className={inputCls} />
        </div>
        <div>
          <label className="text-xs font-medium text-text-muted block mb-1">Promotional Override (%) <span className="text-text-muted font-normal">optional</span></label>
          <input {...register('promotional_override', { valueAsNumber: true })} type="number" step="0.5" min="0" max="100" placeholder="e.g. 0 for promo period" className={inputCls} />
        </div>
      </div>

      <button type="submit" disabled={loading} className="self-end px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
        {loading ? 'Submitting…' : isProposeOnly ? 'Propose Changes' : 'Save Changes'}
      </button>
    </form>
  );
}

const inputCls = 'bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary';
