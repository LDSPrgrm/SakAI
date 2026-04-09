import { adminRequest, extractArray } from './_request';

export interface SystemService {
  name: string;
  status: 'ok' | 'degraded' | 'down';
  latency_ms: number;
  uptime_pct: number;
  last_checked: string;
}

export interface FeatureFlag {
  key: string;
  label: string;
  description: string;
  enabled: boolean;
}

export const systemApi = {
  getIntegrations: () =>
    adminRequest<unknown>('GET', '/system/integrations').then(extractArray),

  updateIntegration: (service: string, data: Record<string, string>) =>
    adminRequest<unknown>('PUT', `/system/integrations/${service}`, data),

  getNotificationTemplates: () =>
    adminRequest<unknown>('GET', '/system/notification-templates').then(extractArray),

  updateTemplate: (event: string, body: string) =>
    adminRequest<unknown>('PUT', `/system/notification-templates/${event}`, { body }),

  getFeatureFlags: () =>
    adminRequest<unknown>('GET', '/system/feature-flags').then(extractArray<FeatureFlag>),

  toggleFlag: (key: string, enabled: boolean) =>
    adminRequest<FeatureFlag>('PUT', `/system/feature-flags/${key}`, { enabled }),

  getServices: () =>
    adminRequest<unknown>('GET', '/system/services').then(extractArray<SystemService>),
};
