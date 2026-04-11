// Built-in role constants — spec superadmin.md §3.1
// These roles are seeded on first deployment. super_admin is immutable.

export const SYSTEM_ROLES = ['super_admin'] as const;
export type SystemRole = (typeof SYSTEM_ROLES)[number];

export const BUILT_IN_ROLES = ['super_admin', 'operations', 'finance', 'support'] as const;
export type BuiltInRole = (typeof BUILT_IN_ROLES)[number];

export const ROLE_LABELS: Record<BuiltInRole, string> = {
  super_admin: 'Super Admin',
  operations:  'Operations',
  finance:     'Finance',
  support:     'Support',
};
