import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { AdminUser } from '@/types/super-admin/admin';

export type { AdminUser };
export type AdminStatus = 'active' | 'suspended' | 'deactivated';

export interface CreateAdminPayload {
  name: string;
  email: string;
  role_id: string;
  password: string;
}

export const adminsApi = {
  list: () =>
    adminRequest<unknown>('GET', '/users').then(extractArray<AdminUser>),

  // TODO(spec, L4): POST /admin/users currently returns UserProfile in the spec;
  // the admin UI needs AdminUser (with role_id, role_name, status). Fill the extra
  // fields with safe defaults until the spec is updated to return AdminUser.
  create: (data: CreateAdminPayload) =>
    adminRequest<AdminUser>('POST', '/users', data).then((u) => ({
      ...u,
      role_id:  (u as AdminUser).role_id  ?? data.role_id,
      role_name: (u as AdminUser).role_name ?? '',
      status:   (u as AdminUser).status   ?? 'active',
    } as AdminUser)),

  /** PUT /admin/users/:id — backend only accepts { role } and returns 204. */
  update: (id: string, data: Partial<AdminUser> & { role?: string }) =>
    adminRequestVoid('PUT', `/users/${id}`, { role: data.role ?? '' }),

  deactivate: (id: string) =>
    adminRequestVoid('DELETE', `/users/${id}`),

  // TODO(spec, M4): PUT /admin/users/{id}/password not in swagger.yaml v1.2.0 — coordinate with backend
  resetPassword: (id: string, password: string) =>
    adminRequestVoid('PUT', `/users/${id}/password`, { password }),

  getActivity: (id: string) =>
    adminRequest<unknown>('GET', `/users/${id}/activity`),
};
