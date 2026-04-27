import React from 'react';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer, CartesianGrid,
} from 'recharts';
import { Wallet } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
import { CHART_COLORS, DARK_TOOLTIP_STYLE } from '@/utils/chartColors';
import { formatPHP } from '@/lib/utils';

interface DataPoint {
  name: string;
  revenue?: number;
  gcash?: number;
  cash?: number;
  paymaya?: number;
  card?: number;
}

type Period = '24h' | '7d' | '30d';

interface RevenueChartProps {
  data: DataPoint[];
  className?: string;
  height?: number;
  period?: Period;
}

const AXIS_TICK = { fill: 'var(--color-text-muted)', fontSize: 11, fontFeatureSettings: '"tnum"' } as const;

const PERIOD_LABEL: Record<Period, string> = {
  '24h': 'Last 24 hours',
  '7d':  'Last 7 days',
  '30d': 'Last 30 days',
};

function seriesTotal(d: DataPoint): number {
  return (d.revenue ?? 0) + (d.gcash ?? 0) + (d.cash ?? 0) + (d.paymaya ?? 0) + (d.card ?? 0);
}

export function RevenueChart({ data, className, height = 240, period = '30d' }: RevenueChartProps) {
  const hasData = !!data && data.length > 0 && data.some((p) => seriesTotal(p) > 0);
  const hasSplit = !!data?.some((p) => p.gcash != null || p.cash != null || p.paymaya != null || p.card != null);
  const total = hasData ? data.reduce((s, p) => s + seriesTotal(p), 0) : 0;

  return (
    <Card className={className}>
      <CardHeader className="flex flex-col gap-1">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]" aria-hidden />
            <CardTitle className="text-sm font-semibold uppercase tracking-wider">Revenue</CardTitle>
          </div>
          <span className="overline">PHP · {PERIOD_LABEL[period]}</span>
        </div>
        {hasData && (
          <p className="text-xs text-text-muted tabular-nums">
            <span className="text-text-main font-semibold">{formatPHP(total)}</span> total
          </p>
        )}
      </CardHeader>
      <CardContent className="p-5 pt-4">
        {!hasData ? (
          <EmptyState
            icon={Wallet}
            title="No revenue posted"
            description="Payments appear once rides complete and settle."
            hint={PERIOD_LABEL[period]}
          />
        ) : (
          <ResponsiveContainer width="100%" height={height}>
            <BarChart data={data} margin={{ top: 8, right: 4, left: 0, bottom: 0 }} barCategoryGap="35%">
              <CartesianGrid stroke="var(--color-border)" strokeDasharray="2 4" vertical={false} opacity={0.4} />
              <XAxis
                dataKey="name"
                tick={AXIS_TICK}
                tickLine={false}
                axisLine={false}
                interval="preserveStartEnd"
                minTickGap={24}
              />
              <YAxis
                tick={AXIS_TICK}
                tickLine={false}
                axisLine={false}
                width={36}
                allowDecimals={false}
                tickFormatter={(v) => (v >= 1000 ? `${Math.round(v / 1000)}k` : `${v}`)}
              />
              <Tooltip {...DARK_TOOLTIP_STYLE} cursor={{ fill: 'var(--color-surface-hover)', opacity: 0.4 }} formatter={(v: number) => formatPHP(v)} />
              {hasSplit ? (
                <>
                  <Legend wrapperStyle={{ color: 'var(--color-text-muted)', fontSize: 11 }} iconSize={8} />
                  <Bar dataKey="gcash"   stackId="a" fill={CHART_COLORS[0]} barSize={14} name="GCash" />
                  <Bar dataKey="cash"    stackId="a" fill={CHART_COLORS[1]} barSize={14} name="Cash" />
                  <Bar dataKey="paymaya" stackId="a" fill={CHART_COLORS[2]} barSize={14} name="PayMaya" />
                  <Bar dataKey="card"    stackId="a" fill={CHART_COLORS[3]} barSize={14} name="Card" radius={[3, 3, 0, 0]} />
                </>
              ) : (
                <Bar dataKey="revenue" fill="var(--color-sa-accent)" barSize={14} radius={[3, 3, 0, 0]} />
              )}
            </BarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
