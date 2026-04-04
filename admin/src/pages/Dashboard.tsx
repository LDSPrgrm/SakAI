import React, { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Users, Car, Clock, MapPin, Activity } from 'lucide-react';
import { PhpIcon } from '@/components/ui/PhpIcon';
import { formatPHP } from '@/lib/utils';
import { api, HealthResponse } from '@/lib/api';
import { adminApi, DashboardMetrics } from '@/lib/admin-api';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export function Dashboard() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [ridesChart, setRidesChart] = useState<{ name: string; rides: number }[]>([]);
  const [revenueChart, setRevenueChart] = useState<{ name: string; revenue: number }[]>([]);
  const [activity, setActivity] = useState<{ id: string; message: string; time: string; isAlert: boolean }[]>([]);

  useEffect(() => {
    api.health.check().then(setHealth).catch(() => setHealth({ status: 'down' }));
    adminApi.dashboard.getMetrics().then(setMetrics).catch(() => {});
    adminApi.dashboard.getRidesChart().then(setRidesChart).catch(() => {});
    adminApi.dashboard.getRevenueChart().then(setRevenueChart).catch(() => {});
    adminApi.dashboard.getActivityFeed().then(setActivity).catch(() => {});
  }, []);

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
          value={metrics ? (metrics.total_riders ?? metrics.active_riders ?? 0).toLocaleString() : '—'}
          icon={<Users className="w-5 h-5 text-primary" />}
          trend={metrics?.riders_trend ?? ''}
        />
        <MetricCard
          title="Active Drivers"
          value={metrics ? (metrics.total_drivers ?? metrics.active_drivers ?? 0).toLocaleString() : '—'}
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
          value={metrics ? `${metrics.platform_uptime ?? metrics.system_uptime ?? 0}%` : '—'}
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
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" vertical={false} />
                  <XAxis dataKey="name" stroke="#A0A0A0" fontSize={12} tickLine={false} axisLine={false} />
                  <YAxis stroke="#A0A0A0" fontSize={12} tickLine={false} axisLine={false} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' }}
                    itemStyle={{ color: '#1A73E8' }}
                  />
                  <Line type="monotone" dataKey="rides" stroke="#1A73E8" strokeWidth={3} dot={{ r: 4, fill: '#1A73E8' }} activeDot={{ r: 6 }} connectNulls />
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
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" vertical={false} />
                  <XAxis dataKey="name" stroke="#A0A0A0" fontSize={12} tickLine={false} axisLine={false} />
                  <YAxis
                    stroke="#A0A0A0"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                    tickFormatter={(value) => `₱${value / 1000}k`}
                  />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' }}
                    cursor={{ fill: '#2A2A2A' }}
                    formatter={(value: number) => [formatPHP(value), 'Revenue']}
                  />
                  <Bar dataKey="revenue" fill="#1A73E8" radius={[4, 4, 0, 0]} />
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
            <div className="h-[250px] bg-surface-hover rounded-lg flex items-center justify-center border border-border relative overflow-hidden">
              <div className="absolute inset-0 opacity-20" style={{ backgroundImage: 'radial-gradient(#1A73E8 1px, transparent 1px)', backgroundSize: '10px 10px' }}></div>
              <div className="absolute top-1/4 left-1/4 w-12 h-12 bg-danger/30 rounded-full animate-pulse flex items-center justify-center">
                <div className="w-4 h-4 bg-danger rounded-full"></div>
              </div>
              <div className="absolute top-1/2 right-1/3 w-16 h-16 bg-primary/30 rounded-full animate-pulse flex items-center justify-center" style={{ animationDelay: '1s' }}>
                <div className="w-6 h-6 bg-primary rounded-full"></div>
              </div>
              <div className="absolute bottom-1/4 right-1/4 w-8 h-8 bg-warning/30 rounded-full animate-pulse flex items-center justify-center" style={{ animationDelay: '0.5s' }}>
                <div className="w-3 h-3 bg-warning rounded-full"></div>
              </div>
              <div className="z-10 flex flex-col items-center text-text-muted">
                <MapPin className="w-8 h-8 mb-2" />
                <span className="text-sm">Metro Manila Map View</span>
              </div>
            </div>
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
