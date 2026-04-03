package usecase

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type paymentUseCase struct {
	paymentRepo domain.PaymentRepository
	auditRepo   domain.AuditRepository
}

func NewPaymentUseCase(paymentRepo domain.PaymentRepository, auditRepo domain.AuditRepository) domain.PaymentUseCase {
	return &paymentUseCase{paymentRepo: paymentRepo, auditRepo: auditRepo}
}

func (uc *paymentUseCase) ListTransactions(ctx context.Context, page, limit int) ([]*domain.Transaction, int, error) {
	return uc.paymentRepo.ListTransactions(ctx, page, limit)
}

func (uc *paymentUseCase) GetSummary(ctx context.Context) (*domain.PaymentSummary, error) {
	return uc.paymentRepo.GetPaymentSummary(ctx)
}

func (uc *paymentUseCase) ListPayouts(ctx context.Context) ([]*domain.DriverPayout, error) {
	return uc.paymentRepo.ListPayouts(ctx)
}

func (uc *paymentUseCase) ApprovePayout(ctx context.Context, actorID, payoutID uuid.UUID) error {
	if err := uc.paymentRepo.ApprovePayout(ctx, payoutID); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "APPROVE", ResourceType: "driver_payout",
		ResourceID: payoutID.String(), IPAddress: "internal",
	})
	return nil
}

func (uc *paymentUseCase) BatchApprovePayouts(ctx context.Context, actorID uuid.UUID, ids []uuid.UUID) (int, error) {
	count := 0
	for _, id := range ids {
		if err := uc.paymentRepo.ApprovePayout(ctx, id); err == nil {
			count++
		}
	}
	idStrs := make([]string, len(ids))
	for i, id := range ids {
		idStrs[i] = id.String()
	}
	after, _ := json.Marshal(map[string]interface{}{"approved_ids": idStrs, "count": count})
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "BATCH_APPROVE", ResourceType: "driver_payout",
		ResourceID: "batch", AfterState: after, IPAddress: "internal",
	})
	return count, nil
}

func (uc *paymentUseCase) GetGatewayConfigs(ctx context.Context) ([]*domain.PaymentGatewayConfig, error) {
	return uc.paymentRepo.GetGatewayConfigs(ctx)
}

func (uc *paymentUseCase) UpdateGatewayConfig(ctx context.Context, actorID uuid.UUID, config *domain.PaymentGatewayConfig) error {
	config.UpdatedBy = actorID
	if err := uc.paymentRepo.UpdateGatewayConfig(ctx, config); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "payment_gateway_config",
		ResourceID: config.Provider, IPAddress: "internal",
	})
	return nil
}

func (uc *paymentUseCase) GetCommissionSettings(ctx context.Context) ([]*domain.CommissionSettings, error) {
	return uc.paymentRepo.GetCommissionSettings(ctx)
}

func (uc *paymentUseCase) UpdateCommissionSettings(ctx context.Context, actorID uuid.UUID, settings *domain.CommissionSettings) error {
	settings.UpdatedBy = actorID
	if err := uc.paymentRepo.UpdateCommissionSettings(ctx, settings); err != nil {
		return err
	}
	after, _ := json.Marshal(settings)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "commission_settings",
		ResourceID: settings.VehicleType, AfterState: after, IPAddress: "internal",
	})
	return nil
}
