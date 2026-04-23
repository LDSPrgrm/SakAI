package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type serviceAreaRepo struct{ db *pgxpool.Pool }

func NewServiceAreaRepo(db *pgxpool.Pool) domain.ServiceAreaRepository {
	return &serviceAreaRepo{db: db}
}

func (r *serviceAreaRepo) ListActive(ctx context.Context) ([]*domain.ServiceArea, error) {
	return r.listWhere(ctx, "WHERE active = true ORDER BY name ASC")
}

func (r *serviceAreaRepo) ListAll(ctx context.Context) ([]*domain.ServiceArea, error) {
	return r.listWhere(ctx, "ORDER BY name ASC")
}

func (r *serviceAreaRepo) listWhere(ctx context.Context, suffix string) ([]*domain.ServiceArea, error) {
	q := `SELECT id, name, COALESCE(lgu_code,''), boundary, active, created_at, updated_at FROM service_areas ` + suffix
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]*domain.ServiceArea, 0)
	for rows.Next() {
		a := &domain.ServiceArea{}
		if err := rows.Scan(&a.ID, &a.Name, &a.LGUCode, &a.Boundary, &a.Active, &a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

func (r *serviceAreaRepo) Create(ctx context.Context, a *domain.ServiceArea) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	const q = `
		INSERT INTO service_areas (id, name, lgu_code, boundary, active, created_at, updated_at)
		VALUES ($1, $2, NULLIF($3,''), $4, $5, NOW(), NOW())`
	_, err := r.db.Exec(ctx, q, a.ID, a.Name, a.LGUCode, a.Boundary, a.Active)
	return err
}

func (r *serviceAreaRepo) Update(ctx context.Context, a *domain.ServiceArea) error {
	const q = `
		UPDATE service_areas
		SET name = $2, lgu_code = NULLIF($3,''), boundary = $4, active = $5, updated_at = NOW()
		WHERE id = $1`
	tag, err := r.db.Exec(ctx, q, a.ID, a.Name, a.LGUCode, a.Boundary, a.Active)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *serviceAreaRepo) Delete(ctx context.Context, id uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM service_areas WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// --- LGU partnerships ---

type lguPartnershipRepo struct{ db *pgxpool.Pool }

func NewLGUPartnershipRepo(db *pgxpool.Pool) domain.LGUPartnershipRepository {
	return &lguPartnershipRepo{db: db}
}

func (r *lguPartnershipRepo) List(ctx context.Context) ([]*domain.LGUPartnership, error) {
	const q = `
		SELECT id, service_area_id, lgu_name, COALESCE(contact_name,''),
		       COALESCE(contact_email,''), COALESCE(contact_phone,''),
		       agreement_start, agreement_end, status, COALESCE(notes,''),
		       created_at, updated_at
		FROM lgu_partnerships
		ORDER BY lgu_name ASC`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]*domain.LGUPartnership, 0)
	for rows.Next() {
		p := &domain.LGUPartnership{}
		if err := rows.Scan(&p.ID, &p.ServiceAreaID, &p.LGUName, &p.ContactName,
			&p.ContactEmail, &p.ContactPhone, &p.AgreementStart, &p.AgreementEnd,
			&p.Status, &p.Notes, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (r *lguPartnershipRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.LGUPartnership, error) {
	const q = `
		SELECT id, service_area_id, lgu_name, COALESCE(contact_name,''),
		       COALESCE(contact_email,''), COALESCE(contact_phone,''),
		       agreement_start, agreement_end, status, COALESCE(notes,''),
		       created_at, updated_at
		FROM lgu_partnerships WHERE id = $1`
	p := &domain.LGUPartnership{}
	err := r.db.QueryRow(ctx, q, id).Scan(&p.ID, &p.ServiceAreaID, &p.LGUName, &p.ContactName,
		&p.ContactEmail, &p.ContactPhone, &p.AgreementStart, &p.AgreementEnd,
		&p.Status, &p.Notes, &p.CreatedAt, &p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return p, err
}

func (r *lguPartnershipRepo) Create(ctx context.Context, p *domain.LGUPartnership) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	if p.Status == "" {
		p.Status = "pending"
	}
	const q = `
		INSERT INTO lgu_partnerships
		    (id, service_area_id, lgu_name, contact_name, contact_email, contact_phone,
		     agreement_start, agreement_end, status, notes, created_at, updated_at)
		VALUES ($1, $2, $3, NULLIF($4,''), NULLIF($5,''), NULLIF($6,''),
		        $7, $8, $9, NULLIF($10,''), NOW(), NOW())`
	_, err := r.db.Exec(ctx, q, p.ID, p.ServiceAreaID, p.LGUName, p.ContactName,
		p.ContactEmail, p.ContactPhone, p.AgreementStart, p.AgreementEnd,
		p.Status, p.Notes)
	return err
}

func (r *lguPartnershipRepo) Update(ctx context.Context, p *domain.LGUPartnership) error {
	const q = `
		UPDATE lgu_partnerships
		SET service_area_id = $2, lgu_name = $3, contact_name = NULLIF($4,''),
		    contact_email = NULLIF($5,''), contact_phone = NULLIF($6,''),
		    agreement_start = $7, agreement_end = $8, status = $9,
		    notes = NULLIF($10,''), updated_at = NOW()
		WHERE id = $1`
	tag, err := r.db.Exec(ctx, q, p.ID, p.ServiceAreaID, p.LGUName, p.ContactName,
		p.ContactEmail, p.ContactPhone, p.AgreementStart, p.AgreementEnd,
		p.Status, p.Notes)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *lguPartnershipRepo) Delete(ctx context.Context, id uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM lgu_partnerships WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}
