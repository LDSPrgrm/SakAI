package handler

import (
	"context"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

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
	rideRepo        domain.RideRepository
	userRepo        domain.UserRepository
	driverRepo      domain.DriverRepository
	paymentRepo     domain.RidePaymentRepository
	upsert          ws.Dispatcher
}

func NewRideHandler(uc domain.RideUseCase, userRideUC usecase.UserRideUseCase, upsert ws.Dispatcher, rideRepo domain.RideRepository, userRepo domain.UserRepository, driverRepo domain.DriverRepository, paymentRepo domain.RidePaymentRepository) *RideHandler {
	return &RideHandler{uc: uc, userRideUC: userRideUC, rideRepo: rideRepo, userRepo: userRepo, driverRepo: driverRepo, paymentRepo: paymentRepo, upsert: upsert}
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

// ListDriverRides handles GET /driver/rides with pagination and status filter.
func (h *RideHandler) ListDriverRides(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)

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

	rides, total, err := h.rideRepo.ListByDriverID(c.Request.Context(), driverID, filter)
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
		"data": items,
		"pagination": gin.H{
			"page":  filter.Page,
			"limit": filter.Limit,
			"total": total,
		},
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
		
		// Fetch passenger profile for WS payload
		passenger, passengerErr := h.userRepo.GetByID(c.Request.Context(), passengerID)
		if passengerErr != nil {
			log.Printf("[RIDE] Failed to fetch passenger profile for WS payload: %v", passengerErr)
		}
		
		// Compute expiry time (5 minutes from now)
		expiresAt := ride.CreatedAt.Add(5 * time.Minute)
		
		// Build complete WS payload matching WsEventRideRequested contract
		payload := gin.H{
			"ride_id":              ride.ID,
			"passenger":            buildPassengerPayload(passenger),
			"origin":               gin.H{"lat": ride.Origin.Lat, "lng": ride.Origin.Lng},
			"destination":          gin.H{"lat": ride.Destination.Lat, "lng": ride.Destination.Lng},
			"origin_address":       ride.OriginAddress,
			"destination_address":  ride.DestinationAddress,
			"notes":                ride.Notes,
			"expires_at":           expiresAt.Format(time.RFC3339),
		}
		
		if wsErr := h.upsert.PublishToUser(c.Request.Context(), *ride.DriverID, ws.EventRideRequested, payload); wsErr != nil {
			log.Printf("[RIDE] WARNING: Failed to send ride request to driver %s via WS: %v", *ride.DriverID, wsErr)
		} else {
			log.Printf("[RIDE] Successfully sent ride request to driver %s via WS", *ride.DriverID)
		}
	} else {
		log.Printf("[RIDE] No driver assigned to ride %s", ride.ID)
	}
	respondCreated(c, h.rideResponse(ride))
}

// buildPassengerPayload builds a safe passenger payload for WS events.
func buildPassengerPayload(user *domain.User) gin.H {
	if user == nil {
		return gin.H{
			"id":         "",
			"name":       "Unknown",
			"email":      "",
			"role":       string(domain.RolePassenger),
			"created_at": time.Now().Format(time.RFC3339),
		}
	}
	return gin.H{
		"id":         user.ID.String(),
		"name":       user.Name,
		"email":      user.Email,
		"role":       string(user.Role),
		"created_at": user.CreatedAt.Format(time.RFC3339),
	}
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
	// Publish decline event to the passenger and the driver who declined.
	_ = h.upsert.PublishToUser(c.Request.Context(), result.Ride.PassengerID, ws.EventRideDeclined, gin.H{"ride_id": result.Ride.ID, "status": result.Ride.Status})
	_ = h.upsert.PublishToUser(c.Request.Context(), driverID, ws.EventRideDeclined, gin.H{"ride_id": result.Ride.ID, "status": result.Ride.Status})
	// If a new driver was matched, send them a ride offer with complete payload.
	if result.NewDriverFound && result.NewDriverID != nil {
		log.Printf("[RIDE] Re-matching ride %s to new driver %s after decline", result.Ride.ID, *result.NewDriverID)
		
		// Fetch passenger profile for WS payload
		passenger, passengerErr := h.userRepo.GetByID(c.Request.Context(), result.Ride.PassengerID)
		if passengerErr != nil {
			log.Printf("[RIDE] Failed to fetch passenger profile for WS payload: %v", passengerErr)
		}
		
		// Compute expiry time (5 minutes from now)
		expiresAt := time.Now().Add(5 * time.Minute)
		
		// Build complete WS payload matching WsEventRideRequested contract
		payload := gin.H{
			"ride_id":              result.Ride.ID,
			"passenger":            buildPassengerPayload(passenger),
			"origin":               gin.H{"lat": result.Ride.Origin.Lat, "lng": result.Ride.Origin.Lng},
			"destination":          gin.H{"lat": result.Ride.Destination.Lat, "lng": result.Ride.Destination.Lng},
			"origin_address":       result.Ride.OriginAddress,
			"destination_address":  result.Ride.DestinationAddress,
			"notes":                result.Ride.Notes,
			"expires_at":           expiresAt.Format(time.RFC3339),
		}

		if wsErr := h.upsert.PublishToUser(c.Request.Context(), *result.NewDriverID, ws.EventRideRequested, payload); wsErr != nil {
			log.Printf("[RIDE] WARNING: Failed to send re-match ride request to driver %s via WS: %v", *result.NewDriverID, wsErr)
		} else {
			log.Printf("[RIDE] Successfully sent re-match ride request to driver %s via WS", *result.NewDriverID)
		}
	}
	respondOK(c, h.rideResponse(result.Ride))
}

func (h *RideHandler) Arrive(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.ArriveAtPickupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	driverID := c.MustGet("userID").(uuid.UUID)
	ride, err := h.uc.Arrive(c.Request.Context(), driverID, rideID, req.DriverLocation.ToDomainLatLng())
	if err != nil {
		respondError(c, err)
		return
	}
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideStatusChanged, gin.H{"ride_id": ride.ID, "status": ride.Status, "updated_at": ride.UpdatedAt.UTC().Format(time.RFC3339)})
	respondOK(c, h.rideResponse(ride))
}

func (h *RideHandler) Start(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Start(c.Request.Context(), driverID, rideID)
	}, ws.EventRideStatusChanged)
}

func (h *RideHandler) Complete(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.CompleteRideRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	driverID := c.MustGet("userID").(uuid.UUID)
	ride, err := h.uc.Complete(c.Request.Context(), driverID, rideID, req.DriverLocation.ToDomainLatLng())
	if err != nil {
		respondError(c, err)
		return
	}
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideStatusChanged, gin.H{"ride_id": ride.ID, "status": ride.Status, "updated_at": ride.UpdatedAt.UTC().Format(time.RFC3339)})
	respondOK(c, h.rideResponse(ride))
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
	ride, err := h.uc.Cancel(c.Request.Context(), userID, role, rideID, req.ReasonCode, req.ReasonText)
	if err != nil {
		respondError(c, err)
		return
	}
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideCancelled, gin.H{"ride_id": ride.ID, "cancelled_by": ride.CancelledBy, "reason_code": ride.CancellationReason})
	respondOK(c, h.rideResponse(ride))
}

func (h *RideHandler) TriggerSOS(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.TriggerSOSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	userID := c.MustGet("userID").(uuid.UUID)
	role := contextUserRole(c)
	incident, err := h.uc.TriggerSOS(c.Request.Context(), userID, role, rideID, req.Reason)
	if err != nil {
		respondError(c, err)
		return
	}

	// Publish SOS event to WebSocket for system monitoring or ride participants
	ride, rideErr := h.rideRepo.GetByID(c.Request.Context(), rideID)
	if rideErr == nil {
		payload := gin.H{
			"ride_id":      ride.ID,
			"incident_id":  incident.ID,
			"triggered_by": incident.TriggeredBy,
			"reason":       req.Reason,
		}
		_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideSOS, payload)
	}

	respondOK(c, dto.NewIncidentDTO(incident))
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
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, event, gin.H{"ride_id": ride.ID, "status": ride.Status, "updated_at": ride.UpdatedAt.UTC().Format(time.RFC3339)})
	respondOK(c, h.rideResponse(ride))
}
