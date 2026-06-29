package dto

import (
	"time"

	"github.com/sakai/backend/internal/domain"
)

type PromotionResponse struct {
	ID            string    `json:"id"`
	Code          string    `json:"code"`
	Title         *string   `json:"title,omitempty"`
	Description   string    `json:"description"`
	DiscountValue float64   `json:"discount_value"`
	DiscountType  string    `json:"discount_type"`
	MaxDiscount   *float64  `json:"max_discount,omitempty"`
	MinRideAmount *float64  `json:"min_ride_amount,omitempty"`
	ExpiresAt     time.Time `json:"expires_at"`
	Terms         *string   `json:"terms,omitempty"`
}

func NewPromotionResponse(p *domain.Promotion) PromotionResponse {
	resp := PromotionResponse{
		ID:            p.ID.String(),
		Code:          p.Code,
		Description:   p.Description,
		DiscountValue: p.DiscountValue,
		DiscountType:  string(p.DiscountType),
		MaxDiscount:   p.MaxDiscount,
		MinRideAmount: p.MinRideAmount,
		ExpiresAt:     p.ExpiresAt,
		Terms:         p.Terms,
	}
	if p.Title != "" {
		resp.Title = &p.Title
	}
	return resp
}

type PromotionValidateRequest struct {
	Code     string   `json:"code" binding:"required"`
	RideFare *float64 `json:"ride_fare,omitempty"`
}

type PromotionValidationResponse struct {
	Valid          bool    `json:"valid"`
	DiscountAmount float64 `json:"discountAmount,omitempty"`
	Message        string  `json:"message,omitempty"`
}
