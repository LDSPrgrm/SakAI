import React from 'react';
import type { RolePermissionKey } from '@/types/super-admin';
import { PERM_ROWS, type PermGrid } from './permissionGrid.helpers';

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
                      <span className="text-text-muted text-xs">&mdash;</span>
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
