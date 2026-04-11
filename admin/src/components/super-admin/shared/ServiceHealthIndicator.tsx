import { cn } from '@/lib/utils';

type ServiceStatus = 'ok' | 'degraded' | 'down';

const COLORS: Record<ServiceStatus, string> = {
  ok:       'bg-success',
  degraded: 'bg-warning',
  down:     'bg-danger',
};
const LABELS: Record<ServiceStatus, string> = {
  ok:       'Operational',
  degraded: 'Degraded',
  down:     'Down',
};

interface ServiceHealthIndicatorProps {
  status: ServiceStatus;
  /** Show a pulse animation for 'ok' status */
  pulse?: boolean;
  className?: string;
}

export function ServiceHealthIndicator({ status, pulse, className }: ServiceHealthIndicatorProps) {
  return (
    <span className={cn('inline-flex items-center gap-1.5', className)}>
      <span className={cn('relative flex h-2 w-2')}>
        {pulse && status === 'ok' && (
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-success opacity-75" />
        )}
        <span className={cn('relative inline-flex rounded-full h-2 w-2', COLORS[status])} />
      </span>
      <span className="text-xs text-text-muted">{LABELS[status]}</span>
    </span>
  );
}
