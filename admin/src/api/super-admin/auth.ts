import { adminRequest } from './_request';
import type { components } from '@/types/openapi';

export type AdminUser = components['schemas']['AdminUser'];

export const authApi = {
  /** GET /admin/users/me — current admin profile */
  me: () => adminRequest<AdminUser>('GET', '/users/me'),
};
