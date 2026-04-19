import type { components } from '@/types/openapi';

type BaseAuditLog = components['schemas']['AuditLog'];

// Extend the generated type: actor_name is shown in the UI, and before/after
// state should be arbitrary records.
//
// TODO(codegen, L3): the generated type emits `Record<string, never>` for `object`
// schemas; this manual override widens to `Record<string, unknown>`. A proper fix
// is to add a postprocess step (or openapi-typescript config option) so future
// regenerations produce the widened type directly. See `npm run generate:types`.
//
// TODO(spec, M9): backend should populate `actor_name` via JOIN; see
// `enrichAuditLog()` in src/api/super-admin/audit.ts for the client-side fallback.
export type AuditLog = Omit<BaseAuditLog, 'before_state' | 'after_state'> & {
  actor_name?: string;
  before_state?: Record<string, unknown> | null;
  after_state?: Record<string, unknown> | null;
};

export interface AuditLogResponse {
  logs?: AuditLog[];
  total?: number;
}
