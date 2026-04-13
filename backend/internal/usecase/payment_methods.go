package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// PaymentMethodUseCase defines the operations for managing saved payment methods.
type PaymentMethodUseCase interface {
	ListMethods(ctx context.Context, userID uuid.UUID) ([]*domain.SavedPaymentMethod, error)
	AddMethod(ctx context.Context, userID uuid.UUID, pmType domain.SavedPaymentMethodType, cardToken *string, provider *string, accountID *string, setAsDefault bool) (*domain.SavedPaymentMethod, error)
	RemoveMethod(ctx context.Context, userID uuid.UUID, methodID uuid.UUID) error
	SetDefault(ctx context.Context, userID uuid.UUID, methodID uuid.UUID) (*domain.SavedPaymentMethod, error)
}

type paymentMethodUseCase struct {
	pmRepo        domain.PaymentMethodRepository
	gatewayClient domain.StripeClient
}

// NewPaymentMethodUseCase creates a usecase for saved payment method management.
func NewPaymentMethodUseCase(pmRepo domain.PaymentMethodRepository, gatewayClient domain.StripeClient) PaymentMethodUseCase {
	return &paymentMethodUseCase{
		pmRepo:        pmRepo,
		gatewayClient: gatewayClient,
	}
}

func (uc *paymentMethodUseCase) ListMethods(ctx context.Context, userID uuid.UUID) ([]*domain.SavedPaymentMethod, error) {
	return uc.pmRepo.ListByUserID(ctx, userID)
}

func (uc *paymentMethodUseCase) AddMethod(ctx context.Context, userID uuid.UUID, pmType domain.SavedPaymentMethodType, cardToken *string, provider *string, accountID *string, setAsDefault bool) (*domain.SavedPaymentMethod, error) {
	// Validate type
	if !pmType.IsValid() {
		return nil, domain.ErrNotFound // TODO: Add ErrUnsupportedPaymentMethod
	}

	// Validate type-specific data
	var cardDetails *domain.SavedCardDetails
	var ewalletDetails *domain.SavedEWalletDetails

	switch pmType {
	case domain.SavedPaymentMethodTypeCard:
		if cardToken == nil || *cardToken == "" {
			return nil, fmt.Errorf("card_token is required for card type")
		}
		// In production, call the gateway client to validate the token and get card details.
		// For now, we'd need to integrate with Stripe's SetupIntent API.
		// This is a placeholder - actual implementation would call gateway.
		cardDetails = &domain.SavedCardDetails{
			Last4:       "****", // Would come from gateway response
			ExpiryMonth: 0,
			ExpiryYear:  0,
			Brand:       "Unknown",
		}

	case domain.SavedPaymentMethodTypeEWallet:
		if provider == nil || *provider == "" {
			return nil, fmt.Errorf("provider is required for e_wallet type")
		}
		if accountID == nil || *accountID == "" {
			return nil, fmt.Errorf("account_id is required for e_wallet type")
		}
		ewalletDetails = &domain.SavedEWalletDetails{
			Provider:  *provider,
			AccountID: *accountID,
		}

	case domain.SavedPaymentMethodTypeCash:
		// Cash requires no additional data
	}

	// If this is the first payment method or setAsDefault is true, mark as default
	if setAsDefault {
		// Clear existing defaults
		if err := uc.pmRepo.ClearDefaults(ctx, userID); err != nil {
			return nil, err
		}
	}

	pm := &domain.SavedPaymentMethod{
		ID:        uuid.New(),
		UserID:    userID,
		Type:      pmType,
		IsDefault: setAsDefault,
		Card:      cardDetails,
		EWallet:   ewalletDetails,
		CreatedAt: time.Now(),
	}

	if err := uc.pmRepo.Create(ctx, pm); err != nil {
		return nil, err
	}

	return pm, nil
}

func (uc *paymentMethodUseCase) RemoveMethod(ctx context.Context, userID uuid.UUID, methodID uuid.UUID) error {
	// Verify ownership
	exists, err := uc.pmRepo.ExistsByUser(ctx, methodID, userID)
	if err != nil {
		return err
	}
	if !exists {
		return domain.ErrNotFound
	}

	return uc.pmRepo.Delete(ctx, methodID)
}

func (uc *paymentMethodUseCase) SetDefault(ctx context.Context, userID uuid.UUID, methodID uuid.UUID) (*domain.SavedPaymentMethod, error) {
	// Verify ownership
	exists, err := uc.pmRepo.ExistsByUser(ctx, methodID, userID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, domain.ErrNotFound
	}

	if err := uc.pmRepo.SetDefault(ctx, methodID); err != nil {
		return nil, err
	}

	return uc.pmRepo.GetByID(ctx, methodID)
}
