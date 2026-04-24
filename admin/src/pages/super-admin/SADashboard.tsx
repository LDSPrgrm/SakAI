import React from 'react';
import { RefreshCw, Users, Car, Activity, Clock, Server } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { PhpIcon } from '@/components/ui/PhpIcon';
import { KPICard } from '@/components/super-admin/dashboard/KPICard';
import { RidesChart } from '@/components/super-admin/dashboard/RidesChart';
import { RevenueChart } from '@/components/super-admin/dashboard/RevenueChart';
import { VehicleDistribution } from '@/components/super-admin/dashboard/VehicleDistribution';
import { ActivityFeed } from '@/components/super-admin/dashboard/ActivityFeed';
import {
  useDashboardMetrics, useRidesChart, useRevenueChart,
  useVehicleDistribution, useActivityFeed,
} from '@/hooks/useMetrics';
import { formatPHP } from '@/lib/utils';

export function SADashboard() {
  const metricsQuery = useDashboardMetrics();
  const ridesChartQuery = useRidesChart();
  const revenueChartQuery = useRevenueChart();
  const vehicleQuery = useVehicleDistribution();
  const activityQuery = useActivityFeed();

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
        Loading...
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-5">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold text-text-main tracking-tight">Super Admin Dashboard</h1>
        <Button
          variant="outline"
          size="sm"
          onClick={refetchAll}
          disabled={isFetching}
          title="Refresh all panels"
          className="flex items-center gap-2"
        >
          <RefreshCw className={`w-4 h-4 ${isFetching ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {/* KPI strip */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        <KPICard
          title="Total Riders"
          value={(metrics.total_riders ?? 0).toLocaleString()}
          icon={Users}
          iconTone="primary"
          trend={metrics.riders_trend}
        />
        <KPICard
          title="Total Drivers"
          value={(metrics.total_drivers ?? 0).toLocaleString()}
          icon={Car}
          iconTone="primary"
          trend={metrics.drivers_trend}
        />
        <KPICard
          title="Rides Today"
          value={(metrics.rides_today ?? 0).toLocaleString()}
          icon={Activity}
          iconTone="primary"
          trend={metrics.rides_trend}
        />
        <KPICard
          title="Revenue Today"
          value={formatPHP(metrics.revenue_today ?? 0)}
          icon={PhpIcon}
          iconTone="success"
          trend={metrics.revenue_trend}
        />
        <KPICard
          title="Avg Wait"
          value={`${metrics.avg_wait_minutes ?? 0} min`}
          icon={Clock}
          iconTone="warning"
          trend={metrics.wait_trend}
          trendDownIsGood
        />
        <KPICard
          title="Uptime"
          value={`${metrics.platform_uptime ?? 0}%`}
          icon={Server}
          iconTone="success"
        />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        <RidesChart data={ridesChart} className="lg:col-span-8" />
        <RevenueChart data={revenueChart} className="lg:col-span-4" />
      </div>

      {/* Bottom row: vehicle + activity */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        <VehicleDistribution data={vehicleData} className="lg:col-span-4" />
        <ActivityFeed events={activity} className="lg:col-span-8" />
      </div>
    </div>
  );
}
