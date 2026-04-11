// Payment gateway / integration config form — spec superadmin.md §4.5 Payment Gateway Configuration
// API keys are masked (last 4 chars shown) per spec.
import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Eye, EyeOff } from 'lucide-react';
import { maskApiKey } from '@/utils/maskApiKey';

interface FieldDef {
  key: string;
  label: string;
  placeholder?: string;
  isSensitive?: boolean;
}

interface IntegrationConfigFormProps {
  service: string;
  fields:  FieldDef[];
  current?: Record<string, string>;
  loading?: boolean;
  onSubmit: (data: Record<string, string>) => void;
  onCancel: () => void;
}

export function IntegrationConfigForm({ service, fields, current, loading, onSubmit, onCancel }: IntegrationConfigFormProps) {
  const [revealed, setRevealed] = useState<Record<string, boolean>>({});
  const { register, handleSubmit } = useForm<Record<string, string>>({
    defaultValues: Object.fromEntries(
      fields.map((f) => [f.key, current?.[f.key] ?? '']),
    ),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <p className="text-sm font-semibold text-text-main capitalize">{service.replace(/_/g, ' ')} Configuration</p>
      {fields.map((field) => {
        const isRevealed = revealed[field.key];
        return (
          <div key={field.key}>
            <label className="text-xs font-medium text-text-muted block mb-1">{field.label}</label>
            <div className="relative flex items-center">
              <input
                {...register(field.key)}
                type={field.isSensitive && !isRevealed ? 'password' : 'text'}
                placeholder={field.placeholder ?? (field.isSensitive ? maskApiKey(current?.[field.key] ?? '') : '')}
                className="bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary pr-10"
              />
              {field.isSensitive && (
                <button
                  type="button"
                  onClick={() => setRevealed((r) => ({ ...r, [field.key]: !r[field.key] }))}
                  className="absolute right-2 text-text-muted hover:text-text-main"
                >
                  {isRevealed ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              )}
            </div>
          </div>
        );
      })}
      <div className="flex justify-end gap-3">
        <button type="button" onClick={onCancel} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">Cancel</button>
        <button type="submit" disabled={loading} className="px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
          {loading ? 'Saving…' : 'Save Config'}
        </button>
      </div>
    </form>
  );
}
