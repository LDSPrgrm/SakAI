package usecase

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

type documentUseCase struct {
	docRepo  domain.DocumentRepository
	rideRepo domain.RideRepository
}

// NewDocumentUseCase creates a new domain.DocumentUseCase.
func NewDocumentUseCase(docRepo domain.DocumentRepository, rideRepo domain.RideRepository) domain.DocumentUseCase {
	return &documentUseCase{docRepo: docRepo, rideRepo: rideRepo}
}

func (uc *documentUseCase) UploadDocument(ctx context.Context, driverID uuid.UUID, docType domain.DocumentType, docNumber string, expiryDate *time.Time, imageURL string) (*domain.DriverDocument, error) {
	// Validate document type.
	if !docType.IsValid() {
		return nil, domain.ErrInvalidDocumentType
	}

	// Validate document number is not empty.
	if docNumber == "" {
		return nil, domain.ErrInvalidDocumentType
	}

	// Validate image URL is provided.
	if imageURL == "" {
		return nil, domain.ErrInvalidFileFormat
	}

	now := time.Now()
	doc := &domain.DriverDocument{
		ID:           uuid.New(),
		DriverID:     driverID,
		DocumentType: docType,
		DocumentNumber: docNumber,
		ImageURL:     imageURL,
		ExpiryDate:   expiryDate,
		UploadStatus: domain.UploadStatusUploaded,
		UploadedAt:   now,
	}

	if err := uc.docRepo.Create(ctx, doc); err != nil {
		return nil, err
	}
	return doc, nil
}

func (uc *documentUseCase) GetDocument(ctx context.Context, driverID, documentID uuid.UUID) (*domain.DriverDocument, error) {
	doc, err := uc.docRepo.GetByID(ctx, documentID)
	if err != nil {
		return nil, err
	}

	// Only the document owner can access it.
	if doc.DriverID != driverID {
		return nil, domain.ErrForbidden
	}
	return doc, nil
}

func (uc *documentUseCase) ListDocuments(ctx context.Context, driverID uuid.UUID) ([]*domain.DriverDocument, error) {
	return uc.docRepo.ListByDriverID(ctx, driverID)
}
