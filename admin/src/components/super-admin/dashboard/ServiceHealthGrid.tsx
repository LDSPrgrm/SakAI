import React from 'react';
import { ServerOff } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { ServiceHealthIndicator } from '@/components/super-admin/shared/ServiceHealthIndicator';
import { EmptyState } from './EmptyState';
import { cn } from '@/lib/utils';
import type { SystemService } from '@/api/super-admin/system';

const LATENCY_GREEN = 250;
const LATENCY_YELLOW = 500;

function latencyToneClass(ms?: number): string {
  if (ms == null) return 'text-text-muted';
  if (ms < LATENCY_GREEN) return 'text-success';
  if (ms < LATENCY_YELLOW) return 'text-warning';
  return 'text-danger';
}

export interface ServiceHealthGridProps {
  services: SystemService[];
  isLoading?: boolean;
  className?: string;
}

export function ServiceHealthGrid({ services, isLoading, className }: ServiceHealthGridProps) {
  if (isLoading) {
    return (
      <div className={cn('grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3', className)}>
        {Array.from({ length: 6 }).map((_, i) => (
          <Card
            key={i}
            data-testid="service-skeleton"
            className="p-3 flex flex-col gap-2 animate-pulse"
          >
            <div className="h-2.5 w-20 rounded bg-surface-hover" />
            <div className="h-4 w-24 rounded bg-surface-hover" />
            <div className="h-3 w-14 rounded bg-surface-hover" />
          </Card>
        ))}
      </div>
    );
  }

  if (services.length === 0) {
    return (
      <Card className={cn('p-4', className)}>
        <EmptyState
          icon={ServerOff}
          title="No services reporting"
          description="Backend health probe has not returned any services yet."
        />
      </Card>
    );
  }

  return (
    <div className={cn('grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3', className)}>
      {services.map((s, i) => (
        <Card key={s.name ?? i} className="p-3 flex flex-col gap-1.5">
          <div className="flex items-center justify-between gap-2 min-w-0">
            <ServiceHealthIndicator status={s.status ?? 'ok'} pulse />
            {s.uptime_pct != null && (
              <span className="text-[10px] uppercase tracking-widest text-text-muted/80 tabular-nums">
                uptime {s.uptime_pct.toFixed(2)}%
              </span>
            )}
          </div>
          <span className="text-sm font-semibold text-text-main truncate">
            {s.name ?? 'unknown service'}
          </span>
          <span className={cn('text-xs tabular-nums', latencyToneClass(s.latency_ms))}>
            {s.latency_ms != null ? `${Math.round(s.latency_ms)}ms` : '—'}
          </span>
        </Card>
      ))}
    </div>
  );
}
