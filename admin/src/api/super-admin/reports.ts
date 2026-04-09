import { adminRequest, extractArray } from './_request';

export const reportsApi = {
  getChartData: (type: string) =>
    adminRequest<unknown[]>('GET', `/reports/chart/${type}`),

  getReportList: () =>
    adminRequest<unknown>('GET', '/reports/list').then(extractArray),

  exportCsv: (type: string) =>
    adminRequest<{ url: string }>('POST', `/reports/export/${type}`).then((r) => r.url),
};
