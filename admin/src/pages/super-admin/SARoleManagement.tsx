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
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { rolesApi } from '@/api/super-admin/roles';
import type { AdminRoleDefinition, RolePermission, RolePermissionKey } from '@/types/super-admin';

// ── Zod schema ────────────────────────────────────────────────────────────────

const roleSchema = z.object({
  name: z.string().min(1, 'Role name is required'),
  description: z.string().optional(),
});

type RoleFormValues = z.infer<typeof roleSchema>;

// ── Permission grid rows ──────────────────────────────────────────────────────

interface PermRow {
  key: RolePermissionKey;
  label: string;
  hasWrite: boolean;
}

const PERM_ROWS: PermRow[] = [
  { key: 'dashboard',        label: 'Dashboard',          hasWrite: false },
  { key: 'admin_management', label: 'Admin Management',   hasWrite: true  },
  { key: 'role_management',  label: 'Role Management',    hasWrite: true  },
  { key: 'fare_config',      label: 'Fare Config',        hasWrite: true  },
  { key: 'payments',         label: 'Payments',           hasWrite: true  },
  { key: 'payouts',          label: 'Payouts',            hasWrite: true  },
  { key: 'user_management',  label: 'User Management',    hasWrite: true  },
  { key: 'kyc_verification', label: 'KYC Verification',   hasWrite: true  },
  { key: 'safety_incidents', label: 'Safety / Incidents', hasWrite: true  },
  { key: 'reports',          label: 'Reports',            hasWrite: true  },
  { key: 'system_config',    label: 'System Config',      hasWrite: true  },
  { key: 'system_health',    label: 'System Health',      hasWrite: false },
  { key: 'audit_log',        label: 'Audit Log',          hasWrite: false },
  { key: 'ltfrb_compliance', label: 'LTFRB Compliance',   hasWrite: true  },
];

type PermGrid = Record<RolePermissionKey, { read: boolean; write: boolean }>;

function emptyGrid(): PermGrid {
  return Object.fromEntries(
    PERM_ROWS.map((r) => [r.key, { read: false, write: false }])
  ) as PermGrid;
}

function fromPermissions(perms: RolePermission[]): PermGrid {
  const grid = emptyGrid();
  for (const p of perms) {
    if (grid[p.permission_key] !== undefined) {
      grid[p.permission_key] = { read: p.read, write: p.write };
    }
  }
  return grid;
}

function toPermissions(grid: PermGrid): RolePermission[] {
  return PERM_ROWS
    .filter((r) => grid[r.key].read || grid[r.key].write)
    .map((r) => ({
      permission_key: r.key,
      read: grid[r.key].read,
      write: r.hasWrite ? grid[r.key].write : false,
    }));
}

function permSummary(perms: RolePermission[]): string {
  const enabled = perms.filter((p) => p.read || p.write).length;
  return `${enabled} of ${PERM_ROWS.length}`;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString('en-PH', {
    year: 'numeric', month: 'short', day: 'numeric',
  });
}

function displayName(name: string): string {
  return name.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

// ── Permission Grid Component ─────────────────────────────────────────────────

function PermissionGrid({
  grid,
  onChange,
  onSelectAllRead,
  onSelectAllWrite,
  onClearAll,
  disabled,
}: {
  grid: PermGrid;
  onChange: (key: RolePermissionKey, scope: 'read' | 'write', value: boolean) => void;
  onSelectAllRead?: () => void;
  onSelectAllWrite?: () => void;
  onClearAll?: () => void;
  disabled?: boolean;
}) {
  return (
    <div className="space-y-3">
      {!disabled && (
        <div className="flex gap-2 text-xs flex-wrap">
          <button type="button" onClick={onSelectAllRead}
            className="px-2 py-1 rounded border border-border text-text-muted hover:text-text-main hover:border-primary transition-colors">
            Select All Read
          </button>
          <button type="button" onClick={onSelectAllWrite}
            className="px-2 py-1 rounded border border-border text-text-muted hover:text-text-main hover:border-primary transition-colors">
            Select All Write
          </button>
          <button type="button" onClick={onClearAll}
            className="px-2 py-1 rounded border border-border text-text-muted hover:text-danger hover:border-danger transition-colors">
            Clear All
          </button>
        </div>
      )}
      <div className="border border-border rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border bg-background">
              <th className="text-left px-3 py-2 font-medium text-text-muted">Permission</th>
              <th className="text-center px-3 py-2 font-medium text-text-muted w-20">Read</th>
              <th className="text-center px-3 py-2 font-medium text-text-muted w-20">Write</th>
            </tr>
          </thead>
          <tbody>
            {PERM_ROWS.map((row, idx) => {
              const cell = grid[row.key];
              return (
                <tr key={row.key} className={idx % 2 === 0 ? 'bg-surface' : 'bg-surface-hover'}>
                  <td className="px-3 py-2 text-text-main">{row.label}</td>
                  <td className="text-center px-3 py-2">
                    <input
                      type="checkbox"
                      checked={cell.read}
                      disabled={disabled}
                      onChange={(e) => onChange(row.key, 'read', e.target.checked)}
                      className="accent-primary w-4 h-4"
                    />
                  </td>
                  <td className="text-center px-3 py-2">
                    {row.hasWrite ? (
                      <input
                        type="checkbox"
                        checked={cell.write}
                        disabled={disabled}
                        onChange={(e) => onChange(row.key, 'write', e.target.checked)}
                        className="accent-primary w-4 h-4"
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
    </div>
  );
}

// ── Main Component ────────────────────────────────────────────────────────────

export function SARoleManagement() {
  const [roles, setRoles] = useState<AdminRoleDefinition[]>([]);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingRole, setEditingRole] = useState<AdminRoleDefinition | null>(null);
  const [viewingRole, setViewingRole] = useState<AdminRoleDefinition | null>(null);
  const [permGrid, setPermGrid] = useState<PermGrid>(emptyGrid());
  const [permError, setPermError] = useState('');

  const [deleteConfirm, setDeleteConfirm] = useState<{
    open: boolean;
    role: AdminRoleDefinition | null;
  }>({ open: false, role: null });

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } =
    useForm<RoleFormValues>({ resolver: zodResolver(roleSchema) });

  async function loadRoles() {
    const list = await rolesApi.list() as unknown as AdminRoleDefinition[];
    setRoles(list);
  }

  useEffect(() => { loadRoles().catch(() => {}); }, []);

  // ── Open helpers ──────────────────────────────────────────────────────────

  function openAdd() {
    setEditingRole(null);
    setPermGrid(emptyGrid());
    setPermError('');
    reset({ name: '', description: '' });
    setModalOpen(true);
  }

  function openEdit(role: AdminRoleDefinition) {
    setEditingRole(role);
    setPermGrid(fromPermissions(role.permissions));
    setPermError('');
    reset({ name: role.name, description: role.description ?? '' });
    setModalOpen(true);
  }

  function openView(role: AdminRoleDefinition) {
    setViewingRole(role);
    setPermGrid(fromPermissions(role.permissions));
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
      const updated = await rolesApi.update(editingRole.id, body) as unknown as AdminRoleDefinition;
      setRoles((prev) => prev.map((r) => r.id === editingRole.id ? updated : r));
    } else {
      const created = await rolesApi.create(body) as unknown as AdminRoleDefinition;
      setRoles((prev) => [created, ...prev]);
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
    const copy = await rolesApi.duplicate(role.id) as unknown as AdminRoleDefinition;
    setRoles((prev) => [...prev, copy]);
  }

  async function handleDelete() {
    if (!deleteConfirm.role) return;
    const id = deleteConfirm.role.id;
    await rolesApi.delete(id);
    setRoles((prev) => prev.filter((r) => r.id !== id));
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
                  <TableHead>Active Admins</TableHead>
                  <TableHead>Permissions</TableHead>
                  <TableHead>Date Created</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {roles.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} className="text-center text-text-muted py-10">
                      No roles found.
                    </TableCell>
                  </TableRow>
                ) : roles.map((role) => (
                  <TableRow key={role.id} className={role.is_system ? 'opacity-70' : ''}>
                    <TableCell className="font-semibold text-text-main">
                      {displayName(role.name)}
                    </TableCell>
                    <TableCell className="text-sm text-text-muted max-w-[180px] truncate">
                      {role.description || '—'}
                    </TableCell>
                    <TableCell>
                      <Badge variant={role.is_system ? 'info' : 'default'}>
                        {role.is_system ? 'System' : 'Custom'}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1.5 text-sm text-text-muted">
                        <Users className="w-3.5 h-3.5" />
                        {role.admin_count ?? 0}
                      </div>
                    </TableCell>
                    <TableCell className="text-sm text-text-muted">
                      {permSummary(role.permissions)}
                    </TableCell>
                    <TableCell className="text-sm text-text-muted">
                      {role.created_at ? formatDate(role.created_at) : '—'}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Button variant="ghost" size="icon" title="View permissions"
                          onClick={() => openView(role)}>
                          <Eye className="w-4 h-4" />
                        </Button>

                        {!role.is_system && (
                          <>
                            <Button variant="ghost" size="icon" title="Edit role"
                              onClick={() => openEdit(role)}>
                              <Pencil className="w-4 h-4" />
                            </Button>
                            <Button variant="ghost" size="icon" title="Duplicate role"
                              onClick={() => handleDuplicate(role).catch(() => {})}>
                              <Copy className="w-4 h-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="icon"
                              title={(role.admin_count ?? 0) > 0
                                ? 'Cannot delete — reassign admins first'
                                : 'Delete role'}
                              disabled={(role.admin_count ?? 0) > 0}
                              onClick={() => setDeleteConfirm({ open: true, role })}
                              className="text-danger hover:text-danger disabled:opacity-30"
                            >
                              <Trash2 className="w-4 h-4" />
                            </Button>
                          </>
                        )}

                        {role.is_system && (
                          <span className="text-xs text-text-muted italic px-2">System role</span>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* ── Create / Edit Modal ── */}
      {modalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-2xl shadow-xl max-h-[90vh] flex flex-col">
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
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-2xl shadow-xl max-h-[90vh] flex flex-col">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border flex-shrink-0">
              <h2 className="text-base font-semibold text-text-main">
                Permissions — {displayName(viewingRole.name)}
              </h2>
              <Button variant="ghost" size="icon" onClick={() => setViewingRole(null)}>
                <X className="w-4 h-4" />
              </Button>
            </div>
            <div className="overflow-y-auto flex-1 px-6 py-5 space-y-4">
              {viewingRole.is_system && (
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
      <ConfirmModal
        open={deleteConfirm.open}
        title="Delete Role"
        message={`Delete the "${deleteConfirm.role?.name}" role? This action cannot be undone.`}
        variant="danger"
        confirmLabel="Delete"
        onConfirm={handleDelete}
        onClose={() => setDeleteConfirm({ open: false, role: null })}
      />
    </div>
  );
}
