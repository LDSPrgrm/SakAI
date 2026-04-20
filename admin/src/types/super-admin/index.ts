// ── Super Admin Types — Barrel re-export ──────────────────────────────────────
// All types are sourced from the generated OpenAPI contract (openapi.d.ts).
// This barrel provides a single import point for consumers.
// ---------------------------------------------------------------------------

// Admin
export type { AdminUser, AdminStatus, AdminRole } from './admin';

// Roles & Permissions
export type { Role, RolePermission, CreateRoleRequest, UpdateRoleRequest, PermissionKey } from './role';
// Backward-compat aliases used by many pages
export type { Role as AdminRoleDefinition } from './role';
export type { PermissionKey as RolePermissionKey } from './role';

// Fares
export type { FareConfig, SurgeConfig, FareSimulationRequest, FareSimulationResponse, AdminFaresResponse } from './fare';

// Payments
export type { Transaction, DriverPayout, PaymentSummary, CommissionConfig, PaymentGatewayConfig, BatchApproveRequest } from './payment';

// Incidents / Safety
export type { Incident, KycEntry, KycDocument, ComplianceData, IncidentResolveRequest } from './incident';

// Audit
export type { AuditLog, AuditLogResponse } from './audit';
// Backward-compat alias
export type { AuditLog as AuditLogEntry } from './audit';

// System
export type { SystemService, FeatureFlag, Integration, NotificationTemplate } from './system';

// Enums
export type { RideStatus, ErrorCode, TransactionStatus, PaymentMethod, IncidentStatus, IncidentSeverity } from './enums';
// Extra enum types used by admin-api.ts consumers
export type { IncidentType } from './enums';

// Dashboard metrics — not in OpenAPI, defined locally for frontend dashboard
export interface DashboardMetrics {
  total_riders: number; riders_trend: string;
  total_drivers: number; drivers_trend: string;
  rides_today: number; rides_trend: string;
  revenue_today: number; revenue_trend: string;
  avg_wait_minutes: number; wait_trend: string;
  platform_uptime: number;
  // backward-compat aliases (Dashboard.tsx)
  active_riders?: number;
  active_drivers?: number;
  system_uptime?: number;
}

// API response envelope
export interface AdminApiResponse<T> {
  success: boolean;
  data: T;
  error?: string | null;
  meta?: { page: number; per_page: number; total: number };
}

// User types (passenger/driver)
export type EndUserStatus = 'active' | 'suspended' | 'deactivated';

export interface PassengerUser {
  id: string; name: string; email: string; role: 'passenger';
  created_at: string; phone?: string;
  status?: EndUserStatus;
}
export interface DriverUser {
  id: string; name: string; email: string; role: 'driver';
  created_at: string; phone?: string;
  status?: EndUserStatus;
  vehicle?: { make: string; model: string; color: string; plate: string } | null;
}

// Ride item
export interface AdminRideItem {
  id: string; status: string; passenger_name: string; driver_name: string | null;
  passenger: { id: string; name: string; email: string };
  driver: { id: string; name: string; vehicle: { make: string; model: string; color: string; plate: string } } | null;
  origin_address: string | null; destination_address: string | null;
  total_fare: number | null; payment_method: string | null;
  created_at: string; updated_at: string;
}
