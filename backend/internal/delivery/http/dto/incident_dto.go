package dto

type TriggerSOSRequest struct {
	Reason string `json:"reason" binding:"required"`
}
