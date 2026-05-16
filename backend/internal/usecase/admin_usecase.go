package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
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
	roleRepo     domain.RoleRepository
}

func NewAdminUseCase(
	adminRepo domain.AdminRepository,
	userRepo domain.UserRepository,
	rideRepo domain.RideRepository,
	incidentRepo domain.IncidentRepository,
	metricsRepo domain.SystemMetricsRepository,
	auditRepo domain.AuditRepository,
	roleRepo domain.RoleRepository,
) domain.AdminUseCase {
	return &adminUseCase{
		adminRepo:    adminRepo,
		userRepo:     userRepo,
		rideRepo:     rideRepo,
		incidentRepo: incidentRepo,
		metricsRepo:  metricsRepo,
		auditRepo:    auditRepo,
		roleRepo:     roleRepo,
	}
}

func (uc *adminUseCase) GetDashboard(ctx context.Context) (*domain.DashboardMetrics, error) {
	return uc.metricsRepo.GetDashboardMetrics(ctx)
}

func (uc *adminUseCase) ListAdmins(ctx context.Context) ([]*domain.User, error) {
	return uc.adminRepo.GetAdmins(ctx)
}

// roleNameToEnum maps a roles-table name to the closest UserRole ENUM value.
// Custom role names that don't match any known ENUM fall back to "admin".
func roleNameToEnum(name string) domain.UserRole {
	switch name {
	case "super_admin", "superadmin":
		return domain.RoleSuperadmin
	case "operations":
		return domain.RoleOperations
	case "finance":
		return domain.RoleFinance
	case "support":
		return domain.RoleSupport
	default:
		return domain.RoleAdmin // generic fallback for custom roles
	}
}

func (uc *adminUseCase) CreateAdmin(ctx context.Context, actorID uuid.UUID, name, email, password string, role domain.UserRole, roleID *uuid.UUID) (*domain.User, error) {
	// 1. Resolve role: if role_id is provided, look up the role and derive the ENUM value.
	if roleID != nil {
		r, err := uc.roleRepo.GetRoleByID(ctx, *roleID)
		if err != nil {
			return nil, errors.New("invalid role_id: role not found")
		}
		role = roleNameToEnum(r.Name)
	} else {
		// Validate the bare role ENUM value when no role_id is given.
		if role != domain.RoleAdmin && role != domain.RoleSuperadmin &&
			role != domain.RoleOperations && role != domain.RoleFinance && role != domain.RoleSupport {
			return nil, errors.New("invalid admin role")
		}
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
		RoleID:    roleID,
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
		IPAddress:    "internal",
	})

	return user, nil
}

func (uc *adminUseCase) UpdateAdminStatus(ctx context.Context, actorID, targetID uuid.UUID, name, email *string, roleID uuid.UUID) error {
	// Cannot modify own role/profile (prevents accidental self-demotion).
	if actorID == targetID {
		return errors.New("cannot modify own account status")
	}

	oldUser, err := uc.userRepo.GetByID(ctx, targetID)
	if err != nil {
		return err
	}

	// Resolve the picked role row → ENUM bucket. Custom roles bucket into
	// RoleAdmin; system roles map to their named ENUM value.
	role, err := uc.roleRepo.GetRoleByID(ctx, roleID)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return err
		}
		return fmt.Errorf("invalid role_id: %w", err)
	}
	enumRole := roleNameToEnum(role.Name)

	// Cannot remove the last superadmin.
	if oldUser.Role == domain.RoleSuperadmin && enumRole != domain.RoleSuperadmin {
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

	// Cannot promote a non-superadmin to superadmin via this endpoint.
	// Superadmin provisioning must stay out-of-band (seed / direct DB).
	if oldUser.Role != domain.RoleSuperadmin && enumRole == domain.RoleSuperadmin {
		return errors.New("cannot promote to superadmin via role update")
	}

	// Resolve name / email — absent fields keep their old value.
	newName := oldUser.Name
	newEmail := oldUser.Email
	if name != nil {
		newName = strings.TrimSpace(*name)
	}
	if email != nil {
		newEmail = strings.TrimSpace(*email)
	}

	// Email collision check — only if it actually changed.
	if newEmail != oldUser.Email {
		other, err := uc.userRepo.GetByEmail(ctx, newEmail)
		if err == nil && other.ID != targetID {
			return domain.ErrEmailAlreadyRegistered
		}
		if err != nil && !errors.Is(err, domain.ErrNotFound) {
			return err
		}
	}

	if err := uc.adminRepo.UpdateAdminProfile(ctx, targetID, newName, newEmail, enumRole, roleID); err != nil {
		return err
	}

	before, _ := json.Marshal(oldUser)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "UPDATE_STATUS",
		ResourceType: "admin_user",
		ResourceID:   targetID.String(),
		BeforeState:  before,
		AfterState: []byte(fmt.Sprintf(
			`{"name":%q,"email":%q,"role":%q,"role_id":%q}`,
			newName, newEmail, enumRole, roleID)),
		IPAddress: "internal",
	})

	return nil
}

func (uc *adminUseCase) DeactivateAdmin(ctx context.Context, actorID, targetID uuid.UUID) error {
	if actorID == targetID {
		return errors.New("cannot deactivate own account")
	}
	oldUser, err := uc.userRepo.GetByID(ctx, targetID)
	if err != nil {
		return err
	}
	// Protect last superadmin
	if oldUser.Role == domain.RoleSuperadmin {
		admins, _ := uc.adminRepo.GetAdmins(ctx)
		superCount := 0
		for _, a := range admins {
			if a.Role == domain.RoleSuperadmin {
				superCount++
			}
		}
		if superCount <= 1 {
			return errors.New("cannot deactivate the last superadmin")
		}
	}
	if err := uc.adminRepo.DeactivateAdmin(ctx, targetID); err != nil {
		return err
	}
	before, _ := json.Marshal(oldUser)
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "DEACTIVATE",
		ResourceType: "admin_user",
		ResourceID:   targetID.String(),
		BeforeState:  before,
		AfterState:   []byte(`{"status":"deactivated"}`),
		IPAddress:    "internal",
	})
	return nil
}

func (uc *adminUseCase) GetAdminActivity(ctx context.Context, adminID uuid.UUID) ([]*domain.AuditLogEntry, error) {
	logs, _, err := uc.auditRepo.List(ctx, domain.AuditQuery{ActorID: &adminID, Page: 0, Limit: 50})
	return logs, err
}

// ResetUserPassword lets a superadmin set another admin's password without
// knowing the current one. The target account must exist.
func (uc *adminUseCase) ResetUserPassword(ctx context.Context, actorID, targetID uuid.UUID, newPassword string) error {
	if actorID == targetID {
		return errors.New("use /admin/auth/password to change your own password")
	}
	if len(newPassword) < 8 {
		return errors.New("password must be at least 8 characters")
	}

	target, err := uc.userRepo.GetByID(ctx, targetID)
	if err != nil {
		return err
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	if err := uc.userRepo.UpdatePassword(ctx, targetID, string(hash)); err != nil {
		return err
	}

	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "RESET_PASSWORD",
		ResourceType: "admin_user",
		ResourceID:   targetID.String(),
		AfterState:   []byte(fmt.Sprintf(`{"email":%q}`, target.Email)),
		IPAddress:    "internal",
	})
	return nil
}

func (uc *adminUseCase) ListIncidents(ctx context.Context, status *string) ([]*domain.Incident, error) {
	return uc.incidentRepo.ListIncidents(ctx, status)
}

func (uc *adminUseCase) ResolveIncident(ctx context.Context, actorID, incidentID uuid.UUID, notes string) error {
	if err := uc.incidentRepo.UpdateIncident(ctx, incidentID, "resolved", notes, &actorID); err != nil {
		return err
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "RESOLVE_INCIDENT",
		ResourceType: "incident",
		ResourceID:   incidentID.String(),
		Reason:       notes,
		IPAddress:    "internal",
	})
	return nil
}

// GetIncident returns the incident, its full status-history timeline, and any
// driver GPS pings captured while the incident was open.
func (uc *adminUseCase) GetIncident(ctx context.Context, incidentID uuid.UUID) (*domain.IncidentDetail, error) {
	inc, err := uc.incidentRepo.GetIncidentByID(ctx, incidentID)
	if err != nil {
		return nil, err
	}
	history, err := uc.incidentRepo.ListStatusHistory(ctx, incidentID)
	if err != nil {
		return nil, err
	}
	trail, err := uc.incidentRepo.ListLocationTrail(ctx, incidentID)
	if err != nil {
		return nil, err
	}
	return &domain.IncidentDetail{Incident: inc, StatusHistory: history, LocationTrail: trail}, nil
}

// AssignIncident reassigns an incident to another support operator (or clears
// the assignee with nil). The DB trigger records the change automatically.
func (uc *adminUseCase) AssignIncident(ctx context.Context, actorID, incidentID uuid.UUID, assigneeID *uuid.UUID) error {
	if err := uc.incidentRepo.AssignIncident(ctx, incidentID, assigneeID); err != nil {
		return err
	}
	afterJSON := `null`
	if assigneeID != nil {
		afterJSON = fmt.Sprintf(`{"assigned_to":%q}`, assigneeID.String())
	}
	_ = uc.auditRepo.Store(ctx, &domain.AuditLogEntry{
		ActorID:      actorID,
		Action:       "ASSIGN_INCIDENT",
		ResourceType: "incident",
		ResourceID:   incidentID.String(),
		AfterState:   []byte(afterJSON),
		IPAddress:    "internal",
	})
	return nil
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

	// Surge: if enabled, apply zone-specific multiplier when origin sits inside
	// a configured zone polygon, otherwise fall back to the global multiplier.
	if surge, err := uc.fareRepo.GetSurgeConfig(ctx); err == nil && surge != nil && surge.Enabled {
		multiplier := surge.MaxMultiplier
		if _, zm, ok := FindZoneMultiplier(ParseSurgeZones(surge.Zones), origin); ok {
			multiplier = zm
		}
		if multiplier > 1.0 {
			total *= multiplier
		}
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

func (uc *auditUseCase) ExportLogs(ctx context.Context, query domain.AuditQuery) ([]byte, error) {
	// Fetch all matching logs (no pagination for export)
	query.Limit = 10000
	query.Page = 0
	logs, _, err := uc.auditRepo.List(ctx, query)
	if err != nil {
		return nil, err
	}
	var buf []byte
	header := "id,timestamp,actor_id,actor_name,action,resource_type,resource_id,reason\n"
	buf = append(buf, []byte(header)...)
	for _, e := range logs {
		row := fmt.Sprintf("%s,%s,%s,%s,%s,%s,%s,%s\n",
			e.ID, e.Timestamp.Format(time.RFC3339),
			e.ActorID, e.ActorName, e.Action, e.ResourceType, e.ResourceID, e.Reason)
		buf = append(buf, []byte(row)...)
	}
	return buf, nil
}
