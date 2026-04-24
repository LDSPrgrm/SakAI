import React from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { cn } from '@/lib/utils';

type IconTone = 'primary' | 'success' | 'warning' | 'danger';

interface KPICardProps {
  title: string;
  value: string | number;
  trend?: string;
  trendDownIsGood?: boolean;
  icon?: React.ElementType;
  iconTone?: IconTone;
  className?: string;
}

const TONE_STYLES: Record<IconTone, string> = {
  primary: 'bg-primary/10 text-primary',
  success: 'bg-success/10 text-success',
  warning: 'bg-warning/10 text-warning',
  danger:  'bg-danger/10 text-danger',
};

export function KPICard({
  title,
  value,
  trend,
  trendDownIsGood = false,
  icon: Icon,
  iconTone = 'primary',
  className,
}: KPICardProps) {
  const isPositive = trend?.startsWith('+');
  const isNegative = trend?.startsWith('-');
  const hasDirection = isPositive || isNegative;
  const isGood = hasDirection ? (trendDownIsGood ? isNegative : isPositive) : null;

  const TrendIcon = isPositive ? TrendingUp : isNegative ? TrendingDown : Minus;
  const trendPillClasses =
    isGood === true
      ? 'bg-success/10 text-success'
      : isGood === false
      ? 'bg-danger/10 text-danger'
      : 'bg-surface-hover text-text-muted';

  return (
    <Card
      interactive
      className={cn('p-5 flex flex-col gap-4 focus-within:ring-2 focus-within:ring-primary/50', className)}
    >
      <div className="flex items-start justify-between gap-2">
        <p className="text-sm font-medium text-text-muted truncate">{title}</p>
        {Icon && (
          <div className={cn('w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0', TONE_STYLES[iconTone])}>
            <Icon className="w-5 h-5" />
          </div>
        )}
      </div>
      <p className="text-3xl font-bold text-text-main tabular-nums tracking-tight leading-none">
        {value}
      </p>
      {trend ? (
        <div className="flex items-center gap-2">
          <span className={cn('inline-flex items-center gap-0.5 px-2 py-0.5 rounded-md text-xs font-semibold tabular-nums', trendPillClasses)}>
            <TrendIcon className="w-3.5 h-3.5" strokeWidth={2.5} />
            {trend}
          </span>
          <span className="text-xs text-text-muted">vs last</span>
        </div>
      ) : (
        <div className="h-[22px]" aria-hidden />
      )}
    </Card>
  );
}
