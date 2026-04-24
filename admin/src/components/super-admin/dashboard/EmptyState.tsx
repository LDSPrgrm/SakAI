import React from 'react';
import type { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description?: string;
  hint?: string;
  action?: React.ReactNode;
  tone?: 'muted' | 'sa';
  className?: string;
}

export function EmptyState({
  icon: Icon,
  title,
  description,
  hint,
  action,
  tone = 'muted',
  className,
}: EmptyStateProps) {
  const tileCls =
    tone === 'sa'
      ? 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)]'
      : 'bg-surface-hover text-text-muted';

  return (
    <div className={cn('flex flex-col items-center justify-center text-center gap-3 py-10', className)}>
      <div className={cn('w-11 h-11 rounded-xl flex items-center justify-center ring-1 ring-border', tileCls)}>
        <Icon className="w-5 h-5" />
      </div>
      <div className="flex flex-col gap-1 max-w-xs">
        <p className="text-sm font-medium text-text-main">{title}</p>
        {description && <p className="text-xs text-text-muted leading-relaxed">{description}</p>}
        {hint && (
          <p className="text-[11px] uppercase tracking-widest text-text-muted/70 mt-1">{hint}</p>
        )}
      </div>
      {action && <div className="mt-1">{action}</div>}
    </div>
  );
}
