import { describe, it, expect } from 'vitest';
import { permSummary } from './permissionGrid.helpers';
import type { RolePermission } from '@/types/super-admin';

describe('permSummary', () => {
  it('returns zeros for empty array', () => {
    expect(permSummary([])).toBe('0R · 0W');
  });

  it('counts read-only permission toward reads only', () => {
    const perms: RolePermission[] = [
      { permission_key: 'dashboard', read: true, write: false },
    ];
    expect(permSummary(perms)).toBe('1R · 0W');
  });

  it('counts a read+write permission toward both totals', () => {
    const perms: RolePermission[] = [
      { permission_key: 'admin_management', read: true, write: true },
    ];
    expect(permSummary(perms)).toBe('1R · 1W');
  });
});
