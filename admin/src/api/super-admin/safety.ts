import { adminRequest, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type Incident = components['schemas']['Incident'];

export interface KycEntry {
  id: string;
  driver_id: string;
  driver_name: string;
  submitted_at: string;
  docs: string[];
  status: 'pending' | 'approved' | 'rejected';
}

export const safetyApi = {
  getIncidents: () =>
    adminRequest<unknown>('GET', '/incidents').then(extractArray<Incident>),

  resolveIncident: (id: string, notes: string) =>
    adminRequest<Incident>('PUT', `/incidents/${id}/resolve`, { notes }),

  getKycQueue: () =>
    adminRequest<unknown>('GET', '/safety/kyc').then(extractArray<KycEntry>),

  updateKyc: (id: string, status: 'approved' | 'rejected') =>
    adminRequest<KycEntry>('PUT', `/safety/kyc/${id}`, { status }),

  getLtfrbCompliance: () =>
    adminRequest<unknown>('GET', '/safety/compliance'),
};
