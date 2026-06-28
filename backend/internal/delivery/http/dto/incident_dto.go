package dto

type TriggerSOSRequest struct {
	Reason string `json:"reason" binding:"required"`
}

// IncidentLocationRequest is the body for `POST /incidents/:incidentId/location`.
// Kept minimal so the route stays usable on flaky cellular links — clients
// can omit recorded_at_client and let the server stamp the time.
type IncidentLocationRequest struct {
	Lat float64 `json:"lat" binding:"required"`
	Lng float64 `json:"lng" binding:"required"`
}
