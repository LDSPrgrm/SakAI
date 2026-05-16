package domain

import (
	"time"

	"github.com/google/uuid"
)

// UserRole distinguishes between passengers and drivers.
type UserRole string

const (
	RolePassenger  UserRole = "passenger"
	RoleDriver     UserRole = "driver"
	RoleAdmin      UserRole = "admin"
	RoleSuperadmin UserRole = "superadmin"
	RoleOperations UserRole = "operations"
	RoleFinance    UserRole = "finance"
	RoleSupport    UserRole = "support"
)

// User is the core identity entity for both passengers and drivers.
type User struct {
	ID        uuid.UUID  `json:"id"`
	Seq       int64      `json:"seq"`
	DisplayID string     `json:"display_id"`
	Name      string     `json:"name"`
	Email     string     `json:"email"`
	Password  string     `json:"-"` // bcrypt hash — never serialized
	Role      UserRole   `json:"role"`
	RoleID    *uuid.UUID `json:"role_id,omitempty"` // links to roles table for admin users
	Vehicle   *Vehicle   `json:"vehicle,omitempty"` // non-nil only for drivers
	CreatedAt time.Time  `json:"created_at"`
}
