package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

func parseDate(v string) (time.Time, error) {
	return time.Parse("2006-01-02", v)
}

type ServiceAreaHandler struct {
	uc domain.ServiceAreaUseCase
}

func NewServiceAreaHandler(uc domain.ServiceAreaUseCase) *ServiceAreaHandler {
	return &ServiceAreaHandler{uc: uc}
}

type serviceAreaInput struct {
	Name     string          `json:"name" binding:"required"`
	LGUCode  string          `json:"lgu_code"`
	Boundary json.RawMessage `json:"boundary"`
	Active   *bool           `json:"active"`
}

// ListPublic — GET /service-area (swagger getServiceAreas, public).
func (h *ServiceAreaHandler) ListPublic(c *gin.Context) {
	areas, err := h.uc.ListPublic(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, areas)
}

// ListAdmin — GET /admin/service-areas (includes inactive).
func (h *ServiceAreaHandler) ListAdmin(c *gin.Context) {
	areas, err := h.uc.ListAdmin(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, areas)
}

func (h *ServiceAreaHandler) Create(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var in serviceAreaInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	a := &domain.ServiceArea{
		Name:     in.Name,
		LGUCode:  in.LGUCode,
		Boundary: in.Boundary,
		Active:   in.Active == nil || *in.Active,
	}
	if err := h.uc.Create(c.Request.Context(), actorID, a); err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, a)
}

func (h *ServiceAreaHandler) Update(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid service area id"})
		return
	}
	var in serviceAreaInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	a := &domain.ServiceArea{
		ID:       id,
		Name:     in.Name,
		LGUCode:  in.LGUCode,
		Boundary: in.Boundary,
		Active:   in.Active == nil || *in.Active,
	}
	if err := h.uc.Update(c.Request.Context(), actorID, a); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *ServiceAreaHandler) Delete(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid service area id"})
		return
	}
	if err := h.uc.Delete(c.Request.Context(), actorID, id); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

// --- LGU partnerships ---

type LGUPartnershipHandler struct {
	uc domain.LGUPartnershipUseCase
}

func NewLGUPartnershipHandler(uc domain.LGUPartnershipUseCase) *LGUPartnershipHandler {
	return &LGUPartnershipHandler{uc: uc}
}

type lguInput struct {
	ServiceAreaID   *string `json:"service_area_id"`
	LGUName         string  `json:"lgu_name" binding:"required"`
	ContactName     string  `json:"contact_name"`
	ContactEmail    string  `json:"contact_email"`
	ContactPhone    string  `json:"contact_phone"`
	AgreementStart  *string `json:"agreement_start"`
	AgreementEnd    *string `json:"agreement_end"`
	Status          string  `json:"status"`
	Notes           string  `json:"notes"`
}

func (h *LGUPartnershipHandler) List(c *gin.Context) {
	items, err := h.uc.List(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, items)
}

func (h *LGUPartnershipHandler) Get(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid id"})
		return
	}
	item, err := h.uc.Get(c.Request.Context(), id)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, item)
}

func (h *LGUPartnershipHandler) Create(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	var in lguInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	p, err := inputToPartnership(&in)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	if err := h.uc.Create(c.Request.Context(), actorID, p); err != nil {
		respondError(c, err)
		return
	}
	respondCreated(c, p)
}

func (h *LGUPartnershipHandler) Update(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid id"})
		return
	}
	var in lguInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	p, err := inputToPartnership(&in)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}
	p.ID = id
	if err := h.uc.Update(c.Request.Context(), actorID, p); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *LGUPartnershipHandler) Delete(c *gin.Context) {
	actorID := c.MustGet("userID").(uuid.UUID)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "INVALID_ID", "message": "invalid id"})
		return
	}
	if err := h.uc.Delete(c.Request.Context(), actorID, id); err != nil {
		respondError(c, err)
		return
	}
	c.Status(http.StatusNoContent)
}

func inputToPartnership(in *lguInput) (*domain.LGUPartnership, error) {
	p := &domain.LGUPartnership{
		LGUName:      in.LGUName,
		ContactName:  in.ContactName,
		ContactEmail: in.ContactEmail,
		ContactPhone: in.ContactPhone,
		Status:       in.Status,
		Notes:        in.Notes,
	}
	if in.ServiceAreaID != nil && *in.ServiceAreaID != "" {
		u, err := uuid.Parse(*in.ServiceAreaID)
		if err != nil {
			return nil, err
		}
		p.ServiceAreaID = &u
	}
	if in.AgreementStart != nil && *in.AgreementStart != "" {
		t, err := parseDate(*in.AgreementStart)
		if err != nil {
			return nil, err
		}
		p.AgreementStart = &t
	}
	if in.AgreementEnd != nil && *in.AgreementEnd != "" {
		t, err := parseDate(*in.AgreementEnd)
		if err != nil {
			return nil, err
		}
		p.AgreementEnd = &t
	}
	return p, nil
}
