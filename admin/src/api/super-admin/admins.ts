import { adminRequest, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type AdminUser = components['schemas']['AdminUser'];
export type AdminStatus = 'active' | 'suspended' | 'deactivated';

export interface CreateAdminPayload {
  name: string;
  email: string;
  role_id: string;
  password: string;
}

/** Normalize frontend role strings to the DB ENUM values the backend expects. */
function toBackendRole(role: string): string {
  if (role === 'super_admin') return 'superadmin';
  return role;
}

export const adminsApi = {
  list: () =>
    adminRequest<unknown>('GET', '/users').then(extractArray<AdminUser>),

  create: (data: CreateAdminPayload) =>
    adminRequest<AdminUser>('POST', '/users', data),

  /** PUT /admin/users/:id — backend only accepts { role } */
  update: (id: string, data: Partial<AdminUser> & { role?: string }) => {
    const role = toBackendRole(data.role ?? '');
    return adminRequest<AdminUser>('PUT', `/users/${id}`, { role });
  },

  deactivate: (id: string) =>
    adminRequest<void>('DELETE', `/users/${id}`),

  resetPassword: (id: string, password: string) =>
    adminRequest<void>('PUT', `/users/${id}/password`, { password }),

  getActivity: (id: string) =>
    adminRequest<unknown>('GET', `/users/${id}/activity`),
};
