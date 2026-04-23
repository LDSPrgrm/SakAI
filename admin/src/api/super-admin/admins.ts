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

export interface UpdateAdminPayload {
  name?:   string;
  email?:  string;
  role_id: string;
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

  /** PUT /admin/users/:id — updates name / email / role_id. Returns 204. */
  update: (id: string, data: UpdateAdminPayload) =>
    adminRequestVoid('PUT', `/users/${id}`, {
      ...(data.name  !== undefined ? { name:  data.name  } : {}),
      ...(data.email !== undefined ? { email: data.email } : {}),
      role_id: data.role_id,
    }),

  deactivate: (id: string) =>
    adminRequestVoid('DELETE', `/users/${id}`),

  resetPassword: (id: string, password: string) =>
    adminRequestVoid('PUT', `/users/${id}/password`, { new_password: password }),

  getActivity: (id: string) =>
    adminRequest<unknown>('GET', `/users/${id}/activity`),
};
