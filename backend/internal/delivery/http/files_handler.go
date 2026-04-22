package handler

import (
	"net/http"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/sakai/backend/internal/domain"
)

// FilesHandler serves driver documents + other uploaded assets under /files/*.
// It enforces ownership and role gates so documents are never world-readable.
type FilesHandler struct {
	// Root is the absolute directory containing all uploaded artifacts. Must be
	// the same base path used by storage.LocalUploader.
	Root string
}

// NewFilesHandler builds a handler; an empty Root disables the route. Callers
// should detect nil and skip registration.
func NewFilesHandler(root string) *FilesHandler {
	root = strings.TrimSpace(root)
	if root == "" {
		return nil
	}
	abs, err := filepath.Abs(root)
	if err != nil {
		abs = root
	}
	return &FilesHandler{Root: abs}
}

// Serve handles GET /files/*filepath. Gin captures the wildcard with a leading
// slash, so we strip it before resolving.
func (h *FilesHandler) Serve(c *gin.Context) {
	if h == nil {
		c.JSON(http.StatusNotFound, gin.H{"code": "NOT_FOUND", "message": "file not found"})
		return
	}
	raw := strings.TrimPrefix(c.Param("filepath"), "/")
	if raw == "" || !safeKey(raw) {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid path"})
		return
	}

	userID := c.MustGet("userID").(uuid.UUID)
	role, _ := c.Get("role")

	if !canReadKey(role, userID, raw) {
		c.JSON(http.StatusForbidden, gin.H{"code": "FORBIDDEN", "message": "access denied"})
		return
	}

	abs := filepath.Join(h.Root, filepath.FromSlash(raw))
	// Confirm the resolved path is still rooted under Root after any symlinks
	// or path normalisation Gin may have done.
	if !strings.HasPrefix(abs, h.Root+string(filepath.Separator)) && abs != h.Root {
		c.JSON(http.StatusForbidden, gin.H{"code": "FORBIDDEN", "message": "access denied"})
		return
	}

	c.File(abs)
}

// safeKey rejects any path that attempts traversal or absolute references.
// Mirrors storage.validateKey so key validation is consistent across the
// write and read paths.
func safeKey(k string) bool {
	if strings.HasPrefix(k, "/") || strings.HasPrefix(k, "\\") {
		return false
	}
	for _, seg := range strings.Split(filepath.ToSlash(k), "/") {
		if seg == "" || seg == "." || seg == ".." {
			return false
		}
	}
	return true
}

// canReadKey enforces who may read which keys. Admins (any role outside of
// driver/passenger) may read anything; drivers may read only their own
// documents; passengers cannot read uploads today.
func canReadKey(role any, userID uuid.UUID, key string) bool {
	r, _ := role.(string)
	switch domain.UserRole(r) {
	case domain.RoleDriver:
		prefix := "documents/" + userID.String() + "/"
		return strings.HasPrefix(key, prefix)
	case domain.RolePassenger:
		return false
	default:
		// superadmin / operations / finance / support — KYC review flows need
		// read access to driver docs.
		return true
	}
}
