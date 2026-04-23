// Package storage provides an Uploader abstraction over the underlying object
// store. The default deployment uses LocalUploader (disk-backed) so the
// backend stays dependency-free; swapping in S3Uploader or GCSUploader is a
// single DI change in cmd/server without touching the handler layer.
package storage

import (
	"context"
	"errors"
	"io"
	"time"
)

// Uploader stores and retrieves files by opaque key. Implementations MUST
// enforce path traversal guards themselves — callers may pass keys derived
// from untrusted input (e.g. driver-uploaded filenames).
type Uploader interface {
	// Put writes r under key. Returns the public URL the caller can hand back
	// to the client, or a signed URL when applicable.
	Put(ctx context.Context, key string, r io.Reader, contentType string) (string, error)

	// Delete removes the object at key. Returns nil if the object doesn't
	// exist — delete is idempotent.
	Delete(ctx context.Context, key string) error

	// SignedURL returns a short-lived URL for key. LocalUploader returns the
	// standard public URL since all files are already authenticated behind the
	// backend's own /files/* route.
	SignedURL(ctx context.Context, key string, ttl time.Duration) (string, error)

	// Exists reports whether the key is currently stored.
	Exists(ctx context.Context, key string) (bool, error)
}

// ErrKeyNotAllowed is returned when a key contains path traversal characters
// or otherwise fails validation.
var ErrKeyNotAllowed = errors.New("storage: key not allowed")
