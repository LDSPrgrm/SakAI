import { adminRequest, adminRequestBlob } from './_request';
import type { components } from '@/types/openapi';

export type AuditLog = components['schemas']['AuditLog'];
export type AuditLogResponse = components['schemas']['AuditLogResponse'];

export const auditApi = {
  getLogs: (params?: { limit?: number; offset?: number; actor_id?: string }) => {
    const qs = new URLSearchParams();
    if (params?.limit)    qs.set('limit',    String(params.limit));
    if (params?.offset)   qs.set('offset',   String(params.offset));
    if (params?.actor_id) qs.set('actor_id', params.actor_id);
    const query = qs.toString();
    return adminRequest<AuditLogResponse>('GET', `/audit${query ? `?${query}` : ''}`)
      .then((res) => res.logs ?? []);
  },

  /** GET /admin/audit/export — returns CSV as a Blob. */
  exportCsv: () => adminRequestBlob('GET', '/audit/export'),
};
