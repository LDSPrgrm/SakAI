package domain

//go:generate go run go.uber.org/mock/mockgen -destination=mocks/mock_ports.go -package=mocks github.com/sakai/backend/internal/domain UserRepository,TokenRepository,RideRepository,DriverRepository,AdminRepository,FareRepository,AuditRepository,IncidentRepository,SosPrefsRepository,SystemMetricsRepository,RoleRepository,PaymentRepository,SafetyRepository,SystemRepository,ReportRepository,MetricsRepository,DocumentRepository,RatingRepository,RidePaymentRepository,SavedPlaceRepository,PromotionRepository,AuthUseCase,RideUseCase,DriverUseCase,AdminUseCase,FareUseCase,AuditUseCase,RoleUseCase,PaymentUseCase,SafetyUseCase,SystemUseCase,ReportUseCase,MetricsUseCase,DocumentUseCase,RatingUseCase,PaymentProcessingUseCase,TipUseCase,SavedPlaceUseCase,PromotionUseCase,StripeClient,EarningsRepository

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// ─── Auth Output ─────────────────────────────────────────────────────────────

// AuthOutput carries the token pair returned after successful auth operations.
type AuthOutput struct {
	AccessToken          string
	RefreshToken         string
	AccessTokenExpiresAt time.Time
	User                 *User
}

// DeclineResult carries the outcome of a ride decline, including any re-matched driver.
type DeclineResult struct {
	Ride           *Ride
	NewDriverID    *uuid.UUID // set when a new driver was found
	NewDriverFound bool
}

// ─── Repository Ports ────────────────────────────────────────────────────────
// These interfaces are the inner-layer contracts that the repository (postgres)
// layer must implement. Usecases depend only on these interfaces, never on
// concrete implementations.

// UserRepository defines data access for user identity.
type UserRepository interface {
	Create(ctx context.Context, user *User) error
	GetByID(ctx context.Context, id uuid.UUID) (*User, error)
	GetByEmail(ctx context.Context, email string) (*User, error)

	// CreateWithTokens atomically inserts a new user and stores their first
	// refresh token in a single DB transaction. Use this from Register to
	// prevent orphaned user records when token storage fails.
	CreateWithTokens(ctx context.Context, user *User, refreshToken string, expiresAt time.Time) error

	// ListByRole returns a paginated list of users matching the given filter.
	// search is matched case-insensitively against name and email.
	// Returns the slice and the total count (before pagination) for metadata.
	ListByRole(ctx context.Context, filter UserListFilter) ([]*User, int, error)

	// UpdatePassword sets a new bcrypt password hash for the user.
	UpdatePassword(ctx context.Context, userID uuid.UUID, passwordHash string) error

	// Delete permanently removes a user record and associated data (e.g., vehicle).
	Delete(ctx context.Context, id uuid.UUID) error
}

// TokenRepository manages opaque refresh tokens (stored server-side).
// Tokens are rotated on every use — old tokens are invalidated immediately.
type TokenRepository interface {
	// Store saves a refresh token tied to a user with an expiry.
	Store(ctx context.Context, userID uuid.UUID, token string, expiresAt time.Time) error

	// GetUserID validates the token and returns the associated user ID.
	// Returns ErrRefreshTokenInvalid if the token is expired or not found.
	GetUserID(ctx context.Context, token string) (uuid.UUID, error)

	// Delete invalidates a token (used on logout).
	Delete(ctx context.Context, token string) error

	// Rotate atomically invalidates the old token and stores the new one.
	Rotate(ctx context.Context, oldToken string, newToken string, userID uuid.UUID, expiresAt time.Time) error
}

// RideRepository manages the ride lifecycle persistence.
type RideRepository interface {
	// Create inserts a new ride. Must enforce idempotency key uniqueness.
	Create(ctx context.Context, ride *Ride) error

	// GetByID retrieves a ride by its UUID.
	GetByID(ctx context.Context, id uuid.UUID) (*Ride, error)

	// GetByIdempotencyKey returns an existing ride matching the key, or nil.
	GetByIdempotencyKey(ctx context.Context, key string) (*Ride, error)

	// GetActiveByPassengerID returns the passenger's in-flight ride (any non-terminal status).
	GetActiveByPassengerID(ctx context.Context, passengerID uuid.UUID) (*Ride, error)

	// GetActiveByDriverID returns the driver's current active ride.
	GetActiveByDriverID(ctx context.Context, driverID uuid.UUID) (*Ride, error)

	// UpdateStatus transitions a ride to a new status and bumps updated_at.
	UpdateStatus(ctx context.Context, id uuid.UUID, status RideStatus, expectedStatus RideStatus) error

	// AssignDriver sets the driver_id on a ride if it is in the expected state.
	AssignDriver(ctx context.Context, rideID, driverID uuid.UUID, expectedStatus RideStatus) error

	// ClearDriver sets driver_id to NULL if it is in the expected state.
	ClearDriver(ctx context.Context, rideID uuid.UUID, expectedStatus RideStatus) error

	// SetCancelled transitions a ride to cancelled if it matches the expected status.
	SetCancelled(ctx context.Context, id uuid.UUID, by CancelledBy, reasonCode *string, reasonText *string, cancellationFee *float64, expectedStatus RideStatus) error

	// CancelExpiredOffers cancels all rides that have been in "requested" status
	// for longer than timeout. Returns the identity of the cancelled rides.
	// Called periodically by the offer-expiry background worker.
	CancelExpiredOffers(ctx context.Context, timeout time.Duration) ([]ExpiredOffer, error)

	// ListAll returns a paginated list of all rides for admin browsing.
	ListAll(ctx context.Context, filter AdminRideFilter) ([]*Ride, int, error)

	// ListByPassengerID returns a paginated list of rides for a specific passenger.
	ListByPassengerID(ctx context.Context, passengerID uuid.UUID, filter UserRideFilter) ([]*Ride, int, error)

	// ListByDriverID returns a paginated list of rides for a specific driver.
	ListByDriverID(ctx context.Context, driverID uuid.UUID, filter UserRideFilter) ([]*Ride, int, error)

	// UpdateRideFare updates the actual fare and breakdown for a ride.
	UpdateRideFare(ctx context.Context, rideID uuid.UUID, actualFare float64, breakdown JSONMap) error

	// IncrementDeclineCount increments the decline count for a ride.
	IncrementDeclineCount(ctx context.Context, rideID uuid.UUID) error
}

// ExpiredOffer contains the identity of a ride canceled due to dispatch timeout.
type ExpiredOffer struct {
	RideID      uuid.UUID
	PassengerID uuid.UUID
	DriverID    *uuid.UUID
}

// NearbyDriver contains enriched details of a driver available for dispatch.
type NearbyDriver struct {
	ID           string  `json:"id"`
	Name         string  `json:"name"`
	VehicleMake  string  `json:"vehicle_make"`
	VehicleModel string  `json:"vehicle_model"`
	VehiclePlate string  `json:"vehicle_plate"`
	VehicleType  string  `json:"vehicle_type"`
	Rating       *float64 `json:"rating,omitempty"`
	DistanceM    float64 `json:"distance_m"`
	Lat          float64 `json:"-"` // not serialized directly
	Lng          float64 `json:"-"` // not serialized directly
	Heading      *float64 `json:"heading,omitempty"`
}

// Location returns the nested location object expected by the mobile API client.
func (n NearbyDriver) Location() map[string]float64 {
	return map[string]float64{
		"lat": n.Lat,
		"lng": n.Lng,
	}
}

// MarshalJSON ensures the location is serialized as a nested object.
func (n NearbyDriver) MarshalJSON() ([]byte, error) {
	type Alias NearbyDriver
	return json.Marshal(&struct {
		Alias
		Location map[string]float64 `json:"location"`
	}{
		Alias:    Alias(n),
		Location: n.Location(),
	})
}

// DriverRepository manages driver operational state and location.
type DriverRepository interface {
	// Create initialises a driver record when a driver-role user registers.
	Create(ctx context.Context, driver *Driver) error

	// GetByUserID retrieves a driver's operational state by their user ID.
	GetByUserID(ctx context.Context, userID uuid.UUID) (*Driver, error)

	// UpdateStatus sets the driver online or offline and returns the updated entity.
	UpdateStatus(ctx context.Context, userID uuid.UUID, status DriverStatus) (*Driver, error)

	// UpdateLocation persists the driver's latest geographic position.
	// Called frequently — implementation must be efficient (upsert pattern).
	UpdateLocation(ctx context.Context, userID uuid.UUID, loc DriverLocation) error

	// FindNearbyOnline returns online drivers within radiusMeters of origin,
	// ordered by distance ascending. Uses PostGIS ST_DWithin for efficiency.
	FindNearbyOnline(ctx context.Context, origin LatLng, radiusMeters float64) ([]*Driver, error)

	// FindNearbyOnlineByType returns online drivers of a specific vehicle type
	// within radiusMeters of origin, ordered by distance ascending.
	FindNearbyOnlineByType(ctx context.Context, lat, lng float64, radiusM float64, rideType RideType) ([]NearbyDriver, error)

	// FindNearbyOnlineAllTypes returns online drivers of all vehicle types
	// within radiusMeters of origin in a single query, capped per vehicle type.
	FindNearbyOnlineAllTypes(ctx context.Context, lat, lng float64, radiusM float64) ([]NearbyDriver, error)
}

// AdminRepository defines management of admin accounts and system settings.
type AdminRepository interface {
	GetAdmins(ctx context.Context) ([]*User, error)
	UpdateAdminProfile(ctx context.Context, id uuid.UUID, name, email string, role UserRole, roleID uuid.UUID) error
	DeactivateAdmin(ctx context.Context, id uuid.UUID) error
	// Extra config persistence (payments, commission)
	GetPaymentConfigs(ctx context.Context) ([]*PaymentGatewayConfig, error)
	UpdatePaymentConfig(ctx context.Context, config *PaymentGatewayConfig) error
	GetCommissionSettings(ctx context.Context) ([]*CommissionSettings, error)
	UpdateCommissionSettings(ctx context.Context, settings *CommissionSettings) error
}

// RoleRepository manages dynamic RBAC roles.
type RoleRepository interface {
	ListRoles(ctx context.Context) ([]*Role, error)
	CreateRole(ctx context.Context, role *Role) error
	GetRoleByID(ctx context.Context, id uuid.UUID) (*Role, error)
	UpdateRole(ctx context.Context, role *Role) error
	DeleteRole(ctx context.Context, id uuid.UUID) error
	GetRolePermissions(ctx context.Context, roleID uuid.UUID) ([]RolePermission, error)
	GetAdminsByRole(ctx context.Context, roleID uuid.UUID) ([]*User, error)
}

// PaymentRepository handles financial data access.
type PaymentRepository interface {
	ListTransactions(ctx context.Context, page, limit int) ([]*Transaction, int, error)
	GetPaymentSummary(ctx context.Context) (*PaymentSummary, error)
	ListPayouts(ctx context.Context) ([]*DriverPayout, error)
	ApprovePayout(ctx context.Context, id uuid.UUID) error
	GetGatewayConfigs(ctx context.Context) ([]*PaymentGatewayConfig, error)
	UpdateGatewayConfig(ctx context.Context, config *PaymentGatewayConfig) error
	GetCommissionSettings(ctx context.Context) ([]*CommissionSettings, error)
	UpdateCommissionSettings(ctx context.Context, settings *CommissionSettings) error
}

// SafetyRepository handles KYC and compliance data.
type SafetyRepository interface {
	ListKyc(ctx context.Context) ([]*KycEntry, error)
	UpdateKycStatus(ctx context.Context, id uuid.UUID, status string, reason string) error
	GetCompliance(ctx context.Context) (*ComplianceData, error)
}

// SystemRepository manages platform configuration and health.
type SystemRepository interface {
	ListServices(ctx context.Context) ([]*SystemService, error)
	ListFeatureFlags(ctx context.Context) ([]*FeatureFlag, error)
	UpdateFeatureFlag(ctx context.Context, key string, enabled bool) error
	ListIntegrations(ctx context.Context) ([]*Integration, error)
	UpdateIntegration(ctx context.Context, service string, config map[string]string) error
	ListNotificationTemplates(ctx context.Context) ([]*NotificationTemplate, error)
	UpdateNotificationTemplate(ctx context.Context, event string, subject, body string) error
	// RecordProbe appends a health-probe row used by the System Health dashboard
	// and 24h uptime rollup. Called from infrastructure/health.Prober.
	RecordProbe(ctx context.Context, name, status string, latencyMs int, errMsg string) error
	// RecordIntegrationTest stamps the outcome of a manual Test Connection on an
	// integration. Consumed by the UI to show last-tested timestamps + status.
	RecordIntegrationTest(ctx context.Context, service string, ok bool, latencyMs int, message string) error
	// GetIntegrationRaw returns the unmasked config map for a given service, used
	// server-side when calling out to the external provider. Must not be
	// returned directly to the frontend.
	GetIntegrationRaw(ctx context.Context, service string) (map[string]string, error)
	// RecordHTTPTiming appends a single request duration sample for the System
	// Health dashboard. Called from the perf middleware.
	RecordHTTPTiming(ctx context.Context, method, path string, statusCode int, durationMs float64) error
	// GetInfraMetrics returns aggregated request-path stats + the latest DB/WS
	// figures consumed by SystemHealth.tsx.
	GetInfraMetrics(ctx context.Context) (*InfraMetrics, error)
}

// InfraMetrics is the aggregated snapshot shown on SystemHealth.
type InfraMetrics struct {
	APIP50Ms        float64 `json:"api_p50_ms"`
	APIP95Ms        float64 `json:"api_p95_ms"`
	WSConnections   int     `json:"ws_connections"`
	DBQueryP99Ms    float64 `json:"db_query_p99_ms"`
	SampleCount     int     `json:"sample_count"`
	WindowMinutes   int     `json:"window_minutes"`
}

// ReportRepository provides report data.
type ReportRepository interface {
	ListReports(ctx context.Context) ([]*ReportDefinition, error)
	GetChartData(ctx context.Context, reportType string, from, to *time.Time) ([]map[string]interface{}, error)
	ExportReport(ctx context.Context, reportType string, from, to *time.Time) ([]byte, error)
}

// MetricsRepository provides individual KPI metrics.
type MetricsRepository interface {
	GetRiderMetrics(ctx context.Context) (*MetricResponse, error)
	GetDriverMetrics(ctx context.Context) (*MetricResponse, error)
	GetRideMetrics(ctx context.Context, period string) (*MetricResponse, error)
	GetRevenueMetrics(ctx context.Context, period string) (*MetricResponse, error)
	GetWaitTimeMetrics(ctx context.Context) (*MetricResponse, error)
	// GetDriverHeatmap returns the current online drivers' last-known
	// PostGIS positions joined with vehicle type and ride availability.
	GetDriverHeatmap(ctx context.Context) (*DriverHeatmap, error)
}

// FareRepository manages pricing rules.
type FareRepository interface {
	GetFareConfigs(ctx context.Context) ([]*FareConfig, error)
	UpdateFareConfig(ctx context.Context, config *FareConfig) error
	GetSurgeConfig(ctx context.Context) (*SurgeConfig, error)
	UpdateSurgeConfig(ctx context.Context, config *SurgeConfig) error
}

// AuditRepository handles the immutable record of admin actions.
type AuditRepository interface {
	Store(ctx context.Context, entry *AuditLogEntry) error
	List(ctx context.Context, query AuditQuery) ([]*AuditLogEntry, int, error)
}

type AuditQuery struct {
	ActorID      *uuid.UUID
	ResourceType *string
	Action       *string
	Page         int
	Limit        int
}

// IncidentRepository tracks safety and compliance triggers.
type IncidentRepository interface {
	ListIncidents(ctx context.Context, status *string) ([]*Incident, error)
	GetIncidentByID(ctx context.Context, id uuid.UUID) (*Incident, error)
	UpdateIncident(ctx context.Context, id uuid.UUID, status string, notes string, assignedTo *uuid.UUID) error
	// ListStatusHistory returns the SOS timeline rows written by the DB
	// trigger on incidents, oldest first.
	ListStatusHistory(ctx context.Context, id uuid.UUID) ([]*IncidentStatusEvent, error)
	// AssignIncident sets assigned_to (nullable) and is recorded in the
	// history via trigger.
	AssignIncident(ctx context.Context, id uuid.UUID, assigneeID *uuid.UUID) error
	// ListLocationTrail returns GPS pings captured while the incident was
	// open, oldest first. Empty slice when no pings were recorded.
	ListLocationTrail(ctx context.Context, id uuid.UUID) ([]*IncidentLocationPoint, error)
	// FindActiveByDriver returns the IDs of any currently-unresolved incidents
	// involving this driver. Called from the driver location hot path — uses
	// the partial index idx_incidents_active_driver so the empty case is O(1).
	FindActiveByDriver(ctx context.Context, driverID uuid.UUID) ([]uuid.UUID, error)
	// RecordLocationPing appends one trail point bound to an incident_id.
	// Called only when FindActiveByDriver returned at least one id.
	RecordLocationPing(ctx context.Context, incidentID, driverID uuid.UUID, lat, lng float64) error

	// RecordIncidentLocation appends one trail point attributed to any ride
	// participant (passenger OR driver). Used by the participant-driven
	// `POST /incidents/:id/location` endpoint. Returns the recorded ping
	// so the handler can publish a `sos.location_stream` WS event with the
	// authoritative server timestamp.
	RecordIncidentLocation(ctx context.Context, incidentID, actorID uuid.UUID, lat, lng float64) (*IncidentLocationPoint, error)

	// Create inserts a new incident record.
	Create(ctx context.Context, incident *Incident) error
}

// SosPrefsRepository stores per-user SOS live-location opt-in.
type SosPrefsRepository interface {
	// GetLiveLocationOptIn returns false (fail closed) when no row exists.
	GetLiveLocationOptIn(ctx context.Context, userID uuid.UUID) (bool, error)
	SetLiveLocationOptIn(ctx context.Context, userID uuid.UUID, optIn bool) error
}

// SystemMetricsRepository aggregates platform-wide KPIs.
type SystemMetricsRepository interface {
	GetDashboardMetrics(ctx context.Context) (*DashboardMetrics, error)
}

type DashboardMetrics struct {
	// Total* are raw user counts (ever-registered).
	TotalRiders  int
	TotalDrivers int
	// Active* are last-30-day engagement counts derived from rides.
	ActiveRiders       int
	ActiveDrivers      int
	RidesToday         int
	RevenueToday       float64
	AvgWaitTimeSeconds float64
	SystemUptime       float64
}

// ─── UseCase Ports ───────────────────────────────────────────────────────────
// These interfaces are consumed by the delivery layer. The delivery layer
// depends only on these abstractions, never on usecase implementations.

// AuthUseCase defines the authentication contract.
type AuthUseCase interface {
	Register(ctx context.Context, name, email, password string, role UserRole, vehicle *Vehicle) (*AuthOutput, error)
	Login(ctx context.Context, email, password string) (*AuthOutput, error)
	Refresh(ctx context.Context, refreshToken string) (*AuthOutput, error)
	Logout(ctx context.Context, refreshToken string) error
	// GetUserByID is a helper for the auth middleware and /users/me endpoint.
	GetUserByID(ctx context.Context, id uuid.UUID) (*User, error)
	ChangePassword(ctx context.Context, userID uuid.UUID, oldPassword, newPassword string) error
	DeleteAccount(ctx context.Context, userID uuid.UUID) error
}

// RideUseCase defines the ride lifecycle contract.
type RideUseCase interface {
	RequestRide(ctx context.Context, passengerID uuid.UUID, origin, destination LatLng, originAddr, destAddr, notes, idempotencyKey string, rideType RideType, paymentMethod PaymentMethod) (*Ride, error)
	GetActive(ctx context.Context, userID uuid.UUID, role UserRole) (*Ride, error)
	GetByID(ctx context.Context, userID uuid.UUID, rideID uuid.UUID) (*Ride, error)
	Accept(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Decline(ctx context.Context, driverID, rideID uuid.UUID) (*DeclineResult, error)
	Arrive(ctx context.Context, driverID, rideID uuid.UUID, driverLocation LatLng) (*Ride, error)
	Start(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Complete(ctx context.Context, driverID, rideID uuid.UUID, driverLocation LatLng) (*Ride, error)
	Cancel(ctx context.Context, userID uuid.UUID, role UserRole, rideID uuid.UUID, reasonCode *string, reasonText *string) (*Ride, error)
	TriggerSOS(ctx context.Context, userID uuid.UUID, role UserRole, rideID uuid.UUID, reason string) (*Incident, error)
}

// DriverUseCase defines driver operational actions.
type DriverUseCase interface {
	SetStatus(ctx context.Context, driverID uuid.UUID, status DriverStatus) (*Driver, error)
	UpdateLocation(ctx context.Context, driverID uuid.UUID, loc DriverLocation) error
	GetIncomingRide(ctx context.Context, driverID uuid.UUID) (*Ride, error)
	// GetActiveRide returns the driver's current active ride regardless of state.
	// Used by the HTTP handler to forward location updates to the passenger.
	GetActiveRide(ctx context.Context, driverID uuid.UUID) (*Ride, error)
	// GetNearbyDrivers returns online drivers of a specific vehicle type within a radius.
	GetNearbyDrivers(ctx context.Context, lat, lng float64, radiusM float64, rideType RideType) ([]NearbyDriver, error)
	// GetNearbyDriversAllTypes returns online drivers grouped by vehicle type.
	GetNearbyDriversAllTypes(ctx context.Context, lat, lng float64, radiusM float64) (map[RideType][]NearbyDriver, error)
	// GetEarnings lists earnings for the authenticated driver over an optional
	// date range with pagination.
	GetEarnings(ctx context.Context, driverID uuid.UUID, from, to *time.Time, page, limit int) ([]*DriverEarnings, int, error)
	// GetStatus returns the current operational status of a driver.
	GetStatus(ctx context.Context, driverID uuid.UUID) (*Driver, error)
}

// AdminRideFilter is the filter/pagination input for admin ride browsing.
type AdminRideFilter struct {
	Status *RideStatus // optional — nil means all statuses
	Page   int         // 1-based; 0 treated as 1
	Limit  int         // max rows; 0 defaults to 20
}

// UserRideFilter is the filter/pagination input for passenger ride history.
type UserRideFilter struct {
	Statuses []RideStatus // optional — empty means all statuses
	Page     int          // 1-based; 0 treated as 1
	Limit    int          // max rows; 0 defaults to 20
}

// UserListFilter is the filter/pagination input for admin user browsing.
type UserListFilter struct {
	Role   *UserRole // nil means all roles
	Search string    // case-insensitive substring match on name or email
	Page   int
	Limit  int
}

// AdminRideItem is a read-only projection of a ride enriched with participant names.
type AdminRideItem struct {
	Ride          *Ride
	PassengerName string
	DriverName    string // empty when no driver is assigned
}

// AdminDriverItem pairs a user record with their driver operational state.
type AdminDriverItem struct {
	User          *User
	DriverStatus  DriverStatus
}

// PaginationMeta carries page metadata for list responses.
type PaginationMeta struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

// AdminUseCase defines the business logic for platform administration.
type AdminUseCase interface {
	GetDashboard(ctx context.Context) (*DashboardMetrics, error)
	ListAdmins(ctx context.Context) ([]*User, error)
	CreateAdmin(ctx context.Context, actorID uuid.UUID, name, email, password string, role UserRole, roleID *uuid.UUID) (*User, error)
	UpdateAdminStatus(ctx context.Context, actorID, targetID uuid.UUID, name, email *string, roleID uuid.UUID) error
	DeactivateAdmin(ctx context.Context, actorID, targetID uuid.UUID) error
	GetAdminActivity(ctx context.Context, adminID uuid.UUID) ([]*AuditLogEntry, error)
	// ResetUserPassword lets a superadmin set another admin's password.
	// Distinct from AuthUseCase.ChangePassword which requires the old password.
	ResetUserPassword(ctx context.Context, actorID, targetID uuid.UUID, newPassword string) error

	// Ride browsing (admin)
	ListRides(ctx context.Context, filter AdminRideFilter) ([]*AdminRideItem, PaginationMeta, error)

	// User browsing (admin)
	ListUsers(ctx context.Context, filter UserListFilter) ([]*User, PaginationMeta, error)

	// Safety & Incidents
	ListIncidents(ctx context.Context, status *string) ([]*Incident, error)
	GetIncident(ctx context.Context, incidentID uuid.UUID) (*IncidentDetail, error)
	ResolveIncident(ctx context.Context, actorID, incidentID uuid.UUID, notes string) error
	AssignIncident(ctx context.Context, actorID, incidentID uuid.UUID, assigneeID *uuid.UUID) error
}

// FareUseCase handles pricing configuration and simulation.
type FareUseCase interface {
	GetConfig(ctx context.Context) ([]*FareConfig, *SurgeConfig, error)
	UpdateFares(ctx context.Context, actorID uuid.UUID, configs []*FareConfig) error
	UpdateSurge(ctx context.Context, actorID uuid.UUID, config *SurgeConfig) error
	SimulateFare(ctx context.Context, vehicleType string, origin, destination LatLng) (float64, error)
}

// AuditUseCase provides auditing services to other system components.
type AuditUseCase interface {
	LogAction(ctx context.Context, entry *AuditLogEntry) error
	GetLogs(ctx context.Context, query AuditQuery) ([]*AuditLogEntry, int, error)
	ExportLogs(ctx context.Context, query AuditQuery) ([]byte, error)
}

// RoleUseCase manages dynamic RBAC roles.
type RoleUseCase interface {
	ListRoles(ctx context.Context) ([]*Role, error)
	CreateRole(ctx context.Context, actorID uuid.UUID, name, description string, permissions []RolePermission) (*Role, error)
	GetRole(ctx context.Context, id uuid.UUID) (*Role, error)
	UpdateRole(ctx context.Context, actorID, roleID uuid.UUID, name, description string, permissions []RolePermission) (*Role, error)
	DeleteRole(ctx context.Context, actorID, roleID uuid.UUID) error
	GetRolePermissions(ctx context.Context, roleID uuid.UUID) ([]RolePermission, error)
	GetRoleAdmins(ctx context.Context, roleID uuid.UUID) ([]*User, error)
	// DuplicateRole clones an existing role ("Copy of <name>") with the same permissions.
	DuplicateRole(ctx context.Context, actorID, roleID uuid.UUID) (*Role, error)
}

// PaymentUseCase handles payment operations.
type PaymentUseCase interface {
	ListTransactions(ctx context.Context, page, limit int) ([]*Transaction, int, error)
	GetSummary(ctx context.Context) (*PaymentSummary, error)
	ListPayouts(ctx context.Context) ([]*DriverPayout, error)
	ApprovePayout(ctx context.Context, actorID, payoutID uuid.UUID) error
	BatchApprovePayouts(ctx context.Context, actorID uuid.UUID, ids []uuid.UUID) (int, error)
	GetGatewayConfigs(ctx context.Context) ([]*PaymentGatewayConfig, error)
	UpdateGatewayConfig(ctx context.Context, actorID uuid.UUID, config *PaymentGatewayConfig) error
	GetCommissionSettings(ctx context.Context) ([]*CommissionSettings, error)
	UpdateCommissionSettings(ctx context.Context, actorID uuid.UUID, settings *CommissionSettings) error
}

// SafetyUseCase handles KYC and compliance operations.
type SafetyUseCase interface {
	ListKyc(ctx context.Context) ([]*KycEntry, error)
	UpdateKyc(ctx context.Context, actorID, kycID uuid.UUID, status, reason string) error
	BatchKyc(ctx context.Context, actorID uuid.UUID, ids []uuid.UUID, status string) (int, error)
	GetCompliance(ctx context.Context) (*ComplianceData, error)
}

// SystemUseCase manages platform configuration.
type SystemUseCase interface {
	ListServices(ctx context.Context) ([]*SystemService, error)
	ListFeatureFlags(ctx context.Context) ([]*FeatureFlag, error)
	UpdateFeatureFlag(ctx context.Context, actorID uuid.UUID, key string, enabled bool) error
	ListIntegrations(ctx context.Context) ([]*Integration, error)
	UpdateIntegration(ctx context.Context, actorID uuid.UUID, service string, config map[string]string) error
	TestIntegration(ctx context.Context, service string) (*SystemService, error)
	ListNotificationTemplates(ctx context.Context) ([]*NotificationTemplate, error)
	UpdateNotificationTemplate(ctx context.Context, actorID uuid.UUID, event, subject, body string) error
	GetInfraMetrics(ctx context.Context) (*InfraMetrics, error)
}

// ReportUseCase provides analytics reports.
type ReportUseCase interface {
	ListReports(ctx context.Context) ([]*ReportDefinition, error)
	GetChartData(ctx context.Context, reportType string, from, to *time.Time) ([]map[string]interface{}, error)
	ExportReport(ctx context.Context, reportType string, from, to *time.Time) ([]byte, error)
}

// MetricsUseCase provides individual KPI metrics for the dashboard.
type MetricsUseCase interface {
	GetRiderMetrics(ctx context.Context) (*MetricResponse, error)
	GetDriverMetrics(ctx context.Context) (*MetricResponse, error)
	GetRideMetrics(ctx context.Context, period string) (*MetricResponse, error)
	GetRevenueMetrics(ctx context.Context, period string) (*MetricResponse, error)
	GetWaitTimeMetrics(ctx context.Context) (*MetricResponse, error)
	GetDriverHeatmap(ctx context.Context) (*DriverHeatmap, error)
}

// ─── New Repository Ports for Documents, Ratings, Payments ───────────────────

// DocumentRepository manages driver verification documents.
type DocumentRepository interface {
	// Create inserts a new driver document record.
	Create(ctx context.Context, doc *DriverDocument) error

	// GetByID retrieves a document by its UUID.
	GetByID(ctx context.Context, id uuid.UUID) (*DriverDocument, error)

	// ListByDriverID returns all documents for a driver.
	ListByDriverID(ctx context.Context, driverID uuid.UUID) ([]*DriverDocument, error)

	// UpdateStatus changes the verification status of a document.
	UpdateStatus(ctx context.Context, id uuid.UUID, status UploadStatus, rejectionReason *string, reviewedAt time.Time, reviewedBy uuid.UUID) error
}

// RatingRepository manages ride ratings.
type RatingRepository interface {
	// Create inserts a new rating.
	Create(ctx context.Context, rating *Rating) error

	// GetByRideAndRater returns an existing rating for a ride+rater pair, or nil.
	GetByRideAndRater(ctx context.Context, rideID, raterID uuid.UUID) (*Rating, error)

	// GetAverageByUserID computes the average rating and count for a user.
	GetAverageByUserID(ctx context.Context, userID uuid.UUID) (*RatingSummary, error)
}

// RidePaymentRepository manages ride-specific payment transactions.
type RidePaymentRepository interface {
	// Create inserts a new ride payment record. Supports transactions via context.
	Create(ctx context.Context, payment *Payment) error

	// GetByRideID returns the payment for a ride, or nil.
	GetByRideID(ctx context.Context, rideID uuid.UUID) (*Payment, error)

	// UpdateStatus changes the payment status. Supports transactions via context.
	UpdateStatus(ctx context.Context, id uuid.UUID, status PaymentStatus, gatewayTxnID *string, processedAt time.Time, failureReason *string) error

	// HasUnpaidBlock returns true if the passenger has any failed payment older than the given cutoff.
	HasUnpaidBlock(ctx context.Context, passengerID uuid.UUID, cutoff time.Time) (bool, error)
}

// EarningsRepository manages driver earnings persistence.
type EarningsRepository interface {
	// Create inserts a new driver earnings record (called on ride completion). Supports transactions via context.
	Create(ctx context.Context, earnings *DriverEarnings) error

	// ListByDriverID returns paginated earnings for a driver, optionally filtered by date range.
	ListByDriverID(ctx context.Context, driverID uuid.UUID, from, to *time.Time, page, limit int) ([]*DriverEarnings, int, error)
}

// StripeClient wraps the Stripe Go SDK for payment operations.
type StripeClient interface {
	// ChargePaymentMethod creates a charge against a payment method.
	// Returns a result with Success=true and ChargeID, or Success=false with FailureReason.
	ChargePaymentMethod(ctx context.Context, paymentMethodID string, amount float64, currency string, idempotencyKey string) (*StripeChargeResult, error)
}

// StripeChargeResult represents the outcome of a Stripe charge attempt.
type StripeChargeResult struct {
	Success       bool
	ChargeID      string
	FailureReason string
}

// ─── New UseCase Ports ───────────────────────────────────────────────────────

// DocumentUseCase defines the driver document upload contract.
type DocumentUseCase interface {
	// UploadDocument validates and stores a driver verification document.
	UploadDocument(ctx context.Context, driverID uuid.UUID, docType DocumentType, docNumber string, expiryDate *time.Time, imageURL string) (*DriverDocument, error)

	// GetDocument returns a document by ID (owner-only access).
	GetDocument(ctx context.Context, driverID, documentID uuid.UUID) (*DriverDocument, error)

	// ListDocuments returns all documents for a driver.
	ListDocuments(ctx context.Context, driverID uuid.UUID) ([]*DriverDocument, error)
}

// RatingUseCase defines the rating submission contract.
type RatingUseCase interface {
	// SubmitRating validates and stores a rating for a completed ride.
	SubmitRating(ctx context.Context, raterID uuid.UUID, rideID uuid.UUID, stars int, feedback *string) (*Rating, error)

	// GetRatingSummary returns the average rating and count for a user.
	GetRatingSummary(ctx context.Context, userID uuid.UUID) (*RatingSummary, error)
}

// PaymentProcessingUseCase defines the card payment processing contract.
type PaymentProcessingUseCase interface {
	// ProcessPayment charges the passenger's card for a completed ride.
	ProcessPayment(ctx context.Context, passengerID uuid.UUID, rideID uuid.UUID, paymentToken string, idempotencyKey string) (*Payment, error)

	// GetReceipt returns the payment receipt for a ride.
	GetReceipt(ctx context.Context, userID uuid.UUID, rideID uuid.UUID) (*Payment, error)
}

// TipOutput carries the result of a successful tip transaction.
type TipOutput struct {
	RideID          uuid.UUID  `json:"ride_id"`
	BaseFare        float64    `json:"base_fare"`
	TipAmount       float64    `json:"tip_amount"`
	FinalTotal      float64    `json:"final_total"`
	Currency        string     `json:"currency"`
	PaymentMethod   string     `json:"payment_method"`
	TransactionID   string     `json:"transaction_id"`
	ProcessedAt     time.Time  `json:"processed_at"`
}

// TipRepository manages tip-specific payment transactions.
type TipRepository interface {
	// AddTip stores a tip record and processes the charge via Stripe.
	AddTip(ctx context.Context, rideID uuid.UUID, tipAmount float64) (*TipOutput, error)

	// GetByRideID returns an existing tip for a ride, or nil.
	GetByRideID(ctx context.Context, rideID uuid.UUID) (*TipOutput, error)
}

// TipUseCase defines the tip submission contract.
type TipUseCase interface {
	// AddTip validates and processes a tip for a completed ride.
	AddTip(ctx context.Context, passengerID uuid.UUID, rideID uuid.UUID, tipAmount float64) (*TipOutput, error)
}

// ─── Saved Payment Method Repository ─────────────────────────────────────────

// PaymentMethodRepository manages user's saved payment methods.
type PaymentMethodRepository interface {
	// Create inserts a new saved payment method.
	Create(ctx context.Context, pm *SavedPaymentMethod) error

	// GetByID retrieves a payment method by its UUID.
	GetByID(ctx context.Context, id uuid.UUID) (*SavedPaymentMethod, error)

	// ListByUserID returns all payment methods for a user.
	ListByUserID(ctx context.Context, userID uuid.UUID) ([]*SavedPaymentMethod, error)

	// Delete removes a payment method.
	Delete(ctx context.Context, id uuid.UUID) error

	// SetDefault marks a payment method as the user's default.
	SetDefault(ctx context.Context, id uuid.UUID) error

	// ClearDefaults removes the default flag from all of a user's payment methods.
	ClearDefaults(ctx context.Context, userID uuid.UUID) error

	// ExistsByUser checks if a payment method belongs to a user (for authorization).
	ExistsByUser(ctx context.Context, id uuid.UUID, userID uuid.UUID) (bool, error)
}

// ─── Saved Places ────────────────────────────────────────────────────────────

// SavedPlaceRepository manages persistent storage for user's saved locations.
type SavedPlaceRepository interface {
	Create(ctx context.Context, place *SavedPlace) error
	GetByID(ctx context.Context, id uuid.UUID) (*SavedPlace, error)
	ListByUserID(ctx context.Context, userID uuid.UUID) ([]*SavedPlace, error)
	Update(ctx context.Context, place *SavedPlace) error
	Delete(ctx context.Context, id uuid.UUID) error
}

// SavedPlaceUseCase defines business logic for saved places.
type SavedPlaceUseCase interface {
	AddPlace(ctx context.Context, userID uuid.UUID, name, address string, lat, lng float64, placeType SavedPlaceType) (*SavedPlace, error)
	ListPlaces(ctx context.Context, userID uuid.UUID) ([]*SavedPlace, error)
	UpdatePlace(ctx context.Context, userID, placeID uuid.UUID, name, address *string, lat, lng *float64, placeType *SavedPlaceType) (*SavedPlace, error)
	DeletePlace(ctx context.Context, userID, placeID uuid.UUID) error
}

// ─── Promotions ──────────────────────────────────────────────────────────────

// PromotionRepository manages promotion data.
type PromotionRepository interface {
	GetByCode(ctx context.Context, code string) (*Promotion, error)
	ListActive(ctx context.Context) ([]*Promotion, error)
}

// PromotionUseCase defines business logic for promotions.
type PromotionUseCase interface {
	ValidateCode(ctx context.Context, code string, rideFare *float64) (*Promotion, error)
	ListActive(ctx context.Context) ([]*Promotion, error)
}

