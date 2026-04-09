// Rides over time — line chart with 7d/30d/90d toggle and optional previous period overlay.
// Spec: superadmin.md §4.1 Charts
import React, { useState } from 'react';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { cn } from '@/lib/utils';

type Period = '7d' | '30d' | '90d';

interface DataPoint {
  name: string;
  rides: number;
  prev?: number;
}

interface RidesChartProps {
  data: DataPoint[];
  className?: string;
}

const PERIODS: Period[] = ['7d', '30d', '90d'];

export function RidesChart({ data, className }: RidesChartProps) {
  const [period, setPeriod] = useState<Period>('30d');
  const [showPrev, setShowPrev] = useState(false);

  const sliced = period === '7d' ? data.slice(-7) : period === '90d' ? data : data.slice(-30);

  return (
    <div className={cn('bg-surface border border-border rounded-xl p-5', className)}>
      <div className="flex items-center justify-between mb-4">
        <p className="text-sm font-semibold text-text-main">Rides Over Time</p>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowPrev((p) => !p)}
            className={cn(
              'text-xs px-2 py-1 rounded border transition-colors',
              showPrev ? 'border-primary text-primary' : 'border-border text-text-muted hover:border-primary/50',
            )}
          >
            Compare
          </button>
          <div className="flex rounded-lg overflow-hidden border border-border">
            {PERIODS.map((p) => (
              <button
                key={p}
                onClick={() => setPeriod(p)}
                className={cn(
                  'px-3 py-1 text-xs transition-colors',
                  period === p ? 'bg-primary text-white' : 'text-text-muted hover:text-text-main',
                )}
              >
                {p}
              </button>
            ))}
          </div>
        </div>
      </div>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={sliced}>
          <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border)" />
          <XAxis dataKey="name" tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }} />
          <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }} />
          <Tooltip
            contentStyle={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8 }}
            labelStyle={{ color: 'var(--color-text-main)' }}
          />
          {showPrev && <Legend />}
          <Line type="monotone" dataKey="rides" stroke="var(--color-primary)" strokeWidth={2} dot={false} name="Rides" />
          {showPrev && (
            <Line type="monotone" dataKey="prev" stroke="var(--color-text-muted)" strokeWidth={1.5} strokeDasharray="4 2" dot={false} name="Prev period" />
          )}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
