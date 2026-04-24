import React from 'react';
import { Car } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
import { CHART_COLORS } from '@/utils/chartColors';

interface VehicleRow {
  name: string;
  value: number;
}

interface VehicleDistributionProps {
  data: VehicleRow[];
  className?: string;
}

export function VehicleDistribution({ data, className }: VehicleDistributionProps) {
  const total = data.reduce((sum, v) => sum + (v.value ?? 0), 0);
  const isEmpty = data.length === 0 || total === 0;

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-sm font-semibold uppercase tracking-wide">Vehicle Types</CardTitle>
        <span className="text-xs text-text-muted tabular-nums">
          {total.toLocaleString()} rides
        </span>
      </CardHeader>
      <CardContent className="p-5">
        {isEmpty ? (
          <EmptyState icon={Car} title="No ride data yet" description="Vehicle mix appears after the first trip." />
        ) : (
          <ul className="flex flex-col gap-3">
            {data.map((v, i) => {
              const pct = total > 0 ? (v.value / total) * 100 : 0;
              const color = CHART_COLORS[i % CHART_COLORS.length];
              return (
                <li
                  key={v.name}
                  className="group rounded-md px-2 py-1.5 -mx-2 transition-colors hover:bg-surface-hover/50"
                >
                  <div className="flex items-baseline justify-between text-sm mb-1.5">
                    <span className="text-text-main capitalize font-medium">{v.name}</span>
                    <span className="text-text-muted tabular-nums text-xs">
                      {v.value.toLocaleString()}
                      <span className="ml-1.5 opacity-70">{pct.toFixed(0)}%</span>
                    </span>
                  </div>
                  <div className="h-1.5 rounded-full bg-surface-hover overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{ width: `${pct}%`, backgroundColor: color }}
                    />
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </CardContent>
    </Card>
  );
}
