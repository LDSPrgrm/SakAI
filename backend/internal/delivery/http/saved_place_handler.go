package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

type SavedPlaceHandler struct {
	savedPlaceUC domain.SavedPlaceUseCase
}

func NewSavedPlaceHandler(spUC domain.SavedPlaceUseCase) *SavedPlaceHandler {
	return &SavedPlaceHandler{
		savedPlaceUC: spUC,
	}
}

// Create handles POST /users/me/saved-places
func (h *SavedPlaceHandler) Create(c *gin.Context) {
	userIDStr := c.MustGet("user_id").(string)
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req dto.SavedPlaceCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	sp, err := h.savedPlaceUC.AddPlace(
		c.Request.Context(),
		userID,
		req.Name,
		req.Address,
		req.Latitude,
		req.Longitude,
		req.Type,
	)
	if err != nil {
		respondError(c, err)
		return
	}

	respondCreated(c, dto.NewSavedPlaceResponse(sp))
}

// List handles GET /users/me/saved-places
func (h *SavedPlaceHandler) List(c *gin.Context) {
	userIDStr := c.MustGet("user_id").(string)
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	places, err := h.savedPlaceUC.ListPlaces(c.Request.Context(), userID)
	if err != nil {
		respondError(c, err)
		return
	}

	resp := make([]dto.SavedPlaceResponse, len(places))
	for i, p := range places {
		resp[i] = dto.NewSavedPlaceResponse(p)
	}

	respondOK(c, resp)
}

// Delete handles DELETE /users/me/saved-places/:placeId
func (h *SavedPlaceHandler) Delete(c *gin.Context) {
	placeIDStr := c.Param("placeId")
	placeID, err := uuid.Parse(placeIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid placeId"})
		return
	}

	userIDStr := c.MustGet("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)

	if err := h.savedPlaceUC.DeletePlace(c.Request.Context(), userID, placeID); err != nil {
		respondError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
