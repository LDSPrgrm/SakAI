package domain

import (
	"time"

	"github.com/google/uuid"
)

// ─── Document Types ──────────────────────────────────────────────────────────

// DocumentType identifies the category of driver verification document.
type DocumentType string

const (
	DocumentTypeLicense      DocumentType = "license"
	DocumentTypeRegistration DocumentType = "registration"
	DocumentTypeInsurance    DocumentType = "insurance"
)

// IsValid returns true if the document type is one of the known values.
func (dt DocumentType) IsValid() bool {
	switch dt {
	case DocumentTypeLicense, DocumentTypeRegistration, DocumentTypeInsurance:
		return true
	}
	return false
}

// UploadStatus tracks the verification state of a document.
type UploadStatus string

const (
	UploadStatusUploaded      UploadStatus = "uploaded"
	UploadStatusUnderReview   UploadStatus = "under_review"
	UploadStatusApproved      UploadStatus = "approved"
	UploadStatusRejected      UploadStatus = "rejected"
)

// IsApproved returns true if the document has been approved.
func (s UploadStatus) IsApproved() bool {
	return s == UploadStatusApproved
}

// ─── DriverDocument Entity ───────────────────────────────────────────────────

// DriverDocument represents a verification document uploaded by a driver.
type DriverDocument struct {
	ID              uuid.UUID    `json:"id"`
	DriverID        uuid.UUID    `json:"driver_id"`
	DocumentType    DocumentType `json:"document_type"`
	DocumentNumber  string       `json:"document_number"`
	ImageURL        string       `json:"image_url"`
	ExpiryDate      *time.Time   `json:"expiry_date,omitempty"`
	UploadStatus    UploadStatus `json:"upload_status"`
	RejectionReason *string      `json:"rejection_reason,omitempty"`
	UploadedAt      time.Time    `json:"uploaded_at"`
	ReviewedAt      *time.Time   `json:"reviewed_at,omitempty"`
	ReviewedBy      *uuid.UUID   `json:"reviewed_by,omitempty"`
}

// ─── Rating Entity ───────────────────────────────────────────────────────────

// Rating represents a rating given by one user to another after a ride.
type Rating struct {
	ID        uuid.UUID `json:"id"`
	RideID    uuid.UUID `json:"ride_id"`
	RaterID   uuid.UUID `json:"rater_id"`
	RateeID   uuid.UUID `json:"ratee_id"`
	Stars     int       `json:"stars"`
	Feedback  *string   `json:"feedback,omitempty"`
	CreatedAt time.Time `json:"created_at"`
}

// IsValidStars returns true if the star rating is within valid range.
func (r Rating) IsValidStars() bool {
	return r.Stars >= 1 && r.Stars <= 5
}

// ─── Payment Types ───────────────────────────────────────────────────────────

// PaymentMethod identifies how a ride was paid for.
type PaymentMethod string

const (
	PaymentMethodCash    PaymentMethod = "cash"
	PaymentMethodCard    PaymentMethod = "card"
	PaymentMethodGcash   PaymentMethod = "gcash"
	PaymentMethodPaymaya PaymentMethod = "paymaya"
)

// IsValid returns true if the payment method is known. Keep in sync with the
// `payment_method` ENUM in Postgres (migration 011 + extension 027).
func (pm PaymentMethod) IsValid() bool {
	switch pm {
	case PaymentMethodCash, PaymentMethodCard, PaymentMethodGcash, PaymentMethodPaymaya:
		return true
	}
	return false
}

// ─── Saved Payment Method Types ──────────────────────────────────────────────

// SavedPaymentMethodType identifies the type of a saved payment method.
type SavedPaymentMethodType string

const (
	SavedPaymentMethodTypeCard    SavedPaymentMethodType = "card"
	SavedPaymentMethodTypeEWallet SavedPaymentMethodType = "e_wallet"
	SavedPaymentMethodTypeCash    SavedPaymentMethodType = "cash"
)

// IsValid returns true if the type is one of the known values.
func (t SavedPaymentMethodType) IsValid() bool {
	switch t {
	case SavedPaymentMethodTypeCard, SavedPaymentMethodTypeEWallet, SavedPaymentMethodTypeCash:
		return true
	}
	return false
}

// SavedCardDetails holds non-sensitive card information for display.
type SavedCardDetails struct {
	Last4       string `json:"last4"`
	ExpiryMonth int    `json:"expiry_month"`
	ExpiryYear  int    `json:"expiry_year"`
	Brand       string `json:"brand"`
}

// SavedEWalletDetails holds e-wallet account information.
type SavedEWalletDetails struct {
	Provider  string `json:"provider"`
	AccountID string `json:"account_id"`
}

// SavedPaymentMethod represents a user's saved payment method for future rides.
type SavedPaymentMethod struct {
	ID        uuid.UUID              `json:"id"`
	UserID    uuid.UUID              `json:"user_id"`
	Type      SavedPaymentMethodType `json:"type"`
	IsDefault bool                   `json:"is_default"`
	Card      *SavedCardDetails      `json:"card,omitempty"`
	EWallet   *SavedEWalletDetails   `json:"e_wallet,omitempty"`
	CreatedAt time.Time              `json:"created_at"`
}

// PaymentStatus tracks the state of a payment transaction.
type PaymentStatus string

const (
	PaymentStatusPending   PaymentStatus = "pending"
	PaymentStatusCompleted PaymentStatus = "completed"
	PaymentStatusFailed    PaymentStatus = "failed"
	PaymentStatusRefunded  PaymentStatus = "refunded"
)

// IsCompleted returns true if the payment has been successfully processed.
func (ps PaymentStatus) IsCompleted() bool {
	return ps == PaymentStatusCompleted
}

// ─── Payment Entity ──────────────────────────────────────────────────────────

// Payment represents the financial transaction for a completed ride.
type Payment struct {
	ID                   uuid.UUID     `json:"id"`
	RideID               uuid.UUID     `json:"ride_id"`
	PassengerID          uuid.UUID     `json:"passenger_id"`
	Amount               float64       `json:"amount"`
	Currency             string        `json:"currency"`
	Method               PaymentMethod `json:"method"`
	Status               PaymentStatus `json:"status"`
	GatewayTransactionID *string       `json:"gateway_transaction_id,omitempty"` // Stripe charge ID (ch_...)
	StripeChargeID       *string       `json:"stripe_charge_id,omitempty"`       // Alias for GatewayTransactionID
	IdempotencyKey       *string       `json:"idempotency_key,omitempty"`
	GatewayResponse      *string       `json:"gateway_response,omitempty"`
	ProcessedAt          *time.Time    `json:"processed_at,omitempty"`
	FailureReason        *string       `json:"failure_reason,omitempty"`
	CreatedAt            time.Time     `json:"created_at"`
}

// ─── Rating Summary (read-only projection) ───────────────────────────────────

// RatingSummary is a computed aggregate of a user's ratings.
type RatingSummary struct {
	UserID        uuid.UUID `json:"user_id"`
	AverageRating float64   `json:"average_rating"`
	RatingCount   int       `json:"rating_count"`
	LastUpdated   time.Time `json:"last_updated"`
}
