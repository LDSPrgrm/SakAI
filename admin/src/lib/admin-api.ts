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
    getMetrics: async (): Promise<DashboardMetrics> => dashboardMock.metrics,
    getRidesChart: async (): Promise<{ name: string; rides: number }[]> => dashboardMock.ridesChart,
    getRevenueChart: async (): Promise<{ name: string; revenue: number; gcash: number; cash: number; paymaya: number; card: number }[]> => dashboardMock.revenueChart,
    getVehicleDistribution: async (): Promise<{ name: string; value: number }[]> => dashboardMock.vehicleDistribution,
    getActivityFeed: async (): Promise<dashboardMock.ActivityItem[]> => dashboardMock.activityFeed,
  },

  admins: {
    list: async (): Promise<AdminUser[]> => adminsMock.admins,
    create: async (data: Omit<AdminUser, 'id' | 'created_at' | 'last_login_at'> & { password?: string }): Promise<AdminUser> => {
      const { password, ...rest } = data;
      void password; // In a real API, send to backend
      return {
        ...rest,
        id: crypto.randomUUID(),
        created_at: new Date().toISOString(),
        last_login_at: null,
      };
    },
    update: async (id: string, data: Partial<AdminUser>): Promise<AdminUser> => {
      const found = adminsMock.admins.find(a => a.id === id)!;
      return { ...found, ...data };
    },
    deactivate: async (id: string): Promise<void> => { void id; },
    resetPassword: async (id: string, newPassword: string): Promise<void> => {
      void id;
      void newPassword;
      // In a real API, call backend to update password
    },
  },

  fares: {
    getConfigs: async (): Promise<FareConfig[]> => faresMock.fareConfigs,
    getSurge: async (): Promise<SurgeConfig> => faresMock.surgeConfig,
    updateConfig: async (id: string, data: Partial<FareConfig>): Promise<FareConfig> => {
      const found = faresMock.fareConfigs.find(f => f.id === id)!;
      return { ...found, ...data, updated_at: new Date().toISOString() };
    },
    updateSurge: async (data: Partial<SurgeConfig>): Promise<SurgeConfig> => ({
      ...faresMock.surgeConfig,
      ...data,
    }),
    simulate: async (vehicle: string, distanceKm: number, minutes: number): Promise<number> => {
      const cfg = faresMock.fareConfigs.find(f => f.vehicle_type === vehicle)!;
      return Math.max(cfg.minimum_fare, cfg.base_fare + distanceKm * cfg.per_km_rate + minutes * cfg.per_min_rate + cfg.booking_fee);
    },
  },

  payments: {
    getTransactions: async (): Promise<Transaction[]> => paymentsMock.transactions,
    getPayouts: async (): Promise<DriverPayout[]> => paymentsMock.payouts,
    approvePayout: async (id: string): Promise<void> => { void id; },
    getSummary: async () => paymentsMock.summary,
    getCommissionConfig: async () => ({
      rates: { motorcycle: 15, tricycle: 12, other: 20 },
      minimum_commission: 10,
      promotional_override: 0,
    }),
    updateCommissionConfig: async (data: any) => data,
  },

  safety: {
    getIncidents: async (): Promise<Incident[]> => safetyMock.incidents,
    updateIncident: async (id: string, data: Partial<Incident>): Promise<Incident> => {
      const found = safetyMock.incidents.find(i => i.id === id)!;
      return { ...found, ...data };
    },
    getKycQueue: async (): Promise<KycEntry[]> => safetyMock.kycQueue,
    updateKyc: async (id: string, status: 'approved' | 'rejected'): Promise<KycEntry> => {
      const found = safetyMock.kycQueue.find(k => k.id === id)!;
      return { ...found, status };
    },
    getLtfrbCompliance: async () => safetyMock.ltfrbCompliance,
  },

  reports: {
    getChartData: async (type: string) => reportsMock.getChartData(type),
    getReportList: async () => reportsMock.reportList,
    exportCsv: async (type: string): Promise<string> => reportsMock.generateCsv(type),
  },

  system: {
    getIntegrations: async () => systemMock.integrations,
    updateIntegration: async (service: string, data: Record<string, string>) => ({ service, ...data }),
    getNotificationTemplates: async () => systemMock.notificationTemplates,
    updateTemplate: async (event: string, body: string) => ({ event, body }),
    getFeatureFlags: async (): Promise<FeatureFlag[]> => systemMock.featureFlags,
    toggleFlag: async (key: string, enabled: boolean): Promise<FeatureFlag> => {
      const found = systemMock.featureFlags.find(f => f.key === key)!;
      return { ...found, enabled };
    },
    getServices: async (): Promise<SystemService[]> => systemMock.services,
  },

  audit: {
    getLogs: async (): Promise<AuditLogEntry[]> => auditMock.auditLogs,
    exportCsv: async (): Promise<string> => auditMock.generateCsv(),
  },
};
