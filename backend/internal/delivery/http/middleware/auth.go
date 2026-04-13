// Package middleware provides Gin middleware for authentication, role enforcement,
// and rate limiting.
package middleware

import (
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/sakai/backend/internal/domain"
	pkgjwt "github.com/sakai/backend/pkg/jwt"
)

// Auth validates the Bearer access token and populates the Gin context with
// the authenticated userID (uuid.UUID) and role (domain.UserRole).
func Auth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenStr := extractToken(c)
		if tokenStr == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"code":    "TOKEN_INVALID",
				"message": "missing or malformed Authorization header",
			})
			return
		}
		claims, err := pkgjwt.ValidateAccessToken(tokenStr, jwtSecret)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"code":    "TOKEN_INVALID",
				"message": "invalid or expired access token",
			})
			return
		}
		c.Set("userID", claims.UserID)
		c.Set("role", string(claims.Role))
		log.Printf("[auth] userID=%s role=%s", claims.UserID.String(), string(claims.Role))
		c.Next()
	}
}

// extractToken gets the JWT from Authorization header or query parameter (for WebSocket).
func extractToken(c *gin.Context) string {
	// First try Authorization header.
	header := c.GetHeader("Authorization")
	if strings.HasPrefix(header, "Bearer ") {
		return strings.TrimPrefix(header, "Bearer ")
	}
	// Fallback to query parameter (used by WebSocket connections).
	if t := c.Query("token"); t != "" {
		return t
	}
	return ""
}

// RequireRole aborts with 403 if the authenticated user's role is not in the
// allowed set. Must be used after the Auth middleware.
func RequireRole(roles ...domain.UserRole) gin.HandlerFunc {
	allowed := make(map[domain.UserRole]struct{}, len(roles))
	for _, r := range roles {
		allowed[r] = struct{}{}
	}
	return func(c *gin.Context) {
		role := domain.UserRole(c.MustGet("role").(string))
		log.Printf("[auth] role check user_role=%s allowed=%v", role, roles)
		if _, ok := allowed[role]; !ok {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"code":    "FORBIDDEN",
				"message": "insufficient role",
			})
			return
		}
		c.Next()
	}
}
