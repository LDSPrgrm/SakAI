import { adminRequest, unwrapList, type PaginationMeta } from '@/api/super-admin/_request';
import type { AdminRideItem } from '@/types/super-admin';

export interface AdminListParams {
  page?: number;
  limit?: number;
  status?: string;
}

export const ridesApi = {
  list: async (params: AdminListParams = {}): Promise<{ items: AdminRideItem[]; meta?: PaginationMeta }> => {
    const qs = new URLSearchParams();
    if (params.status) qs.set('status', params.status);
    if (params.page)   qs.set('page',   String(params.page));
    if (params.limit)  qs.set('limit',  String(params.limit));
    const query = qs.toString();
    const res = await adminRequest<unknown>('GET', `/rides${query ? `?${query}` : ''}`);
    return unwrapList<AdminRideItem>(res);
  },
};
