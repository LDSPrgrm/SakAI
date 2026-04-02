// ---------------------------------------------------------------------------
// RBAC permission matrix
// ---------------------------------------------------------------------------

export type AdminRole = 'super_admin' | 'operations' | 'finance' | 'support';

// Permission keys
export const PERM = {
  // Dashboard
  DASHBOARD_VIEW: 'dashboard.view',
  DASHBOARD_SYSTEM: 'dashboard.system',
  DASHBOARD_FINANCIAL: 'dashboard.financial',

  // Admin management
  ADMINS_MANAGE: 'admins.manage',

  // Fare config
  FARES_VIEW: 'fares.view',
  FARES_MANAGE: 'fares.manage',

  // Surge
  SURGE_MANAGE: 'surge.manage',

  // Payments
  PAYMENTS_VIEW: 'payments.view',
  PAYMENTS_GATEWAY: 'payments.gateway',
  PAYMENTS_COMMISSION: 'payments.commission',
  PAYMENTS_COMMISSION_PROPOSE: 'payments.commission.propose',
  PAYMENTS_PAYOUT_APPROVE: 'payments.payout.approve',

  // Users / rides
  USERS_MANAGE: 'users.manage',
  USERS_READ: 'users.read',

  // KYC
  KYC_MANAGE: 'kyc.manage',

  // Safety
  SAFETY_MANAGE: 'safety.manage',
  SAFETY_READ: 'safety.read',

  // Reports
  REPORTS_OPERATIONAL: 'reports.operational',
  REPORTS_FINANCIAL: 'reports.financial',

  // System config
  SYSTEM_MANAGE: 'system.manage',

  // Audit log
  AUDIT_VIEW: 'audit.view',

  // Notifications
  NOTIFICATIONS_MANAGE: 'notifications.manage',

  // LTFRB
  LTFRB_MANAGE: 'ltfrb.manage',
  LTFRB_VIEW: 'ltfrb.view',
} as const;

export type Permission = (typeof PERM)[keyof typeof PERM];

const ROLE_PERMISSIONS: Record<AdminRole, Permission[] | ['*']> = {
  super_admin: ['*'],
  operations: [
    PERM.DASHBOARD_VIEW,
    PERM.USERS_MANAGE,
    PERM.USERS_READ,
    PERM.KYC_MANAGE,
    PERM.SAFETY_MANAGE,
    PERM.SAFETY_READ,
    PERM.REPORTS_OPERATIONAL,
    PERM.NOTIFICATIONS_MANAGE,
    PERM.LTFRB_VIEW,
    PERM.FARES_VIEW,
  ],
  finance: [
    PERM.DASHBOARD_VIEW,
    PERM.DASHBOARD_FINANCIAL,
    PERM.FARES_VIEW,
    PERM.PAYMENTS_VIEW,
    PERM.PAYMENTS_PAYOUT_APPROVE,
    PERM.PAYMENTS_COMMISSION_PROPOSE,
    PERM.REPORTS_OPERATIONAL,
    PERM.REPORTS_FINANCIAL,
  ],
  support: [
    PERM.DASHBOARD_VIEW,
    PERM.USERS_READ,
    PERM.SAFETY_READ,
  ],
};

export function checkPermission(role: AdminRole, permission: Permission): boolean {
  const perms = ROLE_PERMISSIONS[role];
  if (perms[0] === '*') return true;
  return (perms as Permission[]).includes(permission);
}
