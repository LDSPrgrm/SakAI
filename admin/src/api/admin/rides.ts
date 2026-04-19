import { adminRequest, extractArray } from '@/api/super-admin/_request';
import type { AdminRideItem } from '@/types/super-admin';

export const ridesApi = {
  list: async (status?: string) => {
    const res = await adminRequest<unknown>('GET', `/rides${status ? `?status=${encodeURIComponent(status)}` : ''}`);
    return extractArray<AdminRideItem>(res);
  },
};
