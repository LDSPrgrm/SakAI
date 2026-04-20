// React Query hooks for the report list + chart data + CSV export.

import { useMutation, useQuery } from '@tanstack/react-query';
import { reportsApi } from '@/api/super-admin/reports';

const REPORTS_KEY = ['admin', 'reports'] as const;

export function useReportList() {
  return useQuery({
    queryKey: [...REPORTS_KEY, 'list'] as const,
    queryFn: () => reportsApi.getReportList(),
  });
}

export function useReportChart(type: string) {
  return useQuery({
    queryKey: [...REPORTS_KEY, 'chart', type] as const,
    queryFn: () => reportsApi.getChartData(type),
    enabled: !!type,
  });
}

export function useExportReport() {
  return useMutation({
    mutationFn: (type: string) => reportsApi.exportCsv(type),
  });
}
