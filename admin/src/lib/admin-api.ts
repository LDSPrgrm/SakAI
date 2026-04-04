// ---------------------------------------------------------------------------
// SakAI Admin API Client — /api/admin/* endpoints (superadmin.md spec)
// Returns mock data now; swap body of each function to a real request() call
// when the backend ships.
// ---------------------------------------------------------------------------

import { tokenStore } from '@/lib/api';

const BASE_URL = (import.meta.env.VITE_API_URL as string) || 'http://192.168.100.22:8080/api';

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
export type RideStatus = 'requested' | 'accepted' | 'arrived' | 'in_progress' | 'completed' | 'cancelled';

export interface PassengerUser {
  id: string;
  name: string;
  email: string;
  role: 'passenger';
  created_at: string;
  phone?: string;
}

export interface DriverUser {
  id: string;
  name: string;
  email: string;
  role: 'driver';
  created_at: string;
  phone?: string;
  vehicle?: {
    make: string;
    model: string;
    color: string;
    plate: string;
  } | null;
}

export interface AdminRideItem {
  id: string;
  status: RideStatus;
  passenger_name: string;
  driver_name: string | null;
  passenger: { id: string; name: string; email: string };
  driver: { id: string; name: string; vehicle: { make: string; model: string; color: string; plate: string } } | null;
  origin_address: string | null;
  destination_address: string | null;
  total_fare: number | null;
  payment_method: 'cash' | 'gcash' | 'paymaya' | 'card' | null;
  created_at: string;
  updated_at: string;
}

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

export type IncidentSeverity = 'low' | 'medium' | 'high';

export interface Incident {
  id: string;
  ride_id: string;
  triggered_by: 'rider' | 'driver';
  rider_name: string;
  driver_name: string;
  type: IncidentType;
  severity: IncidentSeverity | null;
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

export type RolePermissionKey =
  | 'dashboard' | 'admin_management' | 'role_management' | 'fare_config'
  | 'payments' | 'payouts' | 'user_management' | 'kyc_verification'
  | 'safety_incidents' | 'reports' | 'system_config' | 'system_health'
  | 'audit_log' | 'ltfrb_compliance';

export interface RolePermission {
  permission_key: RolePermissionKey;
  read: boolean;
  write: boolean;
}

export interface AdminRoleDefinition {
  id: string;
  name: string;
  description: string;
  is_system: boolean;
  permissions: RolePermission[];
  admin_count: number;
  created_by: string;
  created_at: string;
  updated_at: string;
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
  // Frontend-facing names (used by SADashboard.tsx)
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
  // Raw backend names from swagger DashboardResponse schema
  active_riders?: number;
  active_drivers?: number;
  avg_wait_time_seconds?: number;
  system_uptime?: number;
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
  const json = await res.json();

  if (!res.ok) {
    throw new Error(json?.error || json?.message || `Request failed (${res.status})`);
  }

  // Automatically unwrap standard { success: true, data: ... } envelopes
  if (json && typeof json === 'object' && 'success' in json && 'data' in json) {
    if (!json.success) throw new Error(json.error || 'API request failed');
    return json.data;
  }
  return json;
}

// ── Defensive Array Extractor ─────────────────────────────────────────────────
// Ensures we always return an array to the UI, regardless of how the backend wraps it
function extractArray<T>(res: any): T[] {
  if (!res) return [];
  if (Array.isArray(res)) return res;
  if (Array.isArray(res.data)) return res.data;
  if (Array.isArray(res.items)) return res.items;
  if (Array.isArray(res.logs)) return res.logs;
  // Probe object properties if no standard envelope matches
  const found = Object.values(res).find(Array.isArray);
  if (found) return found as T[];
  return [];
}

// suppress unused warning until backend is ready
void adminRequest;

// ── Admin API (mock-backed, swap to adminRequest when backend ships) ──────────

export const adminApi = {
  dashboard: {
    getMetrics: () => adminRequest<any>('GET', '/dashboard').then((raw) => ({
      // Map backend DashboardResponse fields to frontend DashboardMetrics shape
      total_riders: raw.total_riders ?? raw.active_riders ?? 0,
      riders_trend: raw.riders_trend ?? '',
      total_drivers: raw.total_drivers ?? raw.active_drivers ?? 0,
      drivers_trend: raw.drivers_trend ?? '',
      rides_today: raw.rides_today ?? 0,
      rides_trend: raw.rides_trend ?? '',
      revenue_today: raw.revenue_today ?? 0,
      revenue_trend: raw.revenue_trend ?? '',
      // Swagger returns avg_wait_time_seconds; convert to minutes for UI
      avg_wait_minutes: raw.avg_wait_minutes ?? (raw.avg_wait_time_seconds != null ? Math.round(raw.avg_wait_time_seconds / 60) : 0),
      wait_trend: raw.wait_trend ?? '',
      platform_uptime: raw.platform_uptime ?? raw.system_uptime ?? 0,
    } as DashboardMetrics)),
    getRidesChart: () => adminRequest<{ name: string; rides: number }[]>('GET', '/reports/chart/rides'),
    getRevenueChart: () => adminRequest<{ name: string; revenue: number; gcash: number; cash: number; paymaya: number; card: number }[]>('GET', '/reports/chart/revenue'),
    getVehicleDistribution: () => adminRequest<{ name: string; value: number }[]>('GET', '/reports/chart/vehicles'),
    getActivityFeed: () => adminRequest<any>('GET', '/audit?limit=10').then((res) => {
      const logs = Array.isArray(res) ? res : (res?.logs ?? []);
      return logs.map((log: any) => ({
        id: log.id,
        message: `${log.actor_name} ${log.action}d ${(log.resource_type || 'resource').replace('_', ' ')}`,
        time: new Date(log.timestamp).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
        isAlert: log.action === 'delete' || log.action === 'reject',
      }));
    }),
  },

  admins: {
    list: () => adminRequest<any>('GET', '/users').then(extractArray<AdminUser>),
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
    getConfigs: () => adminRequest<any>('GET', '/fares').then(res => extractArray<FareConfig>(res?.fares || res)),
    getSurge: () => adminRequest<any>('GET', '/fares').then(res => (res?.surge || {}) as SurgeConfig),
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
    getTransactions: () => adminRequest<any>('GET', '/payments/transactions').then(extractArray<Transaction>),
    getPayouts: () => adminRequest<any>('GET', '/payments/payouts').then(extractArray<DriverPayout>),
    approvePayout: (id: string) => adminRequest<void>('PUT', `/payments/payouts/${id}/approve`),
    getSummary: () => adminRequest<any>('GET', '/payments/summary'),
    getCommissionConfig: () => adminRequest<any>('GET', '/payments/commission-config'),
    updateCommissionConfig: (data: any) => adminRequest<any>('PUT', '/payments/commission-config', data),
    getPaymentConfigs: () => adminRequest<any>('GET', '/payments/config').then(extractArray<any>),
  },

  safety: {
    getIncidents: () => adminRequest<any>('GET', '/incidents').then(extractArray<Incident>),
    updateIncident: (id: string, data: Partial<Incident>) =>
      adminRequest<Incident>('PUT', `/incidents/${id}/resolve`, { notes: data.resolution_notes || 'Resolved' }),
    getKycQueue: () => adminRequest<any>('GET', '/safety/kyc').then(extractArray<KycEntry>),
    updateKyc: (id: string, status: 'approved' | 'rejected') =>
      adminRequest<KycEntry>('PUT', `/safety/kyc/${id}`, { status }),
    getLtfrbCompliance: () => adminRequest<any>('GET', '/safety/compliance'),
  },

  reports: {
    getChartData: (type: string) => adminRequest<any[]>('GET', `/reports/chart/${type}`),
    getReportList: () => adminRequest<any[]>('GET', '/reports/list'),
    exportCsv: (type: string) => adminRequest<any>('POST', `/reports/export/${type}`).then(res => res.url),
  },

  system: {
    getIntegrations: () => adminRequest<any>('GET', '/system/integrations').then(extractArray<any>),
    updateIntegration: (service: string, data: Record<string, string>) =>
      adminRequest<any>('PUT', `/system/integrations/${service}`, data),
    getNotificationTemplates: () => adminRequest<any>('GET', '/system/notification-templates').then(extractArray<any>),
    updateTemplate: (event: string, body: string) =>
      adminRequest<any>('PUT', `/system/notification-templates/${event}`, { body }),
    getFeatureFlags: () => adminRequest<any>('GET', '/system/feature-flags').then(extractArray<FeatureFlag>),
    toggleFlag: (key: string, enabled: boolean) =>
      adminRequest<FeatureFlag>('PUT', `/system/feature-flags/${key}`, { enabled }),
    getServices: () => adminRequest<any>('GET', '/system/services').then(extractArray<SystemService>),
  },

  users: {
    getPassengers: (q?: string) =>
      adminRequest<any>('GET', `/users/passengers${q ? `?q=${encodeURIComponent(q)}` : ''}`).then(extractArray<PassengerUser>),
    getDrivers: (q?: string) =>
      adminRequest<any>('GET', `/users/drivers${q ? `?q=${encodeURIComponent(q)}` : ''}`).then(extractArray<DriverUser>),
    updateStatus: (id: string, data: { status: AdminStatus }) =>
      adminRequest<void>('PUT', `/users/${id}`, data),
  },

  rides: {
    list: (status?: string) =>
      adminRequest<any>('GET', `/rides${status ? `?status=${encodeURIComponent(status)}` : ''}`).then(extractArray<AdminRideItem>),
  },

  audit: {
    getLogs: () => adminRequest<any>('GET', '/audit').then(extractArray<AuditLogEntry>),
    exportCsv: () => adminRequest<any>('POST', '/reports/export/audit').then(res => res?.url || ''),
  },

  roles: {
    list: () => adminRequest<any>('GET', '/roles').then(extractArray<AdminRoleDefinition>),
    create: (data: { name: string; description: string; permissions: RolePermission[] }) =>
      adminRequest<AdminRoleDefinition>('POST', '/roles', data),
    update: (id: string, data: { name: string; description: string; permissions: RolePermission[] }) =>
      adminRequest<AdminRoleDefinition>('PUT', `/roles/${id}`, data),
    delete: (id: string) => adminRequest<void>('DELETE', `/roles/${id}`),
    duplicate: (id: string) => adminRequest<AdminRoleDefinition>('POST', `/roles/${id}/duplicate`),
  },
};
