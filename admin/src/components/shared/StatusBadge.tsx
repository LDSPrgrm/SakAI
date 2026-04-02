import React from 'react';
import { Badge } from '@/components/ui/Badge';

type Variant = 'success' | 'warning' | 'danger' | 'info' | 'default';

const STATUS_MAP: Record<string, Variant> = {
  // Generic
  active: 'success',
  online: 'success',
  ok: 'success',
  verified: 'success',
  approved: 'success',
  settled: 'success',
  completed: 'success',
  resolved: 'success',

  pending: 'warning',
  investigating: 'warning',
  degraded: 'warning',
  in_progress: 'info',
  accepted: 'info',
  arrived: 'info',

  suspended: 'danger',
  deactivated: 'danger',
  rejected: 'danger',
  failed: 'danger',
  cancelled: 'danger',
  down: 'danger',
  open: 'danger',
  escalated: 'danger',

  offline: 'default',
  refunded: 'default',
  default: 'default',
};

interface StatusBadgeProps {
  status: string;
  label?: string;
}

export function StatusBadge({ status, label }: StatusBadgeProps) {
  const variant = STATUS_MAP[status.toLowerCase()] ?? 'default';
  return <Badge variant={variant}>{label ?? status}</Badge>;
}
