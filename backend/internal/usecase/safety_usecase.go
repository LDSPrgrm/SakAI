package usecase

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type safetyUseCase struct {
	safetyRepo domain.SafetyRepository
	auditRepo  domain.AuditRepository
}

func NewSafetyUseCase(safetyRepo domain.SafetyRepository, auditRepo domain.AuditRepository) domain.SafetyUseCase {
	return &safetyUseCase{safetyRepo: safetyRepo, auditRepo: auditRepo}
}

func (uc *safetyUseCase) ListKyc(ctx context.Context) ([]*domain.KycEntry, error) {
	return uc.safetyRepo.ListKyc(ctx)
}

func (uc *safetyUseCase) UpdateKyc(ctx context.Context, actorID, kycID uuid.UUID, status, reason string) error {
	if err := uc.safetyRepo.UpdateKycStatus(ctx, kycID, status, reason); err != nil {
		return err
	}
	after, _ := json.Marshal(map[string]string{"status": status, "reason": reason})
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE", ResourceType: "kyc_submission",
		ResourceID: kycID.String(), AfterState: after, IPAddress: "internal",
	})
	return nil
}

func (uc *safetyUseCase) BatchKyc(ctx context.Context, actorID uuid.UUID, ids []uuid.UUID, status string) (int, error) {
	count := 0
	for _, id := range ids {
		if err := uc.safetyRepo.UpdateKycStatus(ctx, id, status, "batch"); err == nil {
			count++
		}
	}
	after, _ := json.Marshal(map[string]interface{}{"status": status, "count": count})
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "BATCH_UPDATE", ResourceType: "kyc_submission",
		ResourceID: "batch", AfterState: after, IPAddress: "internal",
	})
	return count, nil
}

func (uc *safetyUseCase) GetCompliance(ctx context.Context) (*domain.ComplianceData, error) {
	return uc.safetyRepo.GetCompliance(ctx)
}
