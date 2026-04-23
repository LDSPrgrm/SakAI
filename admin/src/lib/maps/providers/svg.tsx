import React, { useRef } from 'react';
import type { Bounds, MapProvider, PolygonEditorProps, SurgeZone } from '../MapProvider';

// SVG-based polygon editor. Click inside the canvas to add a vertex to the
// selected zone; click an existing vertex to remove it. Intentionally simple
// — the real payoff is that SurgeZoneEditor never imports a map SDK directly
// and swapping to Mapbox / Google is a config flip.

const COLORS = [
  'rgba(239,68,68,0.35)',   // red
  'rgba(234,179,8,0.35)',   // yellow
  'rgba(34,197,94,0.35)',   // green
  'rgba(99,102,241,0.35)',  // indigo
  'rgba(236,72,153,0.35)',  // pink
];

function latLngToSvg(lat: number, lng: number, bounds: Bounds, w: number, h: number) {
  const x = ((lng - bounds.west) / (bounds.east - bounds.west)) * w;
  const y = ((bounds.north - lat) / (bounds.north - bounds.south)) * h;
  return { x, y };
}

function svgToLatLng(x: number, y: number, bounds: Bounds, w: number, h: number) {
  const lng = bounds.west + (x / w) * (bounds.east - bounds.west);
  const lat = bounds.north - (y / h) * (bounds.north - bounds.south);
  return { lat, lng };
}

const SvgPolygonEditor: React.FC<PolygonEditorProps> = ({
  value,
  bounds,
  onChange,
  selectedIndex,
  onSelect,
}) => {
  const svgRef = useRef<SVGSVGElement>(null);
  const W = 640;
  const H = 400;

  function handleClick(e: React.MouseEvent<SVGSVGElement>) {
    if (selectedIndex == null) return;
    if ((e.target as SVGElement).closest('[data-vertex]')) return;
    const rect = svgRef.current?.getBoundingClientRect();
    if (!rect) return;
    const relX = ((e.clientX - rect.left) / rect.width) * W;
    const relY = ((e.clientY - rect.top) / rect.height) * H;
    const { lat, lng } = svgToLatLng(relX, relY, bounds, W, H);
    const next = value.map((z, i) =>
      i === selectedIndex ? { ...z, polygon: [...z.polygon, [lat, lng] as [number, number]] } : z,
    );
    onChange(next);
  }

  function removeVertex(zoneIdx: number, vertIdx: number) {
    const next = value.map((z, i) =>
      i === zoneIdx ? { ...z, polygon: z.polygon.filter((_, j) => j !== vertIdx) } : z,
    );
    onChange(next);
  }

  return (
    <svg
      ref={svgRef}
      viewBox={`0 0 ${W} ${H}`}
      preserveAspectRatio="none"
      className="w-full h-full cursor-crosshair bg-background"
      onClick={handleClick}
    >
      {/* Grid */}
      {Array.from({ length: 9 }).map((_, i) => (
        <line
          key={`v${i}`}
          x1={(W / 8) * i}
          y1={0}
          x2={(W / 8) * i}
          y2={H}
          stroke="rgba(255,255,255,0.04)"
        />
      ))}
      {Array.from({ length: 7 }).map((_, i) => (
        <line
          key={`h${i}`}
          x1={0}
          y1={(H / 6) * i}
          x2={W}
          y2={(H / 6) * i}
          stroke="rgba(255,255,255,0.04)"
        />
      ))}

      {value.map((zone: SurgeZone, idx) => {
        const points = zone.polygon.map(([lat, lng]) => latLngToSvg(lat, lng, bounds, W, H));
        const path =
          points.length === 0
            ? ''
            : `M ${points.map((p) => `${p.x},${p.y}`).join(' L ')} Z`;
        const color = COLORS[idx % COLORS.length];
        const selected = selectedIndex === idx;
        return (
          <g
            key={idx}
            onClick={(e) => {
              e.stopPropagation();
              onSelect(idx);
            }}
          >
            {points.length >= 3 && (
              <path
                d={path}
                fill={color}
                stroke={selected ? 'rgb(59,130,246)' : 'rgba(255,255,255,0.4)'}
                strokeWidth={selected ? 2 : 1}
              />
            )}
            {points.length >= 2 && points.length < 3 && (
              <polyline
                points={points.map((p) => `${p.x},${p.y}`).join(' ')}
                fill="none"
                stroke={selected ? 'rgb(59,130,246)' : 'rgba(255,255,255,0.4)'}
                strokeWidth={1}
              />
            )}
            {points.map((p, vi) => (
              <circle
                key={vi}
                data-vertex
                cx={p.x}
                cy={p.y}
                r={selected ? 5 : 3}
                fill={selected ? 'rgb(59,130,246)' : 'rgba(255,255,255,0.8)'}
                className="cursor-pointer"
                onClick={(e) => {
                  e.stopPropagation();
                  if (selected) removeVertex(idx, vi);
                  else onSelect(idx);
                }}
              />
            ))}
            {points.length > 0 && (
              <text
                x={points[0].x + 6}
                y={points[0].y - 6}
                fill="rgba(255,255,255,0.8)"
                fontSize="11"
              >
                {zone.name} ×{zone.multiplier.toFixed(2)}
              </text>
            )}
          </g>
        );
      })}
    </svg>
  );
};

export const svgMapProvider: MapProvider = {
  id: 'svg',
  label: 'SVG (placeholder)',
  PolygonEditor: SvgPolygonEditor,
};
