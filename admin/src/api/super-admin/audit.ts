import { adminRequest, adminRequestBlob } from './_request';
import type { components } from '@/types/openapi';
import type { AuditLog as UiAuditLog } from '@/types/super-admin/audit';

export type AuditLog = components['schemas']['AuditLog'];
export type AuditLogResponse = components['schemas']['AuditLogResponse'];

/**
 * Backfill `actor_name` on audit entries from a cached admin list.
 * TODO(spec, M9): add readOnly actor_name field to AuditLog schema so the
 * backend resolves this via JOIN and the client-side enrichment becomes unnecessary.
 */
export function enrichAuditLog(
  logs: UiAuditLog[],
  admins: Array<{ id?: string; name?: string }>,
): UiAuditLog[] {
  if (!admins.length) return logs;
  const byId = new Map(admins.filter((a) => a.id).map((a) => [a.id!, a.name ?? ''] as const));
  return logs.map((log) => ({
    ...log,
    actor_name: log.actor_name ?? (log.actor_id ? byId.get(log.actor_id) ?? '' : ''),
  }));
}

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
