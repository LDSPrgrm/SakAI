// Reusable create/edit form for admin accounts.
// Used by SAAdminManagement (super-admin page) and Settings → Admins tab.
import React, { useEffect } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import type { AdminRoleDefinition } from '@/types/super-admin';

export const adminSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(255, 'Name is too long'),
  email: z.string().email('Must be a valid email address').max(255, 'Email is too long'),
  role: z.string().min(1, 'Role is required').max(100, 'Role is too long'),
  status: z.enum(['active', 'suspended', 'deactivated']),
  password: z
    .string()
    .min(8, 'Must be at least 8 characters')
    .max(128, 'Password is too long')
    .optional()
    .or(z.literal('')),
});

export type AdminFormValues = z.infer<typeof adminSchema>;

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
    formState: { errors, isSubmitting },
  } = useForm<AdminFormValues>({
    resolver: zodResolver(adminSchema),
    defaultValues: { ...EMPTY, ...initial },
  });

  useEffect(() => {
    reset({ ...EMPTY, ...initial });
  }, [initial, reset]);

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="px-6 py-5 space-y-4" noValidate>
      {apiError && (
        <div className="bg-danger/10 border border-danger rounded-lg p-3 flex items-start gap-2">
          <X className="w-4 h-4 text-danger mt-0.5 flex-shrink-0" />
          <p className="text-sm text-danger">{apiError}</p>
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-text-muted mb-1">Full Name</label>
        <Input
          {...register('name')}
          placeholder="e.g. Maria Santos"
          className={errors.name ? 'border-danger' : ''}
        />
        {errors.name && <p className="text-xs text-danger mt-1">{errors.name.message}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-text-muted mb-1">Email Address</label>
        <Input
          {...register('email')}
          type="email"
          placeholder="e.g. maria@sakai.ph"
          className={errors.email ? 'border-danger' : ''}
        />
        {errors.email && <p className="text-xs text-danger mt-1">{errors.email.message}</p>}
      </div>

      {mode === 'add' && (
        <div>
          <label className="block text-sm font-medium text-text-muted mb-1">Temporary Password</label>
          <Input
            {...register('password')}
            type="text"
            placeholder="Must be at least 8 characters"
            className={errors.password ? 'border-danger' : ''}
          />
          {errors.password && (
            <p className="text-xs text-danger mt-1">{errors.password.message}</p>
          )}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-text-muted mb-1">Role</label>
        <Controller
          name="role"
          control={control}
          render={({ field }) => (
            <select
              {...field}
              className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
            >
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
          )}
        />
        {errors.role && <p className="text-xs text-danger mt-1">{errors.role.message}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-text-muted mb-1">Status</label>
        <Controller
          name="status"
          control={control}
          render={({ field }) => (
            <select
              {...field}
              className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="active">Active</option>
              <option value="suspended">Suspended</option>
              <option value="deactivated">Deactivated</option>
            </select>
          )}
        />
        {errors.status && <p className="text-xs text-danger mt-1">{errors.status.message}</p>}
      </div>

      <div className="flex justify-end gap-3 pt-2">
        <Button type="button" variant="outline" size="sm" onClick={onCancel}>
          Cancel
        </Button>
        <Button type="submit" size="sm" disabled={isSubmitting}>
          {isSubmitting ? 'Saving…' : 'Save'}
        </Button>
      </div>
    </form>
  );
}
