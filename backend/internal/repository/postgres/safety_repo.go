package postgres

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type safetyRepo struct {
	db *pgxpool.Pool //nolint:unused
}

func NewSafetyRepo(db *pgxpool.Pool) domain.SafetyRepository {
	return &safetyRepo{db: db}
}

func (r *safetyRepo) ListKyc(_ context.Context) ([]*domain.KycEntry, error) {
	// Stub: KYC table pending driver onboarding schema
	return []*domain.KycEntry{
		{
			ID: uuid.New(), DriverID: uuid.New(), DriverName: "Ramon Villanueva",
			SubmittedAt: time.Now().Add(-24 * time.Hour),
			Docs:        []string{"drivers_license", "vehicle_registration", "insurance"},
			Status:      "pending",
		},
		{
			ID: uuid.New(), DriverID: uuid.New(), DriverName: "Lorna Bautista",
			SubmittedAt: time.Now().Add(-48 * time.Hour),
			Docs:        []string{"drivers_license", "nbi_clearance", "profile_photo"},
			Status:      "pending",
		},
	}, nil
}

func (r *safetyRepo) UpdateKycStatus(_ context.Context, _ uuid.UUID, _, _ string) error {
	return nil
}

func (r *safetyRepo) GetCompliance(_ context.Context) (*domain.ComplianceData, error) {
	// Stub: LTFRB compliance data pending regulatory integration
	return &domain.ComplianceData{
		AccreditationStatus:  "active",
		AccreditationExpiry:  time.Now().AddDate(1, 0, 0),
		DriverComplianceRate: 94.5,
		ViolationCount:       3,
	}, nil
}
