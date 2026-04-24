import React from 'react';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer,
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

interface RevenueChartProps {
  data: DataPoint[];
  className?: string;
  height?: number;
}

const AXIS_TICK = { fill: 'var(--color-text-muted)', fontSize: 11 } as const;

export function RevenueChart({ data, className, height = 240 }: RevenueChartProps) {
  const isEmpty = !data || data.length === 0;
  const hasSplit = data?.some((p) => p.gcash != null || p.cash != null || p.paymaya != null || p.card != null);

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-sm font-semibold uppercase tracking-wide">Revenue by Week</CardTitle>
        <span className="text-xs text-text-muted">PHP</span>
      </CardHeader>
      <CardContent className="p-5">
        {isEmpty ? (
          <EmptyState icon={Wallet} title="No revenue data" description="Weekly revenue appears once payments post." />
        ) : (
          <ResponsiveContainer width="100%" height={height}>
            <BarChart data={data} margin={{ top: 8, right: 4, left: 0, bottom: 0 }}>
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
              <Tooltip {...DARK_TOOLTIP_STYLE} cursor={false} formatter={(v: number) => formatPHP(v)} />
              {hasSplit ? (
                <>
                  <Legend wrapperStyle={{ color: 'var(--color-text-muted)', fontSize: 11 }} iconSize={8} />
                  <Bar dataKey="gcash"   stackId="a" fill={CHART_COLORS[0]} name="GCash" />
                  <Bar dataKey="cash"    stackId="a" fill={CHART_COLORS[1]} name="Cash" />
                  <Bar dataKey="paymaya" stackId="a" fill={CHART_COLORS[2]} name="PayMaya" />
                  <Bar dataKey="card"    stackId="a" fill={CHART_COLORS[3]} name="Card" radius={[3, 3, 0, 0]} />
                </>
              ) : (
                <Bar dataKey="revenue" fill={CHART_COLORS[0]} radius={[3, 3, 0, 0]} />
              )}
            </BarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
