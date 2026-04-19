import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, waitFor } from '@testing-library/react';
import React from 'react';
import {
  useDashboardMetrics,
  useRidesChart,
  useRevenueChart,
  useActivityFeed,
} from '../useMetrics';

vi.mock('@/api/super-admin/metrics', () => ({
  metricsApi: {
    getDashboard:        vi.fn().mockResolvedValue({ total_riders: 0, total_drivers: 0, rides_today: 0, revenue_today: 0, avg_wait_minutes: 0, platform_uptime: 100, riders_trend: '', drivers_trend: '', rides_trend: '', revenue_trend: '', wait_trend: '' }),
    getRidesChart:       vi.fn().mockResolvedValue([]),
    getRevenueChart:     vi.fn().mockResolvedValue([]),
    getVehicleDistribution: vi.fn().mockResolvedValue([]),
    getActivityFeed:     vi.fn().mockResolvedValue([]),
  },
}));

function wrapper(qc: QueryClient) {
  return ({ children }: { children: React.ReactNode }) =>
    React.createElement(QueryClientProvider, { client: qc }, children);
}

describe('useMetrics hooks', () => {
  let qc: QueryClient;

  beforeEach(() => {
    qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  });

  afterEach(() => {
    qc.clear();
    vi.clearAllMocks();
  });

  it('useDashboardMetrics returns dashboard data', async () => {
    const { metricsApi } = await import('@/api/super-admin/metrics');
    const stub = { total_riders: 1200, total_drivers: 340, rides_today: 88, revenue_today: 45000, avg_wait_minutes: 3.2, platform_uptime: 99.9, riders_trend: '+5%', drivers_trend: '+2%', rides_trend: '+10%', revenue_trend: '+8%', wait_trend: '-0.3' };
    vi.mocked(metricsApi.getDashboard).mockResolvedValue(stub);

    const { result } = renderHook(() => useDashboardMetrics(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(stub);
  });

  it('useDashboardMetrics exposes error state on failure', async () => {
    const { metricsApi } = await import('@/api/super-admin/metrics');
    vi.mocked(metricsApi.getDashboard).mockRejectedValue(new Error('network error'));

    const { result } = renderHook(() => useDashboardMetrics(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toBeInstanceOf(Error);
  });

  it('useRidesChart returns an array of chart points', async () => {
    const { metricsApi } = await import('@/api/super-admin/metrics');
    const points = [{ name: 'Mon', rides: 120 }, { name: 'Tue', rides: 95 }];
    vi.mocked(metricsApi.getRidesChart).mockResolvedValue(points);

    const { result } = renderHook(() => useRidesChart(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(points);
  });

  it('useRevenueChart returns an array of chart points', async () => {
    const { metricsApi } = await import('@/api/super-admin/metrics');
    const points = [{ name: 'Mon', revenue: 5000 }];
    vi.mocked(metricsApi.getRevenueChart).mockResolvedValue(points);

    const { result } = renderHook(() => useRevenueChart(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(points);
  });

  it('useActivityFeed returns activity items', async () => {
    const { metricsApi } = await import('@/api/super-admin/metrics');
    const feed = [{ id: '1', type: 'update', message: 'admin updated fare', time: '02:30 PM', isAlert: false }];
    vi.mocked(metricsApi.getActivityFeed).mockResolvedValue(feed);

    const { result } = renderHook(() => useActivityFeed(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(1);
    expect(result.current.data![0].type).toBe('update');
  });
});
