// React Query hooks for the report list + chart data + CSV export.

import { useMutation, useQuery } from '@tanstack/react-query';
import { reportsApi, type ReportRange } from '@/api/super-admin/reports';

const REPORTS_KEY = ['admin', 'reports'] as const;

export function useReportList() {
  return useQuery({
    queryKey: [...REPORTS_KEY, 'list'] as const,
    queryFn: () => reportsApi.getReportList(),
  });
}

export function useReportChart(
  type: string,
  range?: ReportRange,
  options?: { refetchInterval?: number },
) {
  return useQuery({
    queryKey: [...REPORTS_KEY, 'chart', type, range?.from ?? null, range?.to ?? null] as const,
    queryFn: () => reportsApi.getChartData(type, range),
    enabled: !!type,
    refetchInterval: options?.refetchInterval,
  });
}

export function useExportReport() {
  return useMutation({
    mutationFn: ({ type, range }: { type: string; range?: ReportRange }) =>
      reportsApi.exportCsv(type, range),
  });
}
