package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// --- Service Area ---

type serviceAreaUseCase struct {
	repo      domain.ServiceAreaRepository
	auditRepo domain.AuditRepository
}

func NewServiceAreaUseCase(repo domain.ServiceAreaRepository, auditRepo domain.AuditRepository) domain.ServiceAreaUseCase {
	return &serviceAreaUseCase{repo: repo, auditRepo: auditRepo}
}

func (uc *serviceAreaUseCase) ListPublic(ctx context.Context) ([]*domain.ServiceArea, error) {
	return uc.repo.ListActive(ctx)
}

func (uc *serviceAreaUseCase) ListAdmin(ctx context.Context) ([]*domain.ServiceArea, error) {
	return uc.repo.ListAll(ctx)
}

func (uc *serviceAreaUseCase) Create(ctx context.Context, actorID uuid.UUID, a *domain.ServiceArea) error {
	if a.Name == "" {
		return errors.New("name is required")
	}
	if len(a.Boundary) == 0 || !json.Valid(a.Boundary) {
		return errors.New("boundary must be valid JSON")
	}
	if err := uc.repo.Create(ctx, a); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "CREATE_SERVICE_AREA",
		ResourceType: "service_area", ResourceID: a.ID.String(),
		AfterState: []byte(fmt.Sprintf(`{"name":%q,"active":%t}`, a.Name, a.Active)),
		IPAddress:  "internal",
	})
	return nil
}

func (uc *serviceAreaUseCase) Update(ctx context.Context, actorID uuid.UUID, a *domain.ServiceArea) error {
	if a.ID == uuid.Nil {
		return errors.New("id is required")
	}
	if len(a.Boundary) > 0 && !json.Valid(a.Boundary) {
		return errors.New("boundary must be valid JSON")
	}
	if err := uc.repo.Update(ctx, a); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE_SERVICE_AREA",
		ResourceType: "service_area", ResourceID: a.ID.String(),
		IPAddress: "internal",
	})
	return nil
}

func (uc *serviceAreaUseCase) Delete(ctx context.Context, actorID, id uuid.UUID) error {
	if err := uc.repo.Delete(ctx, id); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "DELETE_SERVICE_AREA",
		ResourceType: "service_area", ResourceID: id.String(),
		IPAddress: "internal",
	})
	return nil
}

// --- LGU Partnerships ---

type lguPartnershipUseCase struct {
	repo      domain.LGUPartnershipRepository
	auditRepo domain.AuditRepository
}

func NewLGUPartnershipUseCase(repo domain.LGUPartnershipRepository, auditRepo domain.AuditRepository) domain.LGUPartnershipUseCase {
	return &lguPartnershipUseCase{repo: repo, auditRepo: auditRepo}
}

func (uc *lguPartnershipUseCase) List(ctx context.Context) ([]*domain.LGUPartnership, error) {
	return uc.repo.List(ctx)
}

func (uc *lguPartnershipUseCase) Get(ctx context.Context, id uuid.UUID) (*domain.LGUPartnership, error) {
	return uc.repo.GetByID(ctx, id)
}

func (uc *lguPartnershipUseCase) Create(ctx context.Context, actorID uuid.UUID, p *domain.LGUPartnership) error {
	if p.LGUName == "" {
		return errors.New("lgu_name is required")
	}
	if err := uc.repo.Create(ctx, p); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "CREATE_LGU_PARTNERSHIP",
		ResourceType: "lgu_partnership", ResourceID: p.ID.String(),
		AfterState: []byte(fmt.Sprintf(`{"lgu_name":%q,"status":%q}`, p.LGUName, p.Status)),
		IPAddress:  "internal",
	})
	return nil
}

func (uc *lguPartnershipUseCase) Update(ctx context.Context, actorID uuid.UUID, p *domain.LGUPartnership) error {
	if p.ID == uuid.Nil {
		return errors.New("id is required")
	}
	if err := uc.repo.Update(ctx, p); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "UPDATE_LGU_PARTNERSHIP",
		ResourceType: "lgu_partnership", ResourceID: p.ID.String(),
		IPAddress: "internal",
	})
	return nil
}

func (uc *lguPartnershipUseCase) Delete(ctx context.Context, actorID, id uuid.UUID) error {
	if err := uc.repo.Delete(ctx, id); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID: actorID, Action: "DELETE_LGU_PARTNERSHIP",
		ResourceType: "lgu_partnership", ResourceID: id.String(),
		IPAddress: "internal",
	})
	return nil
}
