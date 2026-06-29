package domain

import (
	"time"

	"github.com/google/uuid"
)

type PromotionDiscountType string

const (
	PromotionDiscountTypePercentage PromotionDiscountType = "percentage"
	PromotionDiscountTypeFixed      PromotionDiscountType = "fixed"
)

type Promotion struct {
	ID            uuid.UUID             `json:"id"`
	Code          string                `json:"code"`
	Title         string                `json:"title"`
	Description   string                `json:"description"`
	DiscountValue float64               `json:"discountValue"`
	DiscountType  PromotionDiscountType `json:"discountType"`
	MaxDiscount   *float64              `json:"maxDiscount,omitempty"`
	MinRideAmount *float64              `json:"minRideAmount,omitempty"`
	ExpiresAt     time.Time             `json:"expiresAt"`
	Terms         *string               `json:"terms,omitempty"`
	CreatedAt     time.Time             `json:"createdAt"`
}
