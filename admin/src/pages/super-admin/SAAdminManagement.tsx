import React, { useState } from 'react';
import { Plus, Search, Pencil, Ban, CheckCircle, X, Trash2, Activity, Key } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/Table';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { useQueryClient } from '@tanstack/react-query';
import { adminsApi } from '@/api/super-admin/admins';
import { useAdmins } from '@/hooks/useAdmins';
import { useRoles } from '@/hooks/useRoles';
import { useAuth } from '@/hooks/useAuth';
import { formatDate } from '@/utils/formatDate';
import { AdminForm, type AdminFormValues } from '@/components/super-admin/forms/AdminForm';
import { PasswordResetResultModal } from '@/components/super-admin/modals/PasswordResetResultModal';
import type { AdminUser, AdminRole, AdminRoleDefinition } from '@/types/super-admin';

// ── Helpers ──────────────────────────────────────────────────────────────────

const ROLE_BADGE: Record<string, 'danger' | 'info' | 'warning' | 'default'> = {
  admin:      'info',
  superadmin: 'danger',
  operations: 'info',
  finance:    'warning',
  support:    'default',
};

const ROLE_LABELS: Record<string, string> = {
  admin:      'Admin',
  superadmin: 'Super Admin',
  operations: 'Operations',
  finance:    'Finance',
  support:    'Support',
};

function roleLabel(role: string): string {
  return ROLE_LABELS[role] ?? role.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function roleBadgeVariant(role: string): 'danger' | 'info' | 'warning' | 'default' {
  return ROLE_BADGE[role] ?? 'default';
}

// ── Main Component ────────────────────────────────────────────────────────────

export function SAAdminManagement() {
  const { user } = useAuth();
  const currentUserId = user?.id ?? '';
  const qc = useQueryClient();
  const adminsQuery = useAdmins();
  const rolesQuery = useRoles();
  const admins = (adminsQuery.data ?? []) as unknown as AdminUser[];
  const roleDefs = (rolesQuery.data ?? []) as unknown as AdminRoleDefinition[];
  const invalidateAdmins = () => qc.invalidateQueries({ queryKey: ['admin', 'admins'] });
  const [search, setSearch] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [editingAdmin, setEditingAdmin] = useState<AdminUser | null>(null);
  const [apiError, setApiError] = useState<string | null>(null);

  const [confirmModal, setConfirmModal] = useState<{
    open: boolean;
    type: 'suspend' | 'activate' | 'deactivate' | 'role_change' | 'reset_password';
    admin: AdminUser | null;
    pendingData?: AdminFormValues;
  }>({ open: false, type: 'suspend', admin: null });

  const [resetResult, setResetResult] = useState<{ open: boolean; password?: string; admin?: AdminUser | null }>({ open: false });
  const [formInitial, setFormInitial] = useState<Partial<AdminFormValues> | undefined>(undefined);

  function generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
    let pass = '';
    for (let i = 0; i < 10; i++) pass += chars.charAt(Math.floor(Math.random() * chars.length));
    return pass;
  }

  async function openAdd() {
    setEditingAdmin(null);
    setApiError(null);
    setFormInitial({ name: '', email: '', role: 'support', status: 'active', password: generatePassword() });
    await qc.invalidateQueries({ queryKey: ['admin', 'roles'] });
    setModalOpen(true);
  }

  async function openEdit(admin: AdminUser) {
    setEditingAdmin(admin);
    setApiError(null);
    setFormInitial({
      name: admin.name,
      email: admin.email,
      role: admin.role,
      status: admin.status ?? 'active',
      password: '',
    });
    await qc.invalidateQueries({ queryKey: ['admin', 'roles'] });
    setModalOpen(true);
  }

  async function onSubmit(values: AdminFormValues) {
    setApiError(null);

    try {
      if (editingAdmin) {
        if (editingAdmin.role !== values.role) {
          setConfirmModal({ open: true, type: 'role_change', admin: editingAdmin, pendingData: values });
          return;
        }
        // update() only sends { role } — role_id not needed here
        await adminsApi.update(editingAdmin.id, { role: values.role as AdminRole });
      } else {
        // Create needs role_id to link the new user to the roles table
        const selectedRoleDef = roleDefs.find(r => r.name === values.role);
        if (!selectedRoleDef) {
          setApiError('Selected role not found. Please refresh the page or select a different role.');
          return;
        }
        await adminsApi.create({
          name: values.name,
          email: values.email,
          role_id: selectedRoleDef.id,
          password: values.password ?? '',
        });
      }
      setModalOpen(false);
      invalidateAdmins();
    } catch (error: unknown) {
      const errorMessage = error instanceof Error
        ? error.message
        : 'Failed to save admin. Please try again.';
      setApiError(errorMessage);
    }
  }

  async function confirmAction() {
    if (!confirmModal.admin) return;
    const admin = confirmModal.admin;

    if (confirmModal.type === 'suspend' || confirmModal.type === 'deactivate') {
      await adminsApi.deactivate(admin.id);
    } else if (confirmModal.type === 'reset_password') {
      const newPass = generatePassword();
      await adminsApi.resetPassword(admin.id, newPass);
      setResetResult({ open: true, password: newPass, admin });
    } else if (confirmModal.type === 'role_change' && confirmModal.pendingData) {
      await adminsApi.update(admin.id, { role: confirmModal.pendingData.role as AdminRole });
      setModalOpen(false);
    }

    invalidateAdmins();
    setConfirmModal({ open: false, type: 'suspend', admin: null });
  }

  const superAdminCount = admins.filter((a) => a.role === 'superadmin').length;

  const filtered = admins.filter((a) => {
    const q = search.toLowerCase();
    return (
      a.name.toLowerCase().includes(q) ||
      a.email.toLowerCase().includes(q) ||
      a.role.toLowerCase().includes(q)
    );
  });

  // ── Render ──────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">Admin Management</h1>
        <Button onClick={openAdd} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Add Admin
        </Button>
      </div>

      {/* Table Card */}
      <Card>
        <CardHeader>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <Input
              icon={<Search className="w-4 h-4" />}
              placeholder="Search admins…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="max-w-xs"
            />
            <span className="text-sm text-text-muted">
              {filtered.length} admin{filtered.length !== 1 ? 's' : ''}
            </span>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name / Email</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Last Login</TableHead>
                  <TableHead>Created By</TableHead>
                  <TableHead>Date Created</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center text-text-muted py-10">
                      No admins found.
                    </TableCell>
                  </TableRow>
                )}
                {filtered.map((admin) => {
                  const isSelf = admin.id === currentUserId;
                  const isLastSuperAdmin =
                    admin.role === 'superadmin' && superAdminCount === 1;
                  const canAct = !isSelf && !isLastSuperAdmin;

                  return (
                    <TableRow key={admin.id}>
                      {/* Name / Email */}
                      <TableCell>
                        <p className="font-semibold text-text-main">{admin.name}</p>
                        <p className="text-xs text-text-muted">{admin.email}</p>
                      </TableCell>

                      {/* Role */}
                      <TableCell>
                        <Badge variant={roleBadgeVariant(admin.role)}>
                          {roleLabel(admin.role)}
                        </Badge>
                      </TableCell>

                      {/* Status */}
                      <TableCell>
                        <StatusBadge status={admin.status || 'active'} />
                      </TableCell>

                      {/* Last Login */}
                      <TableCell className="text-sm text-text-muted">
                        {admin.last_login_at ? formatDate(admin.last_login_at) : 'Never'}
                      </TableCell>

                      {/* Created By */}
                      <TableCell className="text-sm text-text-muted">
                        {admin.created_by ? (
                          <span className="font-mono text-xs">{admin.created_by.substring(0, 8)}…</span>
                        ) : (
                          <span className="text-xs italic">System</span>
                        )}
                      </TableCell>

                      {/* Created */}
                      <TableCell className="text-sm text-text-muted">
                        {admin.created_at ? formatDate(admin.created_at) : 'Unknown'}
                      </TableCell>

                      {/* Actions */}
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-1">
                          <Link to={`/super-admin/audit?actor_id=${admin.id}`}>
                            <Button variant="ghost" size="icon" title="View activity" className="text-text-muted hover:text-primary">
                              <Activity className="w-4 h-4" />
                            </Button>
                          </Link>

                          <Button
                            variant="ghost"
                            size="icon"
                            title="Edit admin"
                            onClick={() => openEdit(admin)}
                          >
                            <Pencil className="w-4 h-4" />
                          </Button>

                          {canAct && admin.status !== 'deactivated' && (
                            <>
                              <Button
                                variant="ghost"
                                size="icon"
                                title="Reset password"
                                onClick={() => setConfirmModal({ open: true, type: 'reset_password', admin })}
                              >
                                <Key className="w-4 h-4" />
                              </Button>

                              <Button
                                variant="ghost"
                                size="icon"
                                title={admin.status === 'suspended' ? 'Activate' : 'Suspend'}
                                className="text-warning hover:text-warning"
                                onClick={() => setConfirmModal({ open: true, type: admin.status === 'suspended' ? 'activate' : 'suspend', admin })}
                              >
                                {admin.status === 'suspended'
                                  ? <CheckCircle className="w-4 h-4" />
                                  : <Ban className="w-4 h-4" />
                                }
                              </Button>

                              <Button
                                variant="ghost"
                                size="icon"
                                title="Deactivate admin"
                                className="text-danger hover:text-danger"
                                onClick={() => setConfirmModal({ open: true, type: 'deactivate', admin })}
                              >
                                <Trash2 className="w-4 h-4" />
                              </Button>
                            </>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Add / Edit Modal */}
      {modalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-md shadow-xl">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border">
              <h2 className="text-base font-semibold text-text-main">
                {editingAdmin ? 'Edit Admin' : 'Add Admin'}
              </h2>
              <Button variant="ghost" size="icon" onClick={() => { setApiError(null); setModalOpen(false); }}>
                <X className="w-4 h-4" />
              </Button>
            </div>

            <AdminForm
              mode={editingAdmin ? 'edit' : 'add'}
              initial={formInitial}
              roleDefinitions={roleDefs}
              apiError={apiError}
              onSubmit={onSubmit}
              onCancel={() => { setApiError(null); setModalOpen(false); }}
            />
          </div>
        </div>
      )}

      {/* Confirm Modal */}
      <ConfirmModal
        open={confirmModal.open}
        title={
          confirmModal.type === 'deactivate' ? 'Deactivate Admin' :
            confirmModal.type === 'reset_password' ? 'Reset Password' :
              confirmModal.type === 'role_change' ? 'Confirm Role Change' :
                confirmModal.type === 'activate' ? 'Activate Admin' : 'Suspend Admin'
        }
        message={
          confirmModal.type === 'deactivate'
            ? `Permanently deactivate ${confirmModal.admin?.name}? They will lose access immediately and this cannot be undone.` :
            confirmModal.type === 'reset_password'
              ? `Are you sure you want to reset the password for ${confirmModal.admin?.name}? A new temporary password will be generated for them.` :
              confirmModal.type === 'role_change'
                ? `Change ${confirmModal.admin?.name}'s role to ${confirmModal.pendingData ? roleLabel(confirmModal.pendingData.role) : ''}? This alters their permissions significantly.` :
                confirmModal.type === 'activate'
                  ? `Re-activate ${confirmModal.admin?.name}? They will regain access immediately.`
                  : `Suspend ${confirmModal.admin?.name}? They will lose access until reactivated.`
        }
        variant={confirmModal.type === 'activate' || confirmModal.type === 'role_change' ? 'success' : 'danger'}
        confirmLabel={
          confirmModal.type === 'deactivate' ? 'Deactivate' :
            confirmModal.type === 'reset_password' ? 'Reset Password' :
              confirmModal.type === 'role_change' ? 'Confirm Change' :
                confirmModal.type === 'activate' ? 'Activate' : 'Suspend'
        }
        onConfirm={confirmAction}
        onClose={() => setConfirmModal({ open: false, type: 'suspend', admin: null })}
      />

      {/* Reset Result Modal */}
      {/* TODO: replace with one-time magic-link flow — requires backend endpoint. */}
      {resetResult.open && (
        <PasswordResetResultModal
          adminName={resetResult.admin?.name ?? ''}
          password={resetResult.password ?? ''}
          onClose={() => setResetResult({ open: false, password: undefined, admin: null })}
        />
      )}
    </div>
  );
}
