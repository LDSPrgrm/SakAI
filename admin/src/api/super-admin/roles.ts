import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { Role, RolePermission } from '@/types/super-admin';

export type { Role, RolePermission };

export interface CreateRolePayload {
  name: string;
  description: string;
  permissions: RolePermission[];
}

export const rolesApi = {
  list: () =>
    adminRequest<unknown>('GET', '/roles').then(extractArray<Role>),

  /** GET /admin/roles/{id} — fetch a single role definition (M2). */
  get: (id: string) =>
    adminRequest<Role>('GET', `/roles/${id}`),

  getPermissions: (id: string) =>
    adminRequest<unknown>('GET', `/roles/${id}/permissions`)
      .then(extractArray<RolePermission>),

  create: (data: CreateRolePayload) =>
    adminRequest<Role>('POST', '/roles', data),

  update: (id: string, data: Partial<CreateRolePayload>) =>
    adminRequest<Role>('PUT', `/roles/${id}`, data),

  delete: (id: string) =>
    adminRequestVoid('DELETE', `/roles/${id}`),

  duplicate: (id: string) =>
    adminRequest<Role>('POST', `/roles/${id}/duplicate`),

  getAdmins: (id: string) =>
    adminRequest<unknown>('GET', `/roles/${id}/admins`)
      .then(extractArray),
};
