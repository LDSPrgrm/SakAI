import React, { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Plus, Pencil, Copy, Trash2, X, Users, Eye } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/Table';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { ActionMenu, type ActionMenuItem } from '@/components/super-admin/shared/ActionMenu';
import { RoleBadge } from '@/components/super-admin/shared/RoleBadge';
import {
  useRoles, useCreateRole, useUpdateRole, useDeleteRole, useDuplicateRole,
} from '@/hooks/useRoles';
import { formatDate } from '@/utils/formatDate';
import {
  PermissionGrid, PERM_ROWS, emptyGrid, parsePermissions, toPermissions,
  type PermGrid,
} from '@/components/super-admin/forms/PermissionGrid';
import type { AdminRoleDefinition, RolePermissionKey } from '@/types/super-admin';

// ── Zod schema ────────────────────────────────────────────────────────────────

const roleSchema = z.object({
  name: z.string().min(1, 'Role name is required'),
  description: z.string().optional(),
});

type RoleFormValues = z.infer<typeof roleSchema>;

// ── Permission grid rows ──────────────────────────────────────────────────────


// ── Helpers ───────────────────────────────────────────────────────────────────

function displayName(name: string): string {
  return name.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

// ── Main Component ────────────────────────────────────────────────────────────

export function SARoleManagement() {
  const rolesQuery = useRoles();
  const createRole = useCreateRole();
  const updateRole = useUpdateRole();
  const deleteRole = useDeleteRole();
  const duplicateRole = useDuplicateRole();
  const roles = (rolesQuery.data ?? []) as unknown as AdminRoleDefinition[];

  const [modalOpen, setModalOpen] = useState(false);
  const [editingRole, setEditingRole] = useState<AdminRoleDefinition | null>(null);
  const [viewingRole, setViewingRole] = useState<AdminRoleDefinition | null>(null);
  const [permGrid, setPermGrid] = useState<PermGrid>(emptyGrid());
  const [permError, setPermError] = useState('');
  const [permWarning, setPermWarning] = useState('');

  const [deleteConfirm, setDeleteConfirm] = useState<{
    open: boolean;
    role: AdminRoleDefinition | null;
  }>({ open: false, role: null });

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } =
    useForm<RoleFormValues>({ resolver: zodResolver(roleSchema) });

  // ── ESC close + body scroll lock for modals ───────────────────────────────

  useEffect(() => {
    const isOpen = modalOpen || !!viewingRole;
    if (!isOpen) return;
    function onKey(event: KeyboardEvent) {
      if (event.key !== 'Escape') return;
      if (viewingRole) setViewingRole(null);
      else setModalOpen(false);
    }
    document.addEventListener('keydown', onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [modalOpen, viewingRole]);

  // ── Open helpers ──────────────────────────────────────────────────────────

  function openAdd() {
    setEditingRole(null);
    setPermGrid(emptyGrid());
    setPermError('');
    setPermWarning('');
    reset({ name: '', description: '' });
    setModalOpen(true);
  }

  function openEdit(role: AdminRoleDefinition) {
    const { grid, unknownKeys } = parsePermissions(role.permissions);
    setEditingRole(role);
    setPermGrid(grid);
    setPermError('');
    setPermWarning(
      unknownKeys.length > 0
        ? `${unknownKeys.length} unrecognized permission key(s) on this role were dropped from the editor (${unknownKeys.join(', ')}). Saving overwrites them.`
        : '',
    );
    reset({ name: role.name, description: role.description ?? '' });
    setModalOpen(true);
  }

  function openView(role: AdminRoleDefinition) {
    setViewingRole(role);
    setPermGrid(parsePermissions(role.permissions).grid);
  }

  // ── Form submit ───────────────────────────────────────────────────────────

  async function onSubmit(values: RoleFormValues) {
    const permissions = toPermissions(permGrid);
    if (permissions.length === 0) {
      setPermError('At least one permission must be enabled.');
      return; // early return — keeps modal open so user sees the error
    }
    setPermError('');

    const body = {
      name: values.name.trim(),
      description: (values.description ?? '').trim(),
      permissions,
    };

    if (editingRole) {
      await updateRole.mutateAsync({ id: editingRole.id, data: body });
    } else {
      await createRole.mutateAsync(body);
    }

    setModalOpen(false);
  }

  // ── Permission grid handlers ───────────────────────────────────────────────

  function handlePermChange(key: RolePermissionKey, scope: 'read' | 'write', value: boolean) {
    setPermGrid((prev) => {
      const cell = { ...prev[key] };
      cell[scope] = value;
      if (scope === 'write' && value) cell.read = true;
      if (scope === 'read' && !value) cell.write = false;
      return { ...prev, [key]: cell };
    });
    setPermError('');
  }

  function handleSelectAllRead() {
    setPermGrid((prev) => {
      const next = { ...prev };
      PERM_ROWS.forEach((r) => { next[r.key] = { ...next[r.key], read: true }; });
      return next;
    });
    setPermError('');
  }

  function handleSelectAllWrite() {
    setPermGrid((prev) => {
      const next = { ...prev };
      PERM_ROWS.forEach((r) => { if (r.hasWrite) next[r.key] = { ...next[r.key], write: true }; });
      return next;
    });
    setPermError('');
  }

  function handleClearAll() {
    setPermGrid(emptyGrid());
  }

  // ── Duplicate / delete ────────────────────────────────────────────────────

  async function handleDuplicate(role: AdminRoleDefinition) {
    await duplicateRole.mutateAsync(role.id);
  }

  async function handleDelete() {
    if (!deleteConfirm.role) return;
    await deleteRole.mutateAsync(deleteConfirm.role.id);
    setDeleteConfirm({ open: false, role: null });
  }

  // ── Render ────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">Role Management</h1>
        <Button onClick={openAdd} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Create Role
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Roles</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Role Name</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Origin</TableHead>
                  <TableHead>Active Admins</TableHead>
                  <TableHead>Permissions</TableHead>
                  <TableHead>Date Created</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {roles.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center text-text-muted py-10">
                      No roles found.
                    </TableCell>
                  </TableRow>
                ) : roles.map((role) => {
                  const isSuper = role.name === 'super_admin';
                  const adminCount = role.admin_count ?? 0;
                  const reads = role.permissions.filter((p) => p.read).length;
                  const writes = role.permissions.filter((p) => p.write).length;

                  const items: ActionMenuItem[] = [
                    {
                      key: 'view',
                      label: 'View permissions',
                      icon: Eye,
                      onClick: () => openView(role),
                    },
                  ];
                  if (!isSuper) {
                    items.push({
                      key: 'edit',
                      label: 'Edit role',
                      icon: Pencil,
                      onClick: () => openEdit(role),
                    });
                  }
                  if (!role.is_system) {
                    items.push({
                      key: 'duplicate',
                      label: 'Duplicate role',
                      icon: Copy,
                      onClick: () => { handleDuplicate(role).catch(() => {}); },
                    });
                    if (adminCount === 0) {
                      items.push({
                        key: 'delete',
                        label: 'Delete role',
                        icon: Trash2,
                        variant: 'danger',
                        separatorBefore: true,
                        onClick: () => setDeleteConfirm({ open: true, role }),
                      });
                    }
                  }

                  return (
                    <TableRow key={role.id} className={role.is_system ? 'opacity-70' : ''}>
                      <TableCell className="font-semibold text-text-main">
                        {displayName(role.name)}
                      </TableCell>
                      <TableCell className="text-sm text-text-muted max-w-[180px] truncate">
                        {role.description || '—'}
                      </TableCell>
                      <TableCell>
                        <RoleBadge role={isSuper ? 'superadmin' : 'admin'} />
                      </TableCell>
                      <TableCell>
                        <StatusBadge status={role.is_system ? 'system' : 'custom'} />
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-1.5 text-sm text-text-muted">
                          <Users className="w-3.5 h-3.5" />
                          {adminCount}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-1.5 text-xs">
                          <span
                            className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-background border border-border text-text-muted"
                            title={`${reads} read permission${reads === 1 ? '' : 's'}`}
                          >
                            <Eye className="w-3 h-3" />
                            {reads}
                          </span>
                          <span
                            className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-background border border-border text-text-muted"
                            title={`${writes} write permission${writes === 1 ? '' : 's'}`}
                          >
                            <Pencil className="w-3 h-3" />
                            {writes}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="text-sm text-text-muted">
                        {role.created_at ? formatDate(role.created_at) : '—'}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end">
                          <ActionMenu items={items} />
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

      {/* ── Create / Edit Modal ── */}
      {modalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
          <div
            className="absolute inset-0 bg-black/60 animate-[role-fade_120ms_ease-out]"
            onClick={() => setModalOpen(false)}
          />
          <div className="relative bg-surface border border-border rounded-xl w-full max-w-2xl shadow-2xl max-h-[90vh] flex flex-col animate-[role-pop_150ms_ease-out]">
            {/* Header */}
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border flex-shrink-0">
              <h2 className="text-base font-semibold text-text-main">
                {editingRole ? `Edit Role — ${displayName(editingRole.name)}` : 'Create Role'}
              </h2>
              <Button variant="ghost" size="icon" onClick={() => setModalOpen(false)}>
                <X className="w-4 h-4" />
              </Button>
            </div>

            {/* Body */}
            <form
              id="role-form"
              onSubmit={handleSubmit(onSubmit)}
              className="overflow-y-auto flex-1 px-6 py-5 space-y-5"
            >
              {/* Role Name */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">Role Name</label>
                <Input
                  {...register('name')}
                  placeholder="e.g. City Manager"
                  className={errors.name ? 'border-danger' : ''}
                />
                {errors.name && (
                  <p className="text-xs text-danger mt-1">{errors.name.message}</p>
                )}
              </div>

              {/* Description */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">Description</label>
                <Input
                  {...register('description')}
                  placeholder="Brief description of this role's purpose"
                />
              </div>

              {/* Permission Grid */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-2">
                  Permission Grid
                </label>
                <PermissionGrid
                  grid={permGrid}
                  onChange={handlePermChange}
                  onSelectAllRead={handleSelectAllRead}
                  onSelectAllWrite={handleSelectAllWrite}
                  onClearAll={handleClearAll}
                />
                {permError && (
                  <p className="text-xs text-danger mt-2">{permError}</p>
                )}
                {permWarning && (
                  <p className="text-xs text-warning mt-2">{permWarning}</p>
                )}
              </div>

              {editingRole && (editingRole.admin_count ?? 0) > 0 && (
                <p className="text-sm text-warning">
                  Warning: {editingRole.admin_count} admin(s) will be affected by this change.
                </p>
              )}
            </form>

            {/* Footer */}
            <div className="flex justify-end gap-3 px-6 py-4 border-t border-border flex-shrink-0">
              <Button type="button" variant="outline" size="sm"
                onClick={() => setModalOpen(false)}>
                Cancel
              </Button>
              <Button type="submit" form="role-form" size="sm" disabled={isSubmitting}>
                {isSubmitting ? 'Saving…' : editingRole ? 'Save Changes' : 'Create Role'}
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* ── View Permissions Modal ── */}
      {viewingRole && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
          <div
            className="absolute inset-0 bg-black/60 animate-[role-fade_120ms_ease-out]"
            onClick={() => setViewingRole(null)}
          />
          <div className="relative bg-surface border border-border rounded-xl w-full max-w-2xl shadow-2xl max-h-[90vh] flex flex-col animate-[role-pop_150ms_ease-out]">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border flex-shrink-0">
              <h2 className="text-base font-semibold text-text-main">
                Permissions — {displayName(viewingRole.name)}
              </h2>
              <Button variant="ghost" size="icon" onClick={() => setViewingRole(null)}>
                <X className="w-4 h-4" />
              </Button>
            </div>
            <div className="overflow-y-auto flex-1 px-6 py-5 space-y-4">
              {viewingRole.name === 'super_admin' && (
                <div className="flex items-center gap-2 p-3 bg-background rounded-lg border border-border">
                  <Badge variant="info">System role — cannot be modified</Badge>
                  {viewingRole.description && (
                    <span className="text-xs text-text-muted">{viewingRole.description}</span>
                  )}
                </div>
              )}
              <PermissionGrid grid={permGrid} onChange={() => {}} disabled />
            </div>
            <div className="flex justify-end px-6 py-4 border-t border-border flex-shrink-0">
              <Button variant="outline" size="sm" onClick={() => setViewingRole(null)}>Close</Button>
            </div>
          </div>
        </div>
      )}

      {/* ── Delete Confirm ── */}
      <ConfirmationModal
        open={deleteConfirm.open}
        title="Delete Role"
        description={`Delete the "${deleteConfirm.role?.name}" role? This action cannot be undone.`}
        variant="danger"
        confirmLabel="Delete"
        onConfirm={() => {
          handleDelete();
          setDeleteConfirm({ open: false, role: null });
        }}
        onCancel={() => setDeleteConfirm({ open: false, role: null })}
      />

      <style>{`
        @keyframes role-fade { from { opacity: 0; } to { opacity: 1; } }
        @keyframes role-pop {
          from { opacity: 0; transform: scale(0.97); }
          to   { opacity: 1; transform: scale(1); }
        }
      `}</style>
    </div>
  );
}
