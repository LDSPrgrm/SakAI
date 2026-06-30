import React from 'react';
import { AlertTriangle } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useSystemServices } from '@/hooks/useSystem';
import { cn } from '@/lib/utils';

export function ServiceStatusBanner({ className }: { className?: string }) {
  const { data } = useSystemServices({ refetchInterval: 30_000 });
  const services = data ?? [];

  const downCount = services.filter((s) => s.status === 'down').length;
  const degradedCount = services.filter((s) => s.status === 'degraded').length;

  if (downCount === 0 && degradedCount === 0) return null;

  const isDown = downCount > 0;
  const tone = isDown
    ? 'bg-danger/10 text-danger ring-danger/30'
    : 'bg-warning/10 text-warning ring-warning/30';

  const message = [
    downCount > 0 && `${downCount} service${downCount === 1 ? '' : 's'} DOWN`,
    degradedCount > 0 && `${degradedCount} DEGRADED`,
  ]
    .filter(Boolean)
    .join(' · ');

  return (
    <div
      role="alert"
      className={cn(
        'flex items-center justify-between gap-3 px-4 py-2.5 rounded-lg ring-1',
        tone,
        className,
      )}
    >
      <div className="flex items-center gap-2 min-w-0">
        <AlertTriangle className="w-4 h-4 flex-shrink-0" />
        <span className="text-sm font-medium tracking-tight">{message}</span>
      </div>
      <Link
        to="/super-admin/health"
        className="text-xs font-semibold uppercase tracking-wider hover:underline flex-shrink-0"
      >
        View Health →
      </Link>
    </div>
  );
}
