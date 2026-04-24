import React from 'react';
import type { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description?: string;
  className?: string;
}

export function EmptyState({ icon: Icon, title, description, className }: EmptyStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center text-center gap-3 py-8', className)}>
      <div className="w-10 h-10 rounded-full bg-surface-hover flex items-center justify-center">
        <Icon className="w-5 h-5 text-text-muted" />
      </div>
      <div className="flex flex-col gap-1">
        <p className="text-sm font-medium text-text-main">{title}</p>
        {description && <p className="text-xs text-text-muted">{description}</p>}
      </div>
    </div>
  );
}
