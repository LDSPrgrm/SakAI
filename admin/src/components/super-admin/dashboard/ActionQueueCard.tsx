import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, type LucideIcon } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { cn } from '@/lib/utils';

export type QueueTone = 'amber' | 'danger' | 'primary' | 'success';

const TONE_CLASS: Record<QueueTone, { tile: string; count: string }> = {
  amber:   { tile: 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)] ring-[var(--color-sa-accent)]/20', count: 'text-[var(--color-sa-accent)]' },
  danger:  { tile: 'bg-danger/10 text-danger ring-danger/20', count: 'text-danger' },
  primary: { tile: 'bg-primary/10 text-primary ring-primary/20', count: 'text-primary' },
  success: { tile: 'bg-success/10 text-success ring-success/20', count: 'text-success' },
};

interface ActionQueueCardProps {
  label: string;
  count: number;
  to: string;
  icon: LucideIcon;
  tone?: QueueTone;
  isLoading?: boolean;
  className?: string;
  emptyHint?: string;
}

export function ActionQueueCard({
  label,
  count,
  to,
  icon: Icon,
  tone = 'amber',
  isLoading = false,
  className,
  emptyHint = 'All clear',
}: ActionQueueCardProps) {
  const t = TONE_CLASS[tone];
  const isEmpty = !isLoading && count === 0;
  return (
    <Link
      to={to}
      className={cn(
        'group block focus:outline-none focus:ring-2 focus:ring-[var(--color-sa-accent)] focus:ring-offset-2 focus:ring-offset-background rounded-xl',
        className,
      )}
    >
      <Card interactive className="h-full">
        <div className="p-4 flex items-center gap-4">
          <div
            className={cn(
              'w-11 h-11 rounded-lg flex items-center justify-center flex-shrink-0 ring-1',
              isEmpty ? 'bg-surface-hover text-text-muted ring-border' : t.tile,
            )}
          >
            <Icon className="w-5 h-5" />
          </div>
          <div className="min-w-0 flex-1 flex flex-col gap-0.5">
            <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
              {label}
            </span>
            <div className="flex items-baseline gap-2">
              <span className={cn('text-2xl font-bold tabular-nums leading-none', isEmpty ? 'text-text-main' : t.count)}>
                {isLoading ? '—' : count}
              </span>
              {isEmpty && <span className="text-xs text-text-muted">{emptyHint}</span>}
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-text-muted opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0" />
        </div>
      </Card>
    </Link>
  );
}
