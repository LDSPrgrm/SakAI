package handler

import (
	"log"
	"net/http"
	"strconv"
	"time"

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
	log.Printf("[DRIVER_HANDLER] UpdateLocation: driverID=%s, loc=(%.5f, %.5f)", driverID, req.Location.Lat, req.Location.Lng)
	loc := req.ToDomainDriverLocation()
	if err := h.uc.UpdateLocation(c.Request.Context(), driverID, loc); err != nil {
		log.Printf("[DRIVER_HANDLER] UpdateLocation error: %v", err)
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
	respondOK(c, dto.NewRideResponse(ride, nil))
}

// GetNearbyDrivers handles GET /drivers/nearby?lat=...&lng=...&radius=...&ride_type=...
func (h *DriverHandler) GetNearbyDrivers(c *gin.Context) {
	lat, err := strconv.ParseFloat(c.Query("lat"), 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "lat is required"})
		return
	}
	lng, err := strconv.ParseFloat(c.Query("lng"), 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "lng is required"})
		return
	}
	radius, _ := strconv.ParseFloat(c.DefaultQuery("radius", "5000"), 64)
	rideTypeStr := c.DefaultQuery("ride_type", "car")
	rideType := domain.RideType(rideTypeStr)

	drivers, err := h.uc.GetNearbyDrivers(c.Request.Context(), lat, lng, radius, rideType)
	if err != nil {
		respondError(c, err)
		return
	}

	resp := make([]dto.NearbyDriverResponse, 0, len(drivers))
	for _, d := range drivers {
		resp = append(resp, dto.NewNearbyDriverResponse(&d))
	}

	c.JSON(http.StatusOK, gin.H{"drivers": resp})
}

// GetEarnings handles GET /driver/earnings?from=&to=&page=&limit=.
func (h *DriverHandler) GetEarnings(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)

	var from, to *time.Time
	if v := c.Query("from"); v != "" {
		t, err := time.Parse("2006-01-02", v)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "from must be YYYY-MM-DD"})
			return
		}
		from = &t
	}
	if v := c.Query("to"); v != "" {
		t, err := time.Parse("2006-01-02", v)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "to must be YYYY-MM-DD"})
			return
		}
		// Include the entire end day.
		end := t.Add(24*time.Hour - time.Nanosecond)
		to = &end
	}
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if limit > 50 {
		limit = 50
	}

	items, total, err := h.uc.GetEarnings(c.Request.Context(), driverID, from, to, page, limit)
	if err != nil {
		respondError(c, err)
		return
	}

	out := make([]dto.EarningsItem, 0, len(items))
	for _, e := range items {
		out = append(out, dto.NewEarningsItem(e))
	}

	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 20
	}
	totalPages := (total + limit - 1) / limit

	c.JSON(http.StatusOK, gin.H{
		"data": out,
		"pagination": dto.PaginationMeta{
			CurrentPage: page,
			Limit:       limit,
			TotalItems:  total,
			TotalPages:  totalPages,
		},
	})
}

// GetNearbyDriversAllTypes handles GET /drivers/nearby/all?lat=...&lng=...&radius=...
// Returns drivers grouped by vehicle type in a single call.
func (h *DriverHandler) GetNearbyDriversAllTypes(c *gin.Context) {
	lat, err := strconv.ParseFloat(c.Query("lat"), 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "lat is required"})
		return
	}
	lng, err := strconv.ParseFloat(c.Query("lng"), 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "lng is required"})
		return
	}
	radius, _ := strconv.ParseFloat(c.DefaultQuery("radius", "5000"), 64)

	drivers, err := h.uc.GetNearbyDriversAllTypes(c.Request.Context(), lat, lng, radius)
	if err != nil {
		respondError(c, err)
		return
	}

	resp := make(map[domain.RideType][]dto.NearbyDriverResponse)
	for rt, list := range drivers {
		dtoList := make([]dto.NearbyDriverResponse, 0, len(list))
		for _, d := range list {
			dtoList = append(dtoList, dto.NewNearbyDriverResponse(&d))
		}
		resp[rt] = dtoList
	}

	c.JSON(http.StatusOK, resp)
}
