package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

// RidePaymentHandler handles /payments/process and /rides/{rideId}/receipt routes.
type RidePaymentHandler struct {
	paymentUC domain.PaymentProcessingUseCase
	rideRepo  domain.RideRepository
	userRepo  domain.UserRepository
}

// NewRidePaymentHandler creates a new RidePaymentHandler.
func NewRidePaymentHandler(
	paymentUC domain.PaymentProcessingUseCase,
	rideRepo domain.RideRepository,
	userRepo domain.UserRepository,
) *RidePaymentHandler {
	return &RidePaymentHandler{
		paymentUC: paymentUC,
		rideRepo:  rideRepo,
		userRepo:  userRepo,
	}
}

// ProcessPayment handles POST /payments/process.
func (h *RidePaymentHandler) ProcessPayment(c *gin.Context) {
	passengerID := c.MustGet("userID").(uuid.UUID)
	idempotencyKey := c.GetHeader("Idempotency-Key")
	if idempotencyKey == "" {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "Idempotency-Key header is required"})
		return
	}

	var req dto.PaymentProcessRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	rideID, err := req.ParseRideID()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid rideId"})
		return
	}

	payment, err := h.paymentUC.ProcessPayment(c.Request.Context(), passengerID, rideID, req.PaymentMethodToken, idempotencyKey)
	if err != nil {
		respondError(c, err)
		return
	}

	respondOK(c, dto.NewPaymentResponse(payment))
}

// GetReceipt handles GET /rides/{rideId}/receipt.
func (h *RidePaymentHandler) GetReceipt(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)

	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	// Get payment.
	payment, err := h.paymentUC.GetReceipt(c.Request.Context(), userID, rideID)
	if err != nil {
		respondError(c, err)
		return
	}

	// Enrich with ride and user data for receipt.
	ride, err := h.rideRepo.GetByID(c.Request.Context(), rideID)
	if err != nil {
		respondError(c, err)
		return
	}

	passenger, err := h.userRepo.GetByID(c.Request.Context(), ride.PassengerID)
	if err != nil {
		respondError(c, err)
		return
	}

	var driverName string
	if ride.DriverID != nil {
		driver, err := h.userRepo.GetByID(c.Request.Context(), *ride.DriverID)
		if err != nil {
			respondError(c, err)
			return
		}
		driverName = driver.Name
	}

	receipt := dto.ReceiptResponse{
		RideID:             rideID.String(),
		PassengerName:      passenger.Name,
		DriverName:         driverName,
		PickupAddress:      ride.OriginAddress,
		DestinationAddress: ride.DestinationAddress,
		Amount:             payment.Amount,
		Currency:           payment.Currency,
		PaymentMethod:      payment.Method,
		PaymentStatus:      payment.Status,
		CompletedAt:        ride.UpdatedAt,
		ProcessedAt:        payment.ProcessedAt,
	}

	respondOK(c, receipt)
}
