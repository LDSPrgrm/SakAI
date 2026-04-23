// WebSocket / polling hook for the super-admin activity feed.
// Spec: superadmin.md §4.1 (Activity Feed — real-time event stream)
//
// Currently implemented as a polling wrapper. When the backend exposes a
// WebSocket channel for admin events, swap the interval for a `new WebSocket`
// connection — the hook surface stays the same.

import { useEffect, useRef, useState } from 'react';

export interface RealTimeEvent<T = unknown> {
  id: string;
  type: string;
  payload: T;
  timestamp: string;
}

export interface UseRealTimeUpdatesOptions {
  /** Polling interval in ms. Default 30s. */
  intervalMs?: number;
  /** Enable or disable polling (e.g. when the tab is hidden). */
  enabled?: boolean;
}

export function useRealTimeUpdates<T = unknown>(
  fetcher: () => Promise<RealTimeEvent<T>[]>,
  options: UseRealTimeUpdatesOptions = {},
) {
  const { intervalMs = 30_000, enabled = true } = options;
  const [events, setEvents] = useState<RealTimeEvent<T>[]>([]);
  const [error, setError] = useState<Error | null>(null);
  const timer = useRef<ReturnType<typeof setInterval> | null>(null);

  // Hold the latest fetcher in a ref so callers passing inline arrows don't
  // re-trigger the effect every render (would cause interval churn + refetch
  // storm). The effect itself depends only on enabled/intervalMs.
  const fetcherRef = useRef(fetcher);
  useEffect(() => {
    fetcherRef.current = fetcher;
  });

  useEffect(() => {
    if (!enabled) return;

    let cancelled = false;
    const tick = async () => {
      try {
        const next = await fetcherRef.current();
        if (!cancelled) setEvents(next);
      } catch (err) {
        if (!cancelled) setError(err instanceof Error ? err : new Error(String(err)));
      }
    };

    void tick();
    timer.current = setInterval(tick, intervalMs);
    return () => {
      cancelled = true;
      if (timer.current) clearInterval(timer.current);
    };
  }, [enabled, intervalMs]);

  return { events, error };
}
