import React from 'react';
import {
  Area, AreaChart, XAxis, YAxis, Tooltip, ResponsiveContainer,
} from 'recharts';
import { BarChart2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
import { DARK_TOOLTIP_STYLE } from '@/utils/chartColors';

interface DataPoint {
  name: string;
  rides?: number;
}

interface RidesChartProps {
  data: DataPoint[];
  className?: string;
  height?: number;
}

const AXIS_TICK = { fill: 'var(--color-text-muted)', fontSize: 11 } as const;

export function RidesChart({ data, className, height = 240 }: RidesChartProps) {
  const isEmpty = !data || data.length === 0;

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-sm font-semibold uppercase tracking-wide">Rides Over Time</CardTitle>
        <span className="text-xs text-text-muted">Last 30 days</span>
      </CardHeader>
      <CardContent className="p-5">
        {isEmpty ? (
          <EmptyState icon={BarChart2} title="No ride data yet" description="Ride volumes will appear once trips are logged." />
        ) : (
          <ResponsiveContainer width="100%" height={height}>
            <AreaChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id="ridesFill" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="var(--color-primary)" stopOpacity={0.35} />
                  <stop offset="100%" stopColor="var(--color-primary)" stopOpacity={0} />
                </linearGradient>
              </defs>
              <XAxis
                dataKey="name"
                tick={AXIS_TICK}
                tickLine={false}
                axisLine={false}
                interval="preserveStartEnd"
                minTickGap={32}
              />
              <YAxis tick={AXIS_TICK} tickLine={false} axisLine={false} width={28} allowDecimals={false} />
              <Tooltip {...DARK_TOOLTIP_STYLE} />
              <Area
                type="monotone"
                dataKey="rides"
                stroke="var(--color-primary)"
                strokeWidth={2}
                fill="url(#ridesFill)"
              />
            </AreaChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
