import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Bell, Inbox } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useActivityFeed } from '@/hooks/useMetrics';
import { iconFor, type FeedEvent } from '@/components/super-admin/shared/activityMeta';
import { cn } from '@/lib/utils';

const LAST_SEEN_KEY = 'sa.notifications.lastSeenId';
const INITIAL_VISIBLE = 6;

function readLastSeenId(): string | null {
  try {
    return window.localStorage.getItem(LAST_SEEN_KEY);
  } catch {
    return null;
  }
}

function writeLastSeenId(value: string) {
  try {
    window.localStorage.setItem(LAST_SEEN_KEY, value);
  } catch {
    /* storage unavailable — silent */
  }
}

export function NotificationBell({ className }: { className?: string }) {
  const navigate = useNavigate();
  const { data: events } = useActivityFeed();
  const [open, setOpen] = useState(false);
  const [lastSeenId, setLastSeenId] = useState<string | null>(() => readLastSeenId());
  const rootRef = useRef<HTMLDivElement | null>(null);

  const feed: FeedEvent[] = events ?? [];
  const visible = feed.slice(0, INITIAL_VISIBLE);

  const unreadCount = useMemo(() => {
    if (feed.length === 0) return 0;
    if (!lastSeenId) return Math.min(feed.length, 9);
    const idx = feed.findIndex((e) => String(e.id) === lastSeenId);
    if (idx === -1) return Math.min(feed.length, 9);
    return idx;
  }, [feed, lastSeenId]);

  const markSeen = useCallback(() => {
    const topId = feed[0]?.id;
    if (topId == null) return;
    const asStr = String(topId);
    writeLastSeenId(asStr);
    setLastSeenId(asStr);
  }, [feed]);

  const toggle = useCallback(() => {
    setOpen((prev) => {
      const next = !prev;
      if (next) markSeen();
      return next;
    });
  }, [markSeen]);

  useEffect(() => {
    if (!open) return;
    const onClick = (e: MouseEvent) => {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setOpen(false);
    };
    document.addEventListener('mousedown', onClick);
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('mousedown', onClick);
      document.removeEventListener('keydown', onKey);
    };
  }, [open]);

  const viewAll = () => {
    setOpen(false);
    navigate('/super-admin/audit');
  };

  return (
    <div ref={rootRef} className={cn('relative', className)}>
      <button
        type="button"
        aria-label={unreadCount > 0 ? `Notifications, ${unreadCount} unread` : 'Notifications'}
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={toggle}
        className="relative p-2 rounded-lg text-text-muted hover:text-text-main hover:bg-surface-hover transition-colors"
      >
        <Bell className="w-5 h-5" />
        {unreadCount > 0 && (
          <span
            className="absolute top-1 right-1 min-w-[16px] h-[16px] px-1 rounded-full bg-danger text-white text-[10px] font-bold leading-[16px] tabular-nums ring-2 ring-surface"
            aria-hidden
          >
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {open && (
        <div
          role="menu"
          className="absolute right-0 mt-2 w-[22rem] max-w-[calc(100vw-2rem)] rounded-xl border border-border bg-surface shadow-xl overflow-hidden z-20"
        >
          <div className="flex items-center justify-between px-4 py-3 border-b border-border">
            <div className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]" aria-hidden />
              <span className="text-xs font-semibold uppercase tracking-wider text-text-main">
                Recent Activity
              </span>
            </div>
            <span className="text-[11px] text-text-muted tabular-nums">
              {feed.length} event{feed.length === 1 ? '' : 's'}
            </span>
          </div>

          {visible.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-2 px-4 py-8 text-center">
              <div className="w-10 h-10 rounded-lg bg-surface-hover text-text-muted flex items-center justify-center">
                <Inbox className="w-5 h-5" />
              </div>
              <p className="text-sm text-text-main">No recent activity</p>
              <p className="text-xs text-text-muted">New events will appear here as the platform runs.</p>
            </div>
          ) : (
            <ul className="flex flex-col max-h-[60vh] overflow-y-auto">
              {visible.map((event) => {
                const { Icon, tone, family } = iconFor(event);
                return (
                  <li
                    key={event.id}
                    className={cn(
                      'flex items-start gap-3 px-4 py-3 border-b border-border/60 last:border-b-0 hover:bg-surface-hover/50 transition-colors',
                      event.isAlert && 'border-l-2 border-danger',
                    )}
                  >
                    <div
                      className={cn(
                        'w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ring-1',
                        tone,
                      )}
                    >
                      <Icon className="w-4 h-4" />
                    </div>
                    <div className="min-w-0 flex-1 flex flex-col gap-0.5">
                      <p
                        className={cn(
                          'text-sm leading-snug',
                          event.isAlert ? 'text-danger font-medium' : 'text-text-main',
                        )}
                      >
                        {event.message}
                      </p>
                      <div className="flex items-center gap-2">
                        <span className="text-[10px] uppercase tracking-widest text-text-muted/80 font-semibold">
                          {family}
                        </span>
                        <span className="w-0.5 h-0.5 rounded-full bg-text-muted/40" aria-hidden />
                        <span className="text-[10px] text-text-muted truncate">
                          {event.type.replace(/_/g, ' ')}
                        </span>
                      </div>
                    </div>
                    <span className="text-xs text-text-muted tabular-nums pt-0.5 flex-shrink-0">
                      {event.time}
                    </span>
                  </li>
                );
              })}
            </ul>
          )}

          <button
            type="button"
            onClick={viewAll}
            className="w-full px-4 py-2.5 text-xs font-semibold text-[var(--color-sa-accent)] hover:bg-surface-hover transition-colors border-t border-border"
          >
            View all in Audit Log →
          </button>
        </div>
      )}
    </div>
  );
}
