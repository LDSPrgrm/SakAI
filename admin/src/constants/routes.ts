// Route path constants — keeps links consistent and refactor-safe.

export const ROUTES = {
  LOGIN:          '/login',
  ADMIN:          '/admin',
  ADMIN_DASHBOARD: '/admin/dashboard',
  SA_ROOT:        '/super-admin',
  SA_DASHBOARD:   '/super-admin/dashboard',
  SA_ADMINS:      '/super-admin/admins',
  SA_ROLES:       '/super-admin/roles',
  SA_FARES:       '/super-admin/fares',
  SA_PAYMENTS:    '/super-admin/payments',
  SA_SAFETY:      '/super-admin/safety',
  SA_REPORTS:     '/super-admin/reports',
  SA_SYSTEM:      '/super-admin/system',
  SA_HEALTH:      '/super-admin/health',
  SA_AUDIT:       '/super-admin/audit',
} as const;
