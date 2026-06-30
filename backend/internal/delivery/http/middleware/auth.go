// Package middleware provides Gin middleware for authentication, role enforcement,
// and rate limiting.
package middleware

import (
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
		c.Next()
	}
}

// isWSUpgrade reports whether the request path is the WebSocket upgrade endpoint.
// Query-parameter tokens are only permitted on this path (M4).
func isWSUpgrade(path string) bool {
	return strings.HasSuffix(path, "/ws")
}

// extractToken gets the JWT from Authorization header or, exclusively for the
// WebSocket upgrade path, a query parameter.
func extractToken(c *gin.Context) string {
	// First try Authorization header (all routes).
	header := c.GetHeader("Authorization")
	if strings.HasPrefix(header, "Bearer ") {
		return strings.TrimPrefix(header, "Bearer ")
	}
	// Fallback to query parameter — ONLY for the WebSocket upgrade (M4).
	// Query strings leak into access logs, proxy logs, history and Referer.
	if isWSUpgrade(c.Request.URL.Path) {
		if t := c.Query("token"); t != "" {
			return strings.TrimPrefix(t, "Bearer ")
		}
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
