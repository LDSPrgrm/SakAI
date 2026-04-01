package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/domain"
)

// DriverHandler handles /driver/* routes.
type DriverHandler struct {
	uc     domain.DriverUseCase
	upsert ws.Dispatcher
}

func NewDriverHandler(uc domain.DriverUseCase, upsert ws.Dispatcher) *DriverHandler {
	return &DriverHandler{uc: uc, upsert: upsert}
}

func (h *DriverHandler) SetStatus(c *gin.Context) {
	var req dto.SetStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	driverID := c.MustGet("userID").(uuid.UUID)
	if err := h.uc.SetStatus(c.Request.Context(), driverID, req.Status); err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.SetStatusResponse{DriverID: driverID.String(), Status: req.Status})
}

func (h *DriverHandler) UpdateLocation(c *gin.Context) {
	var req dto.UpdateLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	driverID := c.MustGet("userID").(uuid.UUID)
	loc := req.ToDomainDriverLocation()
	if err := h.uc.UpdateLocation(c.Request.Context(), driverID, loc); err != nil {
		respondError(c, err)
		return
	}
	// Forward real-time location to the passenger waiting for this driver.
	// Best-effort: if no active ride exists we still return 204.
	if ride, err := h.uc.GetActiveRide(c.Request.Context(), driverID); err == nil {
		_ = h.upsert.PublishToUser(c.Request.Context(), ride.PassengerID, ws.EventDriverLocationUpdated, gin.H{
			"driver_id": driverID,
			"location":  loc.LatLng,
			"heading":   req.Heading,
		})
	}
	c.Status(http.StatusNoContent)
}

func (h *DriverHandler) GetIncomingRide(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)
	ride, err := h.uc.GetIncomingRide(c.Request.Context(), driverID)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, dto.NewRideResponse(ride))
}
