import React, { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Users, Car, Clock, MapPin, Activity } from 'lucide-react';
import { PhpIcon } from '@/components/ui/PhpIcon';
import { formatPHP } from '@/lib/utils';
import { api, HealthResponse } from '@/lib/api';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const rideData = [
  { name: 'Mon', rides: 4000 },
  { name: 'Tue', rides: 3000 },
  { name: 'Wed', rides: 2000 },
  { name: 'Thu', rides: 2780 },
  { name: 'Fri', rides: 1890 },
  { name: 'Sat', rides: 2390 },
  { name: 'Sun', rides: 3490 },
];

const revenueData = [
  { name: 'Week 1', revenue: 400000 },
  { name: 'Week 2', revenue: 300000 },
  { name: 'Week 3', revenue: 200000 },
  { name: 'Week 4', revenue: 278000 },
];

const recentActivity = [
  { id: 1, type: 'booking', message: 'New ride booked in Makati', time: '2 mins ago' },
  { id: 2, type: 'signup', message: 'Driver Juan Dela Cruz signed up', time: '15 mins ago' },
  { id: 3, type: 'incident', message: 'Flagged incident: Ride #4928', time: '1 hour ago', isAlert: true },
  { id: 4, type: 'booking', message: 'New ride booked in BGC', time: '1 hour ago' },
];

export function Dashboard() {
  const [health, setHealth] = useState<HealthResponse | null>(null);

  useEffect(() => {
    api.health.check().then(setHealth).catch(() => setHealth({ status: 'down' }));
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
        <MetricCard title="Active Riders" value="24,592" icon={<Users className="w-5 h-5 text-primary" />} trend="+12%" />
        <MetricCard title="Active Drivers" value="3,842" icon={<Car className="w-5 h-5 text-primary" />} trend="+5%" />
        <MetricCard title="Rides Today" value="12,403" icon={<Activity className="w-5 h-5 text-primary" />} trend="+18%" />
        <MetricCard title="Revenue Today" value={formatPHP(1245000)} icon={<PhpIcon className="w-5 h-5 text-success" />} trend="+8%" valueClassName="text-xl xl:text-2xl tracking-tight" />
        <MetricCard title="Avg Wait Time" value="4.2 mins" icon={<Clock className="w-5 h-5 text-warning" />} trend="-1.5%" trendDownIsGood />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Rides (Past 7 Days)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={rideData} margin={{ top: 5, right: 20, bottom: 5, left: 0 }}>
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
            <div className="space-y-4">
              {recentActivity.map((activity) => (
                <div key={activity.id} className="flex items-start gap-3">
                  <div className={`mt-0.5 w-2 h-2 rounded-full ${activity.isAlert ? 'bg-danger' : 'bg-primary'}`} />
                  <div>
                    <p className={`text-sm font-medium ${activity.isAlert ? 'text-danger' : 'text-text-main'}`}>
                      {activity.message}
                    </p>
                    <p className="text-xs text-text-muted mt-1">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Revenue by Week</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[250px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={revenueData} margin={{ top: 5, right: 20, bottom: 5, left: 20 }}>
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
              {/* Placeholder for Map Widget */}
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

function MetricCard({ title, value, icon, trend, trendDownIsGood = false, valueClassName = "" }: { title: string, value: string, icon: React.ReactNode, trend: string, trendDownIsGood?: boolean, valueClassName?: string }) {
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
          <div className="mt-4 flex items-center text-sm">
            <span className={`font-medium ${isGood ? 'text-success' : 'text-danger'}`}>
              {trend}
            </span>
            <span className="text-text-muted ml-2">vs last period</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
