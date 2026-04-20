// Permission toggle grid for role creation/editing — spec superadmin.md §4.3
// Rows: permission keys | Columns: Read | Write
// Toggling Write auto-enables Read. Dashboard has no write scope.
import React from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { PERMISSION_KEYS, PERMISSION_LABELS, HAS_WRITE_SCOPE } from '@/utils/permissions';
import type { RolePermission, RolePermissionKey } from '@/types/super-admin';

const permSchema = z.object({
  name:        z.string().min(1, 'Role name is required').max(100, 'Role name is too long'),
  description: z.string().max(500, 'Description is too long').optional(),
  permissions: z.array(z.object({
    permission_key: z.string(),
    read:  z.boolean(),
    write: z.boolean(),
  })).refine((perms) => perms.some((p) => p.read || p.write), {
    message: 'At least one permission must be enabled',
  }),
});

export type RoleFormValues = z.infer<typeof permSchema>;

interface RolePermissionFormProps {
  defaultValues?: Partial<RoleFormValues>;
  locked?:  boolean;
  loading?: boolean;
  onSubmit: (data: RoleFormValues) => void;
  onCancel: () => void;
}

function initPermissions(existing?: RolePermission[]): RoleFormValues['permissions'] {
  return PERMISSION_KEYS.map((key) => {
    const match = existing?.find((p) => p.permission_key === key);
    return { permission_key: key, read: match?.read ?? false, write: match?.write ?? false };
  });
}

export function RolePermissionForm({
  defaultValues,
  locked,
  loading,
  onSubmit,
  onCancel,
}: RolePermissionFormProps) {
  const { register, control, handleSubmit, setValue, watch, formState: { errors } } = useForm<RoleFormValues>({
    resolver: zodResolver(permSchema),
    defaultValues: {
      name:        defaultValues?.name        ?? '',
      description: defaultValues?.description ?? '',
      permissions: initPermissions(defaultValues?.permissions as RolePermission[] | undefined),
    },
  });

  const permissions = watch('permissions');

  const setAll = (scope: 'read' | 'write', value: boolean) => {
    permissions.forEach((_, i) => {
      if (scope === 'write' && !HAS_WRITE_SCOPE.has(PERMISSION_KEYS[i])) return;
      setValue(`permissions.${i}.${scope}`, value);
      if (scope === 'write' && value) setValue(`permissions.${i}.read`, true);
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-5">
      {/* Name & Description */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="text-xs font-medium text-text-muted block mb-1">Role Name *</label>
          <input
            {...register('name')}
            readOnly={locked}
            placeholder="e.g. City Manager"
            className="bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary placeholder:text-text-muted read-only:opacity-50"
          />
          {errors.name && <p className="text-xs text-danger mt-1">{errors.name.message}</p>}
        </div>
        <div>
          <label className="text-xs font-medium text-text-muted block mb-1">Description</label>
          <input
            {...register('description')}
            readOnly={locked}
            placeholder="Brief description of this role"
            className="bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary placeholder:text-text-muted read-only:opacity-50"
          />
        </div>
      </div>

      {/* Permission grid */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <p className="text-xs font-semibold text-text-muted uppercase tracking-wide">Permissions</p>
          <div className="flex gap-2 text-xs">
            <button type="button" onClick={() => setAll('read', true)}  className="text-primary hover:underline">All Read</button>
            <button type="button" onClick={() => setAll('write', true)} className="text-primary hover:underline">All Write</button>
            <button type="button" onClick={() => { setAll('read', false); setAll('write', false); }} className="text-text-muted hover:underline">Clear</button>
          </div>
        </div>

        <div className="border border-border rounded-xl overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-background">
              <tr>
                <th className="px-4 py-2 text-left text-xs font-semibold text-text-muted w-full">Permission</th>
                <th className="px-4 py-2 text-center text-xs font-semibold text-text-muted w-20">Read</th>
                <th className="px-4 py-2 text-center text-xs font-semibold text-text-muted w-20">Write</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {PERMISSION_KEYS.map((key, i) => {
                const hasWrite = HAS_WRITE_SCOPE.has(key);
                return (
                  <tr key={key} className="hover:bg-surface-hover">
                    <td className="px-4 py-2.5 text-text-main text-xs">{PERMISSION_LABELS[key]}</td>
                    <td className="px-4 py-2.5 text-center">
                      <Controller
                        name={`permissions.${i}.read`}
                        control={control}
                        render={({ field }) => (
                          <input type="checkbox" checked={field.value} onChange={field.onChange}
                            className="w-4 h-4 accent-primary" />
                        )}
                      />
                    </td>
                    <td className="px-4 py-2.5 text-center">
                      {hasWrite ? (
                        <Controller
                          name={`permissions.${i}.write`}
                          control={control}
                          render={({ field }) => (
                            <input
                              type="checkbox"
                              checked={field.value}
                              onChange={(e) => {
                                field.onChange(e);
                                if (e.target.checked) setValue(`permissions.${i}.read`, true);
                              }}
                              className="w-4 h-4 accent-primary"
                            />
                          )}
                        />
                      ) : (
                        <span className="text-text-muted text-xs">—</span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        {errors.permissions && (
          <p className="text-xs text-danger mt-1">{errors.permissions.root?.message ?? errors.permissions.message}</p>
        )}
      </div>

      <div className="flex justify-end gap-3 pt-2">
        <button type="button" onClick={onCancel} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">
          Cancel
        </button>
        <button type="submit" disabled={loading} className="px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
          {loading ? 'Saving…' : 'Save Role'}
        </button>
      </div>
    </form>
  );
}
