import type { components } from '@/types/openapi';

type BaseAuditLog = components['schemas']['AuditLog'];

// Extend the generated type: actor_name is shown in the UI, and before/after
// state should be arbitrary records (the generated type uses Record<string, never>).
export type AuditLog = Omit<BaseAuditLog, 'before_state' | 'after_state'> & {
  actor_name?: string;
  before_state?: Record<string, unknown> | null;
  after_state?: Record<string, unknown> | null;
};

export interface AuditLogResponse {
  logs?: AuditLog[];
  total?: number;
}
