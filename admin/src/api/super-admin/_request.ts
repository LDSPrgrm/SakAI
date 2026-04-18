// Shared fetch helper for all super-admin API modules.
// Mirrors the pattern in lib/admin-api.ts but lives in its own module
// so each domain file only imports what it needs.

import { tokenStore } from '@/lib/api';

export const BASE_URL =
  (import.meta.env.VITE_API_URL as string) || 'http://192.168.100.43/api';

export async function adminRequest<T>(
  method: string,
  path: string,
  body?: unknown,
): Promise<T> {
  const token = tokenStore.getAccess();
  const res = await fetch(`${BASE_URL}/admin${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  if (res.status === 204) return undefined as T;
  const json = await res.json();
  if (!res.ok) {
    throw new Error(json?.error || json?.message || `Request failed (${res.status})`);
  }
  if (json && typeof json === 'object' && 'success' in json && 'data' in json) {
    if (!json.success) throw new Error(json.error || 'API request failed');
    return json.data as T;
  }
  return json as T;
}

/** Safely extracts an array from various envelope shapes */
export function extractArray<T>(res: unknown): T[] {
  if (!res) return [];
  if (Array.isArray(res)) return res as T[];
  const obj = res as Record<string, unknown>;
  for (const key of ['data', 'items', 'logs', 'results']) {
    if (Array.isArray(obj[key])) return obj[key] as T[];
  }
  const found = Object.values(obj).find(Array.isArray);
  return found ? (found as T[]) : [];
}
