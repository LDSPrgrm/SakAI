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
// No binding tags here to allow permissive unmarshaling; validation is manual.
type SubmitRatingRequest struct {
	Stars    float64 `json:"stars"`
	Feedback *string `json:"feedback"`
}

// GetStars returns the stars as an integer.
func (r SubmitRatingRequest) GetStars() int {
	return int(r.Stars)
}

// RatingResponse is the public API shape for a submitted rating.
type RatingResponse struct {
	ID        string    `json:"id"`
	RideID    string    `json:"rideId"`
	RaterID   string    `json:"raterId"`
	RateeID   string    `json:"rateeId"`
	Stars     int       `json:"stars"`
	Feedback  *string   `json:"feedback,omitempty"`
	CreatedAt time.Time `json:"createdAt"`
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
	UserID        string  `json:"userId"`
	AverageRating float64 `json:"averageRating"`
	RatingCount   int     `json:"ratingCount"`
	LastUpdated   time.Time `json:"lastUpdated"`
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
	RideID               string  `json:"rideId"`
	Amount               float64 `json:"amount"`
	Currency             string  `json:"currency"`
	Method               domain.PaymentMethod `json:"method"`
	Status               domain.PaymentStatus `json:"status"`
	GatewayTransactionID *string `json:"gatewayTransactionId,omitempty"`
	ProcessedAt          *time.Time `json:"processedAt,omitempty"`
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
	RideID             string               `json:"rideId"`
	PassengerName      string               `json:"passengerName"`
	DriverName         string               `json:"driverName"`
	PickupAddress      string               `json:"pickupAddress"`
	DestinationAddress string               `json:"destinationAddress"`
	Amount             float64              `json:"amount"`
	Currency           string               `json:"currency"`
	PaymentMethod      domain.PaymentMethod `json:"paymentMethod"`
	PaymentStatus      domain.PaymentStatus `json:"paymentStatus"`
	CompletedAt        time.Time            `json:"completedAt"`
	ProcessedAt        *time.Time           `json:"processedAt,omitempty"`
	EstimatedFare      *float64             `json:"estimatedFare,omitempty"`
	ActualFare         *float64             `json:"actualFare,omitempty"`
	FareBreakdown      *domain.JSONMap      `json:"fareBreakdown,omitempty"`
}

// ─── Tip DTOs ────────────────────────────────────────────────────────────────

// AddTipRequest is the JSON body for POST /rides/{rideId}/tip.
type AddTipRequest struct {
	TipAmount float64 `json:"tipAmount" binding:"required"`
}

// TipResponse is the public API shape for a successfully added tip.
type TipResponse struct {
	RideID        string    `json:"rideId"`
	BaseFare      float64   `json:"baseFare"`
	TipAmount     float64   `json:"tipAmount"`
	FinalTotal    float64   `json:"finalTotal"`
	Currency      string    `json:"currency"`
	PaymentMethod string    `json:"paymentMethod"`
	TransactionID string    `json:"transactionId"`
	ProcessedAt   time.Time `json:"processedAt"`
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
