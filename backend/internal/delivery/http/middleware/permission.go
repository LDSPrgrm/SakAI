package middleware

import (
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/sakai/backend/internal/domain"
)

// permCacheTTL is exported as a var so tests can shorten it.
var permCacheTTL = 30 * time.Second

type permCacheEntry struct {
	perms     []domain.RolePermission
	expiresAt time.Time
}

type permCache struct {
	mu      sync.RWMutex
	entries map[uuid.UUID]permCacheEntry
}

func (c *permCache) get(userID uuid.UUID) ([]domain.RolePermission, bool) {
	c.mu.RLock()
	e, ok := c.entries[userID]
	c.mu.RUnlock()
	if !ok || time.Now().After(e.expiresAt) {
		return nil, false
	}
	return e.perms, true
}

func (c *permCache) set(userID uuid.UUID, perms []domain.RolePermission) {
	c.mu.Lock()
	c.entries[userID] = permCacheEntry{perms: perms, expiresAt: time.Now().Add(permCacheTTL)}
	c.mu.Unlock()
}

// PermissionGuardFactory builds a gin.HandlerFunc for the given (key, scope).
type PermissionGuardFactory func(key string, scope string) gin.HandlerFunc

// NewPermissionGuard returns a factory closed over the use cases needed to
// resolve a user's role and permissions, plus an in-memory cache (TTL 30s).
//
// Superadmin bypasses both cache and DB lookup, matching the frontend
// usePermissions().can behaviour: superadmin is immutable and always allowed.
func NewPermissionGuard(authUC domain.AuthUseCase, roleUC domain.RoleUseCase) PermissionGuardFactory {
	cache := &permCache{entries: make(map[uuid.UUID]permCacheEntry)}

	return func(key string, scope string) gin.HandlerFunc {
		if scope != "read" && scope != "write" {
			panic("middleware.NewPermissionGuard: scope must be 'read' or 'write', got " + scope)
		}
		return func(c *gin.Context) {
			role := domain.UserRole(c.MustGet("role").(string))
			if role == domain.RoleSuperadmin {
				c.Next()
				return
			}
			userID := c.MustGet("userID").(uuid.UUID)

			perms, ok := cache.get(userID)
			if !ok {
				user, err := authUC.GetUserByID(c.Request.Context(), userID)
				if err != nil || user.RoleID == nil {
					log.Printf("[perm] deny user=%s key=%s scope=%s reason=no-role", userID, key, scope)
					c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
						"code":    "FORBIDDEN",
						"message": "no role assigned",
					})
					return
				}
				roleObj, err := roleUC.GetRole(c.Request.Context(), *user.RoleID)
				if err != nil {
					log.Printf("[perm] deny user=%s key=%s scope=%s reason=role-fetch-error err=%v", userID, key, scope, err)
					c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
						"code":    "FORBIDDEN",
						"message": "could not resolve role",
					})
					return
				}
				perms = roleObj.Permissions
				cache.set(userID, perms)
			}

			for _, p := range perms {
				if p.PermissionKey != key {
					continue
				}
				if (scope == "read" && (p.Read || p.Write)) || (scope == "write" && p.Write) {
					c.Next()
					return
				}
				break
			}

			log.Printf("[perm] deny user=%s key=%s scope=%s", userID, key, scope)
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"code":    "FORBIDDEN",
				"message": "insufficient permission",
			})
		}
	}
}
