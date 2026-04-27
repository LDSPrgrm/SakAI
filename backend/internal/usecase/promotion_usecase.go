package usecase

import (
	"context"
	"time"

	"github.com/sakai/backend/internal/domain"
)

type promotionUseCase struct {
	repo domain.PromotionRepository
}

func NewPromotionUseCase(repo domain.PromotionRepository) domain.PromotionUseCase {
	return &promotionUseCase{repo: repo}
}

func (uc *promotionUseCase) ValidateCode(ctx context.Context, code string, rideFare *float64) (*domain.Promotion, error) {
	promo, err := uc.repo.GetByCode(ctx, code)
	if err != nil {
		return nil, err
	}

	if time.Now().After(promo.ExpiresAt) {
		return nil, domain.ErrPromotionExpired
	}

	if rideFare != nil && promo.MinRideAmount != nil && *rideFare < *promo.MinRideAmount {
		return nil, domain.ErrPromotionMinAmountNotMet
	}

	return promo, nil
}

func (uc *promotionUseCase) ListActive(ctx context.Context) ([]*domain.Promotion, error) {
	return uc.repo.ListActive(ctx)
}
