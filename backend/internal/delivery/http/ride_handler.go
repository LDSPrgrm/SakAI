package handler

import (
	"context"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/usecase"
)

// RideHandler handles /rides/* routes.
type RideHandler struct {
	uc              domain.RideUseCase
	userRideUC      usecase.UserRideUseCase
	userRepo        domain.UserRepository
	driverRepo      domain.DriverRepository
	paymentRepo     domain.RidePaymentRepository
	upsert          ws.Dispatcher
}

func NewRideHandler(uc domain.RideUseCase, userRideUC usecase.UserRideUseCase, upsert ws.Dispatcher, userRepo domain.UserRepository, driverRepo domain.DriverRepository, paymentRepo domain.RidePaymentRepository) *RideHandler {
	return &RideHandler{uc: uc, userRideUC: userRideUC, userRepo: userRepo, driverRepo: driverRepo, paymentRepo: paymentRepo, upsert: upsert}
}

// rideEnricher implements dto.RideResponseEnricher for the handler.
type rideEnricher struct {
	userRepo   domain.UserRepository
	driverRepo domain.DriverRepository
}

func (e *rideEnricher) GetUserByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	return e.userRepo.GetByID(ctx, id)
}

func (e *rideEnricher) GetDriverByUserID(ctx context.Context, userID uuid.UUID) (*domain.Driver, error) {
	return e.driverRepo.GetByUserID(ctx, userID)
}

// paymentEnricher implements dto.RidePaymentEnricher for the handler.
type paymentEnricher struct {
	paymentRepo domain.RidePaymentRepository
}

func (e *paymentEnricher) GetPaymentByRideID(ctx context.Context, rideID uuid.UUID) (*domain.Payment, error) {
	return e.paymentRepo.GetByRideID(ctx, rideID)
}

// rideResponse helpers returns NewRideResponse with both enrichers.
func (h *RideHandler) rideResponse(ride *domain.Ride) dto.RideResponse {
	return dto.NewRideResponse(
		ride,
		&rideEnricher{userRepo: h.userRepo, driverRepo: h.driverRepo},
		&paymentEnricher{paymentRepo: h.paymentRepo},
	)
}

// ListMyRides handles GET /rides with pagination and status filter.
func (h *RideHandler) ListMyRides(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)

	// Parse pagination
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	// Parse status filter (comma-separated)
	var statuses []domain.RideStatus
	if statusStr := c.Query("status"); statusStr != "" {
		for _, s := range strings.Split(statusStr, ",") {
			statuses = append(statuses, domain.RideStatus(strings.TrimSpace(s)))
		}
	}

	filter := domain.UserRideFilter{
		Statuses: statuses,
		Page:     page,
		Limit:    limit,
	}

	rides, pagination, err := h.userRideUC.ListMyRides(c.Request.Context(), userID, filter)
	if err != nil {
		respondError(c, err)
		return
	}

	// Convert to response DTOs
	items := make([]dto.UserRideItemResponse, len(rides))
	for i, ride := range rides {
		items[i] = dto.NewUserRideItemResponse(ride)
	}

	c.JSON(http.StatusOK, gin.H{
		"data":       items,
		"pagination": pagination,
	})
}

func (h *RideHandler) RequestRide(c *gin.Context) {
	idempotencyKey := c.GetHeader("Idempotency-Key")
	if idempotencyKey == "" {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "Idempotency-Key header is required"})
		return
	}
	var req dto.RequestRideRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	passengerID := c.MustGet("userID").(uuid.UUID)

	// Determine ride type (default to car)
	rideType := domain.RideTypeCar
	if req.RideType != "" {
		rideType = domain.RideType(req.RideType)
	}

	// Determine payment method (default to cash)
	paymentMethod := domain.PaymentMethodCash
	if req.PaymentMethod != "" {
		paymentMethod = domain.PaymentMethod(req.PaymentMethod)
	}

	ride, err := h.uc.RequestRide(
		c.Request.Context(), passengerID,
		req.Origin.ToDomainLatLng(), req.Destination.ToDomainLatLng(),
		req.OriginAddress, req.DestinationAddress, req.Notes, idempotencyKey,
		rideType, paymentMethod,
	)
	if err != nil {
		respondError(c, err)
		return
	}
	if ride.DriverID != nil {
		log.Printf("[RIDE] Sending ride request to driver %s via WS", *ride.DriverID)
		_ = h.upsert.PublishToUser(c.Request.Context(), *ride.DriverID, ws.EventRideRequested, gin.H{"ride_id": ride.ID, "passenger_id": ride.PassengerID})
	} else {
		log.Printf("[RIDE] No driver assigned to ride %s", ride.ID)
	}
	respondCreated(c, h.rideResponse(ride))
}

func (h *RideHandler) GetActive(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)
	role := contextUserRole(c)
	ride, err := h.uc.GetActive(c.Request.Context(), userID, role)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, h.rideResponse(ride))
}

func (h *RideHandler) GetByID(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}
	userID := c.MustGet("userID").(uuid.UUID)
	ride, err := h.uc.GetByID(c.Request.Context(), userID, rideID)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, h.rideResponse(ride))
}

func (h *RideHandler) Accept(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Accept(c.Request.Context(), driverID, rideID)
	}, ws.EventRideAccepted)
}

func (h *RideHandler) Decline(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}
	driverID := c.MustGet("userID").(uuid.UUID)
	result, err := h.uc.Decline(c.Request.Context(), driverID, rideID)
	if err != nil {
		respondError(c, err)
		return
	}
	// Publish decline event to the original driver.
	_ = h.upsert.PublishToRide(c.Request.Context(), result.Ride, ws.EventRideDeclined, gin.H{"ride_id": result.Ride.ID, "status": result.Ride.Status})
	// If a new driver was matched, send them a ride offer.
	if result.NewDriverFound && result.NewDriverID != nil {
		_ = h.upsert.PublishToUser(c.Request.Context(), *result.NewDriverID, ws.EventRideRequested, gin.H{"ride_id": result.Ride.ID, "passenger_id": result.Ride.PassengerID})
	}
	respondOK(c, h.rideResponse(result.Ride))
}

func (h *RideHandler) Arrive(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Arrive(c.Request.Context(), driverID, rideID)
	}, ws.EventRideStatusChanged)
}

func (h *RideHandler) Start(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Start(c.Request.Context(), driverID, rideID)
	}, ws.EventRideStatusChanged)
}

func (h *RideHandler) Complete(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Complete(c.Request.Context(), driverID, rideID)
	}, ws.EventRideStatusChanged)
}

func (h *RideHandler) Cancel(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.CancelRideRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	userID := c.MustGet("userID").(uuid.UUID)
	role := contextUserRole(c)
	ride, err := h.uc.Cancel(c.Request.Context(), userID, role, rideID, &req.ReasonCode, req.ReasonText)
	if err != nil {
		respondError(c, err)
		return
	}
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideCancelled, gin.H{"ride_id": ride.ID, "cancelled_by": ride.CancelledBy, "reason_code": ride.CancellationReason})
	respondOK(c, h.rideResponse(ride))
}

// driverTransition is a shared helper for driver-only state-advancing endpoints.
func (h *RideHandler) driverTransition(c *gin.Context, fn func(driverID, rideID uuid.UUID) (*domain.Ride, error), event ws.EventType) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}
	driverID := c.MustGet("userID").(uuid.UUID)
	ride, err := fn(driverID, rideID)
	if err != nil {
		respondError(c, err)
		return
	}
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, event, gin.H{"ride_id": ride.ID, "status": ride.Status})
	respondOK(c, h.rideResponse(ride))
}
