import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, act, waitFor } from '@testing-library/react';
import React from 'react';
import { useAuditLog, useExportAuditLog, useAuditedMutation } from '../useAuditLog';

vi.mock('@/api/super-admin/audit', () => ({
  auditApi: {
    getLogs:   vi.fn().mockResolvedValue([]),
    exportCsv: vi.fn().mockResolvedValue(new Blob(['id,action'], { type: 'text/csv' })),
  },
}));

vi.mock('@/api/super-admin/_request', () => ({
  adminRequestVoid: vi.fn().mockResolvedValue(undefined),
}));

function wrapper(qc: QueryClient) {
  return ({ children }: { children: React.ReactNode }) =>
    React.createElement(QueryClientProvider, { client: qc }, children);
}

describe('useAuditLog', () => {
  let qc: QueryClient;

  beforeEach(() => {
    qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  });

  afterEach(() => {
    qc.clear();
    vi.clearAllMocks();
  });

  it('fetches and returns audit log entries', async () => {
    const { auditApi } = await import('@/api/super-admin/audit');
    const logs = [{ id: 'l1', action: 'update', actor_name: 'Alice', timestamp: new Date().toISOString() }];
    vi.mocked(auditApi.getLogs).mockResolvedValue(logs as any);

    const { result } = renderHook(() => useAuditLog(), { wrapper: wrapper(qc) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(1);
    expect(result.current.data![0].id).toBe('l1');
  });

  it('useExportAuditLog triggers a CSV download', async () => {
    const blob = new Blob(['id,action\n1,update'], { type: 'text/csv' });
    const { auditApi } = await import('@/api/super-admin/audit');
    vi.mocked(auditApi.exportCsv).mockResolvedValue(blob);

    const objectURLSpy = vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:mock-url');
    const revokeURLSpy = vi.spyOn(URL, 'revokeObjectURL').mockReturnValue(undefined);
    const mockLink = { href: '', download: '', click: vi.fn() };
    const originalCreate = document.createElement.bind(document);
    const createElSpy = vi.spyOn(document, 'createElement').mockImplementation(
      (tag: string, ...args: unknown[]) =>
        tag === 'a' ? (mockLink as unknown as HTMLElement) : originalCreate(tag, ...(args as [])),
    );

    const { result } = renderHook(() => useExportAuditLog(), { wrapper: wrapper(qc) });
    await act(async () => { await result.current.mutateAsync(); });

    expect(mockLink.click).toHaveBeenCalled();
    expect(mockLink.download).toMatch(/sakai-audit-log/);
    expect(revokeURLSpy).toHaveBeenCalledWith('blob:mock-url');

    objectURLSpy.mockRestore();
    revokeURLSpy.mockRestore();
    createElSpy.mockRestore();
  });
});

describe('useAuditedMutation', () => {
  let qc: QueryClient;

  beforeEach(() => {
    qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  });

  afterEach(() => {
    qc.clear();
    vi.clearAllMocks();
  });

  it('executes the inner mutation and returns its result', async () => {
    const innerFn = vi.fn().mockResolvedValue({ id: 'x1' });
    const { result } = renderHook(
      () => useAuditedMutation(innerFn, { resourceType: 'fare', resourceId: 'f1', action: 'update' }),
      { wrapper: wrapper(qc) },
    );

    let data: unknown;
    await act(async () => { data = await result.current.mutateAsync({} as never); });
    expect(data).toEqual({ id: 'x1' });
    expect(innerFn).toHaveBeenCalledOnce();
  });

  it('calls captureBefore before the inner mutation runs', async () => {
    const order: string[] = [];
    const captureBefore = vi.fn().mockImplementation(async () => { order.push('before'); return { snapshot: true }; });
    const innerFn = vi.fn().mockImplementation(async () => { order.push('inner'); return {}; });

    const { result } = renderHook(
      () => useAuditedMutation(innerFn, { resourceType: 'role', resourceId: 'r1', action: 'delete', captureBefore }),
      { wrapper: wrapper(qc) },
    );

    await act(async () => { await result.current.mutateAsync({} as never); });
    expect(order).toEqual(['before', 'inner']);
  });

  it('fires an audit POST after the mutation', async () => {
    const { adminRequestVoid } = await import('@/api/super-admin/_request');
    const innerFn = vi.fn().mockResolvedValue({ id: 'y1' });

    const { result } = renderHook(
      () => useAuditedMutation(innerFn, { resourceType: 'admin', resourceId: 'a1', action: 'create' }),
      { wrapper: wrapper(qc) },
    );
    await act(async () => { await result.current.mutateAsync({} as never); });

    // allow fire-and-forget microtask to settle
    await new Promise((r) => setTimeout(r, 0));
    expect(adminRequestVoid).toHaveBeenCalledWith('POST', '/audit', expect.objectContaining({
      resource_type: 'admin',
      resource_id: 'a1',
      action: 'create',
    }));
  });

  it('still resolves if the audit POST fails', async () => {
    const { adminRequestVoid } = await import('@/api/super-admin/_request');
    vi.mocked(adminRequestVoid).mockRejectedValue(new Error('audit down'));
    const innerFn = vi.fn().mockResolvedValue({ ok: true });

    const { result } = renderHook(
      () => useAuditedMutation(innerFn, { resourceType: 'fare', resourceId: 'f2', action: 'update' }),
      { wrapper: wrapper(qc) },
    );

    let data: unknown;
    await act(async () => { data = await result.current.mutateAsync({} as never); });
    expect(data).toEqual({ ok: true });
    expect(result.current.isError).toBe(false);
  });
});
