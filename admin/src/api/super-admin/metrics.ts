import { adminRequest, extractArray } from './_request';
import type { components } from '@/types/openapi';
import type { HeatmapResponse } from '@/types/super-admin/heatmap';
import { METRO_MANILA_BOUNDS } from '@/types/super-admin/heatmap';

export type DashboardResponse = components['schemas']['DashboardResponse'];
export type MetricResponse    = components['schemas']['MetricResponse'];

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

// TODO(spec, L1): DashboardResponse has ambiguous dual fields
// (total_riders|active_riders, avg_wait_time_seconds|avg_wait_minutes,
// system_uptime|platform_uptime). Clarify the spec to a single canonical field
// per metric; the fallback chains have been removed per audit L1.
export const metricsApi = {
  getDashboard: () =>
    adminRequest<DashboardResponse>('GET', '/dashboard').then((raw) => ({
      total_riders:    raw.total_riders    ?? 0,
      riders_trend:    raw.riders_trend    ?? '',
      total_drivers:   raw.total_drivers   ?? 0,
      drivers_trend:   raw.drivers_trend   ?? '',
      rides_today:     raw.rides_today     ?? 0,
      rides_trend:     raw.rides_trend     ?? '',
      revenue_today:   raw.revenue_today   ?? 0,
      revenue_trend:   raw.revenue_trend   ?? '',
      avg_wait_minutes: raw.avg_wait_minutes ?? 0,
      wait_trend:      raw.wait_trend      ?? '',
      platform_uptime: raw.platform_uptime ?? 0,
    } satisfies DashboardMetrics)),

  getRidesChart: () =>
    adminRequest<ChartPoint[]>('GET', '/reports/chart/rides'),

  getRevenueChart: () =>
    adminRequest<ChartPoint[]>('GET', '/reports/chart/revenue'),

  getVehicleDistribution: () =>
    adminRequest<{ name: string; value: number }[]>('GET', '/reports/chart/vehicles'),

  // Individual metric endpoints — spec §Metrics (M7). Use for per-KPI refresh.
  getRiderMetric:   () => adminRequest<MetricResponse>('GET', '/metrics/riders'),
  getDriverMetric:  () => adminRequest<MetricResponse>('GET', '/metrics/drivers'),
  getRidesMetric:   () => adminRequest<MetricResponse>('GET', '/metrics/rides'),
  getRevenueMetric: () => adminRequest<MetricResponse>('GET', '/metrics/revenue'),
  getWaitTimeMetric: () => adminRequest<MetricResponse>('GET', '/metrics/wait-time'),

  // Driver supply heatmap — one position per online driver, last-known PostGIS
  // location plus vehicle type and availability. Falls back to Metro Manila
  // bounds if backend returns an empty list or the query fails.
  getDriverHeatmap: async (): Promise<HeatmapResponse> => {
    try {
      const raw = await adminRequest<HeatmapResponse>('GET', '/drivers/heatmap');
      return {
        positions: raw.positions ?? [],
        bounds: raw.bounds ?? METRO_MANILA_BOUNDS,
        generated_at: raw.generated_at ?? new Date().toISOString(),
      };
    } catch {
      return { positions: [], bounds: METRO_MANILA_BOUNDS, generated_at: new Date().toISOString() };
    }
  },

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
