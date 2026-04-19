import { adminRequest, extractArray } from './_request';

export interface ReportExportResponse {
  url: string;
  data: string;
}

export const reportsApi = {
  getChartData: (type: string) =>
    adminRequest<unknown[]>('GET', `/reports/chart/${type}`),

  getReportList: () =>
    adminRequest<unknown>('GET', '/reports/list').then(extractArray),

  /** POST /admin/reports/export/{type} — returns both a presigned url and the raw CSV data (M8). */
  exportCsv: (type: string) =>
    adminRequest<ReportExportResponse>('POST', `/reports/export/${type}`),
};
