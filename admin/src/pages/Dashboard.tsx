import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Users, Car, Clock, Activity } from 'lucide-react';
import { PhpIcon } from '@/components/ui/PhpIcon';
import { formatPHP } from '@/lib/utils';
import {
  useDashboardMetrics, useRidesChart, useRevenueChart, useActivityFeed, useDriverHeatmap,
} from '@/hooks/useMetrics';
import { DriverHeatmap } from '@/components/super-admin/dashboard/DriverHeatmap';
import { useHealth } from '@/hooks/useSystem';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import {
  AXIS_COLOR, GRID_COLOR, PRIMARY_LINE_COLOR, TOOLTIP_CURSOR_FILL, DARK_TOOLTIP_STYLE,
} from '@/utils/chartColors';

export function Dashboard() {
  const healthQuery = useHealth();
  const metricsQuery = useDashboardMetrics();
  const ridesChartQuery = useRidesChart();
  const revenueChartQuery = useRevenueChart();
  const activityQuery = useActivityFeed();
  const heatmapQuery = useDriverHeatmap();

  const health = healthQuery.isError
    ? { status: 'down' as const }
    : healthQuery.data;
  const metrics = metricsQuery.data;
  const ridesChart = ridesChartQuery.data ?? [];
  const revenueChart = revenueChartQuery.data ?? [];
  const activity = activityQuery.data ?? [];

  const statusColor = health?.status === 'ok'
    ? 'text-success'
    : health?.status === 'degraded'
      ? 'text-warning'
      : 'text-danger';

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap justify-between items-center gap-3">
        <h1 className="text-2xl font-bold text-text-main">Dashboard</h1>
        {health && (
          <div className="flex items-center gap-2 text-sm bg-surface border border-border rounded-lg px-3 py-1.5">
            <span className={`w-2 h-2 rounded-full ${health.status === 'ok' ? 'bg-success' : health.status === 'degraded' ? 'bg-warning' : 'bg-danger'}`} />
            <span className={`font-medium ${statusColor}`}>
              API {health.status.toUpperCase()}
            </span>
            {health.version && (
              <span className="text-text-muted">v{health.version}</span>
            )}
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <MetricCard
          title="Active Riders"
          value={metrics ? (metrics.total_riders ?? 0).toLocaleString() : '—'}
          icon={<Users className="w-5 h-5 text-primary" />}
          trend={metrics?.riders_trend ?? ''}
        />
        <MetricCard
          title="Active Drivers"
          value={metrics ? (metrics.total_drivers ?? 0).toLocaleString() : '—'}
          icon={<Car className="w-5 h-5 text-primary" />}
          trend={metrics?.drivers_trend ?? ''}
        />
        <MetricCard
          title="Rides Today"
          value={metrics ? (metrics.rides_today ?? 0).toLocaleString() : '—'}
          icon={<Activity className="w-5 h-5 text-primary" />}
          trend={metrics?.rides_trend ?? ''}
        />
        <MetricCard
          title="Revenue Today"
          value={metrics ? formatPHP(metrics.revenue_today ?? 0) : '—'}
          icon={<PhpIcon className="w-5 h-5 text-success" />}
          trend={metrics?.revenue_trend ?? ''}
          valueClassName="text-xl xl:text-2xl tracking-tight"
        />
        <MetricCard
          title="Avg Wait Time"
          value={metrics ? `${metrics.avg_wait_minutes ?? 0} mins` : '—'}
          icon={<Clock className="w-5 h-5 text-warning" />}
          trend={metrics?.wait_trend ?? ''}
          trendDownIsGood
        />
        <MetricCard
          title="Platform Uptime"
          value={metrics ? `${metrics.platform_uptime ?? 0}%` : '—'}
          icon={<Activity className="w-5 h-5 text-success" />}
          trend=""
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Rides (Past 7 Days)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={ridesChart} margin={{ top: 5, right: 20, bottom: 5, left: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke={GRID_COLOR} vertical={false} />
                  <XAxis dataKey="name" stroke={AXIS_COLOR} fontSize={12} tickLine={false} axisLine={false} />
                  <YAxis stroke={AXIS_COLOR} fontSize={12} tickLine={false} axisLine={false} />
                  <Tooltip
                    {...DARK_TOOLTIP_STYLE}
                    itemStyle={{ color: PRIMARY_LINE_COLOR }}
                  />
                  <Line type="monotone" dataKey="rides" stroke={PRIMARY_LINE_COLOR} strokeWidth={3} dot={{ r: 4, fill: PRIMARY_LINE_COLOR }} activeDot={{ r: 6 }} connectNulls />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            {activity.length === 0 ? (
              <p className="text-sm text-text-muted text-center py-4">No recent activity.</p>
            ) : (
              <div className="space-y-4">
                {activity.map((item) => (
                  <div key={item.id} className="flex items-start gap-3">
                    <div className={`mt-0.5 w-2 h-2 rounded-full flex-shrink-0 ${item.isAlert ? 'bg-danger' : 'bg-primary'}`} />
                    <div>
                      <p className={`text-sm font-medium ${item.isAlert ? 'text-danger' : 'text-text-main'}`}>
                        {item.message}
                      </p>
                      <p className="text-xs text-text-muted mt-1">{item.time}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Revenue by Week</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[250px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={revenueChart} margin={{ top: 5, right: 20, bottom: 5, left: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke={GRID_COLOR} vertical={false} />
                  <XAxis dataKey="name" stroke={AXIS_COLOR} fontSize={12} tickLine={false} axisLine={false} />
                  <YAxis
                    stroke={AXIS_COLOR}
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                    tickFormatter={(value) => `₱${value / 1000}k`}
                  />
                  <Tooltip
                    {...DARK_TOOLTIP_STYLE}
                    cursor={{ fill: TOOLTIP_CURSOR_FILL }}
                    formatter={(value: number) => [formatPHP(value), 'Revenue']}
                  />
                  <Bar dataKey="revenue" fill={PRIMARY_LINE_COLOR} radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Live Hotspots</CardTitle>
          </CardHeader>
          <CardContent>
            <DriverHeatmap
              positions={heatmapQuery.data?.positions}
              bounds={heatmapQuery.data?.bounds}
              loading={heatmapQuery.isPending}
              className="h-[250px]"
            />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function MetricCard({ title, value, icon, trend, trendDownIsGood = false, valueClassName = "" }: {
  title: string;
  value: string;
  icon: React.ReactNode;
  trend: string;
  trendDownIsGood?: boolean;
  valueClassName?: string;
}) {
  const isPositive = trend.startsWith('+');
  const isGood = trendDownIsGood ? !isPositive : isPositive;

  return (
    <Card>
      <CardContent className="p-5 flex flex-col justify-between h-full">
        <div className="flex justify-between items-start mb-4">
          <p className="text-sm font-medium text-text-muted">{title}</p>
          <div className="p-2 bg-surface-hover rounded-lg flex items-center justify-center flex-shrink-0">
            {icon}
          </div>
        </div>
        <div>
          <h4 className={`text-2xl sm:text-3xl font-bold text-text-main tracking-tight leading-none break-words ${valueClassName}`}>
            {value}
          </h4>
          {trend && (
            <div className="mt-4 flex items-center text-sm">
              <span className={`font-medium ${isGood ? 'text-success' : 'text-danger'}`}>
                {trend}
              </span>
              <span className="text-text-muted ml-2">vs last period</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
