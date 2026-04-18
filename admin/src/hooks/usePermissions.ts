// Dynamic RBAC hook — caches the current admin's role + permissions in Zustand.
// Permissions are fetched from GET /api/admin/roles/:id/permissions on auth.
// Spec: superadmin.md §3 (Dynamic RBAC)

import { create } from 'zustand';
import { useAuth } from '@/contexts/AuthContext';
import { tokenStore } from '@/lib/api';

// Permission keys defined by the spec (superadmin.md §3.2)
export type PermissionKey =
  | 'dashboard'
  | 'admin_management'
  | 'role_management'
  | 'fare_config'
  | 'payments'
  | 'payouts'
  | 'user_management'
  | 'kyc_verification'
  | 'safety_incidents'
  | 'reports'
  | 'system_config'
  | 'system_health'
  | 'audit_log'
  | 'ltfrb_compliance';

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

const BASE_URL = (import.meta.env.VITE_API_URL as string) || 'http://192.168.100.43/api';

async function fetchRolePermissions(roleId: string): Promise<Role> {
  const token = tokenStore.getAccess();
  const res = await fetch(`${BASE_URL}/admin/roles/${roleId}/permissions`, {
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (!res.ok) throw new Error(`Failed to load permissions (${res.status})`);
  const json = await res.json();
  // Unwrap the standard envelope if present
  const role = (json?.data ?? json) as Role;
  // Normalize backend "superadmin" → "super_admin"
  if (role?.name === 'superadmin') role.name = 'super_admin';
  return role;
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
    // super_admin is immutable and always allowed — check both the auth context
    // (available immediately from the JWT) and the loaded role (from the permissions API)
    if (user?.role === 'super_admin' || role?.name === 'super_admin') return true;
    const entry = permissions.find((p) => p.permission_key === key);
    if (!entry) return false;
    return scope === 'read' ? entry.read || entry.write : entry.write;
  };

  return { can, role, permissions, loading, error, loadPermissions, clear };
}
