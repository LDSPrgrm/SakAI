// Phase 2 / H1 regression: mutations against 204 endpoints must trigger
// queryClient.invalidateQueries on success (since there's no response body
// to drive an optimistic update).

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, waitFor } from '@testing-library/react';
import React from 'react';
import { useUpdateFareConfig, useUpdateSurgeConfig } from '../useFareConfig';

vi.mock('@/api/super-admin/fares', () => ({
  faresApi: {
    updateConfigs: vi.fn().mockResolvedValue(undefined),
    updateSurge:   vi.fn().mockResolvedValue(undefined),
    getConfigs:    vi.fn().mockResolvedValue([]),
    getSurge:      vi.fn().mockResolvedValue({}),
    simulate:      vi.fn(),
  },
}));

function wrapper(qc: QueryClient) {
  return ({ children }: { children: React.ReactNode }) =>
    React.createElement(QueryClientProvider, { client: qc }, children);
}

describe('H1 — 204 mutations invalidate their query cache', () => {
  let qc: QueryClient;
  let spy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    spy = vi.spyOn(qc, 'invalidateQueries');
  });

  afterEach(() => {
    spy.mockRestore();
    qc.clear();
  });

  it('useUpdateFareConfig invalidates the fares cache on success', async () => {
    const { result } = renderHook(() => useUpdateFareConfig(), { wrapper: wrapper(qc) });
    await result.current.mutateAsync([]);
    await waitFor(() =>
      expect(spy).toHaveBeenCalledWith({ queryKey: ['admin', 'fares'] }),
    );
  });

  it('useUpdateSurgeConfig invalidates the surge cache on success', async () => {
    const { result } = renderHook(() => useUpdateSurgeConfig(), { wrapper: wrapper(qc) });
    await result.current.mutateAsync({});
    await waitFor(() =>
      expect(spy).toHaveBeenCalledWith({ queryKey: ['admin', 'surge'] }),
    );
  });
});
