import React, { useState } from 'react';
import { Calendar } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { cn } from '@/lib/utils';

export type DatePreset = '7d' | '30d' | '90d' | 'custom';

export interface DateRange {
  from: Date;
  to: Date;
  preset: DatePreset;
}

interface DateRangePickerProps {
  value: DateRange;
  onChange: (range: DateRange) => void;
  className?: string;
}

const PRESETS: { label: string; value: DatePreset; days: number }[] = [
  { label: '7 days', value: '7d', days: 7 },
  { label: '30 days', value: '30d', days: 30 },
  { label: '90 days', value: '90d', days: 90 },
];

function subtractDays(d: Date, days: number): Date {
  const result = new Date(d);
  result.setDate(result.getDate() - days);
  return result;
}

export function getDefaultRange(preset: DatePreset = '30d'): DateRange {
  const to = new Date();
  const days = preset === '7d' ? 7 : preset === '90d' ? 90 : 30;
  return { from: subtractDays(to, days), to, preset };
}

export function DateRangePicker({ value, onChange, className }: DateRangePickerProps) {
  const [showCustom, setShowCustom] = useState(false);

  const handlePreset = (preset: (typeof PRESETS)[0]) => {
    const to = new Date();
    onChange({ from: subtractDays(to, preset.days), to, preset: preset.value });
    setShowCustom(false);
  };

  const fmtDate = (d: Date) => d.toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' });

  return (
    <div className={cn('flex items-center gap-2 flex-wrap', className)}>
      <div className="flex items-center gap-1.5 text-sm text-text-muted bg-surface border border-border rounded-lg px-3 py-1.5">
        <Calendar className="w-4 h-4" />
        <span>{fmtDate(value.from)} – {fmtDate(value.to)}</span>
      </div>
      <div className="flex gap-1">
        {PRESETS.map((p) => (
          <Button
            key={p.value}
            variant={value.preset === p.value ? 'primary' : 'ghost'}
            size="sm"
            onClick={() => handlePreset(p)}
          >
            {p.label}
          </Button>
        ))}
        <Button
          variant={value.preset === 'custom' ? 'primary' : 'ghost'}
          size="sm"
          onClick={() => setShowCustom(!showCustom)}
        >
          Custom
        </Button>
      </div>
      {showCustom && (
        <div className="flex items-center gap-2 text-sm">
          <input
            type="date"
            className="bg-surface border border-border rounded-lg px-2 py-1 text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            value={value.from.toISOString().slice(0, 10)}
            onChange={(e) => onChange({ ...value, from: new Date(e.target.value), preset: 'custom' })}
          />
          <span className="text-text-muted">to</span>
          <input
            type="date"
            className="bg-surface border border-border rounded-lg px-2 py-1 text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            value={value.to.toISOString().slice(0, 10)}
            onChange={(e) => onChange({ ...value, to: new Date(e.target.value), preset: 'custom' })}
          />
        </div>
      )}
    </div>
  );
}
