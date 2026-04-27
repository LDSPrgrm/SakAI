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
      <CardHeader className="flex flex-col gap-1">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]" aria-hidden />
            <CardTitle className="text-sm font-semibold uppercase tracking-wider">Fleet Mix</CardTitle>
          </div>
          <span className="text-xs text-text-muted tabular-nums">
            <span className="text-text-main font-semibold">{total.toLocaleString()}</span> rides
          </span>
        </div>
      </CardHeader>
      <CardContent className="p-5">
        {isEmpty ? (
          <EmptyState
            icon={Car}
            title="Fleet mix pending"
            description="Vehicle distribution appears after the first trip."
            hint="Updates live"
          />
        ) : (
          <div className="flex flex-col gap-4">
            {/* Stacked bar glyph */}
            <div className="h-2 w-full rounded-full bg-surface-hover overflow-hidden flex">
              {data.map((v, i) => {
                const pct = total > 0 ? (v.value / total) * 100 : 0;
                const color = CHART_COLORS[i % CHART_COLORS.length];
                return (
                  <div
                    key={`bar-${v.name}`}
                    className="h-full transition-all duration-500"
                    style={{ width: `${pct}%`, backgroundColor: color }}
                    title={`${v.name}: ${pct.toFixed(1)}%`}
                  />
                );
              })}
            </div>

            <ul className="flex flex-col gap-2">
              {data.map((v, i) => {
                const pct = total > 0 ? (v.value / total) * 100 : 0;
                const color = CHART_COLORS[i % CHART_COLORS.length];
                return (
                  <li
                    key={v.name}
                    className="group flex items-center gap-3 rounded-md px-2 py-1.5 -mx-2 transition-colors hover:bg-surface-hover/50"
                  >
                    <span
                      className="w-2.5 h-2.5 rounded-sm flex-shrink-0"
                      style={{ backgroundColor: color }}
                      aria-hidden
                    />
                    <span className="text-sm text-text-main capitalize font-medium flex-1 truncate">
                      {v.name}
                    </span>
                    <span className="text-text-muted tabular-nums text-xs">
                      {v.value.toLocaleString()}
                    </span>
                    <span className="text-[11px] font-semibold tabular-nums text-text-main bg-surface-hover px-1.5 py-0.5 rounded min-w-[3rem] text-right">
                      {pct.toFixed(0)}%
                    </span>
                  </li>
                );
              })}
            </ul>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
