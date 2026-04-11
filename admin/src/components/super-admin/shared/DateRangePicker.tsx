import React, { useState } from 'react';
import { CalendarDays } from 'lucide-react';
import { cn } from '@/lib/utils';

export interface DateRange {
  from: string; // ISO date string
  to:   string;
}

interface DateRangePickerProps {
  value?: DateRange;
  onChange: (range: DateRange) => void;
  className?: string;
}

export function DateRangePicker({ value, onChange, className }: DateRangePickerProps) {
  const [from, setFrom] = useState(value?.from ?? '');
  const [to,   setTo]   = useState(value?.to   ?? '');

  const commit = (newFrom: string, newTo: string) => {
    if (newFrom && newTo) onChange({ from: newFrom, to: newTo });
  };

  return (
    <div className={cn('flex items-center gap-2', className)}>
      <CalendarDays className="w-4 h-4 text-text-muted flex-shrink-0" />
      <input
        type="date"
        value={from}
        onChange={(e) => { setFrom(e.target.value); commit(e.target.value, to); }}
        className="bg-surface border border-border rounded px-2 py-1 text-sm text-text-main focus:outline-none focus:border-primary"
      />
      <span className="text-text-muted text-sm">–</span>
      <input
        type="date"
        value={to}
        min={from}
        onChange={(e) => { setTo(e.target.value); commit(from, e.target.value); }}
        className="bg-surface border border-border rounded px-2 py-1 text-sm text-text-main focus:outline-none focus:border-primary"
      />
    </div>
  );
}
