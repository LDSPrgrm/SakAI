// ---------------------------------------------------------------------------
// SakAI Admin API — Compatibility layer
// ---------------------------------------------------------------------------
// Keeps all original type definitions so existing pages compile without change.
// The adminApi implementation delegates to the modular src/api/super-admin/*
// domain modules. Pages should be migrated to import from those modules
// directly; this file can be deleted once all imports are updated.
//
// Migration tracker:
//   [ ] src/pages/super-admin/SAAdminManagement.tsx
//   [ ] src/pages/super-admin/SAAuditLog.tsx
//   [ ] src/pages/super-admin/SADashboard.tsx
//   [ ] src/pages/super-admin/SAFareConfig.tsx
//   [ ] src/pages/super-admin/SAPayments.tsx
//   [ ] src/pages/super-admin/SAReports.tsx
//   [ ] src/pages/super-admin/SARoleManagement.tsx
//   [ ] src/pages/super-admin/SASafetyCompliance.tsx
//   [ ] src/pages/super-admin/SASystemConfig.tsx
//   [ ] src/pages/super-admin/SASystemHealth.tsx
//   [ ] src/pages/Dashboard.tsx
//   [ ] src/pages/FareSurge.tsx
//   [ ] src/pages/Payments.tsx
//   [ ] src/pages/Reports.tsx
//   [ ] src/pages/RideManagement.tsx
//   [ ] src/pages/SafetyCompliance.tsx
//   [ ] src/pages/Settings.tsx
//   [ ] src/pages/UserManagement.tsx
//   [ ] src/mocks/admin/*
// ---------------------------------------------------------------------------

import { tokenStore } from '@/lib/api';
import { metricsApi }  from '@/api/super-admin/metrics';
import { adminsApi }   from '@/api/super-admin/admins';
import { faresApi }    from '@/api/super-admin/fares';
import { paymentsApi } from '@/api/super-admin/payments';
import { safetyApi }   from '@/api/super-admin/safety';
import { reportsApi }  from '@/api/super-admin/reports';
import { systemApi }   from '@/api/super-admin/system';
import { auditApi }    from '@/api/super-admin/audit';
import { rolesApi }    from '@/api/super-admin/roles';

// ── Response envelope ─────────────────────────────────────────────────────────

export interface AdminApiResponse<T> {
  success: boolean;
  data: T;
  error?: string | null;
  meta?: { page: number; per_page: number; total: number };
}

// ── Data models ───────────────────────────────────────────────────────────────

export type AdminRole   = 'super_admin' | 'operations' | 'finance' | 'support';
export type AdminStatus = 'active' | 'suspended' | 'deactivated';
export type RideStatus  = 'requested' | 'accepted' | 'arrived' | 'in_progress' | 'completed' | 'cancelled';
export type PaymentMethod = 'cash' | 'gcash' | 'paymaya' | 'card';
export type TransactionStatus = 'settled' | 'pending' | 'failed' | 'refunded';
export type IncidentStatus  = 'open' | 'investigating' | 'resolved' | 'escalated';
export type IncidentSeverity = 'low' | 'medium' | 'high';
export type IncidentType = 'sos_triggered' | 'reported_incident' | 'safety_complaint';

export interface PassengerUser {
  id: string; name: string; email: string; role: 'passenger';
  created_at: string; phone?: string;
}
export interface DriverUser {
  id: string; name: string; email: string; role: 'driver';
  created_at: string; phone?: string;
  vehicle?: { make: string; model: string; color: string; plate: string } | null;
}
export interface AdminRideItem {
  id: string; status: RideStatus; passenger_name: string; driver_name: string | null;
  passenger: { id: string; name: string; email: string };
  driver: { id: string; name: string; vehicle: { make: string; model: string; color: string; plate: string } } | null;
  origin_address: string | null; destination_address: string | null;
  total_fare: number | null; payment_method: PaymentMethod | null;
  created_at: string; updated_at: string;
}
export interface AdminUser {
  id: string; name: string; email: string;
  role: AdminRole; role_id?: string; status: AdminStatus;
  created_by: string; created_at: string; last_login_at: string | null;
}
export interface FareConfig {
  id: string; vehicle_type: 'motorcycle' | 'tricycle' | 'car';
  base_fare: number; per_km_rate: number; per_min_rate: number;
  minimum_fare: number; booking_fee: number; cancellation_fee: number;
  updated_by: string; updated_at: string;
}
export interface SurgeConfig {
  id: string; enabled: boolean; max_multiplier: number; trigger_ratio: number;
  blackout_hours: { day: number; start: string; end: string }[];
}
export interface Incident {
  id: string; ride_id: string; triggered_by: 'rider' | 'driver';
  rider_name: string; driver_name: string;
  type: IncidentType; severity: IncidentSeverity | null; status: IncidentStatus;
  assigned_to: string | null; resolution_notes: string | null;
  created_at: string; resolved_at: string | null;
}
export interface KycEntry {
  id: string; driver_id: string; driver_name: string;
  submitted_at: string; docs: string[]; status: 'pending' | 'approved' | 'rejected';
}
export interface Transaction {
  id: string; ride_id: string; rider_name: string; driver_name: string;
  amount: number; payment_method: PaymentMethod; status: TransactionStatus;
  commission: number; created_at: string;
}
export interface DriverPayout {
  id: string; batch: string; driver_count: number;
  total_amount: number; period: string;
  status: 'pending' | 'approved' | 'processing' | 'done';
}
export interface PaymentSummary {
  total_revenue: number;
  /** driver payouts total (Payments.tsx uses .payouts) */
  payouts: number;
  driver_payouts?: number;
  commission: number;
  pending_settlements: number;
  failed_transactions?: number;
}
export type RolePermissionKey =
  | 'dashboard' | 'admin_management' | 'role_management' | 'fare_config'
  | 'payments'  | 'payouts'          | 'user_management'  | 'kyc_verification'
  | 'safety_incidents' | 'reports'   | 'system_config'    | 'system_health'
  | 'audit_log' | 'ltfrb_compliance';
export interface RolePermission {
  permission_key: RolePermissionKey; read: boolean; write: boolean;
}
export interface AdminRoleDefinition {
  id: string; name: string; description: string; is_system: boolean;
  permissions: RolePermission[]; admin_count: number;
  created_by: string; created_at: string; updated_at: string;
}
export interface AuditLogEntry {
  id: string; timestamp: string; actor_id: string; actor_name: string;
  ip_address: string;
  action: 'create' | 'update' | 'delete' | 'approve' | 'reject' | 'login' | 'logout';
  resource_type: string; resource_id: string;
  before_state: Record<string, unknown> | null;
  after_state: Record<string, unknown> | null;
  reason: string | null;
}
export interface SystemService {
  name: string; status: 'ok' | 'degraded' | 'down';
  latency_ms: number; uptime_pct: number; last_checked: string;
}
export interface FeatureFlag {
  key: string; label: string; description: string; enabled: boolean;
}
export interface DashboardMetrics {
  total_riders: number; riders_trend: string;
  total_drivers: number; drivers_trend: string;
  rides_today: number; rides_trend: string;
  revenue_today: number; revenue_trend: string;
  avg_wait_minutes: number; wait_trend: string;
  platform_uptime: number;
  // backward-compat aliases (Dashboard.tsx uses optional fallback)
  active_riders?: number;
  active_drivers?: number;
  system_uptime?: number;
}

// ── Shared helpers ────────────────────────────────────────────────────────────

const BASE_URL = (import.meta.env.VITE_API_URL as string) || 'http://192.168.100.22:8080/api';

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
  const json = await res.json();
  if (!res.ok) throw new Error(json?.error || json?.message || `Request failed (${res.status})`);
  if (json && typeof json === 'object' && 'success' in json && 'data' in json) {
    if (!json.success) throw new Error(json.error || 'API request failed');
    return json.data as T;
  }
  return json as T;
}

function extractArray<T>(res: unknown): T[] {
  if (!res) return [];
  if (Array.isArray(res)) return res as T[];
  const obj = res as Record<string, unknown>;
  for (const key of ['data', 'items', 'logs', 'results']) {
    if (Array.isArray(obj[key])) return obj[key] as T[];
  }
  const found = Object.values(obj).find(Array.isArray);
  return found ? (found as T[]) : [];
}

// ── Aggregated API ────────────────────────────────────────────────────────────

export const adminApi = {
  dashboard: {
    getMetrics: () =>
      metricsApi.getDashboard() as unknown as Promise<DashboardMetrics>,
    getRidesChart: () =>
      metricsApi.getRidesChart() as unknown as Promise<{ name: string; rides: number }[]>,
    getRevenueChart: () =>
      metricsApi.getRevenueChart() as unknown as Promise<{ name: string; revenue: number; gcash: number; cash: number; paymaya: number; card: number }[]>,
    getVehicleDistribution: () =>
      metricsApi.getVehicleDistribution(),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    getActivityFeed: (): Promise<any[]> => metricsApi.getActivityFeed() as Promise<any[]>,
  },

  admins: {
    list: () =>
      adminsApi.list() as unknown as Promise<AdminUser[]>,
    create: (data: Omit<AdminUser, 'id' | 'created_at' | 'last_login_at'> & { password?: string }) =>
      adminsApi.create({ name: data.name, email: data.email, role_id: data.role_id ?? '', password: data.password ?? '' }) as unknown as Promise<AdminUser>,
    update: (id: string, data: Partial<AdminUser>) =>
      adminsApi.update(id, data as unknown as Parameters<typeof adminsApi.update>[1]) as unknown as Promise<AdminUser>,
    deactivate: (id: string) => adminsApi.deactivate(id),
    resetPassword: (id: string, pw: string) => adminsApi.resetPassword(id, pw),
  },

  fares: {
    getConfigs: () =>
      faresApi.getConfigs() as unknown as Promise<FareConfig[]>,
    getSurge: () =>
      faresApi.getSurge() as unknown as Promise<SurgeConfig>,
    updateConfig: (_id: string, data: Partial<FareConfig>) =>
      faresApi.updateConfigs([data as Parameters<typeof faresApi.updateConfigs>[0][0]]) as unknown as Promise<FareConfig>,
    updateSurge: (data: Partial<SurgeConfig>) =>
      faresApi.updateSurge(data as Parameters<typeof faresApi.updateSurge>[0]) as unknown as Promise<SurgeConfig>,
    simulate: (vehicle: string, distanceKm: number, _minutes: number) =>
      faresApi.simulate(vehicle, { lat: 14.5995, lng: 120.9842 }, { lat: 14.5995 + distanceKm * 0.01, lng: 120.9842 }),
  },

  payments: {
    getTransactions: () =>
      paymentsApi.getTransactions() as unknown as Promise<Transaction[]>,
    getPayouts: () =>
      paymentsApi.getPayouts() as unknown as Promise<DriverPayout[]>,
    approvePayout: (id: string) => paymentsApi.approvePayout(id),
    getSummary: () =>
      paymentsApi.getSummary() as unknown as Promise<PaymentSummary>,
    getCommissionConfig: () => paymentsApi.getCommissionConfig(),
    updateCommissionConfig: (data: unknown) => paymentsApi.updateCommissionConfig(data),
    getPaymentConfigs: () => paymentsApi.getGatewayConfigs(),
  },

  safety: {
    getIncidents: () =>
      safetyApi.getIncidents() as unknown as Promise<Incident[]>,
    updateIncident: (id: string, data: Partial<Incident>) =>
      safetyApi.resolveIncident(id, data.resolution_notes || 'Resolved') as unknown as Promise<Incident>,
    getKycQueue: () =>
      safetyApi.getKycQueue() as unknown as Promise<KycEntry[]>,
    updateKyc: (id: string, status: 'approved' | 'rejected') => safetyApi.updateKyc(id, status),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    getLtfrbCompliance: (): Promise<any> => safetyApi.getLtfrbCompliance() as Promise<any>,
  },

  reports: {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    getChartData: (type: string): Promise<any[]> => reportsApi.getChartData(type) as Promise<any[]>,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    getReportList: (): Promise<any[]> => reportsApi.getReportList() as Promise<any[]>,
    exportCsv: (type: string) => reportsApi.exportCsv(type),
  },

  system: {
    getIntegrations: () => systemApi.getIntegrations(),
    updateIntegration: (service: string, data: Record<string, string>) =>
      systemApi.updateIntegration(service, data),
    getNotificationTemplates: () => systemApi.getNotificationTemplates(),
    updateTemplate: (event: string, body: string) => systemApi.updateTemplate(event, body),
    getFeatureFlags: () =>
      systemApi.getFeatureFlags() as unknown as Promise<FeatureFlag[]>,
    toggleFlag: (key: string, enabled: boolean) =>
      systemApi.toggleFlag(key, enabled) as unknown as Promise<FeatureFlag>,
    getServices: () =>
      systemApi.getServices() as unknown as Promise<SystemService[]>,
  },

  users: {
    getPassengers: (q?: string) =>
      adminRequest<unknown>('GET', `/users/passengers${q ? `?q=${encodeURIComponent(q)}` : ''}`)
        .then(extractArray<PassengerUser>),
    getDrivers: (q?: string) =>
      adminRequest<unknown>('GET', `/users/drivers${q ? `?q=${encodeURIComponent(q)}` : ''}`)
        .then(extractArray<DriverUser>),
    updateStatus: (id: string, data: { status: AdminStatus }) =>
      adminRequest<void>('PUT', `/users/${id}`, data),
  },

  rides: {
    list: (status?: string) =>
      adminRequest<unknown>('GET', `/rides${status ? `?status=${encodeURIComponent(status)}` : ''}`)
        .then(extractArray<AdminRideItem>),
  },

  audit: {
    getLogs: () =>
      auditApi.getLogs() as unknown as Promise<AuditLogEntry[]>,
    exportCsv: () => auditApi.exportCsv(),
  },

  roles: {
    list: () =>
      rolesApi.list() as unknown as Promise<AdminRoleDefinition[]>,
    create: (data: { name: string; description: string; permissions: RolePermission[] }) =>
      rolesApi.create(data) as unknown as Promise<AdminRoleDefinition>,
    update: (id: string, data: { name: string; description: string; permissions: RolePermission[] }) =>
      rolesApi.update(id, data) as unknown as Promise<AdminRoleDefinition>,
    delete: (id: string) => rolesApi.delete(id),
    duplicate: (id: string) =>
      rolesApi.duplicate(id) as unknown as Promise<AdminRoleDefinition>,
  },
};
