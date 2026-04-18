import React, { useEffect, useState } from 'react';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';
import { RefreshCw, Users, Car, Activity, Clock, Server } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { PhpIcon } from '@/components/ui/PhpIcon';
import { SummaryCard } from '@/components/shared/SummaryCard';
import { metricsApi } from '@/api/super-admin/metrics';
import type { DashboardMetrics } from '@/types/super-admin';
import { formatPHP } from '@/lib/utils';
import type { ActivityItem } from '@/mocks/admin/dashboard';

const COLORS = ['#1A73E8', '#34A853', '#FBBC05', '#EA4335', '#9C27B0'];

const TOOLTIP_STYLE = {
  contentStyle: { backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' },
};

export function SADashboard() {
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [ridesChart, setRidesChart] = useState<any[] | null>(null);
  const [revenueChart, setRevenueChart] = useState<any[] | null>(null);
  const [vehicleData, setVehicleData] = useState<any[] | null>(null);
  const [activity, setActivity] = useState<any[] | null>(null);
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      const [m, rc, rev, vd, af] = await Promise.all([
        metricsApi.getDashboard(),
        metricsApi.getRidesChart(),
        metricsApi.getRevenueChart(),
        metricsApi.getVehicleDistribution(),
        metricsApi.getActivityFeed(),
      ]);
      if (cancelled) return;
      setMetrics(m);
      setRidesChart(rc);
      setRevenueChart(rev);
      setVehicleData(vd);
      setActivity(af);
    }

    load();
    return () => { cancelled = true; };
  }, [refreshKey]);

  const isLoading = !metrics || !ridesChart || !revenueChart || !vehicleData || !activity;

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64 text-text-muted text-sm">
        Loading...
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">Super Admin Dashboard</h1>
        <Button
          variant="outline"
          size="sm"
          onClick={() => {
            setMetrics(null);
            setRefreshKey(k => k + 1);
          }}
          className="flex items-center gap-2"
        >
          <RefreshCw className="w-4 h-4" />
          Refresh
        </Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <SummaryCard
          title="Total Riders"
          value={(metrics.total_riders ?? 0).toLocaleString()}
          icon={<Users className="w-5 h-5 text-primary" />}
          trend={metrics.riders_trend ?? ''}
        />
        <SummaryCard
          title="Total Drivers"
          value={(metrics.total_drivers ?? 0).toLocaleString()}
          icon={<Car className="w-5 h-5 text-primary" />}
          trend={metrics.drivers_trend ?? ''}
        />
        <SummaryCard
          title="Rides Today"
          value={(metrics.rides_today ?? 0).toLocaleString()}
          icon={<Activity className="w-5 h-5 text-primary" />}
          trend={metrics.rides_trend ?? ''}
        />
        <SummaryCard
          title="Revenue Today"
          value={formatPHP(metrics.revenue_today ?? 0)}
          icon={<PhpIcon className="w-5 h-5 text-success" />}
          trend={metrics.revenue_trend ?? ''}
        />
        <SummaryCard
          title="Avg Wait Time"
          value={`${metrics.avg_wait_minutes ?? 0} mins`}
          icon={<Clock className="w-5 h-5 text-warning" />}
          trend={metrics.wait_trend ?? ''}
          trendDownIsGood
        />
        <SummaryCard
          title="Platform Uptime"
          value={`${metrics.platform_uptime ?? 0}%`}
          icon={<Server className="w-5 h-5 text-success" />}
        />
      </div>

      {/* Row 2: Rides Chart + Activity Feed */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Rides Over Time */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Rides Over Time</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <LineChart data={ridesChart} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                <XAxis dataKey="name" tick={{ fill: '#9CA3AF', fontSize: 12 }} />
                <YAxis tick={{ fill: '#9CA3AF', fontSize: 12 }} />
                <Tooltip {...TOOLTIP_STYLE} />
                <Line
                  type="monotone"
                  dataKey="rides"
                  stroke="#1A73E8"
                  strokeWidth={2}
                  dot={{ fill: '#1A73E8', r: 4 }}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Recent Activity */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="space-y-3">
              {activity.map((item) => (
                <li key={item.id} className="flex items-start gap-3">
                  <span
                    className={`mt-1.5 w-2 h-2 rounded-full flex-shrink-0 ${item.isAlert ? 'bg-danger' : 'bg-primary'
                      }`}
                  />
                  <div className="min-w-0">
                    <p
                      className={`text-sm leading-snug ${item.isAlert ? 'text-danger' : 'text-text-main'
                        }`}
                    >
                      {item.message}
                    </p>
                    <p className="text-xs text-text-muted mt-0.5">{item.time}</p>
                  </div>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      </div>

      {/* Row 3: Revenue Chart + Vehicle Distribution */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue by Week */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Revenue by Week</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={revenueChart} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                <XAxis dataKey="name" tick={{ fill: '#9CA3AF', fontSize: 12 }} />
                <YAxis
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                  tickFormatter={(v) => `₱${v / 1000}k`}
                />
                <Tooltip {...TOOLTIP_STYLE} />
                <Legend wrapperStyle={{ color: '#9CA3AF', fontSize: 12 }} />
                <Bar dataKey="gcash" stackId="a" fill={COLORS[0]} name="GCash" />
                <Bar dataKey="cash" stackId="a" fill={COLORS[1]} name="Cash" />
                <Bar dataKey="paymaya" stackId="a" fill={COLORS[2]} name="PayMaya" />
                <Bar dataKey="card" stackId="a" fill={COLORS[3]} name="Card" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Vehicle Distribution */}
        <Card>
          <CardHeader>
            <CardTitle>Vehicle Distribution</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col items-center">
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie
                  data={vehicleData}
                  dataKey="value"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={90}
                  paddingAngle={3}
                >
                  {vehicleData.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip {...TOOLTIP_STYLE} formatter={(v) => [`${v}%`, '']} />
                <Legend
                  iconType="circle"
                  wrapperStyle={{ color: '#9CA3AF', fontSize: 12 }}
                />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
