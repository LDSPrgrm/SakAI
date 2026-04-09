// Revenue by week — stacked bar chart by payment method (PHP values).
// Spec: superadmin.md §4.1 Charts
import React from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';
import { cn } from '@/lib/utils';

interface DataPoint {
  name: string;
  cash?: number;
  gcash?: number;
  paymaya?: number;
  card?: number;
}

interface RevenueChartProps {
  data: DataPoint[];
  className?: string;
}

const METHOD_COLORS = {
  cash:    '#6B7280',
  gcash:   '#1A73E8',
  paymaya: '#4CAF50',
  card:    '#FF9800',
};

export function RevenueChart({ data, className }: RevenueChartProps) {
  return (
    <div className={cn('bg-surface border border-border rounded-xl p-5', className)}>
      <p className="text-sm font-semibold text-text-main mb-4">Revenue by Week (₱)</p>
      <ResponsiveContainer width="100%" height={200}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border)" />
          <XAxis dataKey="name" tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }} />
          <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            tickFormatter={(v) => `₱${(v / 1000).toFixed(0)}k`} />
          <Tooltip
            contentStyle={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8 }}
            formatter={(v: number, name: string) => [`₱${v.toLocaleString('en-PH')}`, name]}
          />
          <Legend />
          <Bar dataKey="gcash"   stackId="rev" fill={METHOD_COLORS.gcash}   name="GCash"   />
          <Bar dataKey="paymaya" stackId="rev" fill={METHOD_COLORS.paymaya} name="PayMaya" />
          <Bar dataKey="card"    stackId="rev" fill={METHOD_COLORS.card}    name="Card"    />
          <Bar dataKey="cash"    stackId="rev" fill={METHOD_COLORS.cash}    name="Cash"    radius={[4,4,0,0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
