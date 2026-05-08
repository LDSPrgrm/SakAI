// Vehicle type distribution — donut chart (motorcycle / tricycle / other).
// Spec: superadmin.md §4.1 Charts
import React from 'react';
import {
  PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';
import { cn } from '@/lib/utils';
import { renderInsidePieLabel } from '@/utils/pieLabels';

interface DataPoint {
  name: string;
  value: number;
}

interface VehicleTypeDonutProps {
  data: DataPoint[];
  className?: string;
}

const COLORS = ['#1A73E8', '#FF9800', '#4CAF50', '#9C27B0'];

export function VehicleTypeDonut({ data, className }: VehicleTypeDonutProps) {
  return (
    <div className={cn('bg-surface border border-border rounded-xl p-5', className)}>
      <p className="text-sm font-semibold text-text-main">Vehicle Type Distribution</p>
      <p className="text-xs text-text-muted mb-4">Share by vehicle type</p>
      <ResponsiveContainer width="100%" height={200}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            innerRadius={55}
            outerRadius={80}
            dataKey="value"
            label={renderInsidePieLabel}
            labelLine={false}
          >
            {data.map((_entry, i) => (
              <Cell key={i} fill={COLORS[i % COLORS.length]} />
            ))}
          </Pie>
          <Tooltip
            contentStyle={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8 }}
          />
          <Legend iconType="circle" iconSize={8} formatter={(v) => <span className="text-xs text-text-muted">{v}</span>} />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
