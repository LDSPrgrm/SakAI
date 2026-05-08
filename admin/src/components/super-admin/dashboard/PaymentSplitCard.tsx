import React, { useMemo } from 'react';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { PieChart as PieIcon } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
import { CHART_COLORS, DARK_TOOLTIP_STYLE } from '@/utils/chartColors';
import { renderInsidePieLabel } from '@/utils/pieLabels';
import { cn } from '@/lib/utils';
import type { UseQueryResult } from '@tanstack/react-query';

type ChartPoint = { label?: string; value?: number };

export interface PaymentSplitCardProps {
  query: UseQueryResult<unknown[]>;
  className?: string;
}

export function PaymentSplitCard({ query, className }: PaymentSplitCardProps) {
  const normalized = useMemo(() => {
    const raw = (query.data ?? []) as ChartPoint[];
    return raw
      .map((d) => ({ name: d.label ?? '', value: d.value ?? 0 }))
      .filter((d) => d.value > 0);
  }, [query.data]);

  return (
    <Card className={cn('flex flex-col', className)}>
      <CardHeader className="flex flex-col gap-1">
        <div className="flex flex-row items-center justify-between">
          <div className="flex items-center gap-2">
            <span
              className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]"
              aria-hidden
            />
            <CardTitle className="text-sm font-semibold uppercase tracking-wider">
              Payment Split
            </CardTitle>
          </div>
          <span className="text-[10px] uppercase tracking-widest text-text-muted/80">
            today
          </span>
        </div>
        <p className="text-xs text-text-muted">Share of payments today</p>
      </CardHeader>
      <CardContent className="flex-1 min-h-0 pt-0">
        {query.isLoading ? (
          <div
            data-testid="payment-split-skeleton"
            className="h-[200px] w-full rounded-md bg-surface-hover animate-pulse"
          />
        ) : normalized.length === 0 ? (
          <EmptyState
            icon={PieIcon}
            title="No payment data"
            description="Transactions will split across GCash, PayMaya, Card, and Cash once rides settle today."
          />
        ) : (
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie
                data={normalized}
                cx="50%"
                cy="50%"
                innerRadius={55}
                outerRadius={80}
                dataKey="value"
                label={renderInsidePieLabel}
                labelLine={false}
              >
                {normalized.map((_entry, i) => (
                  <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip {...DARK_TOOLTIP_STYLE} />
              <Legend
                iconType="circle"
                iconSize={8}
                formatter={(v) => (
                  <span className="text-xs text-text-muted">{v}</span>
                )}
              />
            </PieChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
