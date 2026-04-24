import React, { useEffect, useState } from 'react';
import { RefreshCw, Users, Car, Activity, Clock, Server, PhilippinePeso } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { KPICard } from '@/components/super-admin/dashboard/KPICard';
import { RidesChart } from '@/components/super-admin/dashboard/RidesChart';
import { RevenueChart } from '@/components/super-admin/dashboard/RevenueChart';
import { VehicleDistribution } from '@/components/super-admin/dashboard/VehicleDistribution';
import { ActivityFeed } from '@/components/super-admin/dashboard/ActivityFeed';
import {
  useDashboardMetrics, useRidesChart, useRevenueChart,
  useVehicleDistribution, useActivityFeed,
} from '@/hooks/useMetrics';
import { formatPHP, cn } from '@/lib/utils';

type Period = '24h' | '7d' | '30d';

const PERIODS: Period[] = ['24h', '7d', '30d'];

function useNow(intervalMs = 30_000) {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const id = window.setInterval(() => setNow(new Date()), intervalMs);
    return () => window.clearInterval(id);
  }, [intervalMs]);
  return now;
}

export function SADashboard() {
  const metricsQuery = useDashboardMetrics();
  const ridesChartQuery = useRidesChart();
  const revenueChartQuery = useRevenueChart();
  const vehicleQuery = useVehicleDistribution();
  const activityQuery = useActivityFeed();

  const [period, setPeriod] = useState<Period>('30d');
  const now = useNow();

  const refetchAll = () => {
    void metricsQuery.refetch();
    void ridesChartQuery.refetch();
    void revenueChartQuery.refetch();
    void vehicleQuery.refetch();
    void activityQuery.refetch();
  };

  const metrics = metricsQuery.data;
  const ridesChart = ridesChartQuery.data;
  const revenueChart = revenueChartQuery.data;
  const vehicleData = vehicleQuery.data;
  const activity = activityQuery.data;

  const isLoading = !metrics || !ridesChart || !revenueChart || !vehicleData || !activity;
  const isFetching =
    metricsQuery.isFetching ||
    ridesChartQuery.isFetching ||
    revenueChartQuery.isFetching ||
    vehicleQuery.isFetching ||
    activityQuery.isFetching;

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64 text-text-muted text-sm">
        Loading dispatch console…
      </div>
    );
  }

  const timestamp = new Intl.DateTimeFormat('en-PH', {
    timeZone: 'Asia/Manila',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  }).format(now);

  const dateLabel = new Intl.DateTimeFormat('en-PH', {
    timeZone: 'Asia/Manila',
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(now);

  const kpis = [
    {
      title: 'Revenue Today',
      value: formatPHP(metrics.revenue_today ?? 0),
      icon: PhilippinePeso,
      tone: 'sa-accent' as const,
      trend: metrics.revenue_trend,
    },
    {
      title: 'Riders',
      value: (metrics.total_riders ?? 0).toLocaleString(),
      icon: Users,
      tone: 'primary' as const,
      trend: metrics.riders_trend,
    },
    {
      title: 'Drivers',
      value: (metrics.total_drivers ?? 0).toLocaleString(),
      icon: Car,
      tone: 'primary' as const,
      trend: metrics.drivers_trend,
    },
    {
      title: 'Rides Today',
      value: (metrics.rides_today ?? 0).toLocaleString(),
      icon: Activity,
      tone: 'sa-accent' as const,
      trend: metrics.rides_trend,
    },
    {
      title: 'Avg Wait',
      value: `${metrics.avg_wait_minutes ?? 0}m`,
      icon: Clock,
      tone: 'warning' as const,
      trend: metrics.wait_trend,
      trendDownIsGood: true,
    },
    {
      title: 'Uptime',
      value: `${metrics.platform_uptime ?? 0}%`,
      icon: Server,
      tone: 'success' as const,
    },
  ];

  return (
    <div className="flex flex-col gap-5">
      {/* Editorial header */}
      <header className="flex flex-col gap-3 pb-2 border-b border-border/60">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <span className="overline text-[var(--color-sa-accent)]">
            Super Admin · Operations
          </span>
          <div className="flex items-center gap-2 text-xs text-text-muted tabular-nums">
            <span className="relative flex w-2 h-2">
              <span className="absolute inset-0 rounded-full bg-success animate-ping opacity-60" />
              <span className="relative rounded-full bg-success w-2 h-2" />
            </span>
            <span className="hidden sm:inline">{dateLabel} · Manila</span>
            <span className="font-mono text-text-main">{timestamp}</span>
          </div>
        </div>

        <div className="flex flex-wrap items-end justify-between gap-3">
          <div className="flex flex-col gap-1 min-w-0">
            <h1 className="text-2xl md:text-3xl font-bold text-text-main tracking-tight leading-none">
              Dispatch Console
            </h1>
            <p className="text-sm text-text-muted">
              Real-time pulse of SakAI rides, revenue, and platform health.
            </p>
          </div>
          <div className="flex items-center gap-2 flex-shrink-0">
            <div
              role="tablist"
              aria-label="Time period"
              className="flex rounded-lg border border-border bg-background p-0.5"
            >
              {PERIODS.map((p) => (
                <button
                  key={p}
                  role="tab"
                  aria-selected={period === p}
                  onClick={() => setPeriod(p)}
                  className={cn(
                    'px-3 py-1 text-xs font-semibold rounded-md transition-colors uppercase tracking-wider tabular-nums',
                    period === p
                      ? 'bg-[var(--color-sa-accent)] text-black'
                      : 'text-text-muted hover:text-text-main hover:bg-surface-hover',
                  )}
                >
                  {p}
                </button>
              ))}
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={refetchAll}
              disabled={isFetching}
              title="Refresh all panels"
              className="flex items-center gap-2"
            >
              <RefreshCw className={cn('w-4 h-4', isFetching && 'animate-spin')} />
              Refresh
            </Button>
          </div>
        </div>
      </header>

      {/* Uniform 6-up KPI strip */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        {kpis.map((k, i) => (
          <div key={k.title} className="kpi-rise" style={{ animationDelay: `${i * 55}ms` }}>
            <KPICard
              title={k.title}
              value={k.value}
              icon={k.icon}
              iconTone={k.tone}
              trend={k.trend}
              trendDownIsGood={k.trendDownIsGood}
            />
          </div>
        ))}
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        <RidesChart data={ridesChart} period={period} accent="sa" className="lg:col-span-8" />
        <RevenueChart data={revenueChart} period={period} className="lg:col-span-4" />
      </div>

      {/* Bottom row — items-start so Fleet Mix keeps its natural height */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-start">
        <VehicleDistribution data={vehicleData} className="lg:col-span-4" />
        <ActivityFeed events={activity} className="lg:col-span-8" />
      </div>
    </div>
  );
}
