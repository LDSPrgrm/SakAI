import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, waitFor } from '@testing-library/react';
import React from 'react';
import {
  useRoles,
  useCreateRole,
  useUpdateRole,
  useDeleteRole,
  useDuplicateRole,
} from '../useRoles';

vi.mock('@/api/super-admin/roles', () => ({
  rolesApi: {
    list:      vi.fn().mockResolvedValue([]),
    get:       vi.fn(),
    create:    vi.fn().mockResolvedValue({ id: 'r1', name: 'operations', description: '', permissions: [] }),
    update:    vi.fn().mockResolvedValue({ id: 'r1', name: 'operations-v2', description: '', permissions: [] }),
    delete:    vi.fn().mockResolvedValue(undefined),
    duplicate: vi.fn().mockResolvedValue({ id: 'r2', name: 'operations_copy', description: '', permissions: [] }),
    getPermissions: vi.fn(),
    getAdmins: vi.fn(),
  },
}));

function wrapper(qc: QueryClient) {
  return ({ children }: { children: React.ReactNode }) =>
    React.createElement(QueryClientProvider, { client: qc }, children);
}

describe('useRoles', () => {
  let qc: QueryClient;
  let invalidateSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    invalidateSpy = vi.spyOn(qc, 'invalidateQueries');
  });

  afterEach(() => {
    invalidateSpy.mockRestore();
    qc.clear();
    vi.clearAllMocks();
  });

  it('fetches and exposes the roles list', async () => {
    const { rolesApi } = await import('@/api/super-admin/roles');
    vi.mocked(rolesApi.list).mockResolvedValue([{ id: 'r1', name: 'operations', permissions: [] } as any]);

    const { result } = renderHook(() => useRoles(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(1);
    expect(result.current.data![0].name).toBe('operations');
  });

  it('useCreateRole invalidates the roles cache on success', async () => {
    const { result } = renderHook(() => useCreateRole(), { wrapper: wrapper(qc) });
    await result.current.mutateAsync({ name: 'ops', description: '', permissions: [] });
    await waitFor(() =>
      expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['admin', 'roles'] }),
    );
  });

  it('useUpdateRole invalidates the roles cache on success', async () => {
    const { result } = renderHook(() => useUpdateRole(), { wrapper: wrapper(qc) });
    await result.current.mutateAsync({ id: 'r1', data: { name: 'ops-v2', description: '', permissions: [] } });
    await waitFor(() =>
      expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['admin', 'roles'] }),
    );
  });

  it('useDeleteRole invalidates the roles cache on success', async () => {
    const { result } = renderHook(() => useDeleteRole(), { wrapper: wrapper(qc) });
    await result.current.mutateAsync('r1');
    await waitFor(() =>
      expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['admin', 'roles'] }),
    );
  });

  it('useDuplicateRole invalidates the roles cache on success', async () => {
    const { result } = renderHook(() => useDuplicateRole(), { wrapper: wrapper(qc) });
    await result.current.mutateAsync('r1');
    await waitFor(() =>
      expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['admin', 'roles'] }),
    );
  });
});
