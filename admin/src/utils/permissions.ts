// Permission key constants used across UI components.
// Spec: superadmin.md §3.2

export const PERMISSION_KEYS = [
  'dashboard',
  'admin_management',
  'role_management',
  'fare_config',
  'payments',
  'payouts',
  'user_management',
  'kyc_verification',
  'safety_incidents',
  'reports',
  'system_config',
  'system_health',
  'audit_log',
  'ltfrb_compliance',
] as const;

export type PermissionKey = (typeof PERMISSION_KEYS)[number];

export const PERMISSION_LABELS: Record<PermissionKey, string> = {
  dashboard:         'Dashboard',
  admin_management:  'Admin Management',
  role_management:   'Role Management',
  fare_config:       'Fare Config',
  payments:          'Payments',
  payouts:           'Payouts',
  user_management:   'User Management',
  kyc_verification:  'KYC Verification',
  safety_incidents:  'Safety / Incidents',
  reports:           'Reports',
  system_config:     'System Config',
  system_health:     'System Health',
  audit_log:         'Audit Log',
  ltfrb_compliance:  'LTFRB Compliance',
};

/** Which permissions have a write scope (Dashboard is read-only) */
export const HAS_WRITE_SCOPE = new Set<PermissionKey>(
  PERMISSION_KEYS.filter((k) => k !== 'dashboard'),
);
