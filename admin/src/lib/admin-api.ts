// ---------------------------------------------------------------------------
// SakAI Admin API Client — /api/admin/* endpoints (superadmin.md spec)
// Returns mock data now; swap body of each function to a real request() call
// when the backend ships.
// ---------------------------------------------------------------------------

import { tokenStore } from '@/lib/api';
import * as dashboardMock from '@/mocks/admin/dashboard';
import * as adminsMock from '@/mocks/admin/admins';
import * as faresMock from '@/mocks/admin/fares';
import * as paymentsMock from '@/mocks/admin/payments';
import * as safetyMock from '@/mocks/admin/safety';
import * as reportsMock from '@/mocks/admin/reports';
import * as systemMock from '@/mocks/admin/system';
import * as auditMock from '@/mocks/admin/audit';

const BASE_URL = (import.meta.env.VITE_API_URL as string) || 'http://192.168.7.130:8080/api';

// ── Response envelope ─────────────────────────────────────────────────────────

export interface AdminApiResponse<T> {
  success: boolean;
  data: T;
  error?: string | null;
  meta?: { page: number; per_page: number; total: number };
}

// ── Data models (spec §6) ─────────────────────────────────────────────────────

export type AdminRole = 'super_admin' | 'operations' | 'finance' | 'support';
export type AdminStatus = 'active' | 'suspended' | 'deactivated';

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
  status: AdminStatus;
  created_by: string;
  created_at: string;
  last_login_at: string | null;
}

export interface FareConfig {
  id: string;
  vehicle_type: 'motorcycle' | 'tricycle' | 'car';
  base_fare: number;
  per_km_rate: number;
  per_min_rate: number;
  minimum_fare: number;
  booking_fee: number;
  cancellation_fee: number;
  updated_by: string;
  updated_at: string;
}

export interface SurgeConfig {
  id: string;
  enabled: boolean;
  max_multiplier: number;
  trigger_ratio: number;
  blackout_hours: { day: number; start: string; end: string }[];
}

export type IncidentType = 'sos_triggered' | 'reported_incident' | 'safety_complaint';
export type IncidentStatus = 'open' | 'investigating' | 'resolved' | 'escalated';

export interface Incident {
  id: string;
  ride_id: string;
  triggered_by: 'rider' | 'driver';
  rider_name: string;
  driver_name: string;
  type: IncidentType;
  status: IncidentStatus;
  assigned_to: string | null;
  resolution_notes: string | null;
  created_at: string;
  resolved_at: string | null;
}

export interface KycEntry {
  id: string;
  driver_id: string;
  driver_name: string;
  submitted_at: string;
  docs: string[];
  status: 'pending' | 'approved' | 'rejected';
}

export type TransactionStatus = 'settled' | 'pending' | 'failed' | 'refunded';
export type PaymentMethod = 'cash' | 'gcash' | 'paymaya' | 'card';

export interface Transaction {
  id: string;
  ride_id: string;
  rider_name: string;
  driver_name: string;
  amount: number;
  payment_method: PaymentMethod;
  status: TransactionStatus;
  commission: number;
  created_at: string;
}

export interface DriverPayout {
  id: string;
  batch: string;
  driver_count: number;
  total_amount: number;
  period: string;
  status: 'pending' | 'approved' | 'processing' | 'done';
}

export interface AuditLogEntry {
  id: string;
  timestamp: string;
  actor_id: string;
  actor_name: string;
  ip_address: string;
  action: 'create' | 'update' | 'delete' | 'approve' | 'reject' | 'login' | 'logout';
  resource_type: string;
  resource_id: string;
  before_state: Record<string, unknown> | null;
  after_state: Record<string, unknown> | null;
  reason: string | null;
}

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

export interface DashboardMetrics {
  total_riders: number;
  riders_trend: string;
  total_drivers: number;
  drivers_trend: string;
  rides_today: number;
  rides_trend: string;
  revenue_today: number;
  revenue_trend: string;
  avg_wait_minutes: number;
  wait_trend: string;
  platform_uptime: number;
}

// ── Core helper (ready for real requests) ────────────────────────────────────

async function adminRequest<T>(method: string, path: string, body?: unknown): Promise<T> {
  const token = tokenStore.getAccess();
  const res = await fetch(`${BASE_URL}/admin${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  if (res.status === 204) return undefined as T;
  return res.json();
}
// suppress unused warning until backend is ready
void adminRequest;

// ── Admin API (mock-backed, swap to adminRequest when backend ships) ──────────

export const adminApi = {
  dashboard: {
    getMetrics: () => adminRequest<DashboardMetrics>('GET', '/dashboard'),
    getRidesChart: () => adminRequest<{ name: string; rides: number }[]>('GET', '/reports/chart/rides'),
    getRevenueChart: () => adminRequest<{ name: string; revenue: number; gcash: number; cash: number; paymaya: number; card: number }[]>('GET', '/reports/chart/revenue'),
    getVehicleDistribution: () => adminRequest<{ name: string; value: number }[]>('GET', '/reports/chart/vehicles'),
    getActivityFeed: () => adminRequest<dashboardMock.ActivityItem[]>('GET', '/audit?limit=10'),
  },

  admins: {
    list: () => adminRequest<AdminUser[]>('GET', '/users'),
    create: (data: Omit<AdminUser, 'id' | 'created_at' | 'last_login_at'> & { password?: string }) =>
      adminRequest<AdminUser>('POST', '/users', data),
    update: (id: string, data: Partial<AdminUser>) =>
      adminRequest<AdminUser>('PUT', `/users/${id}`, data),
    deactivate: (id: string) =>
      adminRequest<void>('PUT', `/users/${id}`, { role: 'admin' }), // Fallback payload
    resetPassword: (id: string, newPassword: string) =>
      adminRequest<void>('PUT', `/users/${id}/password`, { password: newPassword }),
  },

  fares: {
    getConfigs: () => adminRequest<any>('GET', '/fares').then(res => res.fares as FareConfig[]),
    getSurge: () => adminRequest<any>('GET', '/fares').then(res => res.surge as SurgeConfig),
    updateConfig: (id: string, data: Partial<FareConfig>) =>
      adminRequest<FareConfig>('PUT', `/fares`, [data]),
    updateSurge: (data: Partial<SurgeConfig>) =>
      adminRequest<SurgeConfig>('PUT', '/surge', data),
    simulate: (vehicle: string, distanceKm: number, minutes: number) =>
      adminRequest<any>('POST', '/fares/simulate', {
        vehicle_type: vehicle,
        origin: { lat: 14.5995, lng: 120.9842 },
        destination: { lat: 14.5995 + (distanceKm * 0.01), lng: 120.9842 }
      }).then(res => res.estimated_fare),
  },

  payments: {
    getTransactions: () => adminRequest<Transaction[]>('GET', '/payments/transactions'),
    getPayouts: () => adminRequest<DriverPayout[]>('GET', '/payments/payouts'),
    approvePayout: (id: string) => adminRequest<void>('PUT', `/payments/payouts/${id}/approve`),
    getSummary: () => adminRequest<any>('GET', '/payments/summary'),
    getCommissionConfig: () => adminRequest<any>('GET', '/payments/commission-config'),
    updateCommissionConfig: (data: any) => adminRequest<any>('PUT', '/payments/commission-config', data),
  },

  safety: {
    getIncidents: () => adminRequest<Incident[]>('GET', '/incidents'),
    updateIncident: (id: string, data: Partial<Incident>) =>
      adminRequest<Incident>('PUT', `/incidents/${id}/resolve`, { notes: data.resolution_notes || 'Resolved' }),
    getKycQueue: () => adminRequest<KycEntry[]>('GET', '/safety/kyc'),
    updateKyc: (id: string, status: 'approved' | 'rejected') =>
      adminRequest<KycEntry>('PUT', `/safety/kyc/${id}`, { status }),
    getLtfrbCompliance: async () => safetyMock.ltfrbCompliance,
  },

  reports: {
    getChartData: (type: string) => adminRequest<any[]>('GET', `/reports/chart/${type}`),
    getReportList: () => adminRequest<any[]>('GET', '/reports/list'),
    exportCsv: (type: string) => adminRequest<any>('POST', `/reports/export/${type}`).then(res => res.url),
  },

  system: {
    getIntegrations: () => adminRequest<any[]>('GET', '/system/integrations'),
    updateIntegration: (service: string, data: Record<string, string>) =>
      adminRequest<any>('PUT', `/system/integrations/${service}`, data),
    getNotificationTemplates: () => adminRequest<any[]>('GET', '/system/notification-templates'),
    updateTemplate: (event: string, body: string) =>
      adminRequest<any>('PUT', `/system/notification-templates/${event}`, { body }),
    getFeatureFlags: () => adminRequest<FeatureFlag[]>('GET', '/system/feature-flags'),
    toggleFlag: (key: string, enabled: boolean) =>
      adminRequest<FeatureFlag>('PUT', `/system/feature-flags/${key}`, { enabled }),
    getServices: () => adminRequest<SystemService[]>('GET', '/system/services'),
  },

  audit: {
    getLogs: () => adminRequest<any>('GET', '/audit').then(res => res.logs as AuditLogEntry[]),
    exportCsv: () => adminRequest<any>('POST', '/reports/export/audit').then(res => res.url),
  },
};
