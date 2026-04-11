// Real-time activity feed — spec superadmin.md §4.1 Activity Feed
// Filterable event stream: sign-ups, SOS, payment failures, AC1 violations, API alerts.
import React, { useState } from 'react';
import { AlertTriangle, Info } from 'lucide-react';
import { cn } from '@/lib/utils';

export interface FeedEvent {
  id: string | number;
  type: string;
  message: string;
  time: string;
  isAlert: boolean;
}

type Filter = 'all' | 'alerts';

interface ActivityFeedProps {
  events: FeedEvent[];
  className?: string;
}

export function ActivityFeed({ events, className }: ActivityFeedProps) {
  const [filter, setFilter] = useState<Filter>('all');

  const visible = filter === 'alerts' ? events.filter((e) => e.isAlert) : events;

  return (
    <div className={cn('bg-surface border border-border rounded-xl p-5 flex flex-col gap-3', className)}>
      <div className="flex items-center justify-between">
        <p className="text-sm font-semibold text-text-main">Live Activity</p>
        <div className="flex rounded-lg overflow-hidden border border-border">
          {(['all', 'alerts'] as Filter[]).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={cn(
                'px-3 py-1 text-xs transition-colors capitalize',
                filter === f ? 'bg-primary text-white' : 'text-text-muted hover:text-text-main',
              )}
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      <ul className="space-y-2 max-h-72 overflow-y-auto">
        {visible.length === 0 && (
          <li className="text-xs text-text-muted text-center py-4">No events</li>
        )}
        {visible.map((event) => (
          <li key={event.id} className="flex items-start gap-2">
            {event.isAlert ? (
              <AlertTriangle className="w-4 h-4 text-warning flex-shrink-0 mt-0.5" />
            ) : (
              <Info className="w-4 h-4 text-text-muted flex-shrink-0 mt-0.5" />
            )}
            <div className="flex-1 min-w-0">
              <p className="text-xs text-text-main leading-snug">{event.message}</p>
              <p className="text-[10px] text-text-muted mt-0.5">{event.time}</p>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
