import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type SystemService       = components['schemas']['SystemService'];
export type FeatureFlag         = components['schemas']['FeatureFlag'];
export type Integration         = components['schemas']['Integration'];
export type NotificationTemplate = components['schemas']['NotificationTemplate'];
export type IntegrationTestResult = components['schemas']['IntegrationTestResult'];

export const systemApi = {
  getIntegrations: () =>
    adminRequest<unknown>('GET', '/system/integrations').then(extractArray<Integration>),

  updateIntegration: (service: string, data: Record<string, string>) =>
    adminRequestVoid('PUT', `/system/integrations/${service}`, data),

  /** POST /admin/system/integrations/{service}/test — probe a configured integration (M6). */
  testIntegration: (service: string) =>
    adminRequest<IntegrationTestResult>('POST', `/system/integrations/${service}/test`),

  getNotificationTemplates: () =>
    adminRequest<unknown>('GET', '/system/notification-templates').then(extractArray<NotificationTemplate>),

  updateTemplate: (event: string, body: string) =>
    adminRequestVoid('PUT', `/system/notification-templates/${event}`, { body }),

  getFeatureFlags: () =>
    adminRequest<unknown>('GET', '/system/feature-flags').then(extractArray<FeatureFlag>),

  /** PUT /admin/system/feature-flags/{key} — returns 204. */
  toggleFlag: (key: string, enabled: boolean) =>
    adminRequestVoid('PUT', `/system/feature-flags/${key}`, { enabled }),

  getServices: () =>
    adminRequest<unknown>('GET', '/system/services').then(extractArray<SystemService>),
};
