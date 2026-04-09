// Audit log hooks — fetch audit entries + a mutation wrapper that captures
// before/after state for critical actions.
// Spec: superadmin.md §3.6 & §4.10 (Audit Log)

import {
  useMutation,
  UseMutationOptions,
  useQuery,
} from '@tanstack/react-query';
import { auditApi, type AuditLog } from '@/api/super-admin/audit';

const AUDIT_KEY = ['admin', 'audit'] as const;

export function useAuditLog() {
  return useQuery({
    queryKey: AUDIT_KEY,
    queryFn: () => auditApi.getLogs(),
  });
}

export function useExportAuditLog() {
  return useMutation({
    mutationFn: () => auditApi.exportCsv(),
  });
}

/**
 * Wraps a React Query mutation to automatically capture `before` and `after`
 * state for audit logging. The caller provides a `captureBefore` function that
 * returns the current resource state prior to mutation. The result of the
 * mutation is treated as the `after` state.
 *
 * NOTE: Logging is fire-and-forget — a failure to write the audit entry does
 * not roll back the underlying mutation.
 */
export interface AuditedMutationContext<TBefore> {
  resourceType: string;
  resourceId: string;
  action: NonNullable<AuditLog['action']>;
  captureBefore?: () => Promise<TBefore> | TBefore;
  reason?: string;
}

export function useAuditedMutation<TData, TVars, TBefore = unknown>(
  mutationFn: (vars: TVars) => Promise<TData>,
  auditCtx: AuditedMutationContext<TBefore> | ((vars: TVars) => AuditedMutationContext<TBefore>),
  options?: UseMutationOptions<TData, Error, TVars>,
) {
  return useMutation<TData, Error, TVars>({
    ...options,
    mutationFn: async (vars: TVars) => {
      const ctx = typeof auditCtx === 'function' ? auditCtx(vars) : auditCtx;
      let before: TBefore | undefined;
      try {
        before = ctx.captureBefore ? await ctx.captureBefore() : undefined;
      } catch {
        // swallow — audit capture must not block the mutation
      }
      const after = await mutationFn(vars);
      // Fire-and-forget audit log write
      void fetch('/api/admin/audit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          resource_type: ctx.resourceType,
          resource_id: ctx.resourceId,
          action: ctx.action,
          before_state: before ?? null,
          after_state: after ?? null,
          reason: ctx.reason ?? null,
        }),
      }).catch(() => {});
      return after;
    },
  });
}
