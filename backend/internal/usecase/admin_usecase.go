package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"golang.org/x/crypto/bcrypt"
)

// adminUseCase handles platform-level administration tasks.
type adminUseCase struct {
	adminRepo    domain.AdminRepository
	userRepo     domain.UserRepository
	rideRepo     domain.RideRepository
	incidentRepo domain.IncidentRepository
	metricsRepo  domain.SystemMetricsRepository
	auditRepo    domain.AuditRepository
}

func NewAdminUseCase(
	adminRepo domain.AdminRepository,
	userRepo domain.UserRepository,
	rideRepo domain.RideRepository,
	incidentRepo domain.IncidentRepository,
	metricsRepo domain.SystemMetricsRepository,
	auditRepo domain.AuditRepository,
) domain.AdminUseCase {
	return &adminUseCase{
		adminRepo:    adminRepo,
		userRepo:     userRepo,
		rideRepo:     rideRepo,
		incidentRepo: incidentRepo,
		metricsRepo:  metricsRepo,
		auditRepo:    auditRepo,
	}
}

func (uc *adminUseCase) GetDashboard(ctx context.Context) (*domain.DashboardMetrics, error) {
	return uc.metricsRepo.GetDashboardMetrics(ctx)
}

func (uc *adminUseCase) ListAdmins(ctx context.Context) ([]*domain.User, error) {
	return uc.adminRepo.GetAdmins(ctx)
}

func (uc *adminUseCase) CreateAdmin(ctx context.Context, actorID uuid.UUID, name, email, password string, role domain.UserRole) (*domain.User, error) {
	// 1. Business Rule: Only specific roles allowed
	if role != domain.RoleAdmin && role != domain.RoleSuperadmin && role != domain.RoleOperations && role != domain.RoleFinance && role != domain.RoleSupport {
		return nil, errors.New("invalid admin role")
	}

	// 2. Check if email exists
	if _, err := uc.userRepo.GetByEmail(ctx, email); !errors.Is(err, domain.ErrNotFound) {
		if err == nil {
			return nil, domain.ErrEmailAlreadyRegistered
		}
		return nil, err
	}

	// 3. Hash password
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &domain.User{
		ID:        uuid.New(),
		Name:      name,
		Email:     email,
		Password:  string(hash),
		Role:      role,
		CreatedAt: time.Now(),
	}

	// 4. Persist
	if err := uc.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	// 5. Audit
	after, _ := json.Marshal(user)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "CREATE",
		ResourceType: "admin_user",
		ResourceID:   user.ID.String(),
		AfterState:   after,
		IPAddress:    "internal", // This should ideally come from the request context
	})

	return user, nil
}

func (uc *adminUseCase) UpdateAdminStatus(ctx context.Context, actorID, targetID uuid.UUID, status domain.UserRole) error {
	// Business Rule: Cannot modify own role/status (prevents accidental self-demotion)
	if actorID == targetID {
		return errors.New("cannot modify own account status")
	}

	oldUser, err := uc.userRepo.GetByID(ctx, targetID)
	if err != nil {
		return err
	}

	// Business Rule: Cannot deactivate the last superadmin
	if oldUser.Role == domain.RoleSuperadmin && status != domain.RoleSuperadmin {
		admins, _ := uc.adminRepo.GetAdmins(ctx)
		superCount := 0
		for _, a := range admins {
			if a.Role == domain.RoleSuperadmin {
				superCount++
			}
		}
		if superCount <= 1 {
			return errors.New("cannot remove the last superadmin")
		}
	}

	if err := uc.adminRepo.UpdateAdminStatus(ctx, targetID, status); err != nil {
		return err
	}

	// Audit
	before, _ := json.Marshal(oldUser)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "UPDATE_STATUS",
		ResourceType: "admin_user",
		ResourceID:   targetID.String(),
		BeforeState:  before,
		AfterState:   []byte(fmt.Sprintf(`{"role": "%s"}`, status)),
		IPAddress:    "internal",
	})

	return nil
}

func (uc *adminUseCase) ListIncidents(ctx context.Context, status *string) ([]*domain.Incident, error) {
	return uc.incidentRepo.ListIncidents(ctx, status)
}

func (uc *adminUseCase) ResolveIncident(ctx context.Context, actorID, incidentID uuid.UUID, notes string) error {
	return uc.incidentRepo.UpdateIncident(ctx, incidentID, "resolved", notes, &actorID)
}

func (uc *adminUseCase) ListRides(ctx context.Context, filter domain.AdminRideFilter) ([]*domain.AdminRideItem, domain.PaginationMeta, error) {
	rides, total, err := uc.rideRepo.ListAll(ctx, filter)
	if err != nil {
		return nil, domain.PaginationMeta{}, err
	}

	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.Limit < 1 {
		filter.Limit = 20
	}

	meta := domain.PaginationMeta{
		Page:       filter.Page,
		Limit:      filter.Limit,
		Total:      total,
		TotalPages: (total + filter.Limit - 1) / filter.Limit,
	}

	items := make([]*domain.AdminRideItem, 0, len(rides))
	for _, ride := range rides {
		item := &domain.AdminRideItem{Ride: ride}
		// Best-effort enrichment: missing user names are non-fatal.
		if p, err := uc.userRepo.GetByID(ctx, ride.PassengerID); err == nil {
			item.PassengerName = p.Name
		}
		if ride.DriverID != nil {
			if d, err := uc.userRepo.GetByID(ctx, *ride.DriverID); err == nil {
				item.DriverName = d.Name
			}
		}
		items = append(items, item)
	}
	return items, meta, nil
}

func (uc *adminUseCase) ListUsers(ctx context.Context, filter domain.UserListFilter) ([]*domain.User, domain.PaginationMeta, error) {
	users, total, err := uc.userRepo.ListByRole(ctx, filter)
	if err != nil {
		return nil, domain.PaginationMeta{}, err
	}

	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.Limit < 1 {
		filter.Limit = 20
	}

	meta := domain.PaginationMeta{
		Page:       filter.Page,
		Limit:      filter.Limit,
		Total:      total,
		TotalPages: (total + filter.Limit - 1) / filter.Limit,
	}
	return users, meta, nil
}


// --- Fare Use Case ---

type fareUseCase struct {
	fareRepo  domain.FareRepository
	auditRepo domain.AuditRepository
}

func NewFareUseCase(fareRepo domain.FareRepository, auditRepo domain.AuditRepository) domain.FareUseCase {
	return &fareUseCase{
		fareRepo:  fareRepo,
		auditRepo: auditRepo,
	}
}

func (uc *fareUseCase) GetConfig(ctx context.Context) ([]*domain.FareConfig, *domain.SurgeConfig, error) {
	fares, err := uc.fareRepo.GetFareConfigs(ctx)
	if err != nil {
		return nil, nil, err
	}
	surge, err := uc.fareRepo.GetSurgeConfig(ctx)
	if err != nil {
		return nil, nil, err
	}
	return fares, surge, nil
}

func (uc *fareUseCase) UpdateFares(ctx context.Context, actorID uuid.UUID, configs []*domain.FareConfig) error {
	for _, c := range configs {
		c.UpdatedBy = actorID
		if err := uc.fareRepo.UpdateFareConfig(ctx, c); err != nil {
			return err
		}
	}
	
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "UPDATE_FARES",
		ResourceType: "fare_config",
		ResourceID:   "batch",
		IPAddress:    "internal",
	})
	return nil
}

func (uc *fareUseCase) UpdateSurge(ctx context.Context, actorID uuid.UUID, config *domain.SurgeConfig) error {
	config.UpdatedBy = actorID
	if err := uc.fareRepo.UpdateSurgeConfig(ctx, config); err != nil {
		return err
	}

	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "UPDATE_SURGE",
		ResourceType: "surge_config",
		ResourceID:   config.ID.String(),
		IPAddress:    "internal",
	})
	return nil
}

func (uc *fareUseCase) SimulateFare(ctx context.Context, vehicleType string, origin, destination domain.LatLng) (float64, error) {
	fares, err := uc.fareRepo.GetFareConfigs(ctx)
	if err != nil {
		return 0, err
	}

	var config *domain.FareConfig
	for _, f := range fares {
		if f.VehicleType == vehicleType {
			config = f
			break
		}
	}

	if config == nil {
		return 0, errors.New("vehicle type not found")
	}

	// Simple Euclidean distance for simulation (in production use Mapbox/Google)
	dist := origin.DistanceTo(destination) / 1000.0 // km
	
	total := config.BaseFare + (dist * config.PerKmRate) + config.BookingFee
	if total < config.MinimumFare {
		total = config.MinimumFare
	}

	return total, nil
}

// --- Audit Use Case ---

type auditUseCase struct {
	auditRepo domain.AuditRepository
}

func NewAuditUseCase(auditRepo domain.AuditRepository) domain.AuditUseCase {
	return &auditUseCase{auditRepo: auditRepo}
}

func (uc *auditUseCase) LogAction(ctx context.Context, entry *domain.AuditLogEntry) error {
	return uc.auditRepo.Store(ctx, entry)
}

func (uc *auditUseCase) GetLogs(ctx context.Context, query domain.AuditQuery) ([]*domain.AuditLogEntry, int, error) {
	return uc.auditRepo.List(ctx, query)
}
