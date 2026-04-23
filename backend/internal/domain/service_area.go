package domain

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// ServiceArea is a public-facing operating polygon that the mobile clients use
// to decide whether they can request a ride. Boundary JSON shape matches the
// surge-zone editor so the UI reuses a single polygon control.
type ServiceArea struct {
	ID        uuid.UUID       `json:"id"`
	Name      string          `json:"name"`
	LGUCode   string          `json:"lgu_code,omitempty"`
	Boundary  json.RawMessage `json:"boundary"`
	Active    bool            `json:"active"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`
}

// LGUPartnership tracks a local-government-unit agreement. An optional
// ServiceAreaID links the partnership to its coverage polygon.
type LGUPartnership struct {
	ID              uuid.UUID  `json:"id"`
	ServiceAreaID   *uuid.UUID `json:"service_area_id,omitempty"`
	LGUName         string     `json:"lgu_name"`
	ContactName     string     `json:"contact_name,omitempty"`
	ContactEmail    string     `json:"contact_email,omitempty"`
	ContactPhone    string     `json:"contact_phone,omitempty"`
	AgreementStart  *time.Time `json:"agreement_start,omitempty"`
	AgreementEnd    *time.Time `json:"agreement_end,omitempty"`
	Status          string     `json:"status"`
	Notes           string     `json:"notes,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

// ServiceAreaRepository persists service-area polygons.
type ServiceAreaRepository interface {
	ListActive(ctx context.Context) ([]*ServiceArea, error)
	ListAll(ctx context.Context) ([]*ServiceArea, error)
	Create(ctx context.Context, a *ServiceArea) error
	Update(ctx context.Context, a *ServiceArea) error
	Delete(ctx context.Context, id uuid.UUID) error
}

// LGUPartnershipRepository persists local-government-unit agreements.
type LGUPartnershipRepository interface {
	List(ctx context.Context) ([]*LGUPartnership, error)
	GetByID(ctx context.Context, id uuid.UUID) (*LGUPartnership, error)
	Create(ctx context.Context, p *LGUPartnership) error
	Update(ctx context.Context, p *LGUPartnership) error
	Delete(ctx context.Context, id uuid.UUID) error
}

// ServiceAreaUseCase is the public entry point used by the mobile + admin UI.
type ServiceAreaUseCase interface {
	ListPublic(ctx context.Context) ([]*ServiceArea, error)
	ListAdmin(ctx context.Context) ([]*ServiceArea, error)
	Create(ctx context.Context, actorID uuid.UUID, a *ServiceArea) error
	Update(ctx context.Context, actorID uuid.UUID, a *ServiceArea) error
	Delete(ctx context.Context, actorID, id uuid.UUID) error
}

// LGUPartnershipUseCase handles CRUD for partnerships.
type LGUPartnershipUseCase interface {
	List(ctx context.Context) ([]*LGUPartnership, error)
	Get(ctx context.Context, id uuid.UUID) (*LGUPartnership, error)
	Create(ctx context.Context, actorID uuid.UUID, p *LGUPartnership) error
	Update(ctx context.Context, actorID uuid.UUID, p *LGUPartnership) error
	Delete(ctx context.Context, actorID, id uuid.UUID) error
}
