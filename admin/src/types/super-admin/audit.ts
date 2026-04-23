import type { components } from '@/types/openapi';

// TODO(spec, M9): backend should populate `actor_name` via JOIN; see
// `enrichAuditLog()` in src/api/super-admin/audit.ts for the client-side fallback.
export type AuditLog = components['schemas']['AuditLog'] & {
  actor_name?: string;
};

export interface AuditLogResponse {
  logs?: AuditLog[];
  total?: number;
}
