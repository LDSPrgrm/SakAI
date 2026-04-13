package domain

// VehicleType represents the category of a vehicle.
type VehicleType string

const (
	VehicleTypeMotorcycle VehicleType = "motorcycle"
	VehicleTypeCar        VehicleType = "car"
	VehicleTypeTricycle   VehicleType = "tricycle"
)

// Vehicle holds a driver's vehicle details.
// Displayed to passengers immediately after a successful match.
type Vehicle struct {
	Make        string      `json:"make"`
	Model       string      `json:"model"`
	Color       string      `json:"color"`
	Plate       string      `json:"plate"`
	VehicleType VehicleType `json:"vehicle_type"`
}
