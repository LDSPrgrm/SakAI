import { AlertTriangle, Info, Shield, CheckCircle2, RefreshCw, type LucideIcon } from 'lucide-react';

export interface FeedEvent {
  id: string | number;
  type: string;
  message: string;
  time: string;
  isAlert: boolean;
}

const SECURITY_TYPES = new Set(['login', 'logout', 'permission', 'role']);
const APPROVE_TYPES  = new Set(['approve', 'complete', 'payout', 'create']);
const UPDATE_TYPES   = new Set(['update', 'update_status', 'update_fares', 'edit', 'modify']);

export interface ActivityIcon {
  Icon: LucideIcon;
  tone: string;
  family: string;
}

export function iconFor(event: FeedEvent): ActivityIcon {
  const type = event.type.toLowerCase();
  if (event.isAlert) {
    return { Icon: AlertTriangle, tone: 'bg-danger/10 text-danger ring-danger/20', family: 'Alert' };
  }
  if (SECURITY_TYPES.has(type)) {
    return {
      Icon: Shield,
      tone: 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)] ring-[var(--color-sa-accent)]/20',
      family: 'Security',
    };
  }
  if (APPROVE_TYPES.has(type)) {
    return { Icon: CheckCircle2, tone: 'bg-success/10 text-success ring-success/20', family: 'Approve' };
  }
  if (UPDATE_TYPES.has(type) || type.startsWith('update')) {
    return { Icon: RefreshCw, tone: 'bg-primary/10 text-primary ring-primary/20', family: 'Update' };
  }
  return { Icon: Info, tone: 'bg-surface-hover text-text-muted ring-border', family: 'Event' };
}
