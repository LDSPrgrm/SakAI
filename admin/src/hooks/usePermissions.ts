// Dynamic RBAC hook — caches the current admin's role + permissions in Zustand.
// Permissions are fetched from GET /api/admin/roles/:id/permissions on auth.
// Spec: superadmin.md §3 (Dynamic RBAC)

import { create } from 'zustand';
import { useAuth } from '@/contexts/AuthContext';
import { adminRequest } from '@/api/super-admin/_request';
import type { PermissionKey } from '@/utils/permissions';

export type { PermissionKey };
export type PermissionScope = 'read' | 'write';

export interface RolePermission {
  permission_key: PermissionKey;
  read: boolean;
  write: boolean;
}

export interface Role {
  id: string;
  name: string;
  description?: string;
  is_system?: boolean;
  permissions: RolePermission[];
}

interface PermissionsState {
  role: Role | null;
  permissions: RolePermission[];
  loading: boolean;
  error: string | null;
  loadPermissions: (roleId: string) => Promise<void>;
  clear: () => void;
}

// Uses adminRequest so token refresh on 401 and the shared envelope-unwrap
// logic apply. The role payload matches the `Role` shape above.
async function fetchRolePermissions(roleId: string): Promise<Role> {
  return adminRequest<Role>('GET', `/roles/${roleId}/permissions`);
}

export const usePermissionsStore = create<PermissionsState>((set) => ({
  role: null,
  permissions: [],
  loading: false,
  error: null,
  async loadPermissions(roleId: string) {
    set({ loading: true, error: null });
    try {
      const role = await fetchRolePermissions(roleId);
      set({ role, permissions: role.permissions ?? [], loading: false });
    } catch (err) {
      set({
        loading: false,
        error: err instanceof Error ? err.message : 'Unknown error',
      });
    }
  },
  clear() {
    set({ role: null, permissions: [], loading: false, error: null });
  },
}));

/**
 * Hook used by components to gate UI based on the current admin's permissions.
 *
 * Usage:
 *   const { can } = usePermissions();
 *   if (!can('fare_config', 'write')) return <AccessDenied />;
 */
export function usePermissions() {
  const { user } = useAuth();
  const { role, permissions, loading, error, loadPermissions, clear } =
    usePermissionsStore();

  const can = (key: PermissionKey, scope: PermissionScope): boolean => {
    // superadmin is immutable and always allowed — check both the auth context
    // (available immediately from the JWT) and the loaded role (from the permissions API)
    if (user?.role === 'superadmin' || role?.name === 'superadmin') return true;
    const entry = permissions.find((p) => p.permission_key === key);
    if (!entry) return false;
    return scope === 'read' ? entry.read || entry.write : entry.write;
  };

  return { can, role, permissions, loading, error, loadPermissions, clear };
}
