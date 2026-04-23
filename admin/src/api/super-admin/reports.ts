import { adminRequest, extractArray } from './_request';

export interface ReportExportResponse {
  url: string;
  data: string;
}

export interface ReportRange {
  from?: string;
  to?: string;
}

function toQuery(range?: ReportRange): string {
  if (!range) return '';
  const params = new URLSearchParams();
  if (range.from) params.set('from', range.from);
  if (range.to) params.set('to', range.to);
  const qs = params.toString();
  return qs ? `?${qs}` : '';
}

export const reportsApi = {
  getChartData: (type: string, range?: ReportRange) =>
    adminRequest<unknown[]>('GET', `/reports/chart/${type}${toQuery(range)}`),

  getReportList: () =>
    adminRequest<unknown>('GET', '/reports/list').then(extractArray),

  /** POST /admin/reports/export/{type} — returns both a presigned url and the raw CSV data. */
  exportCsv: (type: string, range?: ReportRange) =>
    adminRequest<ReportExportResponse>('POST', `/reports/export/${type}${toQuery(range)}`),
};
