import { adminRequest, adminRequestVoid, unwrapList, type PaginationMeta } from '@/api/super-admin/_request';
import type { PassengerUser, DriverUser, AdminStatus } from '@/types/super-admin';

export interface UserListParams {
  page?: number;
  limit?: number;
  q?: string;
}

function buildQuery(params: UserListParams): string {
  const qs = new URLSearchParams();
  if (params.q)     qs.set('q',     params.q);
  if (params.page)  qs.set('page',  String(params.page));
  if (params.limit) qs.set('limit', String(params.limit));
  const s = qs.toString();
  return s ? `?${s}` : '';
}

export const usersApi = {
  getPassengers: async (params: UserListParams = {}): Promise<{ items: PassengerUser[]; meta?: PaginationMeta }> => {
    const res = await adminRequest<unknown>('GET', `/users/passengers${buildQuery(params)}`);
    return unwrapList<PassengerUser>(res);
  },
  getDrivers: async (params: UserListParams = {}): Promise<{ items: DriverUser[]; meta?: PaginationMeta }> => {
    const res = await adminRequest<unknown>('GET', `/users/drivers${buildQuery(params)}`);
    return unwrapList<DriverUser>(res);
  },
  updateStatus: (id: string, data: { status: AdminStatus }) =>
    adminRequestVoid('PUT', `/users/${id}`, data),
};
