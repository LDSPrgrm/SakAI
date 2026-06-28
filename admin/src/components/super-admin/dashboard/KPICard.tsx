import React from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { cn } from '@/lib/utils';

type IconTone = 'primary' | 'success' | 'warning' | 'danger' | 'sa-accent';

interface KPICardProps {
  title: string;
  value: string | number;
  trend?: string;
  trendDownIsGood?: boolean;
  icon?: React.ElementType;
  iconTone?: IconTone;
  className?: string;
  style?: React.CSSProperties;
}

const TONE_STYLES: Record<IconTone, string> = {
  primary:     'bg-primary/10 text-primary',
  success:     'bg-success/10 text-success',
  warning:     'bg-warning/10 text-warning',
  danger:      'bg-danger/10 text-danger',
  'sa-accent': 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)]',
};

export function KPICard({
  title,
  value,
  trend,
  trendDownIsGood = false,
  icon: Icon,
  iconTone = 'primary',
  className,
  style,
}: KPICardProps) {
  const isPositive = trend?.startsWith('+');
  const isNegative = trend?.startsWith('-');
  const hasDirection = isPositive || isNegative;
  const isGood = hasDirection ? (trendDownIsGood ? isNegative : isPositive) : null;

  const TrendIcon = isPositive ? TrendingUp : isNegative ? TrendingDown : Minus;
  const trendPillClasses =
    isGood === true
      ? 'bg-success/10 text-success ring-success/20'
      : isGood === false
      ? 'bg-danger/10 text-danger ring-danger/20'
      : 'bg-surface-hover text-text-muted ring-border';

  return (
    <Card
      interactive
      className={cn(
        'p-4 flex flex-col gap-3 h-full focus-within:ring-2 focus-within:ring-[var(--color-sa-accent)]/40',
        className,
      )}
      style={style}
    >
      <div className="flex items-start justify-between gap-2">
        <p className="text-[11px] font-semibold text-text-muted uppercase tracking-widest leading-tight min-w-0">
          {title}
        </p>
        {Icon && (
          <div className={cn('w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', TONE_STYLES[iconTone])}>
            <Icon className="w-4 h-4" />
          </div>
        )}
      </div>
      <p className="text-2xl font-bold text-text-main tabular-nums tracking-tight leading-none truncate">
        {value}
      </p>
      <div className="min-h-[1.25rem] flex items-center">
        {trend ? (
          <span className={cn('inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[11px] font-semibold tabular-nums ring-1', trendPillClasses)}>
            <TrendIcon className="w-3 h-3" strokeWidth={2.5} />
            {trend}
          </span>
        ) : (
          <span className="text-[11px] text-text-muted/50">—</span>
        )}
      </div>
    </Card>
  );
}
