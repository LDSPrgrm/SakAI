package usecase_test

import (
	"context"
	"testing"
	"time"

	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/internal/usecase"
	"go.uber.org/mock/gomock"
)

func TestPromotionUseCase_ValidateCode_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	repo := mocks.NewMockPromotionRepository(ctrl)
	uc := usecase.NewPromotionUseCase(repo)

	code := "SAVE10"
	promo := &domain.Promotion{
		Code:      code,
		ExpiresAt: time.Now().Add(1 * time.Hour),
	}

	repo.EXPECT().GetByCode(gomock.Any(), code).Return(promo, nil)

	validated, err := uc.ValidateCode(context.Background(), code, nil)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if validated.Code != code {
		t.Errorf("expected code %s, got %s", code, validated.Code)
	}
}

func TestPromotionUseCase_ValidateCode_Expired(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	repo := mocks.NewMockPromotionRepository(ctrl)
	uc := usecase.NewPromotionUseCase(repo)

	code := "EXPIRED"
	promo := &domain.Promotion{
		Code:      code,
		ExpiresAt: time.Now().Add(-1 * time.Hour),
	}

	repo.EXPECT().GetByCode(gomock.Any(), code).Return(promo, nil)

	_, err := uc.ValidateCode(context.Background(), code, nil)
	if err != domain.ErrPromotionExpired {
		t.Errorf("expected ErrPromotionExpired, got %v", err)
	}
}

func TestPromotionUseCase_ValidateCode_MinAmountNotMet(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	repo := mocks.NewMockPromotionRepository(ctrl)
	uc := usecase.NewPromotionUseCase(repo)

	code := "MIN100"
	minAmount := 100.0
	promo := &domain.Promotion{
		Code:          code,
		ExpiresAt:     time.Now().Add(1 * time.Hour),
		MinRideAmount: &minAmount,
	}

	repo.EXPECT().GetByCode(gomock.Any(), code).Return(promo, nil)

	rideFare := 50.0
	_, err := uc.ValidateCode(context.Background(), code, &rideFare)
	if err != domain.ErrPromotionMinAmountNotMet {
		t.Errorf("expected ErrPromotionMinAmountNotMet, got %v", err)
	}
}
