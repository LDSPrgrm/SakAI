import React from 'react';
import {
  Area, AreaChart, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
} from 'recharts';
import { BarChart2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
import { DARK_TOOLTIP_STYLE } from '@/utils/chartColors';

interface DataPoint {
  name: string;
  rides?: number;
}

type Accent = 'primary' | 'sa';
type Period = '24h' | '7d' | '30d';

interface RidesChartProps {
  data: DataPoint[];
  className?: string;
  height?: number;
  accent?: Accent;
  period?: Period;
}

const AXIS_TICK = { fill: 'var(--color-text-muted)', fontSize: 11, fontFeatureSettings: '"tnum"' } as const;

const PERIOD_LABEL: Record<Period, string> = {
  '24h': 'Last 24 hours',
  '7d':  'Last 7 days',
  '30d': 'Last 30 days',
};

const ACCENT_STROKE: Record<Accent, string> = {
  primary: 'var(--color-primary)',
  sa:      'var(--color-sa-accent)',
};

export function RidesChart({
  data,
  className,
  height = 240,
  accent = 'primary',
  period = '30d',
}: RidesChartProps) {
  const hasData = !!data && data.length > 0 && data.some((p) => (p.rides ?? 0) > 0);
  const stroke = ACCENT_STROKE[accent];
  const gradientId = `ridesFill-${accent}`;
  const total = hasData ? data.reduce((s, p) => s + (p.rides ?? 0), 0) : 0;

  return (
    <Card className={className}>
      <CardHeader className="flex flex-col gap-1">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]" aria-hidden />
            <CardTitle className="text-sm font-semibold uppercase tracking-wider">Rides Over Time</CardTitle>
          </div>
          <span className="overline">{PERIOD_LABEL[period]}</span>
        </div>
        {hasData && (
          <p className="text-xs text-text-muted tabular-nums">
            <span className="text-text-main font-semibold">{total.toLocaleString()}</span> rides logged
          </p>
        )}
      </CardHeader>
      <CardContent className="p-5 pt-4">
        {!hasData ? (
          <EmptyState
            icon={BarChart2}
            title="Awaiting first trip"
            description="Ride volume will stream in as drivers accept requests."
            hint={PERIOD_LABEL[period]}
          />
        ) : (
          <ResponsiveContainer width="100%" height={height}>
            <AreaChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={stroke} stopOpacity={0.45} />
                  <stop offset="100%" stopColor={stroke} stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid stroke="var(--color-border)" strokeDasharray="2 4" vertical={false} opacity={0.4} />
              <XAxis
                dataKey="name"
                tick={AXIS_TICK}
                tickLine={false}
                axisLine={false}
                interval="preserveStartEnd"
                minTickGap={32}
              />
              <YAxis tick={AXIS_TICK} tickLine={false} axisLine={false} width={28} allowDecimals={false} />
              <Tooltip {...DARK_TOOLTIP_STYLE} cursor={{ stroke: stroke, strokeOpacity: 0.3, strokeWidth: 1 }} />
              <Area
                type="monotone"
                dataKey="rides"
                stroke={stroke}
                strokeWidth={2}
                fill={`url(#${gradientId})`}
                isAnimationActive
                animationDuration={900}
              />
            </AreaChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
