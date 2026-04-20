import React from 'react';
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
  const grid = emptyGrid();
  for (const p of perms) {
    if (grid[p.permission_key] !== undefined) {
      grid[p.permission_key] = { read: p.read, write: p.write };
    }
  }
  return grid;
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
  const enabled = perms.filter((p) => p.read || p.write).length;
  return `${enabled} of ${PERM_ROWS.length}`;
}

export interface PermissionGridProps {
  grid: PermGrid;
  onChange: (key: RolePermissionKey, scope: 'read' | 'write', value: boolean) => void;
  onSelectAllRead?: () => void;
  onSelectAllWrite?: () => void;
  onClearAll?: () => void;
  disabled?: boolean;
}

export function PermissionGrid({
  grid,
  onChange,
  onSelectAllRead,
  onSelectAllWrite,
  onClearAll,
  disabled,
}: PermissionGridProps) {
  return (
    <div className="space-y-3">
      {!disabled && (
        <div className="flex gap-2 text-xs flex-wrap">
          <button type="button" onClick={onSelectAllRead}
            className="px-2 py-1 rounded border border-border text-text-muted hover:text-text-main hover:border-primary transition-colors">
            Select All Read
          </button>
          <button type="button" onClick={onSelectAllWrite}
            className="px-2 py-1 rounded border border-border text-text-muted hover:text-text-main hover:border-primary transition-colors">
            Select All Write
          </button>
          <button type="button" onClick={onClearAll}
            className="px-2 py-1 rounded border border-border text-text-muted hover:text-danger hover:border-danger transition-colors">
            Clear All
          </button>
        </div>
      )}
      <div className="border border-border rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border bg-background">
              <th className="text-left px-3 py-2 font-medium text-text-muted">Permission</th>
              <th className="text-center px-3 py-2 font-medium text-text-muted w-20">Read</th>
              <th className="text-center px-3 py-2 font-medium text-text-muted w-20">Write</th>
            </tr>
          </thead>
          <tbody>
            {PERM_ROWS.map((row, idx) => {
              const cell = grid[row.key];
              return (
                <tr key={row.key} className={idx % 2 === 0 ? 'bg-surface' : 'bg-surface-hover'}>
                  <td className="px-3 py-2 text-text-main">{row.label}</td>
                  <td className="text-center px-3 py-2">
                    <input
                      type="checkbox"
                      checked={cell.read}
                      disabled={disabled}
                      onChange={(e) => onChange(row.key, 'read', e.target.checked)}
                      className="accent-primary w-4 h-4"
                    />
                  </td>
                  <td className="text-center px-3 py-2">
                    {row.hasWrite ? (
                      <input
                        type="checkbox"
                        checked={cell.write}
                        disabled={disabled}
                        onChange={(e) => onChange(row.key, 'write', e.target.checked)}
                        className="accent-primary w-4 h-4"
                      />
                    ) : (
                      <span className="text-text-muted text-xs">—</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
