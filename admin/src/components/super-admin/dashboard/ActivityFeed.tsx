import React, { useState } from 'react';
import { Inbox, ChevronRight, ChevronDown } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
import { cn } from '@/lib/utils';
import { iconFor, type FeedEvent } from '@/components/super-admin/shared/activityMeta';

export type { FeedEvent };

type Filter = 'all' | 'alerts';

interface ActivityFeedProps {
  events: FeedEvent[];
  className?: string;
  initialVisible?: number;
}

export function ActivityFeed({ events, className, initialVisible = 6 }: ActivityFeedProps) {
  const [filter, setFilter] = useState<Filter>('all');
  const [expanded, setExpanded] = useState(false);

  const filtered = filter === 'alerts' ? events.filter((e) => e.isAlert) : events;
  const hasOverflow = filtered.length > initialVisible;
  const visible = expanded || !hasOverflow ? filtered : filtered.slice(0, initialVisible);
  const hiddenCount = filtered.length - visible.length;

  return (
    <Card className={cn('flex flex-col', className)}>
      <CardHeader className="flex flex-row items-center justify-between flex-shrink-0">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]" aria-hidden />
            <CardTitle className="text-sm font-semibold uppercase tracking-wider">Recent Activity</CardTitle>
          </div>
          <span className="text-xs text-text-muted tabular-nums">{events.length} events</span>
        </div>
        <div className="flex rounded-lg overflow-hidden border border-border bg-background">
          {(['all', 'alerts'] as Filter[]).map((f) => (
            <button
              type="button"
              key={f}
              onClick={() => { setFilter(f); setExpanded(false); }}
              className={cn(
                'px-3 py-1 text-xs transition-colors capitalize font-medium',
                filter === f
                  ? 'bg-[var(--color-sa-accent)] text-black'
                  : 'text-text-muted hover:text-text-main hover:bg-surface-hover',
              )}
            >
              {f}
            </button>
          ))}
        </div>
      </CardHeader>
      <CardContent className="p-3 flex-1 min-h-0">
        {visible.length === 0 ? (
          <EmptyState
            icon={Inbox}
            title={filter === 'alerts' ? 'No alerts' : 'No recent activity'}
            description={filter === 'alerts' ? 'You are all caught up.' : 'New events will appear here as the platform runs.'}
          />
        ) : (
          <>
            <ul className="flex flex-col">
              {visible.map((event) => {
                const { Icon, tone, family } = iconFor(event);
                return (
                  <li
                    key={event.id}
                    className={cn(
                      'group flex items-start gap-3 px-2 py-2.5 rounded-md transition-colors hover:bg-surface-hover/50 cursor-default',
                      event.isAlert && 'border-l-2 border-danger pl-3',
                    )}
                  >
                    <div className={cn('w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ring-1', tone)}>
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
                    <div className="flex items-center gap-1 flex-shrink-0 pt-1">
                      <span className="text-xs text-text-muted tabular-nums">{event.time}</span>
                      <ChevronRight className="w-3.5 h-3.5 text-text-muted opacity-0 group-hover:opacity-100 transition-opacity" />
                    </div>
                  </li>
                );
              })}
            </ul>

            {hasOverflow && (
              <button
                type="button"
                onClick={() => setExpanded((v) => !v)}
                className="mt-2 w-full flex items-center justify-center gap-1.5 px-3 py-2 rounded-md text-xs font-semibold text-text-muted hover:text-[var(--color-sa-accent)] hover:bg-surface-hover/50 transition-colors border-t border-border/60 pt-3"
              >
                {expanded ? (
                  <>
                    Show less
                    <ChevronDown className="w-3.5 h-3.5 rotate-180 transition-transform" />
                  </>
                ) : (
                  <>
                    Show {hiddenCount} more
                    <ChevronDown className="w-3.5 h-3.5 transition-transform" />
                  </>
                )}
              </button>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}
