package domain

//go:generate go run go.uber.org/mock/mockgen -destination=mocks/mock_ports.go -package=mocks github.com/sakai/backend/internal/domain UserRepository,TokenRepository,RideRepository,DriverRepository,AdminRepository,FareRepository,AuditRepository,IncidentRepository,SystemMetricsRepository,AuthUseCase,RideUseCase,DriverUseCase,AdminUseCase,FareUseCase,AuditUseCase

import (
	"context"
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
	UpdateStatus(ctx context.Context, id uuid.UUID, status RideStatus) error

	// AssignDriver sets the driver_id on a ride in the requested state.
	AssignDriver(ctx context.Context, rideID, driverID uuid.UUID) error

	// ClearDriver sets driver_id to NULL, used when a driver declines a ride.
	ClearDriver(ctx context.Context, rideID uuid.UUID) error

	// SetCancelled transitions a ride to cancelled and records who cancelled.
	SetCancelled(ctx context.Context, id uuid.UUID, by CancelledBy) error

	// CancelExpiredOffers cancels all rides that have been in "requested" status
	// for longer than timeout. Returns the identity of the cancelled rides.
	// Called periodically by the offer-expiry background worker.
	CancelExpiredOffers(ctx context.Context, timeout time.Duration) ([]ExpiredOffer, error)

	// ListAll returns a paginated list of all rides for admin browsing.
	ListAll(ctx context.Context, filter AdminRideFilter) ([]*Ride, int, error)
}

// ExpiredOffer contains the identity of a ride canceled due to dispatch timeout.
type ExpiredOffer struct {
	RideID      uuid.UUID
	PassengerID uuid.UUID
}

// DriverRepository manages driver operational state and location.
type DriverRepository interface {
	// Create initialises a driver record when a driver-role user registers.
	Create(ctx context.Context, driver *Driver) error

	// GetByUserID retrieves a driver's operational state by their user ID.
	GetByUserID(ctx context.Context, userID uuid.UUID) (*Driver, error)

	// UpdateStatus sets the driver online or offline.
	UpdateStatus(ctx context.Context, userID uuid.UUID, status DriverStatus) error

	// UpdateLocation persists the driver's latest geographic position.
	// Called frequently — implementation must be efficient (upsert pattern).
	UpdateLocation(ctx context.Context, userID uuid.UUID, loc DriverLocation) error

	// FindNearbyOnline returns online drivers within radiusMeters of origin,
	// ordered by distance ascending. Uses PostGIS ST_DWithin for efficiency.
	FindNearbyOnline(ctx context.Context, origin LatLng, radiusMeters float64) ([]*Driver, error)
}

// AdminRepository defines management of admin accounts and system settings.
type AdminRepository interface {
	GetAdmins(ctx context.Context) ([]*User, error)
	UpdateAdminStatus(ctx context.Context, id uuid.UUID, status UserRole) error
	// Extra config persistence (payments, commission)
	GetPaymentConfigs(ctx context.Context) ([]*PaymentGatewayConfig, error)
	UpdatePaymentConfig(ctx context.Context, config *PaymentGatewayConfig) error
	GetCommissionSettings(ctx context.Context) ([]*CommissionSettings, error)
	UpdateCommissionSettings(ctx context.Context, settings *CommissionSettings) error
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
}

// SystemMetricsRepository aggregates platform-wide KPIs.
type SystemMetricsRepository interface {
	GetDashboardMetrics(ctx context.Context) (*DashboardMetrics, error)
}

type DashboardMetrics struct {
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
}

// RideUseCase defines the ride lifecycle contract.
type RideUseCase interface {
	RequestRide(ctx context.Context, passengerID uuid.UUID, origin, destination LatLng, originAddr, destAddr, notes, idempotencyKey string) (*Ride, error)
	GetActive(ctx context.Context, userID uuid.UUID, role UserRole) (*Ride, error)
	GetByID(ctx context.Context, userID uuid.UUID, rideID uuid.UUID) (*Ride, error)
	Accept(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Decline(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Arrive(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Start(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Complete(ctx context.Context, driverID, rideID uuid.UUID) (*Ride, error)
	Cancel(ctx context.Context, userID uuid.UUID, role UserRole, rideID uuid.UUID) (*Ride, error)
}

// DriverUseCase defines driver operational actions.
type DriverUseCase interface {
	SetStatus(ctx context.Context, driverID uuid.UUID, status DriverStatus) error
	UpdateLocation(ctx context.Context, driverID uuid.UUID, loc DriverLocation) error
	GetIncomingRide(ctx context.Context, driverID uuid.UUID) (*Ride, error)
	// GetActiveRide returns the driver's current active ride regardless of state.
	// Used by the HTTP handler to forward location updates to the passenger.
	GetActiveRide(ctx context.Context, driverID uuid.UUID) (*Ride, error)
}

// AdminRideFilter is the filter/pagination input for admin ride browsing.
type AdminRideFilter struct {
	Status *RideStatus // optional — nil means all statuses
	Page   int         // 1-based; 0 treated as 1
	Limit  int         // max rows; 0 defaults to 20
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
	CreateAdmin(ctx context.Context, actorID uuid.UUID, name, email, password string, role UserRole) (*User, error)
	UpdateAdminStatus(ctx context.Context, actorID, targetID uuid.UUID, status UserRole) error

	// Ride browsing (admin)
	ListRides(ctx context.Context, filter AdminRideFilter) ([]*AdminRideItem, PaginationMeta, error)

	// User browsing (admin)
	ListUsers(ctx context.Context, filter UserListFilter) ([]*User, PaginationMeta, error)

	// Safety & Incidents
	ListIncidents(ctx context.Context, status *string) ([]*Incident, error)
	ResolveIncident(ctx context.Context, actorID, incidentID uuid.UUID, notes string) error
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
}
