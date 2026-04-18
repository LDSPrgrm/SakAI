import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook } from '@testing-library/react';
import { usePermissions, usePermissionsStore } from './usePermissions';

vi.mock('@/contexts/AuthContext', () => ({
  useAuth: vi.fn(() => ({ user: null })),
}));

vi.mock('@/lib/api', () => ({
  tokenStore: { getAccess: vi.fn(() => null) },
}));

import { useAuth } from '@/contexts/AuthContext';
const mockUseAuth = vi.mocked(useAuth);

const FINANCE_PERMISSIONS = [
  { permission_key: 'dashboard' as const,  read: true,  write: false },
  { permission_key: 'payments' as const,   read: true,  write: true  },
  { permission_key: 'payouts' as const,    read: true,  write: true  },
  { permission_key: 'fare_config' as const,read: true,  write: true  },
  { permission_key: 'reports' as const,    read: true,  write: true  },
];

beforeEach(() => {
  usePermissionsStore.setState({
    role: { id: '3', name: 'finance', permissions: FINANCE_PERMISSIONS },
    permissions: FINANCE_PERMISSIONS,
    loading: false,
    error: null,
  });
  mockUseAuth.mockReturnValue({ user: { role: 'finance' } } as ReturnType<typeof useAuth>);
});

describe('usePermissions — can()', () => {
  it('returns true for a granted read permission', () => {
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('payments', 'read')).toBe(true);
  });

  it('returns true for a granted write permission', () => {
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('payments', 'write')).toBe(true);
  });

  it('returns false for a write permission that is read-only', () => {
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('dashboard', 'write')).toBe(false);
  });

  it('returns false for a permission key the role does not have', () => {
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('role_management', 'read')).toBe(false);
  });

  it('read returns true when write is granted even if read flag is false', () => {
    usePermissionsStore.setState({
      permissions: [{ permission_key: 'reports', read: false, write: true }],
      role: { id: '3', name: 'finance', permissions: [] },
      loading: false,
      error: null,
    });
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('reports', 'read')).toBe(true);
  });

  it('super_admin bypasses permission checks via auth user role', () => {
    mockUseAuth.mockReturnValue({ user: { role: 'super_admin' } } as ReturnType<typeof useAuth>);
    usePermissionsStore.setState({ permissions: [], role: null, loading: false, error: null });
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('role_management', 'write')).toBe(true);
    expect(result.current.can('system_config', 'write')).toBe(true);
  });

  it('super_admin bypasses checks via loaded role name', () => {
    mockUseAuth.mockReturnValue({ user: null } as ReturnType<typeof useAuth>);
    usePermissionsStore.setState({
      permissions: [],
      role: { id: '1', name: 'super_admin', permissions: [] },
      loading: false,
      error: null,
    });
    const { result } = renderHook(() => usePermissions());
    expect(result.current.can('audit_log', 'read')).toBe(true);
  });

  it('exposes loading and error state from the store', () => {
    usePermissionsStore.setState({ loading: true, error: 'Timeout', permissions: [], role: null });
    const { result } = renderHook(() => usePermissions());
    expect(result.current.loading).toBe(true);
    expect(result.current.error).toBe('Timeout');
  });
});
