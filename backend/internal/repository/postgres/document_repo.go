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

// documentRepo implements domain.DocumentRepository using PostgreSQL.
type documentRepo struct{ db *pgxpool.Pool }

// NewDocumentRepo creates a new Postgres-backed DocumentRepository.
func NewDocumentRepo(db *pgxpool.Pool) domain.DocumentRepository {
	return &documentRepo{db: db}
}

func (r *documentRepo) Create(ctx context.Context, doc *domain.DriverDocument) error {
	const q = `
		INSERT INTO driver_documents (
			id, driver_id, document_type, document_number, image_url,
			expiry_date, upload_status, uploaded_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(ctx, q,
		doc.ID, doc.DriverID, doc.DocumentType, doc.DocumentNumber, doc.ImageURL,
		doc.ExpiryDate, doc.UploadStatus, doc.UploadedAt,
	)
	return err
}

func (r *documentRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.DriverDocument, error) {
	const q = `
		SELECT id, driver_id, document_type, document_number, image_url,
		       expiry_date, upload_status, rejection_reason, uploaded_at,
		       reviewed_at, reviewed_by
		FROM driver_documents
		WHERE id = $1`
	return r.scanDocument(r.db.QueryRow(ctx, q, id))
}

func (r *documentRepo) ListByDriverID(ctx context.Context, driverID uuid.UUID) ([]*domain.DriverDocument, error) {
	const q = `
		SELECT id, driver_id, document_type, document_number, image_url,
		       expiry_date, upload_status, rejection_reason, uploaded_at,
		       reviewed_at, reviewed_by
		FROM driver_documents
		WHERE driver_id = $1
		ORDER BY uploaded_at DESC`

	rows, err := r.db.Query(ctx, q, driverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var docs []*domain.DriverDocument
	for rows.Next() {
		doc, err := r.scanDocument(rows)
		if err != nil {
			return nil, err
		}
		docs = append(docs, doc)
	}
	return docs, rows.Err()
}

func (r *documentRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.UploadStatus, rejectionReason *string, reviewedAt time.Time, reviewedBy uuid.UUID) error {
	const q = `
		UPDATE driver_documents
		SET upload_status = $1,
		    rejection_reason = $2,
		    reviewed_at = $3,
		    reviewed_by = $4
		WHERE id = $5`
	_, err := r.db.Exec(ctx, q, status, rejectionReason, reviewedAt, reviewedBy, id)
	return err
}

func (r *documentRepo) scanDocument(row pgx.Row) (*domain.DriverDocument, error) {
	doc := &domain.DriverDocument{}
	err := row.Scan(
		&doc.ID, &doc.DriverID, &doc.DocumentType, &doc.DocumentNumber, &doc.ImageURL,
		&doc.ExpiryDate, &doc.UploadStatus, &doc.RejectionReason, &doc.UploadedAt,
		&doc.ReviewedAt, &doc.ReviewedBy,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return doc, err
}
