package dto

import (
	"time"

	"github.com/sakai/backend/internal/domain"
)

// RegisterRequest is the body for POST /auth/register.
type RegisterRequest struct {
	Name     string          `json:"name" binding:"required,min=2,max=100"`
	Email    string          `json:"email" binding:"required,email"`
	Password string          `json:"password" binding:"required,min=8"`
	Role     domain.UserRole `json:"role" binding:"required,oneof=passenger driver"`
	Vehicle  *VehicleInput   `json:"vehicle"`
}

// CreateAdminRequest is the body for POST /admin/users.
// Either role_id (UUID from the roles table) or role (ENUM string) must be provided.
// When role_id is given, the ENUM role value is derived server-side.
type CreateAdminRequest struct {
	Name     string `json:"name"     binding:"required,min=2,max=100"`
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
	Role     string `json:"role"`    // optional when role_id is provided
	RoleID   string `json:"role_id"` // UUID of a role from the roles table
}

// VehicleInput is the nested vehicle block in RegisterRequest.
type VehicleInput struct {
	Make        string `json:"make" binding:"required"`
	Model       string `json:"model" binding:"required"`
	Color       string `json:"color" binding:"required"`
	Plate       string `json:"plate" binding:"required"`
	VehicleType string `json:"vehicle_type" binding:"required,oneof=motorcycle car tricycle"`
}

// ToDomainVehicle converts the input DTO to a domain value.
func (v *VehicleInput) ToDomainVehicle() *domain.Vehicle {
	if v == nil {
		return nil
	}
	return &domain.Vehicle{
		Make:        v.Make,
		Model:       v.Model,
		Color:       v.Color,
		Plate:       v.Plate,
		VehicleType: domain.VehicleType(v.VehicleType),
	}
}

// LoginRequest is the body for POST /auth/login.
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// RefreshRequest is the body for POST /auth/refresh and POST /auth/logout.
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// AuthResponse is the JSON shape returned after any successful auth operation.
type AuthResponse struct {
	AccessToken          string        `json:"access_token"`
	RefreshToken         string        `json:"refresh_token"`
	AccessTokenExpiresAt time.Time     `json:"access_token_expires_at"`
	User                 *UserResponse `json:"user"`
}

// UserResponse is the public-facing user shape (never includes the password hash).
type UserResponse struct {
	ID        string          `json:"id"`
	Name      string          `json:"name"`
	Email     string          `json:"email"`
	Role      domain.UserRole `json:"role"`
	RoleID    *string         `json:"role_id,omitempty"`
	Vehicle   *VehicleInfoDTO `json:"vehicle,omitempty"`
	CreatedAt time.Time       `json:"created_at"`
}

// NewAuthResponse maps a domain.AuthOutput into the API response shape.
func NewAuthResponse(out *domain.AuthOutput) AuthResponse {
	return AuthResponse{
		AccessToken:          out.AccessToken,
		RefreshToken:         out.RefreshToken,
		AccessTokenExpiresAt: out.AccessTokenExpiresAt,
		User:                 ptr(NewUserResponse(out.User)),
	}
}

// NewUserResponse maps a domain.User into the public user shape.
func NewUserResponse(u *domain.User) UserResponse {
	r := UserResponse{
		ID:        u.ID.String(),
		Name:      u.Name,
		Email:     u.Email,
		Role:      u.Role,
		CreatedAt: u.CreatedAt,
	}
	if u.RoleID != nil {
		s := u.RoleID.String()
		r.RoleID = &s
	}

	if u.Vehicle != nil {
		r.Vehicle = &VehicleInfoDTO{
			Make:  u.Vehicle.Make,
			Model: u.Vehicle.Model,
			Color: u.Vehicle.Color,
			Plate: u.Vehicle.Plate,
		}
	}

	return r
}

func ptr[T any](v T) *T { return &v }
