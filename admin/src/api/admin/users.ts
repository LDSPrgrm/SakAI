import { adminRequest, extractArray } from '@/api/super-admin/_request';
import type { PassengerUser, DriverUser, AdminStatus } from '@/types/super-admin';

export const usersApi = {
  getPassengers: async (q?: string) => {
    const res = await adminRequest<unknown>('GET', `/users/passengers${q ? `?q=${encodeURIComponent(q)}` : ''}`);
    return extractArray<PassengerUser>(res);
  },
  getDrivers: async (q?: string) => {
    const res = await adminRequest<unknown>('GET', `/users/drivers${q ? `?q=${encodeURIComponent(q)}` : ''}`);
    return extractArray<DriverUser>(res);
  },
  updateStatus: (id: string, data: { status: AdminStatus }) =>
    adminRequest<void>('PUT', `/users/${id}`, data),
};
