package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type safetyRepo struct{ db *pgxpool.Pool }

func NewSafetyRepo(db *pgxpool.Pool) domain.SafetyRepository {
	return &safetyRepo{db: db}
}

// ListKyc returns pending submissions joined with the driver's uploaded docs
// so the review UI can render everything in one pass.
func (r *safetyRepo) ListKyc(ctx context.Context) ([]*domain.KycEntry, error) {
	const q = `
		SELECT s.id, s.driver_id, COALESCE(u.name, ''), s.submitted_at, s.status,
		       COALESCE(
		         (SELECT array_agg(d.document_type ORDER BY d.uploaded_at)
		          FROM driver_documents d
		          WHERE d.submission_id = s.id OR (d.submission_id IS NULL AND d.driver_id = s.driver_id)),
		         ARRAY[]::text[]
		       ) AS docs
		FROM kyc_submissions s
		LEFT JOIN users u ON u.id = s.driver_id
		WHERE s.status IN ('pending', 'needs_more_info')
		ORDER BY s.submitted_at ASC`

	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var entries []*domain.KycEntry
	for rows.Next() {
		e := &domain.KycEntry{}
		if err := rows.Scan(&e.ID, &e.DriverID, &e.DriverName, &e.SubmittedAt, &e.Status, &e.Docs); err != nil {
			return nil, err
		}
		entries = append(entries, e)
	}
	return entries, nil
}

func (r *safetyRepo) UpdateKycStatus(ctx context.Context, id uuid.UUID, status string, reason string) error {
	if status == "" {
		return errors.New("status is required")
	}
	const q = `
		UPDATE kyc_submissions
		SET status = $2,
		    rejection_reason = NULLIF($3, ''),
		    reviewed_at = CASE WHEN $2 IN ('approved','rejected') THEN NOW() ELSE reviewed_at END
		WHERE id = $1`
	tag, err := r.db.Exec(ctx, q, id, status, reason)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// GetCompliance reads the singleton regulatory row. If the compliance_rate
// column is NULL (brand-new deployment) it is derived from the fraction of
// drivers whose documents are all approved.
func (r *safetyRepo) GetCompliance(ctx context.Context) (*domain.ComplianceData, error) {
	const q = `
		SELECT accreditation_status, accreditation_expiry, compliance_rate,
		       violations_open, violations_resolved, last_audit_at
		FROM regulatory_compliance
		WHERE id = 1`

	var (
		status       string
		expiry       *time.Time
		rate         *float64
		openViol     int
		resolvedViol int
		lastAudit    *time.Time
	)
	err := r.db.QueryRow(ctx, q).Scan(&status, &expiry, &rate, &openViol, &resolvedViol, &lastAudit)
	if errors.Is(err, pgx.ErrNoRows) {
		return &domain.ComplianceData{AccreditationStatus: "pending"}, nil
	}
	if err != nil {
		return nil, err
	}

	data := &domain.ComplianceData{
		AccreditationStatus: status,
		ViolationCount:      openViol,
		ViolationsOpen:      openViol,
		ViolationsResolved:  resolvedViol,
		LastAuditAt:         lastAudit,
	}
	if expiry != nil {
		data.AccreditationExpiry = *expiry
	}

	if rate != nil {
		data.DriverComplianceRate = *rate
	} else {
		const qRate = `
			SELECT CASE WHEN active_count = 0 THEN 0
			            ELSE 100.0 * approved_count / active_count
			       END
			FROM (
				SELECT
					(SELECT COUNT(*) FROM users WHERE role = 'driver') AS active_count,
					(SELECT COUNT(DISTINCT s.driver_id) FROM kyc_submissions s WHERE s.status = 'approved') AS approved_count
			) t`
		var derived float64
		if err := r.db.QueryRow(ctx, qRate).Scan(&derived); err == nil {
			data.DriverComplianceRate = derived
		}
	}
	return data, nil
}
