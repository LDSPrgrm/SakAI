// Map provider type primitives. Kept decoupled from any specific vendor so
// DriverHeatmap / SurgeZoneEditor can consume the `MapProvider` interface
// and the actual renderer is swapped via `src/lib/maps/index.ts`.

export interface LatLng {
  lat: number;
  lng: number;
}

export interface Bounds {
  north: number;
  south: number;
  east: number;
  west: number;
}

// Stored shape matches backend usecase.SurgeZone JSON form. Polygon is a
// ring of [lat, lng] pairs, optionally closed.
export interface SurgeZone {
  name: string;
  multiplier: number;
  polygon: [number, number][];
}
