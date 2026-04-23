// Shared fetch helper for all super-admin API modules.
// Mirrors the pattern in lib/api.ts but lives in its own module
// so each domain file only imports what it needs.

import { tokenStore } from '@/lib/api';
import type { components } from '@/types/openapi';

export type PaginationMeta = components['schemas']['PaginationMeta'];

export const BASE_URL =
  (import.meta.env.VITE_API_URL as string) || '/api';

function buildUrl(path: string): string {
  return `${BASE_URL}/admin${path}`;
}

function authHeaders(extra?: Record<string, string>): Record<string, string> {
  const token = tokenStore.getAccess();
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...extra,
  };
}

async function parseOrThrow(res: Response): Promise<unknown> {
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = json as { error?: string; message?: string };
    throw new Error(err?.error || err?.message || `Request failed (${res.status})`);
  }
  if (json && typeof json === 'object' && 'success' in json && 'data' in json) {
    if (!(json as { success: boolean }).success) {
      throw new Error((json as { error?: string }).error || 'API request failed');
    }
    return (json as { data: unknown }).data;
  }
  return json;
}

// ── Token refresh ─────────────────────────────────────────────────────────────
// Prevents concurrent 401s from each spawning their own refresh call.
let isRefreshing = false;
let pendingResolvers: Array<(token: string) => void> = [];
let pendingRejectors: Array<(err: Error) => void> = [];

async function refreshAccessToken(): Promise<string> {
  if (isRefreshing) {
    return new Promise<string>((resolve, reject) => {
      pendingResolvers.push(resolve);
      pendingRejectors.push(reject);
    });
  }

  isRefreshing = true;
  const refreshToken = tokenStore.getRefresh();

  if (!refreshToken) {
    isRefreshing = false;
    throw new Error('No refresh token — please log in again.');
  }

  try {
    const res = await fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    if (!res.ok) {
      tokenStore.clear();
      throw new Error('Session expired — please log in again.');
    }

    const json = await res.json().catch(() => ({}));
    const data = ((json as Record<string, unknown>)?.data ?? json) as Record<string, string>;
    const newAccess: string = data.access_token;
    const newRefresh: string = data.refresh_token ?? refreshToken;

    if (!newAccess) throw new Error('Invalid refresh response from server.');

    tokenStore.set(newAccess, newRefresh);
    pendingResolvers.forEach((r) => r(newAccess));
    return newAccess;
  } catch (err) {
    const error = err instanceof Error ? err : new Error(String(err));
    pendingRejectors.forEach((r) => r(error));
    throw error;
  } finally {
    isRefreshing = false;
    pendingResolvers = [];
    pendingRejectors = [];
  }
}

/** JSON request returning a parsed body. Use for 200 responses with payloads. */
export async function adminRequest<T>(
  method: string,
  path: string,
  body?: unknown,
): Promise<T> {
  const serializedBody = body !== undefined ? JSON.stringify(body) : undefined;
  let res = await fetch(buildUrl(path), {
    method,
    headers: authHeaders(),
    body: serializedBody,
  });

  if (res.status === 401) {
    await refreshAccessToken();
    res = await fetch(buildUrl(path), {
      method,
      headers: authHeaders(),
      body: serializedBody,
    });
  }

  if (res.status === 204) {
    throw new Error(`Unexpected 204 for ${method} ${path} — use adminRequestVoid instead`);
  }
  return (await parseOrThrow(res)) as T;
}

/** Request that expects no response body (HTTP 204). */
export async function adminRequestVoid(
  method: string,
  path: string,
  body?: unknown,
): Promise<void> {
  const serializedBody = body !== undefined ? JSON.stringify(body) : undefined;
  let res = await fetch(buildUrl(path), {
    method,
    headers: authHeaders(),
    body: serializedBody,
  });

  if (res.status === 401) {
    await refreshAccessToken();
    res = await fetch(buildUrl(path), {
      method,
      headers: authHeaders(),
      body: serializedBody,
    });
  }

  if (res.status === 204) return;
  if (!res.ok) {
    const json = await res.json().catch(() => ({}));
    const err = json as { error?: string; message?: string };
    throw new Error(err?.error || err?.message || `Request failed (${res.status})`);
  }
}

/** Request returning a binary blob (CSV export, file download). */
export async function adminRequestBlob(
  method: string,
  path: string,
  accept = 'text/csv',
): Promise<Blob> {
  let res = await fetch(buildUrl(path), {
    method,
    headers: authHeaders({ Accept: accept }),
  });

  if (res.status === 401) {
    await refreshAccessToken();
    res = await fetch(buildUrl(path), {
      method,
      headers: authHeaders({ Accept: accept }),
    });
  }

  if (!res.ok) {
    throw new Error(`Request failed (${res.status})`);
  }
  return res.blob();
}

/** Unwrap a paginated list envelope `{ items, meta }`, with fallbacks. */
export function unwrapList<T>(res: unknown): { items: T[]; meta?: PaginationMeta } {
  if (!res) return { items: [] };
  if (Array.isArray(res)) return { items: res as T[] };
  const obj = res as Record<string, unknown>;
  const meta = (obj['meta'] as PaginationMeta | undefined) ?? undefined;
  for (const key of ['items', 'data', 'logs', 'results']) {
    if (Array.isArray(obj[key])) return { items: obj[key] as T[], meta };
  }
  const found = Object.values(obj).find(Array.isArray);
  return { items: found ? (found as T[]) : [], meta };
}

/**
 * @deprecated Transitional shim — use `unwrapList(res).items` for new code.
 * Kept so legacy callers continue to compile while Phase 3 migrates them.
 */
export function extractArray<T>(res: unknown): T[] {
  return unwrapList<T>(res).items;
}
