package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
)

// RatingHandler handles /rides/{rideId}/rating and /users/{userId}/rating routes.
type RatingHandler struct {
	ratingUC domain.RatingUseCase
}

// NewRatingHandler creates a new RatingHandler.
func NewRatingHandler(ratingUC domain.RatingUseCase) *RatingHandler {
	return &RatingHandler{ratingUC: ratingUC}
}

// SubmitRating handles POST /rides/{rideId}/rating.
func (h *RatingHandler) SubmitRating(c *gin.Context) {
	raterID := c.MustGet("userID").(uuid.UUID)

	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.SubmitRatingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	rating, err := h.ratingUC.SubmitRating(c.Request.Context(), raterID, rideID, req.Stars, req.Feedback)
	if err != nil {
		respondError(c, err)
		return
	}

	respondCreated(c, dto.NewRatingResponse(rating))
}

// GetUserRating handles GET /users/{userId}/rating.
func (h *RatingHandler) GetUserRating(c *gin.Context) {
	userID, err := uuid.Parse(c.Param("userId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid user ID"})
		return
	}

	summary, err := h.ratingUC.GetRatingSummary(c.Request.Context(), userID)
	if err != nil {
		respondError(c, err)
		return
	}

	respondOK(c, dto.NewUserRatingResponse(summary))
}
