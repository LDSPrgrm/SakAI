import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type Incident = components['schemas']['Incident'];
export type KycEntry = components['schemas']['KycEntry'];
export type KycBatchRequest = components['schemas']['KycBatchRequest'];

export const safetyApi = {
  getIncidents: () =>
    adminRequest<unknown>('GET', '/incidents').then(extractArray<Incident>),

  /** PUT /admin/incidents/{id}/resolve — returns 204. */
  resolveIncident: (id: string, notes: string) =>
    adminRequestVoid('PUT', `/incidents/${id}/resolve`, { notes }),

  getKycQueue: () =>
    adminRequest<unknown>('GET', '/safety/kyc').then(extractArray<KycEntry>),

  /** PUT /admin/safety/kyc/{id} — returns 204. */
  updateKyc: (id: string, status: 'approved' | 'rejected') =>
    adminRequestVoid('PUT', `/safety/kyc/${id}`, { status }),

  /** POST /admin/safety/kyc/batch — bulk approve/reject KYC entries (M5). */
  batchKyc: (payload: KycBatchRequest) =>
    adminRequestVoid('POST', '/safety/kyc/batch', payload),

  getLtfrbCompliance: () =>
    adminRequest<unknown>('GET', '/safety/compliance'),
};
