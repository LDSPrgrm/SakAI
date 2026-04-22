import { describe, it, expect } from 'vitest';
import { displayRole } from './displayRole';

const roleDefs = [
  { id: 'r-admin',      name: 'admin' },
  { id: 'r-super',      name: 'superadmin' },
  { id: 'r-operations', name: 'operations' },
  { id: 'r-custom',     name: 'marketing' },
];

describe('displayRole', () => {
  it('resolves role name from role_id when roleDefs provided (custom role override)', () => {
    // Backend sends role:"admin" for user-created custom admins; role_id is the truth.
    expect(
      displayRole({ role: 'admin', role_id: 'r-operations' }, roleDefs),
    ).toBe('operations');
  });

  it('resolves custom (non-system) role names via role_id', () => {
    expect(
      displayRole({ role: 'admin', role_id: 'r-custom' }, roleDefs),
    ).toBe('marketing');
  });

  it('resolves system admin correctly via role_id', () => {
    expect(
      displayRole({ role: 'superadmin', role_id: 'r-super' }, roleDefs),
    ).toBe('superadmin');
  });

  it('falls back to role_name when role_id not in roleDefs', () => {
    expect(
      displayRole({ role: 'admin', role_id: 'missing', role_name: 'ops' }, roleDefs),
    ).toBe('ops');
  });

  it('falls back to role when role_id and role_name are absent', () => {
    expect(displayRole({ role: 'superadmin' }, roleDefs)).toBe('superadmin');
  });

  it('falls back to role when roleDefs not provided', () => {
    expect(displayRole({ role: 'admin', role_id: 'r-operations' })).toBe('admin');
  });

  it('returns empty string when nothing available', () => {
    expect(displayRole({})).toBe('');
  });

  it('treats empty role_name as missing (regression guard for `||` vs `??`)', () => {
    expect(displayRole({ role: 'admin', role_name: '' })).toBe('admin');
  });
});
