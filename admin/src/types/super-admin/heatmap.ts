// Driver supply heatmap types — spec superadmin.md §4.1 Charts.
// Frontend-only contract until backend exposes GET /admin/drivers/locations.

export interface DriverPosition {
  driver_id: string;
  lat: number;
  lng: number;
  vehicle_type?: 'motorcycle' | 'car' | 'tricycle';
  is_available?: boolean;
  updated_at?: string;
}

export interface HeatmapBounds {
  north: number;
  south: number;
  east: number;
  west: number;
}

export interface HeatmapResponse {
  positions: DriverPosition[];
  bounds: HeatmapBounds;
  generated_at: string;
}

export const METRO_MANILA_BOUNDS: HeatmapBounds = {
  north: 14.78,
  south: 14.40,
  east:  121.13,
  west:  120.93,
};
