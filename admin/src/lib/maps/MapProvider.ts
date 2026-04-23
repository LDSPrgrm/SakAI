import type React from 'react';
import type { Bounds, LatLng, SurgeZone } from './types';

// MapProvider is the minimal interface the UI needs to render heatmaps and
// edit polygons. The SVG implementation ships by default; Mapbox / Google
// stubs live next to it and can be wired via VITE_MAP_PROVIDER.

export interface PolygonEditorProps {
  value: SurgeZone[];
  bounds: Bounds;
  onChange: (zones: SurgeZone[]) => void;
  selectedIndex: number | null;
  onSelect: (index: number | null) => void;
}

export interface MapProvider {
  id: 'svg' | 'mapbox' | 'google';
  label: string;
  // Polygon editor used by SurgeZoneEditor. Must support adding / deleting
  // vertices and displaying every zone in `value`. Emits the full array on
  // any change so parent form state stays authoritative.
  PolygonEditor: React.FC<PolygonEditorProps>;
}

export type { LatLng, Bounds, SurgeZone };
