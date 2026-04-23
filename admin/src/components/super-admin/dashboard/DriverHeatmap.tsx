// Driver supply heatmap — spec superadmin.md §4.1 Charts.
//
// Renders a provider-agnostic SVG density visualization over the configured
// bounds. Designed for easy swap to Google Maps / Mapbox GL JS later:
//
//   1. Replace `<HeatmapCanvas />` body with `<MapProvider center={...}>`
//      + a heatmap layer fed by the same `positions` prop.
//   2. The hook (`useDriverHeatmap`) and types (`DriverPosition`,
//      `HeatmapBounds`) stay unchanged, so call sites are unaffected.
//   3. Read API key from `import.meta.env.VITE_MAPS_API_KEY` configured via
//      System Config → Integrations.
//
import React, { useMemo } from 'react';
import { MapPin } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useDriverHeatmap } from '@/hooks/useMetrics';
import type { DriverPosition, HeatmapBounds } from '@/types/super-admin/heatmap';
import { METRO_MANILA_BOUNDS } from '@/types/super-admin/heatmap';

interface DriverHeatmapProps {
  positions?: DriverPosition[];
  bounds?: HeatmapBounds;
  loading?: boolean;
  className?: string;
}

const GRID_COLS = 16;
const GRID_ROWS = 10;

function bucketize(positions: DriverPosition[], bounds: HeatmapBounds): number[][] {
  const grid: number[][] = Array.from({ length: GRID_ROWS }, () =>
    Array.from({ length: GRID_COLS }, () => 0),
  );
  const latSpan = bounds.north - bounds.south;
  const lngSpan = bounds.east  - bounds.west;
  if (latSpan <= 0 || lngSpan <= 0) return grid;

  for (const p of positions) {
    if (p.lat < bounds.south || p.lat > bounds.north) continue;
    if (p.lng < bounds.west  || p.lng > bounds.east)  continue;
    const row = Math.min(GRID_ROWS - 1, Math.floor(((bounds.north - p.lat) / latSpan) * GRID_ROWS));
    const col = Math.min(GRID_COLS - 1, Math.floor(((p.lng - bounds.west) / lngSpan) * GRID_COLS));
    grid[row][col] += 1;
  }
  return grid;
}

// Density → color (red low → yellow mid → green high). Empty cells transparent.
function colorForWeight(weight: number, max: number): string {
  if (weight === 0) return 'rgba(255,255,255,0.02)';
  const ratio = max > 0 ? weight / max : 0;
  if (ratio < 0.34) return `rgba(239, 68, 68, ${0.25 + ratio * 1.2})`;   // red-500
  if (ratio < 0.67) return `rgba(234, 179, 8, ${0.4  + ratio * 0.6})`;    // yellow-500
  return `rgba(34, 197, 94, ${0.5 + ratio * 0.4})`;                        // green-500
}

interface CanvasProps {
  positions: DriverPosition[];
  bounds: HeatmapBounds;
}

function HeatmapCanvas({ positions, bounds }: CanvasProps) {
  const grid = useMemo(() => bucketize(positions, bounds), [positions, bounds]);
  const max  = useMemo(() => grid.reduce((m, row) => Math.max(m, ...row), 0), [grid]);

  return (
    <svg viewBox={`0 0 ${GRID_COLS} ${GRID_ROWS}`} preserveAspectRatio="none" className="w-full h-full">
      {grid.map((row, r) =>
        row.map((weight, c) => (
          <rect
            key={`${r}-${c}`}
            x={c}
            y={r}
            width={1}
            height={1}
            fill={colorForWeight(weight, max)}
          />
        )),
      )}
    </svg>
  );
}

export function DriverHeatmap({
  positions: positionsProp,
  bounds: boundsProp,
  loading: loadingProp,
  className,
}: DriverHeatmapProps) {
  const query = useDriverHeatmap();
  const positions = positionsProp ?? query.data?.positions ?? [];
  const bounds    = boundsProp    ?? query.data?.bounds    ?? METRO_MANILA_BOUNDS;
  const loading   = loadingProp ?? query.isLoading;

  return (
    <div
      className={cn(
        'bg-surface border border-border rounded-xl p-4 flex flex-col gap-3 min-h-[260px]',
        className,
      )}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <MapPin className="w-4 h-4 text-primary" />
          <h3 className="text-sm font-semibold text-text-main">Driver Heatmap</h3>
        </div>
        <span className="text-xs text-text-muted">
          {loading ? 'Loading…' : `${positions.length} drivers · Metro Manila`}
        </span>
      </div>

      <div className="relative flex-1 rounded-lg overflow-hidden bg-background border border-border min-h-[200px]">
        <HeatmapCanvas positions={positions} bounds={bounds} />
        {positions.length === 0 && !loading && (
          <div className="absolute inset-0 flex items-center justify-center text-xs text-text-muted">
            No driver positions available
          </div>
        )}
      </div>

      <div className="flex items-center gap-3 text-xs text-text-muted">
        <span className="flex items-center gap-1">
          <span className="w-2 h-2 rounded-sm" style={{ background: 'rgba(239,68,68,0.7)' }} /> Low
        </span>
        <span className="flex items-center gap-1">
          <span className="w-2 h-2 rounded-sm" style={{ background: 'rgba(234,179,8,0.7)' }} /> Mid
        </span>
        <span className="flex items-center gap-1">
          <span className="w-2 h-2 rounded-sm" style={{ background: 'rgba(34,197,94,0.7)' }} /> High
        </span>
        <span className="ml-auto italic">Map provider not configured — density grid only</span>
      </div>
    </div>
  );
}
