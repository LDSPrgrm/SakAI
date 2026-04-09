import type { components } from '@/types/openapi';

export type Role              = components['schemas']['Role'];
export type RolePermission    = components['schemas']['RolePermission'];
export type CreateRoleRequest = components['schemas']['CreateRoleRequest'];
export type UpdateRoleRequest = components['schemas']['UpdateRoleRequest'];

// Permission keys (spec superadmin.md §3.2)
export type PermissionKey =
  | 'dashboard' | 'admin_management' | 'role_management' | 'fare_config'
  | 'payments'  | 'payouts'          | 'user_management'  | 'kyc_verification'
  | 'safety_incidents' | 'reports'   | 'system_config'    | 'system_health'
  | 'audit_log' | 'ltfrb_compliance';
