// KPI summary card — spec superadmin.md §4.1 Dashboard
// Shows current value + trend arrow + percentage change vs previous period.
import React from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { cn } from '@/lib/utils';

interface KPICardProps {
  title: string;
  value: string | number;
  /** e.g. "+12%" or "-3%" */
  trend?: string;
  /** icon component from lucide-react */
  icon?: React.ElementType;
  className?: string;
}

export function KPICard({ title, value, trend, icon: Icon, className }: KPICardProps) {
  const isPositive = trend ? trend.startsWith('+') : undefined;
  const isNegative = trend ? trend.startsWith('-') : undefined;

  const TrendIcon = isPositive ? TrendingUp : isNegative ? TrendingDown : Minus;
  const trendColor = isPositive
    ? 'text-success'
    : isNegative
    ? 'text-danger'
    : 'text-text-muted';

  return (
    <div className={cn('bg-surface border border-border rounded-xl p-5 flex flex-col gap-3', className)}>
      <div className="flex items-center justify-between">
        <p className="text-sm text-text-muted font-medium">{title}</p>
        {Icon && (
          <div className="w-9 h-9 rounded-lg bg-primary/10 flex items-center justify-center">
            <Icon className="w-5 h-5 text-primary" />
          </div>
        )}
      </div>
      <p className="text-2xl font-bold text-text-main tabular-nums">{value}</p>
      {trend && (
        <div className={cn('flex items-center gap-1 text-xs font-medium', trendColor)}>
          <TrendIcon className="w-3.5 h-3.5" />
          <span>{trend} vs previous period</span>
        </div>
      )}
    </div>
  );
}
