package handler

import (
	"context"
	"errors"
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
	incidentRepo    domain.IncidentRepository
	sosPrefsRepo    domain.SosPrefsRepository
	upsert          ws.Dispatcher
}

func NewRideHandler(uc domain.RideUseCase, userRideUC usecase.UserRideUseCase, upsert ws.Dispatcher, rideRepo domain.RideRepository, userRepo domain.UserRepository, driverRepo domain.DriverRepository, paymentRepo domain.RidePaymentRepository) *RideHandler {
	return &RideHandler{uc: uc, userRideUC: userRideUC, rideRepo: rideRepo, userRepo: userRepo, driverRepo: driverRepo, paymentRepo: paymentRepo, upsert: upsert}
}

// WithIncidentRepo wires the incident repo used by the participant-driven
// `POST /incidents/:incidentId/location` endpoint. Optional — when nil the
// route 503s. Kept off the constructor so existing callers (and tests that
// don't exercise SOS location streaming) don't have to change shape.
func (h *RideHandler) WithIncidentRepo(repo domain.IncidentRepository) *RideHandler {
	h.incidentRepo = repo
	return h
}

// WithSosPrefsRepo wires the SOS opt-in store used to enforce live-location
// consent on the incident-location endpoint. Optional — when nil the endpoint
// rejects pings (fail closed).
func (h *RideHandler) WithSosPrefsRepo(repo domain.SosPrefsRepository) *RideHandler {
	h.sosPrefsRepo = repo
	return h
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
	// ride.completed carries the authoritative final fare/payment/tip data
	// that closes out the passenger receipt + driver earnings UX (RFC v2 P7).
	// Until the canonical PDF service (BE-P7.2) lands, payment lookup may
	// return nil — the payload falls back to "cash" so the mobile clients
	// stop hardcoding it locally (MOB-P7.2).
	_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideCompleted, h.buildCompletedPayload(c.Request.Context(), ride))
	respondOK(c, h.rideResponse(ride))
}

// buildCompletedPayload constructs the ride.completed payload from the
// finalised ride plus its associated payment record. Payment lookup is
// non-fatal: a missing record yields a cash-defaulted payload, which
// matches the current implicit behaviour.
func (h *RideHandler) buildCompletedPayload(ctx context.Context, ride *domain.Ride) ws.RideCompletedPayload {
	fare := 0.0
	if ride.ActualFare != nil {
		fare = *ride.ActualFare
	} else if ride.EstimatedFare != nil {
		fare = *ride.EstimatedFare
	}

	var breakdown *ws.FareBreakdown
	if ride.FareBreakdown != nil {
		bd := *ride.FareBreakdown
		breakdown = &ws.FareBreakdown{
			BaseFare:       jsonFloat(bd["base_fare"]),
			DistanceCharge: jsonFloat(bd["distance_charge"]),
			TimeCharge:     jsonFloat(bd["time_charge"]),
			BookingFee:     jsonFloat(bd["booking_fee"]),
		}
	}

	method := "cash"
	var tip *float64
	if h.paymentRepo != nil {
		if p, err := h.paymentRepo.GetByRideID(ctx, ride.ID); err == nil && p != nil {
			method = string(p.Method)
		}
	}

	return ws.RideCompletedPayload{
		RideID:        ride.ID,
		Fare:          fare,
		FareBreakdown: breakdown,
		PaymentMethod: method,
		TipAmount:     tip,
		CompletedAt:   ride.UpdatedAt.UTC(),
	}
}

// jsonFloat extracts a float from a JSONMap value, tolerating json.Number
// and the int/float ambiguity introduced by Postgres jsonb decoding.
func jsonFloat(v any) float64 {
	switch x := v.(type) {
	case float64:
		return x
	case float32:
		return float64(x)
	case int:
		return float64(x)
	case int64:
		return float64(x)
	}
	return 0
}

func (h *RideHandler) Cancel(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.CancelRideRequest
	// The cancel body is fully optional — clients may send no body at all.
	// ShouldBindJSON returns EOF on an empty body, which we treat as a valid
	// zero-value request (all fields nil / omitted).
	if c.Request.ContentLength != 0 {
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
			return
		}
	}

	userID := c.MustGet("userID").(uuid.UUID)
	role := contextUserRole(c)
	ride, err := h.uc.Cancel(c.Request.Context(), userID, role, rideID, req.ReasonCode, req.ReasonText)
	if err != nil {
		// Race lost: another actor cancelled first. Surface the current
		// ride snapshot so the client can reconcile UI without a second
		// REST round-trip (RFC v2 §8 C9). The client should still receive
		// the canonical ride.cancelled WS event published by the winner.
		if errors.Is(err, domain.ErrCancelRaceLost) && ride != nil {
			c.JSON(http.StatusConflict, gin.H{
				"code":            "CANCEL_RACE_LOST",
				"message":         err.Error(),
				"current_status":  ride.Status,
				"cancelled_by":    ride.CancelledBy,
				"cancellation_reason": ride.CancellationReason,
			})
			return
		}
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

	// Publish SOS event to WebSocket for system monitoring or ride participants.
	// Uses a typed payload — dispatcher merges into the routing envelope via
	// `mergePayloadFields`, so all fields survive the Redis bus.
	ride, rideErr := h.rideRepo.GetByID(c.Request.Context(), rideID)
	if rideErr == nil {
		var reason *string
		if req.Reason != "" {
			r := req.Reason
			reason = &r
		}
		payload := ws.RideSOSPayload{
			RideID:      ride.ID,
			IncidentID:  incident.ID,
			TriggeredBy: incident.TriggeredBy,
			Reason:      reason,
		}
		_ = h.upsert.PublishToRide(c.Request.Context(), ride, ws.EventRideSOS, payload)
	}

	respondOK(c, dto.NewIncidentDTO(incident))
}

// AppendIncidentLocation persists a participant-driven GPS ping for an open
// incident and fans out a `sos.location_stream` event to both ride parties.
//
// Auth: the caller must be either the passenger or assigned driver on the
// ride that owns the incident, and the incident must still be unresolved.
// We deliberately keep the request body minimal (lat/lng + optional
// recorded_at_client) so this route works under flaky cellular conditions
// where any extra serialization adds risk.
//
// OUTSTANDING (MOB-P6 client wiring):
//   - Passenger app: when sos_safety_prefs.liveLocationOptIn is true AND an
//     incident is active, push GPS every 5s to this endpoint. Repo lives at
//     mobile/passenger/lib/features/support/repositories/sos_repository_impl.dart
//     — getActiveIncident() is currently stubbed to null; needs to subscribe
//     to the sos.* WS events to know when an incident is open.
//   - Driver app: same flow gated on a driver-side liveLocation toggle (not
//     yet built — driver settings screen would need to mirror the passenger
//     SOS & Safety screen for parity).
//   - Both apps must NEVER push before opt-in; the privacy invariant is
//     enforced UI-side, not server-side, so a bug in the toggle gate would
//     leak coordinates.
func (h *RideHandler) AppendIncidentLocation(c *gin.Context) {
	if h.incidentRepo == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": "FEATURE_DISABLED", "message": "incident location streaming not configured"})
		return
	}
	incidentID, err := uuid.Parse(c.Param("incidentId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid incident ID"})
		return
	}
	var req dto.IncidentLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if req.Lat < -90 || req.Lat > 90 || req.Lng < -180 || req.Lng > 180 {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "lat/lng out of range"})
		return
	}

	ctx := c.Request.Context()
	incident, err := h.incidentRepo.GetIncidentByID(ctx, incidentID)
	if err != nil {
		respondError(c, err)
		return
	}
	if incident.ResolvedAt != nil {
		c.JSON(http.StatusConflict, gin.H{"code": "INCIDENT_RESOLVED", "message": "incident is already resolved"})
		return
	}

	userID := c.MustGet("userID").(uuid.UUID)
	if userID != incident.RiderID && userID != incident.DriverID {
		c.JSON(http.StatusForbidden, gin.H{"code": "NOT_PARTICIPANT", "message": "only ride participants may stream incident location"})
		return
	}

	// Privacy: enforce live-location opt-in server-side (SOS). Opt-in defaults
	// to false; an opted-out participant cannot stream coordinates.
	if h.sosPrefsRepo == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": "FEATURE_DISABLED", "message": "live-location opt-in store not configured"})
		return
	}
	optIn, err := h.sosPrefsRepo.GetLiveLocationOptIn(ctx, userID)
	if err != nil {
		respondError(c, err)
		return
	}
	if !optIn {
		c.JSON(http.StatusForbidden, gin.H{"code": "LIVE_LOCATION_OPT_OUT", "message": "live location sharing is disabled for this user"})
		return
	}

	ping, err := h.incidentRepo.RecordIncidentLocation(ctx, incidentID, userID, req.Lat, req.Lng)
	if err != nil {
		respondError(c, err)
		return
	}

	ride, rideErr := h.rideRepo.GetByID(ctx, incident.RideID)
	if rideErr == nil {
		_ = h.upsert.PublishToRide(ctx, ride, ws.EventSosLocationStream, ws.SosLocationStreamPayload{
			RideID:     incident.RideID,
			IncidentID: incidentID,
			ActorID:    userID,
			Location:   ws.LatLng{Lat: ping.Lat, Lng: ping.Lng},
			RecordedAt: ping.RecordedAt,
		})
	}

	c.JSON(http.StatusAccepted, gin.H{
		"incident_id": incidentID,
		"actor_id":    userID,
		"lat":         ping.Lat,
		"lng":         ping.Lng,
		"recorded_at": ping.RecordedAt,
	})
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
