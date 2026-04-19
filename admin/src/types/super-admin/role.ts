import type { components } from '@/types/openapi';

// Permission keys (spec superadmin.md §3.2)
export type PermissionKey =
  | 'dashboard' | 'admin_management' | 'role_management' | 'fare_config'
  | 'payments'  | 'payouts'          | 'user_management'  | 'kyc_verification'
  | 'safety_incidents' | 'reports'   | 'system_config'    | 'system_health'
  | 'audit_log' | 'ltfrb_compliance';

// Form-facing RolePermission: keys required so form state matches schema.
export interface RolePermission {
  permission_key: PermissionKey | string;
  read: boolean;
  write: boolean;
}

type BaseRole = components['schemas']['Role'];
export type Role = Omit<BaseRole, 'permissions'> & {
  permissions?: RolePermission[];
};

export interface CreateRoleRequest {
  name: string;
  description?: string;
  permissions: RolePermission[];
}

export interface UpdateRoleRequest {
  name: string;
  description?: string;
  permissions: RolePermission[];
}
