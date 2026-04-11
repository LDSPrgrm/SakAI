import { adminRequest, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type DashboardResponse = components['schemas']['DashboardResponse'];

export interface DashboardMetrics {
  total_riders: number;
  riders_trend: string;
  total_drivers: number;
  drivers_trend: string;
  rides_today: number;
  rides_trend: string;
  revenue_today: number;
  revenue_trend: string;
  avg_wait_minutes: number;
  wait_trend: string;
  platform_uptime: number;
}

export interface ChartPoint {
  name: string;
  rides?: number;
  revenue?: number;
  gcash?: number;
  cash?: number;
  paymaya?: number;
  card?: number;
}

export interface ActivityItem {
  id: string;
  type: string;
  message: string;
  time: string;
  isAlert: boolean;
}

export const metricsApi = {
  getDashboard: () =>
    adminRequest<DashboardResponse>('GET', '/dashboard').then((raw) => ({
      total_riders:    raw.total_riders  ?? raw.active_riders  ?? 0,
      riders_trend:    raw.riders_trend  ?? '',
      total_drivers:   raw.total_drivers ?? raw.active_drivers ?? 0,
      drivers_trend:   raw.drivers_trend ?? '',
      rides_today:     raw.rides_today   ?? 0,
      rides_trend:     raw.rides_trend   ?? '',
      revenue_today:   raw.revenue_today ?? 0,
      revenue_trend:   '',
      avg_wait_minutes: raw.avg_wait_time_seconds != null
        ? Math.round(raw.avg_wait_time_seconds / 60)
        : 0,
      wait_trend:      '',
      platform_uptime: raw.system_uptime ?? 0,
    } satisfies DashboardMetrics)),

  getRidesChart: () =>
    adminRequest<ChartPoint[]>('GET', '/reports/chart/rides'),

  getRevenueChart: () =>
    adminRequest<ChartPoint[]>('GET', '/reports/chart/revenue'),

  getVehicleDistribution: () =>
    adminRequest<{ name: string; value: number }[]>('GET', '/reports/chart/vehicles'),

  getActivityFeed: () =>
    adminRequest<unknown>('GET', '/audit?limit=10').then((raw) => {
      const logs = extractArray<{ id: string; actor_name: string; action: string; resource_type?: string; timestamp: string }>(raw);
      return logs.map((log) => ({
        id:      log.id,
        type:    log.action ?? 'event',
        message: `${log.actor_name} ${log.action}d ${(log.resource_type ?? 'resource').replace('_', ' ')}`,
        time:    new Date(log.timestamp).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
        isAlert: log.action === 'delete' || log.action === 'reject',
      }) satisfies ActivityItem);
    }),
};
