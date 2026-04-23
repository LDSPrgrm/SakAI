// ---------------------------------------------------------------------------
// Permission key constants — used as identifiers throughout the codebase.
// The actual per-role permission set is stored in the database and fetched
// dynamically at runtime via usePermissions() (see hooks/usePermissions.ts).
// ---------------------------------------------------------------------------

export type AdminRole = 'admin' | 'superadmin' | 'operations' | 'finance' | 'support';

// Legacy dot-notation keys kept for reference; prefer the spec PermissionKey
// (superadmin.md §3.2) in new code:  can('fare_config', 'read')
export const PERM = {
  DASHBOARD_VIEW: 'dashboard.view',
  DASHBOARD_SYSTEM: 'dashboard.system',
  DASHBOARD_FINANCIAL: 'dashboard.financial',
  ADMINS_MANAGE: 'admins.manage',
  FARES_VIEW: 'fares.view',
  FARES_MANAGE: 'fares.manage',
  SURGE_MANAGE: 'surge.manage',
  PAYMENTS_VIEW: 'payments.view',
  PAYMENTS_GATEWAY: 'payments.gateway',
  PAYMENTS_COMMISSION: 'payments.commission',
  PAYMENTS_COMMISSION_PROPOSE: 'payments.commission.propose',
  PAYMENTS_PAYOUT_APPROVE: 'payments.payout.approve',
  USERS_MANAGE: 'users.manage',
  USERS_READ: 'users.read',
  KYC_MANAGE: 'kyc.manage',
  SAFETY_MANAGE: 'safety.manage',
  SAFETY_READ: 'safety.read',
  REPORTS_OPERATIONAL: 'reports.operational',
  REPORTS_FINANCIAL: 'reports.financial',
  SYSTEM_MANAGE: 'system.manage',
  AUDIT_VIEW: 'audit.view',
  NOTIFICATIONS_MANAGE: 'notifications.manage',
  LTFRB_MANAGE: 'ltfrb.manage',
  LTFRB_VIEW: 'ltfrb.view',
} as const;

export type Permission = (typeof PERM)[keyof typeof PERM];
