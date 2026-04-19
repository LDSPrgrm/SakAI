import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { renderHook, act, waitFor } from '@testing-library/react';
import React from 'react';
import { AuthProvider, useAuth } from '../AuthContext';

const {
  mockLoadPermissions,
  mockClearPermissions,
  mockTokenStore,
  mockApi,
} = vi.hoisted(() => {
  const mockLoadPermissions = vi.fn();
  const mockClearPermissions = vi.fn();
  const mockTokenStore = {
    getAccess:  vi.fn(),
    getRefresh: vi.fn(),
    set:        vi.fn(),
    clear:      vi.fn(),
  };
  const mockApi = {
    users: { me: vi.fn() },
    auth:  { login: vi.fn(), logout: vi.fn(), refresh: vi.fn() },
  };
  return { mockLoadPermissions, mockClearPermissions, mockTokenStore, mockApi };
});

vi.mock('@/hooks/usePermissions', () => ({
  usePermissionsStore: {
    getState: vi.fn().mockReturnValue({
      loadPermissions: mockLoadPermissions,
      clear: mockClearPermissions,
    }),
  },
}));

vi.mock('@/lib/api', () => ({
  tokenStore: mockTokenStore,
  api:        mockApi,
}));

const mockProfile = {
  id: 'u1', name: 'Alice', email: 'alice@sakai.ph',
  role: 'admin', role_id: 'role-1', created_at: '2025-01-01',
};
const mockAuthResponse = {
  access_token: 'acc', refresh_token: 'ref',
  access_token_expires_at: '', user: mockProfile,
};

function wrapper({ children }: { children: React.ReactNode }) {
  return React.createElement(AuthProvider, null, children);
}

describe('AuthContext', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockLoadPermissions.mockResolvedValue(undefined);
    mockTokenStore.getAccess.mockReturnValue(null);
    mockTokenStore.getRefresh.mockReturnValue(null);
    mockApi.auth.logout.mockResolvedValue(undefined);
    mockApi.users.me.mockResolvedValue(mockProfile);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('starts unauthenticated when no token is stored', async () => {
    mockTokenStore.getAccess.mockReturnValue(null);

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
    expect(mockApi.users.me).not.toHaveBeenCalled();
  });

  it('restores session from stored token on mount', async () => {
    mockTokenStore.getAccess.mockReturnValue('stored-token');

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isAuthenticated).toBe(true));

    expect(result.current.user?.email).toBe('alice@sakai.ph');
    expect(mockLoadPermissions).toHaveBeenCalledWith('role-1');
  });

  it('clears token when /users/me fails on mount', async () => {
    mockTokenStore.getAccess.mockReturnValue('bad-token');
    mockApi.users.me.mockRejectedValue(new Error('Unauthorized'));

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    expect(result.current.isAuthenticated).toBe(false);
    expect(mockTokenStore.clear).toHaveBeenCalled();
  });

  it('login() stores tokens and sets the user', async () => {
    mockApi.auth.login.mockResolvedValue(mockAuthResponse);

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    await act(async () => { await result.current.login('alice@sakai.ph', 'secret'); });

    expect(mockTokenStore.set).toHaveBeenCalledWith('acc', 'ref');
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user?.email).toBe('alice@sakai.ph');
  });

  it('logout() clears tokens and resets user', async () => {
    mockTokenStore.getAccess.mockReturnValue('stored-token');
    mockTokenStore.getRefresh.mockReturnValue('ref');

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isAuthenticated).toBe(true));

    await act(async () => { await result.current.logout(); });

    expect(mockTokenStore.clear).toHaveBeenCalled();
    expect(mockClearPermissions).toHaveBeenCalled();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });
});
