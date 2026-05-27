// Reusable create/edit form for admin accounts.
// Used by SAAdminManagement (super-admin page) and Settings → Admins tab.
import React, { useEffect, useState } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import {
  AlertCircle,
  Check,
  ChevronDown,
  Copy,
  RefreshCw,
  Save,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { generatePassword } from '@/utils/generatePassword';
import { cn } from '@/lib/utils';
import type { AdminRoleDefinition } from '@/types/super-admin';
import { adminSchema, type AdminFormValues } from './adminForm.schema';

export type { AdminFormValues } from './adminForm.schema';

export interface AdminFormProps {
  mode: 'add' | 'edit';
  initial?: Partial<AdminFormValues>;
  roleDefinitions: AdminRoleDefinition[];
  apiError?: string | null;
  onSubmit: (values: AdminFormValues) => Promise<void> | void;
  onCancel: () => void;
}

const ROLE_LABELS: Record<string, string> = {
  admin: 'Admin',
  superadmin: 'Super Admin',
  operations: 'Operations',
  finance: 'Finance',
  support: 'Support',
};

function roleLabel(role: string): string {
  return ROLE_LABELS[role] ?? role.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

const EMPTY: AdminFormValues = {
  name: '',
  email: '',
  role: 'support',
  status: 'active',
  password: '',
};

const fieldLabel = 'block text-xs font-semibold uppercase tracking-wide text-text-muted mb-1.5';
const selectClass = cn(
  'w-full appearance-none bg-background border border-border rounded-lg px-3 py-2 pr-9 text-sm text-text-main',
  'focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary/40 transition-colors',
);

export function AdminForm({
  mode,
  initial,
  roleDefinitions,
  apiError,
  onSubmit,
  onCancel,
}: AdminFormProps) {
  const {
    register,
    handleSubmit,
    control,
    reset,
    setValue,
    getValues,
    formState: { errors, isSubmitting, isDirty },
  } = useForm<AdminFormValues>({
    resolver: zodResolver(adminSchema),
    defaultValues: { ...EMPTY, ...initial },
  });

  const [pwCopied, setPwCopied] = useState(false);

  useEffect(() => {
    reset({ ...EMPTY, ...initial });
  }, [initial, reset]);

  function regeneratePassword() {
    setValue('password', generatePassword(), { shouldDirty: true, shouldValidate: true });
  }

  async function copyPassword() {
    const pw = getValues('password');
    if (!pw) return;
    try {
      await navigator.clipboard.writeText(pw);
      setPwCopied(true);
      setTimeout(() => setPwCopied(false), 1500);
    } catch {
      // ignore — secure context not available
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="px-6 py-5 space-y-5" noValidate>
      {apiError && (
        <div className="bg-danger/10 border border-danger/30 rounded-lg p-3 flex items-start gap-2">
          <AlertCircle className="w-4 h-4 text-danger mt-0.5 flex-shrink-0" />
          <p className="text-sm text-danger leading-relaxed">{apiError}</p>
        </div>
      )}

      <div>
        <label className={fieldLabel}>Full Name</label>
        <Input
          {...register('name')}
          placeholder="e.g. Maria Santos"
          className={errors.name ? 'border-danger focus:ring-danger' : ''}
        />
        {errors.name && <p className="text-xs text-danger mt-1">{errors.name.message}</p>}
      </div>

      <div>
        <label className={fieldLabel}>Email Address</label>
        <Input
          {...register('email')}
          type="email"
          placeholder="e.g. maria@sakai.ph"
          className={errors.email ? 'border-danger focus:ring-danger' : ''}
        />
        {errors.email && <p className="text-xs text-danger mt-1">{errors.email.message}</p>}
      </div>

      {mode === 'add' && (
        <div>
          <div className="flex items-center justify-between mb-1.5">
            <label className={cn(fieldLabel, 'mb-0')}>Temporary Password</label>
            <button
              type="button"
              onClick={regeneratePassword}
              className="inline-flex items-center gap-1 text-xs text-primary hover:text-primary-hover transition-colors"
            >
              <RefreshCw className="w-3.5 h-3.5" />
              Regenerate
            </button>
          </div>

          <div className="relative">
            <Input
              {...register('password')}
              type="text"
              placeholder="Auto-generated — share securely"
              className={cn(
                'pr-10 font-mono',
                errors.password ? 'border-danger focus:ring-danger' : '',
              )}
            />
            <button
              type="button"
              onClick={copyPassword}
              aria-label="Copy password"
              title="Copy password"
              className={cn(
                'absolute inset-y-0 right-0 px-3 flex items-center transition-colors',
                pwCopied ? 'text-success' : 'text-text-muted hover:text-text-main',
              )}
            >
              {pwCopied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
            </button>
          </div>
          {errors.password && (
            <p className="text-xs text-danger mt-1">{errors.password.message}</p>
          )}
        </div>
      )}

      <div>
        <label className={fieldLabel}>Role</label>
        <Controller
          name="role"
          control={control}
          render={({ field }) => (
            <div className="relative">
              <select {...field} className={selectClass}>
                {roleDefinitions.length > 0 ? (
                  roleDefinitions.map((r) => (
                    <option key={r.id} value={r.name}>
                      {roleLabel(r.name)}
                    </option>
                  ))
                ) : (
                  <>
                    <option value="admin">Admin</option>
                    <option value="superadmin">Super Admin</option>
                    <option value="operations">Operations</option>
                    <option value="finance">Finance</option>
                    <option value="support">Support</option>
                  </>
                )}
              </select>
              <ChevronDown className="w-4 h-4 text-text-muted absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none" />
            </div>
          )}
        />
        {errors.role && <p className="text-xs text-danger mt-1">{errors.role.message}</p>}
      </div>

      <div>
        <label className={fieldLabel}>Status</label>
        <Controller
          name="status"
          control={control}
          render={({ field }) => (
            <div className="relative">
              <select {...field} className={selectClass}>
                <option value="active">Active</option>
                <option value="suspended">Suspended</option>
                <option value="deactivated">Deactivated</option>
              </select>
              <ChevronDown className="w-4 h-4 text-text-muted absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none" />
            </div>
          )}
        />
        {errors.status && <p className="text-xs text-danger mt-1">{errors.status.message}</p>}
      </div>

      <div className="flex justify-end gap-2 pt-2 border-t border-border -mx-6 px-6 -mb-5 pb-5 mt-2">
        <Button type="button" variant="outline" size="sm" onClick={onCancel}>
          Cancel
        </Button>
        <Button
          type="submit"
          size="sm"
          disabled={isSubmitting || (mode === 'edit' && !isDirty)}
          className="gap-2"
        >
          <Save className="w-4 h-4" />
          {isSubmitting ? 'Saving…' : mode === 'edit' ? 'Save changes' : 'Create admin'}
        </Button>
      </div>
    </form>
  );
}
