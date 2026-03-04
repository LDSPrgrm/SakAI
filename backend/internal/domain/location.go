package domain

// LatLng represents a geographic coordinate pair.
type LatLng struct {
	Lat float64 `json:"lat" binding:"min=-90,max=90"`
	Lng float64 `json:"lng" binding:"min=-180,max=180"`
}
