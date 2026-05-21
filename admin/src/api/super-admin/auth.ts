import { adminRequestVoid } from './_request';
import type { components } from '@/types/openapi';

export type ChangePasswordRequest = components['schemas']['ChangePasswordRequest'];

export const authApi = {
  /** PUT /admin/auth/password — self-service password change, returns 204. */
  changePassword: (payload: ChangePasswordRequest) =>
    adminRequestVoid('PUT', '/auth/password', payload),
};
