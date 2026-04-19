import { adminRequest, adminRequestVoid } from './_request';
import type { AdminUser } from '@/types/super-admin/admin';
import type { components } from '@/types/openapi';

export type ChangePasswordRequest = components['schemas']['ChangePasswordRequest'];

export const authApi = {
  // TODO(spec, H2): GET /admin/users/me is not in swagger.yaml v1.2.0 — coordinate with backend.
  // The admin UI needs AdminUser-shaped data (role_id, role_name, status); the spec's
  // /users/me returns UserProfile (passenger|driver role) which is semantically wrong here.
  me: () => adminRequest<AdminUser>('GET', '/users/me'),

  /** PUT /admin/auth/password — self-service password change, returns 204. */
  changePassword: (payload: ChangePasswordRequest) =>
    adminRequestVoid('PUT', '/auth/password', payload),
};
