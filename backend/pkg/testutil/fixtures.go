// Package testutil provides shared test helpers, fixtures, and factories
// for use across unit and integration tests.
package testutil

import (
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"golang.org/x/crypto/bcrypt"
)

// hashPassword returns the bcrypt hash of s. Panics on failure (tests only).
func hashPassword(s string) string {
	hash, err := bcrypt.GenerateFromPassword([]byte(s), bcrypt.MinCost)
	if err != nil {
		panic(err)
	}
	return string(hash)
}

// NewTestUser returns a minimal valid passenger User. Apply option funcs to customise.
func NewTestUser(opts ...func(*domain.User)) *domain.User {
	u := &domain.User{
		ID:        uuid.New(),
		Name:      "Test User",
		Email:     "test@example.com",
		Password:  hashPassword("password"),
		Role:      domain.RolePassenger,
		CreatedAt: time.Now(),
	}
	for _, opt := range opts {
		opt(u)
	}
	return u
}

// NewTestDriver returns a minimal valid driver User with a vehicle attached.
func NewTestDriver(opts ...func(*domain.User)) *domain.User {
	u := NewTestUser(func(u *domain.User) {
		u.Role = domain.RoleDriver
		u.Vehicle = &domain.Vehicle{
			Make:  "Toyota",
			Model: "Vios",
			Color: "White",
			Plate: "ABC 1234",
		}
	})
	for _, opt := range opts {
		opt(u)
	}
	return u
}

// NewTestDriverRecord returns a domain.Driver (operational state), not a User.
func NewTestDriverRecord(userID uuid.UUID, opts ...func(*domain.Driver)) *domain.Driver {
	d := &domain.Driver{
		UserID:    userID,
		Status:    domain.DriverStatusOnline,
		UpdatedAt: time.Now(),
	}
	for _, opt := range opts {
		opt(d)
	}
	return d
}

// NewTestRide returns a minimal valid ride in Requested state.
func NewTestRide(passengerID uuid.UUID, opts ...func(*domain.Ride)) *domain.Ride {
	now := time.Now()
	r := &domain.Ride{
		ID:          uuid.New(),
		PassengerID: passengerID,
		Status:      domain.RideStatusRequested,
		Origin:      domain.LatLng{Lat: 14.5995, Lng: 120.9842},
		Destination: domain.LatLng{Lat: 14.6760, Lng: 121.0437},
		CreatedAt:   now,
		UpdatedAt:   now,
	}
	for _, opt := range opts {
		opt(r)
	}
	return r
}
