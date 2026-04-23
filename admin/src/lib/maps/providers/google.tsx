import type React from 'react';
import type { MapProvider, PolygonEditorProps } from '../MapProvider';

// Stub: wire up `@react-google-maps/api` DrawingManager here to swap the SVG
// editor for Google Maps. Interface parity with svgMapProvider.PolygonEditor
// is required.
const NotImplemented: React.FC<PolygonEditorProps> = () => null;

export const googleMapProvider: MapProvider = {
  id: 'google',
  label: 'Google Maps (stub)',
  PolygonEditor: NotImplemented,
};
