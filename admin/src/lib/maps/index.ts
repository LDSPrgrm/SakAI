import { svgMapProvider } from './providers/svg';
import { mapboxMapProvider } from './providers/mapbox';
import { googleMapProvider } from './providers/google';
import type { MapProvider } from './MapProvider';

// Picks the active MapProvider at module load. Override via
// VITE_MAP_PROVIDER=svg|mapbox|google in .env. The stubs are exported so
// future code can target them explicitly when needed.
function resolve(): MapProvider {
  const kind = (import.meta.env.VITE_MAP_PROVIDER as string | undefined) ?? 'svg';
  if (kind === 'mapbox') return mapboxMapProvider;
  if (kind === 'google') return googleMapProvider;
  return svgMapProvider;
}

export const activeMapProvider = resolve();

export { svgMapProvider, mapboxMapProvider, googleMapProvider };
export type { MapProvider } from './MapProvider';
export type { LatLng, Bounds, SurgeZone } from './types';
