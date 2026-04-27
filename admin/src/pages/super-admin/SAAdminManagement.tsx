import React, { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Plus,
  Search,
  Pencil,
  Ban,
  CheckCircle,
  X,
  Trash2,
  Activity,
  Key,
  Users as UsersIcon,
  ShieldCheck,
} from 'lucide-react';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/Table';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { RoleBadge } from '@/components/super-admin/shared/RoleBadge';
import { ActionMenu, type ActionMenuItem } from '@/components/super-admin/shared/ActionMenu';
import { useQueryClient } from '@tanstack/react-query';
import { adminsApi } from '@/api/super-admin/admins';
import { useAdmins } from '@/hooks/useAdmins';
import { useRoles } from '@/hooks/useRoles';
import { useAuth } from '@/hooks/useAuth';
import { formatDate, formatRelativeTime } from '@/utils/formatDate';
import { displayRole } from '@/utils/displayRole';
import { generatePassword } from '@/utils/generatePassword';
import { AdminForm, type AdminFormValues } from '@/components/super-admin/forms/AdminForm';
import { PasswordResetResultModal } from '@/components/super-admin/modals/PasswordResetResultModal';
import { cn } from '@/lib/utils';
import type { AdminUser, AdminRoleDefinition } from '@/types/super-admin';

// ── Helpers ──────────────────────────────────────────────────────────────────

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

function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

// ── Main Component ────────────────────────────────────────────────────────────

export function SAAdminManagement() {
  const { user } = useAuth();
  const currentUserId = user?.id ?? '';
  const qc = useQueryClient();
  const adminsQuery = useAdmins();
  const rolesQuery = useRoles();
  const admins: AdminUser[] = adminsQuery.data ?? [];
  const roleDefs: AdminRoleDefinition[] = rolesQuery.data ?? [];

  const adminsById = useMemo(() => {
    const map = new Map<string, AdminUser>();
    for (const a of admins) map.set(a.id, a);
    return map;
  }, [admins]);

  const invalidateAdminsAndRoles = () => {
    qc.invalidateQueries({ queryKey: ['admin', 'admins'] });
    qc.invalidateQueries({ queryKey: ['admin', 'roles'] });
  };

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
      role: displayRole(admin, roleDefs),
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
        if (displayRole(editingAdmin, roleDefs) !== values.role) {
          setConfirmModal({ open: true, type: 'role_change', admin: editingAdmin, pendingData: values });
          return;
        }
        const def = roleDefs.find(r => r.name === values.role);
        if (!def) {
          setApiError('Selected role not found. Please refresh the page or select a different role.');
          return;
        }
        await adminsApi.update(editingAdmin.id, {
          name:    values.name,
          email:   values.email,
          role_id: def.id,
        });
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
      invalidateAdminsAndRoles();
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
      const def = roleDefs.find(r => r.name === confirmModal.pendingData!.role);
      if (!def) {
        setApiError('Selected role not found. Please refresh the page or select a different role.');
        return;
      }
      await adminsApi.update(admin.id, {
        name:    confirmModal.pendingData.name,
        email:   confirmModal.pendingData.email,
        role_id: def.id,
      });
      setModalOpen(false);
    }

    invalidateAdminsAndRoles();
    setConfirmModal({ open: false, type: 'suspend', admin: null });
  }

  const totals = useMemo(() => {
    let active = 0;
    let suspended = 0;
    let supers = 0;
    for (const a of admins) {
      if (a.status === 'active' || !a.status) active++;
      if (a.status === 'suspended') suspended++;
      if (a.role === 'superadmin') supers++;
    }
    return { total: admins.length, active, suspended, supers };
  }, [admins]);

  const superAdminCount = totals.supers;

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    if (!q) return admins;
    return admins.filter((a) =>
      a.name.toLowerCase().includes(q) ||
      a.email.toLowerCase().includes(q) ||
      displayRole(a, roleDefs).toLowerCase().includes(q),
    );
  }, [admins, roleDefs, search]);

  const isLoading = adminsQuery.isPending;

  // ── Render ──────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-text-main">Admin Management</h1>
          <p className="text-sm text-text-muted mt-1">
            Manage operator and back-office accounts, roles, and access.
          </p>
        </div>
        <Button onClick={openAdd} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Add Admin
        </Button>
      </div>

      {/* KPI strip */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KpiTile label="Total admins"   value={totals.total}     accent="text-text-main"  icon={UsersIcon} />
        <KpiTile label="Active"          value={totals.active}    accent="text-success"    icon={CheckCircle} />
        <KpiTile label="Suspended"       value={totals.suspended} accent="text-warning"    icon={Ban} />
        <KpiTile label="Super admins"    value={totals.supers}    accent="text-primary"    icon={ShieldCheck} />
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
            <span className="text-sm text-text-muted tabular-nums">
              Showing {filtered.length} of {admins.length}
            </span>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs uppercase tracking-wide">Name / Email</TableHead>
                  <TableHead className="text-xs uppercase tracking-wide">Role</TableHead>
                  <TableHead className="text-xs uppercase tracking-wide">Status</TableHead>
                  <TableHead className="text-xs uppercase tracking-wide">Last Login</TableHead>
                  <TableHead className="text-xs uppercase tracking-wide">Created By</TableHead>
                  <TableHead className="text-xs uppercase tracking-wide">Date Created</TableHead>
                  <TableHead className="text-xs uppercase tracking-wide text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading && Array.from({ length: 4 }).map((_, i) => <SkeletonRow key={i} />)}

                {!isLoading && filtered.length === 0 && (
                  <TableRow className="hover:bg-transparent">
                    <TableCell colSpan={7} className="py-12">
                      <EmptyState
                        searching={search.length > 0}
                        onClear={() => setSearch('')}
                        onAdd={openAdd}
                      />
                    </TableCell>
                  </TableRow>
                )}

                {!isLoading && filtered.map((admin) => {
                  const isSelf = admin.id === currentUserId;
                  const isLastSuperAdmin =
                    admin.role === 'superadmin' && superAdminCount === 1;
                  const canAct = !isSelf && !isLastSuperAdmin;
                  const role = displayRole(admin, roleDefs);

                  const creatorName = admin.created_by
                    ? adminsById.get(admin.created_by)?.name ?? null
                    : null;

                  const items: ActionMenuItem[] = [
                    {
                      key: 'activity',
                      label: 'View activity',
                      icon: Activity,
                      asLink: { to: `/super-admin/audit?actor_id=${admin.id}` },
                    },
                    {
                      key: 'edit',
                      label: 'Edit admin',
                      icon: Pencil,
                      onClick: () => openEdit(admin),
                    },
                  ];

                  if (canAct && admin.status !== 'deactivated') {
                    items.push({
                      key: 'reset',
                      label: 'Reset password',
                      icon: Key,
                      onClick: () => setConfirmModal({ open: true, type: 'reset_password', admin }),
                      separatorBefore: true,
                    });
                    items.push({
                      key: 'suspend',
                      label: admin.status === 'suspended' ? 'Reactivate' : 'Suspend',
                      icon: admin.status === 'suspended' ? CheckCircle : Ban,
                      variant: 'warning',
                      onClick: () =>
                        setConfirmModal({
                          open: true,
                          type: admin.status === 'suspended' ? 'activate' : 'suspend',
                          admin,
                        }),
                    });
                    items.push({
                      key: 'deactivate',
                      label: 'Deactivate',
                      icon: Trash2,
                      variant: 'danger',
                      onClick: () => setConfirmModal({ open: true, type: 'deactivate', admin }),
                    });
                  }

                  return (
                    <TableRow key={admin.id}>
                      {/* Name / Email */}
                      <TableCell>
                        <div className="flex items-center gap-3 min-w-[14rem]">
                          <div
                            className={cn(
                              'flex-shrink-0 w-9 h-9 rounded-full flex items-center justify-center text-xs font-semibold',
                              admin.role === 'superadmin'
                                ? 'bg-warning/10 text-warning'
                                : 'bg-primary/10 text-primary',
                            )}
                            aria-hidden="true"
                          >
                            {getInitials(admin.name)}
                          </div>
                          <div className="min-w-0">
                            <p className="font-semibold text-text-main truncate">{admin.name}</p>
                            <p className="text-xs text-text-muted truncate">{admin.email}</p>
                          </div>
                        </div>
                      </TableCell>

                      {/* Role */}
                      <TableCell>
                        <RoleBadge role={role} />
                      </TableCell>

                      {/* Status */}
                      <TableCell>
                        <StatusBadge status={admin.status || 'active'} />
                      </TableCell>

                      {/* Last Login */}
                      <TableCell className="text-sm text-text-muted">
                        {admin.last_login_at ? (
                          <div className="flex flex-col leading-tight">
                            <span className="text-text-main">{formatDate(admin.last_login_at)}</span>
                            <span className="text-xs text-text-muted/80">
                              {formatRelativeTime(admin.last_login_at)}
                            </span>
                          </div>
                        ) : (
                          <span className="text-text-muted/50" aria-label="Never logged in">—</span>
                        )}
                      </TableCell>

                      {/* Created By */}
                      <TableCell className="text-sm">
                        {!admin.created_by ? (
                          <span className="text-xs italic text-text-muted">System</span>
                        ) : creatorName ? (
                          <span className="text-text-main">{creatorName}</span>
                        ) : (
                          <span className="text-xs italic text-text-muted">Unknown</span>
                        )}
                      </TableCell>

                      {/* Created */}
                      <TableCell className="text-sm text-text-muted">
                        {admin.created_at ? formatDate(admin.created_at) : 'Unknown'}
                      </TableCell>

                      {/* Actions */}
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-1">
                          {!canAct ? (
                            // Self-row and last-superadmin: only View activity + Edit are
                            // available; render inline so the two routine actions stay
                            // one click away.
                            <>
                              <Link
                                to={`/super-admin/audit?actor_id=${admin.id}`}
                                aria-label="View activity"
                                title="View activity"
                                className="inline-flex items-center justify-center rounded-lg p-2 text-text-muted hover:bg-surface-hover hover:text-text-main transition-colors"
                              >
                                <Activity className="w-4 h-4" />
                              </Link>
                              <button
                                type="button"
                                onClick={() => openEdit(admin)}
                                aria-label="Edit admin"
                                title="Edit admin"
                                className="inline-flex items-center justify-center rounded-lg p-2 text-text-muted hover:bg-surface-hover hover:text-text-main transition-colors"
                              >
                                <Pencil className="w-4 h-4" />
                              </button>
                            </>
                          ) : (
                            <ActionMenu items={items} />
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
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 animate-[adminmodal-fade_120ms_ease-out]">
          <div className="bg-surface border border-border rounded-2xl w-full max-w-md shadow-2xl animate-[adminmodal-pop_150ms_ease-out]">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border">
              <div>
                <h2 className="text-base font-semibold text-text-main">
                  {editingAdmin ? 'Edit admin' : 'Add admin'}
                </h2>
                <p className="text-xs text-text-muted mt-0.5">
                  {editingAdmin
                    ? `Update ${editingAdmin.name}'s account details and role.`
                    : 'Create a new back-office account with role-based permissions.'}
                </p>
              </div>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => { setApiError(null); setModalOpen(false); }}
                aria-label="Close"
              >
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

          <style>{`
            @keyframes adminmodal-fade { from { opacity: 0; } to { opacity: 1; } }
            @keyframes adminmodal-pop {
              from { opacity: 0; transform: scale(0.97); }
              to   { opacity: 1; transform: scale(1); }
            }
          `}</style>
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

// ── Sub-components ────────────────────────────────────────────────────────────

interface KpiTileProps {
  label: string;
  value: number;
  accent: string;
  icon: React.ComponentType<{ className?: string }>;
}

function KpiTile({ label, value, accent, icon: Icon }: KpiTileProps) {
  return (
    <div className="flex items-center gap-3 rounded-xl border border-border bg-surface px-4 py-3">
      <div className={cn('w-9 h-9 rounded-lg flex items-center justify-center bg-background', accent)}>
        <Icon className="w-4 h-4" />
      </div>
      <div className="min-w-0">
        <p className="text-xs uppercase tracking-wide text-text-muted">{label}</p>
        <p className={cn('text-xl font-bold tabular-nums leading-tight', accent)}>{value}</p>
      </div>
    </div>
  );
}

function SkeletonRow() {
  return (
    <TableRow className="hover:bg-transparent">
      <TableCell>
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-border/40 animate-pulse" />
          <div className="space-y-1.5">
            <div className="h-3 w-32 bg-border/40 rounded animate-pulse" />
            <div className="h-2 w-40 bg-border/30 rounded animate-pulse" />
          </div>
        </div>
      </TableCell>
      {Array.from({ length: 5 }).map((_, i) => (
        <TableCell key={i}><div className="h-3 w-20 bg-border/40 rounded animate-pulse" /></TableCell>
      ))}
      <TableCell className="text-right"><div className="h-3 w-8 bg-border/40 rounded animate-pulse ml-auto" /></TableCell>
    </TableRow>
  );
}

interface EmptyStateProps {
  searching: boolean;
  onClear: () => void;
  onAdd: () => void;
}

function EmptyState({ searching, onClear, onAdd }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center text-center gap-3">
      <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center">
        <UsersIcon className="w-5 h-5 text-primary" />
      </div>
      <div>
        <p className="text-sm font-semibold text-text-main">
          {searching ? 'No admins match your search' : 'No admins yet'}
        </p>
        <p className="text-xs text-text-muted mt-1">
          {searching
            ? 'Try a different name, email, or role.'
            : 'Create the first back-office account to get started.'}
        </p>
      </div>
      {searching ? (
        <Button variant="outline" size="sm" onClick={onClear}>
          Clear search
        </Button>
      ) : (
        <Button size="sm" onClick={onAdd} className="gap-2">
          <Plus className="w-4 h-4" />
          Add Admin
        </Button>
      )}
    </div>
  );
}
