import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import {
  adminRequest,
  adminRequestVoid,
  adminRequestBlob,
  unwrapList,
  extractArray,
} from '../_request';

const originalFetch = global.fetch;

function mockResponse(init: {
  status?: number;
  body?: unknown;
  blob?: Blob;
  ok?: boolean;
}): Response {
  const status = init.status ?? 200;
  return {
    ok: init.ok ?? status < 400,
    status,
    json: async () => init.body ?? {},
    blob: async () => init.blob ?? new Blob([]),
  } as Response;
}

describe('adminRequest', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn());
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    global.fetch = originalFetch;
  });

  it('parses a JSON body on 200', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 200, body: { foo: 'bar' } }),
    );
    const result = await adminRequest<{ foo: string }>('GET', '/x');
    expect(result).toEqual({ foo: 'bar' });
  });

  it('unwraps the { success, data } envelope', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 200, body: { success: true, data: { id: 1 } } }),
    );
    const result = await adminRequest<{ id: number }>('GET', '/x');
    expect(result).toEqual({ id: 1 });
  });

  it('throws when called on a 204 endpoint (use adminRequestVoid instead)', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 204 }),
    );
    await expect(adminRequest('PUT', '/fares')).rejects.toThrow(/adminRequestVoid/);
  });

  it('throws with the server error message on non-OK', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 400, ok: false, body: { error: 'bad input' } }),
    );
    await expect(adminRequest('POST', '/x', {})).rejects.toThrow('bad input');
  });
});

describe('adminRequestVoid', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn());
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    global.fetch = originalFetch;
  });

  it('resolves to undefined on 204', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 204 }),
    );
    await expect(adminRequestVoid('PUT', '/x')).resolves.toBeUndefined();
  });

  it('resolves on 200 without parsing', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 200 }),
    );
    await expect(adminRequestVoid('PUT', '/x')).resolves.toBeUndefined();
  });

  it('throws on non-OK', async () => {
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 500, ok: false, body: { error: 'boom' } }),
    );
    await expect(adminRequestVoid('PUT', '/x')).rejects.toThrow('boom');
  });
});

describe('adminRequestBlob', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn());
  });
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('returns a Blob on 200', async () => {
    const blob = new Blob(['id,name\n1,foo'], { type: 'text/csv' });
    (global.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockResponse({ status: 200, blob }),
    );
    const result = await adminRequestBlob('GET', '/audit/export');
    expect(result).toBe(blob);
  });

  it('sets Accept header to text/csv by default', async () => {
    const fetchMock = vi.fn().mockResolvedValue(mockResponse({ status: 200 }));
    vi.stubGlobal('fetch', fetchMock);
    await adminRequestBlob('GET', '/audit/export');
    const headers = fetchMock.mock.calls[0][1].headers as Record<string, string>;
    expect(headers.Accept).toBe('text/csv');
  });
});

describe('unwrapList', () => {
  it('returns items + meta from a paginated envelope', () => {
    const res = { items: [1, 2, 3], meta: { total_items: 10, current_page: 1, total_pages: 4, limit: 3 } };
    const { items, meta } = unwrapList<number>(res);
    expect(items).toEqual([1, 2, 3]);
    expect(meta?.total_items).toBe(10);
    expect(meta?.total_pages).toBe(4);
  });

  it('handles legacy `data` envelope without meta', () => {
    const { items, meta } = unwrapList<number>({ data: [1, 2] });
    expect(items).toEqual([1, 2]);
    expect(meta).toBeUndefined();
  });

  it('handles a bare array', () => {
    const { items } = unwrapList<number>([1, 2, 3]);
    expect(items).toEqual([1, 2, 3]);
  });

  it('returns empty items for null', () => {
    expect(unwrapList<number>(null).items).toEqual([]);
  });
});

describe('extractArray (shim)', () => {
  it('delegates to unwrapList and returns items only', () => {
    expect(extractArray<number>({ items: [1, 2], meta: {} })).toEqual([1, 2]);
    expect(extractArray<number>({ data: [3] })).toEqual([3]);
    expect(extractArray<number>([4, 5])).toEqual([4, 5]);
  });
});
