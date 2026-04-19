import React, { useEffect, useState } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Plus, Search, Pencil, Ban, CheckCircle, X, Trash2, Activity, Key } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/Table';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { adminsApi } from '@/api/super-admin/admins';
import { rolesApi } from '@/api/super-admin/roles';
import type { AdminUser, AdminRole, AdminStatus, AdminRoleDefinition } from '@/types/super-admin';

// ── Zod schema ───────────────────────────────────────────────────────────────

const adminSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Must be a valid email address'),
  role: z.string().min(1, 'Role is required'),
  status: z.enum(['active', 'suspended', 'deactivated']),
  password: z.string().min(8, 'Must be at least 8 characters').optional().or(z.literal('')),
});

type AdminFormValues = z.infer<typeof adminSchema>;

// ── Helpers ──────────────────────────────────────────────────────────────────

const ROLE_BADGE: Record<string, 'danger' | 'info' | 'warning' | 'default'> = {
  super_admin: 'danger',
  operations: 'info',
  finance: 'warning',
  support: 'default',
};

const ROLE_LABELS: Record<string, string> = {
  super_admin: 'Super Admin',
  operations: 'Operations',
  finance: 'Finance',
  support: 'Support',
};

function roleLabel(role: string): string {
  return ROLE_LABELS[role] ?? role.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function roleBadgeVariant(role: string): 'danger' | 'info' | 'warning' | 'default' {
  return ROLE_BADGE[role] ?? 'default';
}

function formatDate(iso: string | null): string {
  if (!iso) return 'Never';
  return new Date(iso).toLocaleDateString('en-PH', {
    year: 'numeric', month: 'short', day: 'numeric',
  });
}

// Hardcoded current user ID (replace with auth context if available)
const CURRENT_USER_ID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

/** Convert backend ENUM role ("superadmin") to roles-table name ("super_admin"). */
function toFormRole(role: string): string {
  if (role === 'superadmin') return 'super_admin';
  return role;
}

// ── Main Component ────────────────────────────────────────────────────────────

export function SAAdminManagement() {
  const [admins, setAdmins] = useState<AdminUser[]>([]);
  const [roleDefs, setRoleDefs] = useState<AdminRoleDefinition[]>([]);
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

  const { register, handleSubmit, control, reset, formState: { errors, isSubmitting } } =
    useForm<AdminFormValues>({ resolver: zodResolver(adminSchema) });

  async function loadAdmins() {
    const list = await adminsApi.list() as unknown as AdminUser[];
    setAdmins(list);
  }

  useEffect(() => {
    loadAdmins();
    rolesApi.list().then(r => setRoleDefs(r as unknown as AdminRoleDefinition[])).catch(() => {});
  }, []);

  function generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
    let pass = '';
    for (let i = 0; i < 10; i++) pass += chars.charAt(Math.floor(Math.random() * chars.length));
    return pass;
  }

  async function openAdd() {
    setEditingAdmin(null);
    setApiError(null); // Clear any previous errors
    reset({ name: '', email: '', role: 'support', status: 'active', password: generatePassword() });
    // Refresh roleDefs to include any newly created custom roles
    await rolesApi.list().then(r => setRoleDefs(r as unknown as AdminRoleDefinition[])).catch(() => {});
    setModalOpen(true);
  }

  async function openEdit(admin: AdminUser) {
    setEditingAdmin(admin);
    setApiError(null); // Clear any previous errors
    reset({
      name: admin.name,
      email: admin.email,
      role: toFormRole(admin.role),
      status: admin.status ?? 'active',
      password: '',
    });
    // Refresh roleDefs to include any newly created custom roles
    await rolesApi.list().then(r => setRoleDefs(r as unknown as AdminRoleDefinition[])).catch(() => {});
    setModalOpen(true);
  }

  async function onSubmit(values: AdminFormValues) {
    setApiError(null);

    try {
      if (editingAdmin) {
        // Compare normalized forms so "superadmin" == "super_admin" doesn't trigger a spurious confirm
        const currentRole = toFormRole(editingAdmin.role);
        if (currentRole !== values.role) {
          setConfirmModal({ open: true, type: 'role_change', admin: editingAdmin, pendingData: values });
          return;
        }
        // update() only sends { role } — role_id not needed here
        await adminsApi.update(editingAdmin.id, { role: values.role } as any);
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
      await loadAdmins();
    } catch (error: any) {
      const errorMessage = error?.message || 'Failed to save admin. Please try again.';
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
      await adminsApi.update(admin.id, { role: confirmModal.pendingData.role } as any);
      setModalOpen(false);
    }

    await loadAdmins();
    setConfirmModal({ open: false, type: 'suspend', admin: null });
  }

  const superAdminCount = admins.filter((a) => a.role === 'super_admin').length;

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
                  const isSelf = admin.id === CURRENT_USER_ID;
                  const isLastSuperAdmin =
                    admin.role === 'super_admin' && superAdminCount === 1;
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
            {/* Modal Header */}
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border">
              <h2 className="text-base font-semibold text-text-main">
                {editingAdmin ? 'Edit Admin' : 'Add Admin'}
              </h2>
              <Button variant="ghost" size="icon" onClick={() => { setApiError(null); setModalOpen(false); }}>
                <X className="w-4 h-4" />
              </Button>
            </div>

            {/* Modal Body */}
            <form onSubmit={handleSubmit(onSubmit)} className="px-6 py-5 space-y-4">
              {/* Error Message Display */}
              {apiError && (
                <div className="bg-danger/10 border border-danger rounded-lg p-3 flex items-start gap-2">
                  <X className="w-4 h-4 text-danger mt-0.5 flex-shrink-0" />
                  <p className="text-sm text-danger">{apiError}</p>
                </div>
              )}

              {/* Name */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Full Name
                </label>
                <Input
                  {...register('name')}
                  placeholder="e.g. Maria Santos"
                  className={errors.name ? 'border-danger' : ''}
                />
                {errors.name && (
                  <p className="text-xs text-danger mt-1">{errors.name.message}</p>
                )}
              </div>

              {/* Email */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Email Address
                </label>
                <Input
                  {...register('email')}
                  type="email"
                  placeholder="e.g. maria@sakai.ph"
                  className={errors.email ? 'border-danger' : ''}
                />
                {errors.email && (
                  <p className="text-xs text-danger mt-1">{errors.email.message}</p>
                )}
              </div>

              {/* Password (Create Only) */}
              {!editingAdmin && (
                <div>
                  <label className="block text-sm font-medium text-text-muted mb-1">
                    Temporary Password
                  </label>
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

              {/* Role */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Role
                </label>
                <Controller
                  name="role"
                  control={control}
                  render={({ field }) => (
                    <select
                      {...field}
                      className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      {roleDefs.length > 0 ? (
                        roleDefs.map((r) => (
                          <option key={r.id} value={r.name}>{roleLabel(r.name)}</option>
                        ))
                      ) : (
                        <>
                          <option value="super_admin">Super Admin</option>
                          <option value="operations">Operations</option>
                          <option value="finance">Finance</option>
                          <option value="support">Support</option>
                        </>
                      )}
                    </select>
                  )}
                />
                {errors.role && (
                  <p className="text-xs text-danger mt-1">{errors.role.message}</p>
                )}
              </div>

              {/* Status */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Status
                </label>
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
                {errors.status && (
                  <p className="text-xs text-danger mt-1">{errors.status.message}</p>
                )}
              </div>

              {/* Actions */}
              <div className="flex justify-end gap-3 pt-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => { setApiError(null); setModalOpen(false); }}
                >
                  Cancel
                </Button>
                <Button type="submit" size="sm" disabled={isSubmitting}>
                  {isSubmitting ? 'Saving…' : 'Save'}
                </Button>
              </div>
            </form>
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
      {resetResult.open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-sm shadow-xl p-6 text-center space-y-4">
            <div className="mx-auto bg-success/20 text-success rounded-full w-12 h-12 flex items-center justify-center mb-2">
              <CheckCircle className="w-6 h-6" />
            </div>
            <h2 className="text-lg font-semibold text-text-main">Password Reset</h2>
            <p className="text-sm text-text-muted">
              The password for <strong>{resetResult.admin?.name}</strong> has been reset. Share this temporary password securely:
            </p>
            <div className="bg-background border border-border rounded p-3 font-mono text-center text-lg select-all">
              {resetResult.password}
            </div>
            <div className="pt-4">
              <Button className="w-full" onClick={() => setResetResult({ open: false })}>
                Close
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
