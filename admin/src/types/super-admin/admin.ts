// Admin user types — override the openapi-generated AdminUser so the role
// field accepts admin role values instead of the UserProfile (passenger|driver) union.
import type { components } from '@/types/openapi';

export type AdminStatus = 'active' | 'suspended' | 'deactivated';
export type AdminRole   = 'admin' | 'superadmin' | 'operations' | 'finance' | 'support';

type BaseAdminUser = components['schemas']['AdminUser'];

export type AdminUser = Omit<BaseAdminUser, 'role' | 'status'> & {
  // Base privilege enum; lossy for user-created custom roles (backend maps unknown
  // names → "admin"). For display labels, resolve via role_id using displayRole().
  role: AdminRole;
  status?: AdminStatus;
};

export type { AdminUser as default };
