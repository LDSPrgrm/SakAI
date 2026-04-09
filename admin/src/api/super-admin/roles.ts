import { adminRequest, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type Role           = components['schemas']['Role'];
export type RolePermission = components['schemas']['RolePermission'];

export interface CreateRolePayload {
  name: string;
  description: string;
  permissions: RolePermission[];
}

export const rolesApi = {
  list: () =>
    adminRequest<unknown>('GET', '/roles').then(extractArray<Role>),

  getPermissions: (id: string) =>
    adminRequest<unknown>('GET', `/roles/${id}/permissions`)
      .then(extractArray<RolePermission>),

  create: (data: CreateRolePayload) =>
    adminRequest<Role>('POST', '/roles', data),

  update: (id: string, data: Partial<CreateRolePayload>) =>
    adminRequest<Role>('PUT', `/roles/${id}`, data),

  delete: (id: string) =>
    adminRequest<void>('DELETE', `/roles/${id}`),

  duplicate: (id: string) =>
    adminRequest<Role>('POST', `/roles/${id}/duplicate`),

  getAdmins: (id: string) =>
    adminRequest<unknown>('GET', `/roles/${id}/admins`)
      .then(extractArray),
};
