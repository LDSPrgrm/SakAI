import type { components } from '@/types/openapi';
import type { PermissionKey } from '@/utils/permissions';

export type { PermissionKey };

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
