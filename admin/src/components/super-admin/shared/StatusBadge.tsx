import { cn } from '@/lib/utils';

type Status = 'active' | 'suspended' | 'deactivated' | 'pending' | 'approved' | 'rejected'
  | 'open' | 'investigating' | 'resolved' | 'escalated'
  | 'settled' | 'failed' | 'refunded'
  | 'ok' | 'degraded' | 'down'
  | string;

const VARIANTS: Record<string, string> = {
  active:       'bg-success/10 text-success border-success/20',
  approved:     'bg-success/10 text-success border-success/20',
  resolved:     'bg-success/10 text-success border-success/20',
  settled:      'bg-success/10 text-success border-success/20',
  ok:           'bg-success/10 text-success border-success/20',
  pending:      'bg-warning/10 text-warning border-warning/20',
  investigating:'bg-warning/10 text-warning border-warning/20',
  open:         'bg-warning/10 text-warning border-warning/20',
  processing:   'bg-warning/10 text-warning border-warning/20',
  degraded:     'bg-warning/10 text-warning border-warning/20',
  suspended:    'bg-danger/10 text-danger border-danger/20',
  deactivated:  'bg-danger/10 text-danger border-danger/20',
  rejected:     'bg-danger/10 text-danger border-danger/20',
  failed:       'bg-danger/10 text-danger border-danger/20',
  escalated:    'bg-danger/10 text-danger border-danger/20',
  down:         'bg-danger/10 text-danger border-danger/20',
  refunded:     'bg-primary/10 text-primary border-primary/20',
};

interface StatusBadgeProps {
  status: Status;
  label?: string;
  className?: string;
}

export function StatusBadge({ status, label, className }: StatusBadgeProps) {
  const variant = VARIANTS[status] ?? 'bg-surface text-text-muted border-border';
  const text = label ?? status.replace(/_/g, ' ');

  return (
    <span
      className={cn(
        'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium border capitalize',
        variant,
        className,
      )}
    >
      {text}
    </span>
  );
}
