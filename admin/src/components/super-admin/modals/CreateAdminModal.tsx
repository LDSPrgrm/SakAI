// Create admin account modal — spec superadmin.md §4.2 Actions
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { X } from 'lucide-react';
import type { AdminRoleDefinition } from '@/types/super-admin';

const schema = z.object({
  name:     z.string().min(2, 'Name is required'),
  email:    z.string().email('Valid email required'),
  role_id:  z.string().min(1, 'Role is required'),
  password: z.string().min(8, 'Minimum 8 characters'),
});
type FormValues = z.infer<typeof schema>;

interface CreateAdminModalProps {
  open: boolean;
  roles: AdminRoleDefinition[];
  loading?: boolean;
  onSubmit: (data: FormValues) => void;
  onCancel: () => void;
}

export function CreateAdminModal({ open, roles, loading, onSubmit, onCancel }: CreateAdminModalProps) {
  const { register, handleSubmit, formState: { errors }, reset } = useForm<FormValues>({
    resolver: zodResolver(schema),
  });

  if (!open) return null;

  const handleClose = () => { reset(); onCancel(); };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/60" onClick={handleClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-md p-6">
        <button onClick={handleClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main">
          <X className="w-5 h-5" />
        </button>
        <h3 className="text-base font-semibold text-text-main mb-5">Create Admin</h3>

        <form onSubmit={handleSubmit((data) => { onSubmit(data); reset(); })} className="flex flex-col gap-4">
          <Field label="Full Name" error={errors.name?.message}>
            <input {...register('name')} placeholder="Maria Santos" className={inputCls} />
          </Field>
          <Field label="Email" error={errors.email?.message}>
            <input {...register('email')} type="email" placeholder="admin@sakai.ph" className={inputCls} />
          </Field>
          <Field label="Role" error={errors.role_id?.message}>
            <select {...register('role_id')} className={inputCls}>
              <option value="">Select a role…</option>
              {roles.map((r) => (
                <option key={r.id} value={r.id}>{r.name}</option>
              ))}
            </select>
          </Field>
          <Field label="Temporary Password" error={errors.password?.message}>
            <input {...register('password')} type="password" placeholder="Min. 8 characters" className={inputCls} />
          </Field>
          <p className="text-xs text-text-muted">Admin will be prompted to change password on first login.</p>
          <div className="flex justify-end gap-3 mt-1">
            <button type="button" onClick={handleClose} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">
              Cancel
            </button>
            <button type="submit" disabled={loading} className="px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
              {loading ? 'Creating…' : 'Create Admin'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function Field({ label, error, children }: { label: string; error?: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs font-medium text-text-muted">{label}</label>
      {children}
      {error && <p className="text-xs text-danger">{error}</p>}
    </div>
  );
}

const inputCls = 'bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:border-primary placeholder:text-text-muted';
