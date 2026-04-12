package handler

import (
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
	upsert          ws.Dispatcher
}

func NewRideHandler(uc domain.RideUseCase, userRideUC usecase.UserRideUseCase, upsert ws.Dispatcher) *RideHandler {
	return &RideHandler{uc: uc, userRideUC: userRideUC, upsert: upsert}
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
	ride, err := h.uc.RequestRide(
		c.Request.Context(), passengerID,
		req.Origin.ToDomainLatLng(), req.Destination.ToDomainLatLng(),
		req.OriginAddress, req.DestinationAddress, req.Notes, idempotencyKey,
	)
	if err != nil {
		respondError(c, err)
		return
	}
	if ride.DriverID != nil {
		_ = h.upsert.PublishToUser(c.Request.Context(), *ride.DriverID, ws.EventRideRequested, gin.H{"ride_id": ride.ID, "passenger_id": ride.PassengerID})
	}
	respondCreated(c, dto.NewRideResponse(ride))
}

func (h *RideHandler) GetActive(c *gin.Context) {
	userID := c.MustGet("userID").(uuid.UUID)
	role := contextUserRole(c)
	ride, err := h.uc.GetActive(c.Request.Context(), userID, role)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewRideResponse(ride))
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
	respondOK(c, dto.NewRideResponse(ride))
}

func (h *RideHandler) Accept(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Accept(c.Request.Context(), driverID, rideID)
	}, ws.EventRideAccepted)
}

func (h *RideHandler) Decline(c *gin.Context) {
	h.driverTransition(c, func(driverID, rideID uuid.UUID) (*domain.Ride, error) {
		return h.uc.Decline(c.Request.Context(), driverID, rideID)
	}, ws.EventRideDeclined)
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
	userID := c.MustGet("userID").(uuid.UUID)
	role := contextUserRole(c)
	ride, err := h.uc.Cancel(c.Request.Context(), userID, role, rideID)
	if err != nil {
		respondError(c, err)
		return
	}
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideCancelled, gin.H{"ride_id": ride.ID, "cancelled_by": ride.CancelledBy})
	respondOK(c, dto.NewRideResponse(ride))
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
	respondOK(c, dto.NewRideResponse(ride))
}
