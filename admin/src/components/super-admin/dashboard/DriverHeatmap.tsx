// Driver supply heatmap placeholder — spec superadmin.md §4.1 Charts
// Renders a basic visual until Google Maps / Mapbox GL JS is integrated.
// Color gradient: red (low density) → green (high density).
import React from 'react';
import { MapPin } from 'lucide-react';
import { cn } from '@/lib/utils';

interface DriverHeatmapProps {
  className?: string;
}

export function DriverHeatmap({ className }: DriverHeatmapProps) {
  return (
    <div
      className={cn(
        'bg-surface border border-border rounded-xl p-5 flex flex-col items-center justify-center gap-3 min-h-[200px]',
        className,
      )}
    >
      <MapPin className="w-10 h-10 text-text-muted opacity-40" />
      <div className="text-center">
        <p className="text-sm font-medium text-text-main">Driver Heatmap</p>
        <p className="text-xs text-text-muted mt-1">
          Requires Google Maps API key or Mapbox GL JS integration.<br />
          Configure in{' '}
          <span className="text-primary">System Config → Integrations</span>.
        </p>
      </div>
    </div>
  );
}
