import { adminRequest, adminRequestVoid, extractArray } from './_request';

export type AlertRuleType =
  | 'low_rating'
  | 'high_cancellation'
  | 'fraud_velocity'
  | 'kyc_expiry';

export interface AlertRule {
  id: string;
  name: string;
  type: AlertRuleType;
  enabled: boolean;
  config: Record<string, unknown>;
  created_by?: string | null;
  created_at?: string;
  updated_at?: string;
}

export interface AlertEvent {
  id: string;
  rule_id?: string | null;
  fired_at: string;
  subject_type?: string;
  subject_id?: string | null;
  payload: Record<string, unknown>;
}

export interface AlertRuleInput {
  name: string;
  type: AlertRuleType;
  enabled?: boolean;
  config: Record<string, unknown>;
}

export const alertsApi = {
  listRules: () =>
    adminRequest<unknown>('GET', '/alerts/rules').then(extractArray<AlertRule>),
  listEvents: (limit = 100) =>
    adminRequest<unknown>('GET', `/alerts/events?limit=${limit}`).then(extractArray<AlertEvent>),
  create: (data: AlertRuleInput) =>
    adminRequest<AlertRule>('POST', '/alerts/rules', data),
  update: (id: string, data: AlertRuleInput) =>
    adminRequestVoid('PUT', `/alerts/rules/${id}`, data),
  remove: (id: string) => adminRequestVoid('DELETE', `/alerts/rules/${id}`),
};
