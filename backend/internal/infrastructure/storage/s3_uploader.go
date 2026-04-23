package storage

import (
	"context"
	"errors"
	"io"
	"time"
)

// S3Uploader is a placeholder implementation reserved for the future swap from
// local storage to AWS S3 (or any S3-compatible provider like MinIO). The
// methods intentionally return ErrNotImplemented so callers wiring this up in
// cmd/server fail loudly rather than silently dropping uploads.
//
// To enable:
//  1. Add github.com/aws/aws-sdk-go-v2 dependency.
//  2. Populate a real S3 client in NewS3Uploader and remove this notice.
//  3. Implement Put/Delete/SignedURL/Exists via s3.Client.
//  4. Bind in cmd/server based on env (e.g. STORAGE_PROVIDER=s3).
type S3Uploader struct {
	Bucket string
	Region string
}

var ErrNotImplemented = errors.New("storage: s3 uploader not implemented — bind LocalUploader in DI for now")

func NewS3Uploader(bucket, region string) *S3Uploader {
	return &S3Uploader{Bucket: bucket, Region: region}
}

func (*S3Uploader) Put(context.Context, string, io.Reader, string) (string, error) {
	return "", ErrNotImplemented
}

func (*S3Uploader) Delete(context.Context, string) error {
	return ErrNotImplemented
}

func (*S3Uploader) SignedURL(context.Context, string, time.Duration) (string, error) {
	return "", ErrNotImplemented
}

func (*S3Uploader) Exists(context.Context, string) (bool, error) {
	return false, ErrNotImplemented
}
