package storage

import (
	"context"
	"errors"
	"io"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// LocalUploader writes under BaseDir and builds public URLs as
//
//	PublicBaseURL + "/" + key
//
// where the backend is expected to serve /files/* via an authenticated route
// that maps key -> BaseDir/key.
type LocalUploader struct {
	BaseDir       string
	PublicBaseURL string
}

// NewLocalUploader ensures BaseDir exists (mkdir -p) and returns an instance
// ready for use. PublicBaseURL is stored as-is; callers should include the
// scheme + host and any path prefix (e.g. https://api.example.com/files).
func NewLocalUploader(baseDir, publicBaseURL string) (*LocalUploader, error) {
	if err := os.MkdirAll(baseDir, 0o755); err != nil {
		return nil, err
	}
	return &LocalUploader{
		BaseDir:       baseDir,
		PublicBaseURL: strings.TrimRight(publicBaseURL, "/"),
	}, nil
}

func (u *LocalUploader) Put(_ context.Context, key string, r io.Reader, _ string) (string, error) {
	if err := validateKey(key); err != nil {
		return "", err
	}
	full := filepath.Join(u.BaseDir, key)
	if err := os.MkdirAll(filepath.Dir(full), 0o755); err != nil {
		return "", err
	}
	f, err := os.Create(full)
	if err != nil {
		return "", err
	}
	defer f.Close()
	if _, err := io.Copy(f, r); err != nil {
		return "", err
	}
	return u.PublicBaseURL + "/" + key, nil
}

func (u *LocalUploader) Delete(_ context.Context, key string) error {
	if err := validateKey(key); err != nil {
		return err
	}
	err := os.Remove(filepath.Join(u.BaseDir, key))
	if errors.Is(err, os.ErrNotExist) {
		return nil
	}
	return err
}

func (u *LocalUploader) SignedURL(_ context.Context, key string, _ time.Duration) (string, error) {
	if err := validateKey(key); err != nil {
		return "", err
	}
	// Local uploader has no signing — the authenticated /files/* route enforces
	// access. Return the standard public URL.
	return u.PublicBaseURL + "/" + url.PathEscape(key), nil
}

func (u *LocalUploader) Exists(_ context.Context, key string) (bool, error) {
	if err := validateKey(key); err != nil {
		return false, err
	}
	_, err := os.Stat(filepath.Join(u.BaseDir, key))
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}
	return err == nil, err
}

// ResolvePath maps an Uploader key to its on-disk path for the authenticated
// /files/* route. Returns ErrKeyNotAllowed on traversal attempts.
func (u *LocalUploader) ResolvePath(key string) (string, error) {
	if err := validateKey(key); err != nil {
		return "", err
	}
	return filepath.Join(u.BaseDir, key), nil
}

// validateKey rejects any key that tries to escape BaseDir via .. or absolute
// paths. Keys are expected to be of the form "documents/<driverId>/<docType>/<filename>".
func validateKey(k string) error {
	if k == "" {
		return ErrKeyNotAllowed
	}
	if strings.HasPrefix(k, "/") || strings.HasPrefix(k, "\\") {
		return ErrKeyNotAllowed
	}
	// Reject any segment equal to ".." or empty.
	for _, seg := range strings.Split(filepath.ToSlash(k), "/") {
		if seg == "" || seg == ".." || seg == "." {
			return ErrKeyNotAllowed
		}
	}
	return nil
}
