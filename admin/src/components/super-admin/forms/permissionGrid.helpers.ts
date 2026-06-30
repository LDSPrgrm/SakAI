// Permission-grid data + transforms. Kept separate from PermissionGrid.tsx so
// the component file only exports components (React Fast Refresh requirement —
// react-doctor `only-export-components`).
import type { RolePermission, RolePermissionKey } from '@/types/super-admin';

export interface PermRow {
  key: RolePermissionKey;
  label: string;
  hasWrite: boolean;
}

export const PERM_ROWS: PermRow[] = [
  { key: 'dashboard',        label: 'Dashboard',          hasWrite: false },
  { key: 'admin_management', label: 'Admin Management',   hasWrite: true  },
  { key: 'role_management',  label: 'Role Management',    hasWrite: true  },
  { key: 'fare_config',      label: 'Fare Config',        hasWrite: true  },
  { key: 'payments',         label: 'Payments',           hasWrite: true  },
  { key: 'payouts',          label: 'Payouts',            hasWrite: true  },
  { key: 'user_management',  label: 'User Management',    hasWrite: true  },
  { key: 'kyc_verification', label: 'KYC Verification',   hasWrite: true  },
  { key: 'safety_incidents', label: 'Safety / Incidents', hasWrite: true  },
  { key: 'reports',          label: 'Reports',            hasWrite: true  },
  { key: 'system_config',    label: 'System Config',      hasWrite: true  },
  { key: 'system_health',    label: 'System Health',      hasWrite: false },
  { key: 'audit_log',        label: 'Audit Log',          hasWrite: false },
  { key: 'ltfrb_compliance', label: 'LTFRB Compliance',   hasWrite: true  },
];

export type PermGrid = Record<RolePermissionKey, { read: boolean; write: boolean }>;

export function emptyGrid(): PermGrid {
  return Object.fromEntries(
    PERM_ROWS.map((r) => [r.key, { read: false, write: false }]),
  ) as PermGrid;
}

export function fromPermissions(perms: RolePermission[]): PermGrid {
  return parsePermissions(perms).grid;
}

// Same as fromPermissions but also returns the list of permission keys that
// were dropped because PERM_ROWS doesn't know them. Useful for surfacing
// schema drift to the user instead of silently losing data.
export function parsePermissions(perms: RolePermission[]): { grid: PermGrid; unknownKeys: string[] } {
  const grid = emptyGrid();
  const unknownKeys: string[] = [];
  for (const p of perms) {
    if (grid[p.permission_key] !== undefined) {
      grid[p.permission_key] = { read: p.read, write: p.write };
    } else {
      unknownKeys.push(p.permission_key);
    }
  }
  if (unknownKeys.length > 0) {
    console.warn('[PermissionGrid] dropped unknown permission keys:', unknownKeys);
  }
  return { grid, unknownKeys };
}

export function toPermissions(grid: PermGrid): RolePermission[] {
  return PERM_ROWS
    .filter((r) => grid[r.key].read || grid[r.key].write)
    .map((r) => ({
      permission_key: r.key,
      read: grid[r.key].read,
      write: r.hasWrite ? grid[r.key].write : false,
    }));
}

export function permSummary(perms: RolePermission[]): string {
  const reads = perms.filter((p) => p.read).length;
  const writes = perms.filter((p) => p.write).length;
  return `${reads}R · ${writes}W`;
}
