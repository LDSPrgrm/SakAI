// Admin user types — override the openapi-generated AdminUser so the role
// field accepts super-admin role values instead of the UserProfile union.
import type { components } from '@/types/openapi';

export type AdminStatus = 'active' | 'suspended' | 'deactivated';
export type AdminRole   = 'super_admin' | 'operations' | 'finance' | 'support';

type BaseAdminUser = components['schemas']['AdminUser'];

export type AdminUser = Omit<BaseAdminUser, 'role' | 'status'> & {
  role: AdminRole;
  status?: AdminStatus;
};

export type { AdminUser as default };
