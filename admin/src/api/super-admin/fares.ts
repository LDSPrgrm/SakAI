import { adminRequest, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type FareConfig  = components['schemas']['FareConfig'];
export type SurgeConfig = components['schemas']['SurgeConfig'];

export const faresApi = {
  getConfigs: () =>
    adminRequest<unknown>('GET', '/fares').then((res) => {
      const r = res as Record<string, unknown>;
      return extractArray<FareConfig>(r['fares'] ?? res);
    }),

  getSurge: () =>
    adminRequest<unknown>('GET', '/fares').then((res) => {
      const r = res as Record<string, unknown>;
      return (r['surge'] ?? {}) as SurgeConfig;
    }),

  updateConfigs: (fares: Partial<FareConfig>[]) =>
    adminRequest<FareConfig[]>('PUT', '/fares', fares),

  updateSurge: (data: Partial<SurgeConfig>) =>
    adminRequest<SurgeConfig>('PUT', '/surge', data),

  simulate: (vehicle_type: string, origin: { lat: number; lng: number }, destination: { lat: number; lng: number }) =>
    adminRequest<{ estimated_fare: number }>('POST', '/fares/simulate', {
      vehicle_type, origin, destination,
    }).then((r) => r.estimated_fare),
};
