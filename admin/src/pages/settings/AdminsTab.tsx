import React, { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import { AdminForm, type AdminFormValues } from '@/components/super-admin/forms/AdminForm';
import { adminsApi } from '@/api/super-admin/admins';
import { useAdmins } from '@/hooks/useAdmins';
import { useRoles } from '@/hooks/useRoles';
import type { AdminRole, AdminRoleDefinition, AdminUser } from '@/types/super-admin';

function roleVariant(role: string): 'info' | 'default' {
  return role === 'superadmin' || role === 'admin' ? 'info' : 'default';
}

function roleLabel(role: string): string {
  switch (role) {
    case 'admin':      return 'Admin';
    case 'superadmin': return 'Super Admin';
    case 'operations': return 'Operations';
    case 'finance':    return 'Finance';
    case 'support':    return 'Support';
    default: return role;
  }
}

export function AdminsTab() {
  const qc = useQueryClient();
  const adminsQuery = useAdmins();
  const rolesQuery = useRoles();
  const admins = (adminsQuery.data ?? []) as unknown as AdminUser[];
  const adminsLoading = adminsQuery.isPending;
  const roleDefinitions = (rolesQuery.data ?? []) as unknown as AdminRoleDefinition[];

  const [modal, setModal] = useState<
    | { mode: 'add' }
    | { mode: 'edit'; admin: AdminUser }
    | null
  >(null);
  const [apiError, setApiError] = useState<string | null>(null);
  const [confirmDeactivate, setConfirmDeactivate] = useState<AdminUser | null>(null);
  const [deactivating, setDeactivating] = useState(false);

  const closeModal = () => { setModal(null); setApiError(null); };

  async function handleSubmit(values: AdminFormValues) {
    setApiError(null);
    try {
      const selectedRoleDef = roleDefinitions.find(r => r.name === values.role);
      if (modal?.mode === 'add') {
        if (!selectedRoleDef) {
          setApiError('Selected role not found. Please refresh the page.');
          return;
        }
        await adminsApi.create({
          name: values.name,
          email: values.email,
          role_id: selectedRoleDef.id,
          password: values.password ?? '',
        });
      } else if (modal?.mode === 'edit') {
        await adminsApi.update(modal.admin.id, {
          name: values.name,
          email: values.email,
          role: values.role as AdminRole,
          role_id: selectedRoleDef?.id,
        });
      }
      qc.invalidateQueries({ queryKey: ['admin', 'admins'] });
      closeModal();
    } catch (error: unknown) {
      setApiError(error instanceof Error ? error.message : 'Failed to save admin.');
    }
  }

  const initial: Partial<AdminFormValues> | undefined =
    modal?.mode === 'edit'
      ? {
          name: modal.admin.name,
          email: modal.admin.email,
          role: modal.admin.role,
          status: modal.admin.status ?? 'active',
          password: '',
        }
      : undefined;

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-medium">Manage Admin Access</h3>
        <Button onClick={() => setModal({ mode: 'add' })}>Add Admin</Button>
      </div>

      {adminsLoading ? (
        <p className="text-sm text-text-muted text-center py-6">Loading...</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Last Login</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {admins.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-10 text-text-muted">No admins found.</TableCell>
              </TableRow>
            ) : admins.map((admin) => (
              <TableRow key={admin.id}>
                <TableCell className="font-medium">{admin.name}</TableCell>
                <TableCell>{admin.email}</TableCell>
                <TableCell>
                  <Badge variant={roleVariant(admin.role)}>{roleLabel(admin.role)}</Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={admin.status === 'active' ? 'success' : 'default'}>
                    {admin.status.charAt(0).toUpperCase() + admin.status.slice(1)}
                  </Badge>
                </TableCell>
                <TableCell className="text-sm text-text-muted">
                  {admin.last_login_at ? new Date(admin.last_login_at).toLocaleDateString('en-PH') : 'Never'}
                </TableCell>
                <TableCell className="text-right">
                  <Button variant="ghost" size="sm" onClick={() => setModal({ mode: 'edit', admin })}>
                    Edit
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-danger"
                    disabled={admin.status === 'deactivated'}
                    onClick={() => setConfirmDeactivate(admin)}
                  >
                    {admin.status === 'deactivated' ? 'Removed' : 'Remove'}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}

      {modal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-md shadow-xl">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border">
              <h2 className="text-base font-semibold text-text-main">
                {modal.mode === 'edit' ? 'Edit Admin' : 'Add Admin'}
              </h2>
              <Button variant="ghost" size="icon" onClick={closeModal}>
                <X className="w-4 h-4" />
              </Button>
            </div>
            <AdminForm
              mode={modal.mode}
              initial={initial}
              roleDefinitions={roleDefinitions}
              apiError={apiError}
              onSubmit={handleSubmit}
              onCancel={closeModal}
            />
          </div>
        </div>
      )}

      <ConfirmationModal
        open={confirmDeactivate !== null}
        title="Deactivate Admin"
        description={`Are you sure you want to deactivate ${confirmDeactivate?.name}? They will lose access immediately.`}
        confirmLabel="Deactivate"
        variant="danger"
        loading={deactivating}
        onCancel={() => setConfirmDeactivate(null)}
        onConfirm={async () => {
          if (!confirmDeactivate) return;
          setDeactivating(true);
          try {
            await adminsApi.deactivate(confirmDeactivate.id);
            qc.invalidateQueries({ queryKey: ['admin', 'admins'] });
          } catch {
            // surfaces via row status on next fetch
          } finally {
            setDeactivating(false);
            setConfirmDeactivate(null);
          }
        }}
      />
    </div>
  );
}
