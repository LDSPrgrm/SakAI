import type React from 'react';
import type { MapProvider, PolygonEditorProps } from '../MapProvider';

// Stub: wire up `mapbox-gl-draw` inside this component to swap the SVG editor
// for a real map. Interface parity with svgMapProvider.PolygonEditor is
// required; onChange must emit the full SurgeZone[] on any edit.
const NotImplemented: React.FC<PolygonEditorProps> = () => null;

export const mapboxMapProvider: MapProvider = {
  id: 'mapbox',
  label: 'Mapbox (stub)',
  PolygonEditor: NotImplemented,
};
