import React from 'react';
import { cn } from '@/lib/utils';

interface PageHeaderProps {
  title: string;
  subtitle?: React.ReactNode;
  actions?: React.ReactNode;
  className?: string;
}

export function PageHeader({ title, subtitle, actions, className }: PageHeaderProps) {
  return (
    <div className={cn('flex flex-wrap justify-between items-center gap-3', className)}>
      <div className="min-w-0">
        <h1 className="text-2xl font-bold text-text-main">{title}</h1>
        {subtitle && (
          <div className="text-sm text-text-muted mt-1">{subtitle}</div>
        )}
      </div>
      {actions && <div className="flex flex-wrap items-center gap-2">{actions}</div>}
    </div>
  );
}
