import React, { useEffect, useState } from 'react';

export function secondsAgo(input: Date | number | undefined | null): string {
  if (input == null) return 'never';
  const ms = input instanceof Date ? input.getTime() : input;
  if (!Number.isFinite(ms) || ms <= 0) return 'never';
  const diff = Math.max(0, Math.floor((Date.now() - ms) / 1000));
  if (diff < 5) return 'just now';
  if (diff < 60) return `${diff}s ago`;
  const mins = Math.floor(diff / 60);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  return `${hrs}h ago`;
}

export interface UpdatedAgoProps {
  timestamp: Date | number | undefined | null;
  prefix?: string;
  className?: string;
}

export function UpdatedAgo({ timestamp, prefix = 'Updated', className }: UpdatedAgoProps) {
  const [, setTick] = useState(0);
  useEffect(() => {
    const id = window.setInterval(() => setTick((n) => n + 1), 1000);
    return () => window.clearInterval(id);
  }, []);
  const label = secondsAgo(timestamp);
  return React.createElement(
    'span',
    {
      className: className ?? 'text-xs text-text-muted tabular-nums',
      title: timestamp ? new Date(typeof timestamp === 'number' ? timestamp : timestamp.getTime()).toISOString() : undefined,
    },
    `${prefix} ${label}`,
  );
}
