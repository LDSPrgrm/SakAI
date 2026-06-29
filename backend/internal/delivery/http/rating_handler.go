package handler

import (
	"bytes"
	"io"
	"log"
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
	// Read and log the raw body first for debugging
	bodyBytes, _ := io.ReadAll(c.Request.Body)
	log.Printf("[DEBUG-V3] SubmitRating RAW BODY: %s", string(bodyBytes))
	
	// Restore body for binding
	c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	raterID := c.MustGet("userID").(uuid.UUID)

	rideID, err := uuid.Parse(c.Param("rideId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid ride ID"})
		return
	}

	var req dto.SubmitRatingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("[DEBUG-V3] SubmitRating BindJSON error for ride %s: %v", rideID, err)
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	stars := req.GetStars()
	if stars < 1 || stars > 5 {
		log.Printf("[DEBUG-V3] SubmitRating invalid stars: %d", stars)
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "stars must be between 1 and 5"})
		return
	}

	log.Printf("[DEBUG-V3] SubmitRating rater=%s ride=%s stars=%d feedback=%v", raterID, rideID, stars, req.Feedback)

	rating, err := h.ratingUC.SubmitRating(c.Request.Context(), raterID, rideID, stars, req.Feedback)
	if err != nil {
		log.Printf("[DEBUG-V3] SubmitRating UseCase error: %v", err)
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
