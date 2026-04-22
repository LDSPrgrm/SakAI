import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type Incident = components['schemas']['Incident'];
export type KycEntry = components['schemas']['KycEntry'];
export type KycBatchRequest = components['schemas']['KycBatchRequest'];

// SOS timeline row. Locally-typed until swagger regen publishes the schema.
export interface IncidentStatusEvent {
  id: string;
  from_status?: string | null;
  to_status: string;
  from_assignee?: string | null;
  to_assignee?: string | null;
  actor_id?: string | null;
  actor_name?: string;
  note?: string;
  occurred_at: string;
}

export interface IncidentDetail {
  incident: Incident;
  status_history: IncidentStatusEvent[];
}

// Slim shape returned by GET /admin/support-staff — id/name/role only, no
// sensitive admin-account metadata. Safe for operations + support callers.
export interface AssigneeCandidate {
  id: string;
  name: string;
  role: string;
}

export const safetyApi = {
  getIncidents: () =>
    adminRequest<unknown>('GET', '/incidents').then(extractArray<Incident>),

  /** GET /admin/incidents/{id} — detail with SOS status-history timeline. */
  getIncident: (id: string) =>
    adminRequest<IncidentDetail>('GET', `/incidents/${id}`),

  /** PUT /admin/incidents/{id}/assign — reassign to another operator (or clear with null). */
  assignIncident: (id: string, assigneeId: string | null) =>
    adminRequestVoid('PUT', `/incidents/${id}/assign`, { assignee_id: assigneeId }),

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

  /** GET /admin/support-staff — candidate assignees for incident reassignment. */
  getAssigneeCandidates: () =>
    adminRequest<unknown>('GET', '/support-staff').then(extractArray<AssigneeCandidate>),
};
