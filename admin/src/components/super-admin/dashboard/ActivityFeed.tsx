import React, { useState } from 'react';
import { AlertTriangle, Info, Inbox, Shield, type LucideIcon } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EmptyState } from './EmptyState';
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

const SECURITY_TYPES = new Set(['login', 'logout', 'permission', 'role']);

function iconFor(event: FeedEvent): { Icon: LucideIcon; tone: string } {
  if (event.isAlert) return { Icon: AlertTriangle, tone: 'bg-danger/10 text-danger' };
  if (SECURITY_TYPES.has(event.type.toLowerCase())) return { Icon: Shield, tone: 'bg-primary/10 text-primary' };
  return { Icon: Info, tone: 'bg-surface-hover text-text-muted' };
}

export function ActivityFeed({ events, className }: ActivityFeedProps) {
  const [filter, setFilter] = useState<Filter>('all');
  const visible = filter === 'alerts' ? events.filter((e) => e.isAlert) : events;

  return (
    <Card className={cn('flex flex-col', className)}>
      <CardHeader className="flex flex-row items-center justify-between flex-shrink-0">
        <div className="flex items-center gap-3">
          <CardTitle className="text-sm font-semibold uppercase tracking-wide">Recent Activity</CardTitle>
          <span className="text-xs text-text-muted tabular-nums">{events.length} events</span>
        </div>
        <div className="flex rounded-lg overflow-hidden border border-border">
          {(['all', 'alerts'] as Filter[]).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={cn(
                'px-3 py-1 text-xs transition-colors capitalize',
                filter === f
                  ? 'bg-primary text-white'
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
            description={filter === 'alerts' ? 'You are all caught up.' : 'New events will appear here.'}
          />
        ) : (
          <ul className="flex flex-col">
            {visible.map((event) => {
              const { Icon, tone } = iconFor(event);
              const resource = event.type ? event.type.replace(/_/g, ' ') : 'event';
              return (
                <li
                  key={event.id}
                  className={cn(
                    'group flex items-start gap-3 px-2 py-2 rounded-md transition-colors hover:bg-surface-hover/50',
                    event.isAlert && 'border-l-2 border-danger pl-3',
                  )}
                >
                  <div className={cn('w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', tone)}>
                    <Icon className="w-4 h-4" />
                  </div>
                  <div className="min-w-0 flex-1 flex flex-col gap-0.5">
                    <p
                      className={cn(
                        'text-sm leading-snug',
                        event.isAlert ? 'text-danger' : 'text-text-main',
                      )}
                    >
                      {event.message}
                    </p>
                    <p className="text-[10px] uppercase tracking-wide text-text-muted truncate">
                      {resource}
                    </p>
                  </div>
                  <span className="text-xs text-text-muted tabular-nums flex-shrink-0 pt-1">
                    {event.time}
                  </span>
                </li>
              );
            })}
          </ul>
        )}
      </CardContent>
    </Card>
  );
}
