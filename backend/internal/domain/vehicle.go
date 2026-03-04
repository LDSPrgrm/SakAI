package domain

// Vehicle holds a driver's vehicle details.
// Displayed to passengers immediately after a successful match.
type Vehicle struct {
	Make  string `json:"make"`
	Model string `json:"model"`
	Color string `json:"color"`
	Plate string `json:"plate"`
}
