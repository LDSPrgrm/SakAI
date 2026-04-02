package domain

import "math"

// LatLng represents a geographic coordinate pair.
type LatLng struct {
	Lat float64 `json:"lat" binding:"min=-90,max=90"`
	Lng float64 `json:"lng" binding:"min=-180,max=180"`
}

// DistanceTo calculating the distance between two coordinate pairs (approximate meters).
func (l LatLng) DistanceTo(other LatLng) float64 {
	const EarthRadius = 6371000 // meters
	lat1 := l.Lat * math.Pi / 180
	lat2 := other.Lat * math.Pi / 180
	dLat := (other.Lat - l.Lat) * math.Pi / 180
	dLng := (other.Lng - l.Lng) * math.Pi / 180

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1)*math.Cos(lat2)*
			math.Sin(dLng/2)*math.Sin(dLng/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return EarthRadius * c
}
