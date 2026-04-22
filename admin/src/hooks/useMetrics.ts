// React Query hooks for dashboard KPI + chart metrics.
// Spec: superadmin.md §4.1 (Dashboard)
// Live counts auto-refresh every 60s per spec.

import { useQuery } from '@tanstack/react-query';
import { metricsApi } from '@/api/super-admin/metrics';

export function useDashboardMetrics() {
  return useQuery({
    queryKey: ['admin', 'metrics', 'dashboard'],
    queryFn: () => metricsApi.getDashboard(),
    refetchInterval: 60_000, // spec: auto-refresh every 60s
  });
}

export function useRidesChart() {
  return useQuery({
    queryKey: ['admin', 'metrics', 'rides-chart'],
    queryFn: () => metricsApi.getRidesChart(),
  });
}

export function useRevenueChart() {
  return useQuery({
    queryKey: ['admin', 'metrics', 'revenue-chart'],
    queryFn: () => metricsApi.getRevenueChart(),
  });
}

export function useVehicleDistribution() {
  return useQuery({
    queryKey: ['admin', 'metrics', 'vehicle-distribution'],
    queryFn: () => metricsApi.getVehicleDistribution(),
  });
}

export function useDriverHeatmap() {
  return useQuery({
    queryKey: ['admin', 'metrics', 'driver-heatmap'],
    queryFn: () => metricsApi.getDriverHeatmap(),
    refetchInterval: 30_000,
  });
}

export function useActivityFeed() {
  return useQuery({
    queryKey: ['admin', 'metrics', 'activity-feed'],
    queryFn: () => metricsApi.getActivityFeed(),
    refetchInterval: 30_000,
  });
}
