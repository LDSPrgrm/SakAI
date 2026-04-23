package usecase

import (
	"encoding/json"

	"github.com/sakai/backend/internal/domain"
)

// SurgeZone is a named polygon with a surge multiplier. Stored inside
// surge_configs.zones as a JSON array so existing rows decode cleanly without
// a schema migration. Polygon is a ring of [lat, lng] pairs — closed ring
// (first == last) optional; the point-in-polygon check closes it on the fly.
type SurgeZone struct {
	Name       string      `json:"name"`
	Multiplier float64     `json:"multiplier"`
	Polygon    [][]float64 `json:"polygon"`
}

// ParseSurgeZones decodes the JSONB blob stored on SurgeConfig.Zones. Empty
// or invalid JSON returns nil — callers should fall back to the global
// multiplier.
func ParseSurgeZones(raw []byte) []SurgeZone {
	if len(raw) == 0 {
		return nil
	}
	var zones []SurgeZone
	if err := json.Unmarshal(raw, &zones); err != nil {
		return nil
	}
	return zones
}

// FindZoneMultiplier returns the first zone that contains origin plus its
// multiplier. Matches are evaluated in zone-array order so the UI can express
// precedence by ordering. Returns ("", 0, false) when origin is outside every
// polygon, letting the caller skip zone pricing.
func FindZoneMultiplier(zones []SurgeZone, origin domain.LatLng) (string, float64, bool) {
	for _, z := range zones {
		if len(z.Polygon) < 3 {
			continue
		}
		if pointInPolygon(origin.Lat, origin.Lng, z.Polygon) {
			return z.Name, z.Multiplier, true
		}
	}
	return "", 0, false
}

// pointInPolygon runs the standard ray-casting test. Treats polygon as a
// closed ring — no need for callers to repeat the first vertex.
func pointInPolygon(lat, lng float64, polygon [][]float64) bool {
	inside := false
	n := len(polygon)
	j := n - 1
	for i := 0; i < n; i++ {
		if len(polygon[i]) < 2 || len(polygon[j]) < 2 {
			j = i
			continue
		}
		yi, xi := polygon[i][0], polygon[i][1]
		yj, xj := polygon[j][0], polygon[j][1]
		// Ray cast: edge straddles the horizontal line through (lat,lng) and
		// intersects to the east.
		if ((yi > lat) != (yj > lat)) &&
			(lng < (xj-xi)*(lat-yi)/(yj-yi)+xi) {
			inside = !inside
		}
		j = i
	}
	return inside
}
