// Create / Edit role modal — wraps RolePermissionForm.
// Spec: superadmin.md §4.3 Role Management
import React from 'react';
import { X } from 'lucide-react';
import { RolePermissionForm, type RoleFormValues } from '../forms/RolePermissionForm';
import type { AdminRoleDefinition } from '@/lib/admin-api';

interface CreateRoleModalProps {
  open:      boolean;
  existing?: AdminRoleDefinition | null;
  loading?:  boolean;
  onSubmit:  (data: RoleFormValues) => void;
  onCancel:  () => void;
}

export function CreateRoleModal({ open, existing, loading, onSubmit, onCancel }: CreateRoleModalProps) {
  if (!open) return null;

  const isEdit = !!existing;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div className="absolute inset-0 bg-black/60" onClick={onCancel} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-2xl my-8">
        <div className="flex items-center justify-between px-6 pt-6 pb-4 border-b border-border">
          <h3 className="text-base font-semibold text-text-main">
            {isEdit ? `Edit Role: ${existing!.name}` : 'Create Role'}
          </h3>
          <button onClick={onCancel} className="text-text-muted hover:text-text-main">
            <X className="w-5 h-5" />
          </button>
        </div>
        <div className="p-6">
          {isEdit && existing?.is_system && (
            <div className="mb-4 px-4 py-3 rounded-lg bg-warning/5 border border-warning/20 text-sm text-warning">
              This is a system role. Name and description are locked. You can still modify permissions.
            </div>
          )}
          <RolePermissionForm
            defaultValues={
              existing
                ? {
                    name:        existing.name,
                    description: existing.description,
                    permissions: existing.permissions,
                  }
                : undefined
            }
            locked={existing?.is_system ?? false}
            loading={loading}
            onSubmit={onSubmit}
            onCancel={onCancel}
          />
        </div>
      </div>
    </div>
  );
}
