import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type FareConfig  = components['schemas']['FareConfig'];
export type SurgeConfig = components['schemas']['SurgeConfig'];

export const faresApi = {
  getConfigs: () =>
    adminRequest<unknown>('GET', '/fares').then((res) => {
      const r = res as Record<string, unknown>;
      return extractArray<FareConfig>(r['fares'] ?? res);
    }),

  /** GET /admin/fares/surge — dedicated surge endpoint (M1). */
  getSurge: () => adminRequest<SurgeConfig>('GET', '/fares/surge'),

  /** PUT /admin/fares — returns 204. */
  updateConfigs: (fares: Partial<FareConfig>[]) =>
    adminRequestVoid('PUT', '/fares', fares),

  /** PUT /admin/surge — returns 204. */
  updateSurge: (data: Partial<SurgeConfig>) =>
    adminRequestVoid('PUT', '/surge', data),

  simulate: (vehicle_type: string, origin: { lat: number; lng: number }, destination: { lat: number; lng: number }) =>
    adminRequest<{ estimated_fare: number }>('POST', '/fares/simulate', {
      vehicle_type, origin, destination,
    }).then((r) => r.estimated_fare),
};
