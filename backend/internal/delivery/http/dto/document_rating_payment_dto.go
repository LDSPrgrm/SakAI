package dto

import (
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// ─── Document Upload DTOs ────────────────────────────────────────────────────

// DocumentUploadRequest is the multipart/form-data shape for POST /drivers/documents.
// Note: Gin binds form fields separately from the file header.
type DocumentUploadRequest struct {
	DocumentType   string `form:"documentType" binding:"required,oneof=license registration insurance"`
	DocumentNumber string `form:"documentNumber" binding:"required,min=5,max=50"`
	ExpiryDate     string `form:"expiryDate"` // ISO 8601 date string, optional
}

// ToDomain converts the DTO to domain DocumentType.
func (r DocumentUploadRequest) ToDomainDocumentType() domain.DocumentType {
	return domain.DocumentType(r.DocumentType)
}

// ParseExpiryDate returns the parsed expiry date or nil if empty.
func (r DocumentUploadRequest) ParseExpiryDate() *time.Time {
	if r.ExpiryDate == "" {
		return nil
	}
	t, err := time.Parse("2006-01-02", r.ExpiryDate)
	if err != nil {
		return nil
	}
	return &t
}

// DriverDocumentResponse is the public API shape for a driver document.
type DriverDocumentResponse struct {
	ID              string               `json:"id"`
	DriverID        string               `json:"driver_id"`
	DocumentType    domain.DocumentType  `json:"document_type"`
	DocumentNumber  string               `json:"document_number"`
	ImageURL        string               `json:"image_url"`
	ExpiryDate      *time.Time           `json:"expiry_date,omitempty"`
	UploadStatus    domain.UploadStatus  `json:"upload_status"`
	RejectionReason *string              `json:"rejection_reason,omitempty"`
	UploadedAt      time.Time            `json:"uploaded_at"`
	ReviewedAt      *time.Time           `json:"reviewed_at,omitempty"`
}

// NewDriverDocumentResponse maps a domain.DriverDocument into the API response.
func NewDriverDocumentResponse(doc *domain.DriverDocument) DriverDocumentResponse {
	return DriverDocumentResponse{
		ID:              doc.ID.String(),
		DriverID:        doc.DriverID.String(),
		DocumentType:    doc.DocumentType,
		DocumentNumber:  doc.DocumentNumber,
		ImageURL:        doc.ImageURL,
		ExpiryDate:      doc.ExpiryDate,
		UploadStatus:    doc.UploadStatus,
		RejectionReason: doc.RejectionReason,
		UploadedAt:      doc.UploadedAt,
		ReviewedAt:      doc.ReviewedAt,
	}
}

// DriverDocumentsListResponse wraps a list of documents.
type DriverDocumentsListResponse struct {
	Documents []DriverDocumentResponse `json:"documents"`
}

// ─── Rating DTOs ─────────────────────────────────────────────────────────────

// SubmitRatingRequest is the JSON body for POST /rides/{rideId}/rating.
type SubmitRatingRequest struct {
	Stars    int     `json:"stars" binding:"required,min=1,max=5"`
	Feedback *string `json:"feedback" binding:"max=500"`
}

// RatingResponse is the public API shape for a submitted rating.
type RatingResponse struct {
	ID        string    `json:"id"`
	RideID    string    `json:"ride_id"`
	RaterID   string    `json:"rater_id"`
	RateeID   string    `json:"ratee_id"`
	Stars     int       `json:"stars"`
	Feedback  *string   `json:"feedback,omitempty"`
	CreatedAt time.Time `json:"created_at"`
}

// NewRatingResponse maps a domain.Rating into the API response.
func NewRatingResponse(r *domain.Rating) RatingResponse {
	return RatingResponse{
		ID:        r.ID.String(),
		RideID:    r.RideID.String(),
		RaterID:   r.RaterID.String(),
		RateeID:   r.RateeID.String(),
		Stars:     r.Stars,
		Feedback:  r.Feedback,
		CreatedAt: r.CreatedAt,
	}
}

// UserRatingResponse is the public API shape for a user's average rating.
type UserRatingResponse struct {
	UserID        string  `json:"user_id"`
	AverageRating float64 `json:"average_rating"`
	RatingCount   int     `json:"rating_count"`
	LastUpdated   time.Time `json:"last_updated"`
}

// NewUserRatingResponse maps a domain.RatingSummary into the API response.
func NewUserRatingResponse(s *domain.RatingSummary) UserRatingResponse {
	return UserRatingResponse{
		UserID:        s.UserID.String(),
		AverageRating: s.AverageRating,
		RatingCount:   s.RatingCount,
		LastUpdated:   s.LastUpdated,
	}
}

// ─── Payment DTOs ────────────────────────────────────────────────────────────

// PaymentProcessRequest is the JSON body for POST /payments/process.
type PaymentProcessRequest struct {
	RideID             string `json:"rideId" binding:"required,uuid"`
	PaymentMethodToken string `json:"paymentMethodToken" binding:"required"`
}

// ParseRideID parses the ride ID from the request.
func (r PaymentProcessRequest) ParseRideID() (uuid.UUID, error) {
	return uuid.Parse(r.RideID)
}

// PaymentResponse is the public API shape for a processed payment.
type PaymentResponse struct {
	ID                   string  `json:"id"`
	RideID               string  `json:"ride_id"`
	Amount               float64 `json:"amount"`
	Currency             string  `json:"currency"`
	Method               domain.PaymentMethod `json:"method"`
	Status               domain.PaymentStatus `json:"status"`
	GatewayTransactionID *string `json:"gateway_transaction_id,omitempty"`
	ProcessedAt          *time.Time `json:"processed_at,omitempty"`
}

// NewPaymentResponse maps a domain.Payment into the API response.
func NewPaymentResponse(p *domain.Payment) PaymentResponse {
	return PaymentResponse{
		ID:                   p.ID.String(),
		RideID:               p.RideID.String(),
		Amount:               p.Amount,
		Currency:             p.Currency,
		Method:               p.Method,
		Status:               p.Status,
		GatewayTransactionID: p.GatewayTransactionID,
		ProcessedAt:          p.ProcessedAt,
	}
}

// ReceiptResponse is the public API shape for a ride payment receipt.
type ReceiptResponse struct {
	RideID           string               `json:"ride_id"`
	PassengerName    string               `json:"passenger_name"`
	DriverName       string               `json:"driver_name"`
	PickupAddress    string               `json:"pickup_address"`
	DestinationAddress string             `json:"destination_address"`
	Amount           float64              `json:"amount"`
	Currency         string               `json:"currency"`
	PaymentMethod    domain.PaymentMethod `json:"payment_method"`
	PaymentStatus    domain.PaymentStatus `json:"payment_status"`
	CompletedAt      time.Time            `json:"completed_at"`
	ProcessedAt      *time.Time           `json:"processed_at,omitempty"`
}

// ─── Tip DTOs ────────────────────────────────────────────────────────────────

// AddTipRequest is the JSON body for POST /rides/{rideId}/tip.
type AddTipRequest struct {
	TipAmount float64 `json:"tipAmount" binding:"required"`
}

// TipResponse is the public API shape for a successfully added tip.
type TipResponse struct {
	RideID        string    `json:"ride_id"`
	BaseFare      float64   `json:"base_fare"`
	TipAmount     float64   `json:"tip_amount"`
	FinalTotal    float64   `json:"final_total"`
	Currency      string    `json:"currency"`
	PaymentMethod string    `json:"payment_method"`
	TransactionID string    `json:"transaction_id"`
	ProcessedAt   time.Time `json:"processed_at"`
}

// NewTipResponse maps a domain.TipOutput into the API response.
func NewTipResponse(t *domain.TipOutput) TipResponse {
	return TipResponse{
		RideID:        t.RideID.String(),
		BaseFare:      t.BaseFare,
		TipAmount:     t.TipAmount,
		FinalTotal:    t.FinalTotal,
		Currency:      t.Currency,
		PaymentMethod: t.PaymentMethod,
		TransactionID: t.TransactionID,
		ProcessedAt:   t.ProcessedAt,
	}
}
