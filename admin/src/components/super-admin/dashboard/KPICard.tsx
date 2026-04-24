import React from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { Area, AreaChart, ResponsiveContainer } from 'recharts';
import { Card } from '@/components/ui/Card';
import { cn } from '@/lib/utils';

type IconTone = 'primary' | 'success' | 'warning' | 'danger' | 'sa-accent';
type Variant = 'compact' | 'lead';

interface SparklinePoint {
  name?: string;
  value: number;
}

interface KPICardProps {
  title: string;
  value: string | number;
  trend?: string;
  trendDownIsGood?: boolean;
  icon?: React.ElementType;
  iconTone?: IconTone;
  variant?: Variant;
  /** Lead-variant micro-chart. Hidden automatically if empty or all-zero. */
  sparkline?: SparklinePoint[];
  /** Eyebrow label shown above the title (lead variant only). */
  eyebrow?: string;
  /** Optional secondary copy under the value. */
  subtext?: string;
  className?: string;
  /** For stagger reveal; wired to a CSS custom property. */
  style?: React.CSSProperties;
}

const TONE_STYLES: Record<IconTone, string> = {
  primary:     'bg-primary/10 text-primary',
  success:     'bg-success/10 text-success',
  warning:     'bg-warning/10 text-warning',
  danger:      'bg-danger/10 text-danger',
  'sa-accent': 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)]',
};

const TONE_STROKE: Record<IconTone, string> = {
  primary:     'var(--color-primary)',
  success:     'var(--color-success)',
  warning:     'var(--color-warning)',
  danger:      'var(--color-danger)',
  'sa-accent': 'var(--color-sa-accent)',
};

export function KPICard({
  title,
  value,
  trend,
  trendDownIsGood = false,
  icon: Icon,
  iconTone = 'primary',
  variant = 'compact',
  sparkline,
  eyebrow,
  subtext,
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

  const sparkHasData = sparkline && sparkline.length > 1 && sparkline.some((p) => (p.value ?? 0) > 0);
  const isLead = variant === 'lead';

  if (isLead) {
    return (
      <Card
        surface="raised"
        className={cn(
          'p-6 flex flex-col justify-between gap-5 h-full relative',
          'focus-within:ring-2 focus-within:ring-[var(--color-sa-accent)]/40',
          className,
        )}
        style={style}
      >
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0 flex flex-col gap-1">
            {eyebrow && (
              <span className="overline text-[var(--color-sa-accent)]">{eyebrow}</span>
            )}
            <p className="text-sm font-medium text-text-main">{title}</p>
          </div>
          {Icon && (
            <div className={cn('w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0 ring-1 ring-white/5', TONE_STYLES[iconTone])}>
              <Icon className="w-5 h-5" />
            </div>
          )}
        </div>

        <div className="flex items-end justify-between gap-4">
          <div className="flex flex-col gap-2 min-w-0">
            <p className="text-4xl md:text-5xl font-bold text-text-main tabular-nums tracking-tight leading-none truncate">
              {value}
            </p>
            {(trend || subtext) && (
              <div className="flex items-center gap-2 flex-wrap">
                {trend && (
                  <span className={cn('inline-flex items-center gap-0.5 px-2 py-0.5 rounded-md text-xs font-semibold tabular-nums ring-1', trendPillClasses)}>
                    <TrendIcon className="w-3.5 h-3.5" strokeWidth={2.5} />
                    {trend}
                  </span>
                )}
                {subtext && <span className="text-xs text-text-muted">{subtext}</span>}
              </div>
            )}
          </div>

          {sparkHasData && (
            <div className="w-28 h-12 flex-shrink-0 opacity-90">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={sparkline} margin={{ top: 2, right: 0, left: 0, bottom: 0 }}>
                  <defs>
                    <linearGradient id={`spark-${iconTone}`} x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor={TONE_STROKE[iconTone]} stopOpacity={0.45} />
                      <stop offset="100%" stopColor={TONE_STROKE[iconTone]} stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <Area
                    type="monotone"
                    dataKey="value"
                    stroke={TONE_STROKE[iconTone]}
                    strokeWidth={1.75}
                    fill={`url(#spark-${iconTone})`}
                    isAnimationActive
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>
      </Card>
    );
  }

  return (
    <Card
      interactive
      className={cn(
        'p-4 flex flex-col gap-3 focus-within:ring-2 focus-within:ring-primary/50 h-full',
        className,
      )}
      style={style}
    >
      <div className="flex items-start justify-between gap-2">
        <p className="text-xs font-medium text-text-muted uppercase tracking-wider leading-tight">{title}</p>
        {Icon && (
          <div className={cn('w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', TONE_STYLES[iconTone])}>
            <Icon className="w-4 h-4" />
          </div>
        )}
      </div>
      <p className="text-2xl font-bold text-text-main tabular-nums tracking-tight leading-none">
        {value}
      </p>
      <div className="min-h-[1.5rem] flex items-center">
        {trend ? (
          <span className={cn('inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[11px] font-semibold tabular-nums ring-1', trendPillClasses)}>
            <TrendIcon className="w-3 h-3" strokeWidth={2.5} />
            {trend}
          </span>
        ) : (
          <span className="text-[11px] text-text-muted/60">—</span>
        )}
      </div>
    </Card>
  );
}
