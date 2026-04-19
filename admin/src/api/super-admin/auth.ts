import { adminRequest, adminRequestVoid } from './_request';
import type { AdminUser } from '@/types/super-admin/admin';
import type { components } from '@/types/openapi';

export type ChangePasswordRequest = components['schemas']['ChangePasswordRequest'];

export const authApi = {
  me: () => adminRequest<AdminUser>('GET', '/users/me'),

  /** PUT /admin/auth/password — self-service password change, returns 204. */
  changePassword: (payload: ChangePasswordRequest) =>
    adminRequestVoid('PUT', '/auth/password', payload),
};
