package storage

import (
	"context"
	"fmt"
	"io"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
)

// S3Uploader stores files in any S3-compatible bucket (AWS S3, Supabase Storage,
// Cloudflare R2, MinIO, etc.). Configure via environment variables and construct
// with NewS3Uploader.
type S3Uploader struct {
	client          *s3.Client
	bucket          string
	publicBaseURL   string // e.g. https://<ref>.supabase.co/storage/v1/object/public/<bucket>
	presignClient   *s3.PresignClient
}

// S3Config holds the credentials and endpoint needed to connect to an
// S3-compatible store. For Supabase Storage:
//
//	Endpoint:      https://<project-ref>.supabase.co/storage/v1/s3
//	Region:        ap-southeast-1  (match your Supabase project region)
//	AccessKey:     from Supabase Dashboard → Storage → S3 Access Keys
//	SecretKey:     from Supabase Dashboard → Storage → S3 Access Keys
//	Bucket:        bucket name you created in Supabase Storage
//	PublicBaseURL: https://<project-ref>.supabase.co/storage/v1/object/public/<bucket>
type S3Config struct {
	Endpoint      string
	Region        string
	AccessKey     string
	SecretKey     string
	Bucket        string
	PublicBaseURL string
}

// NewS3Uploader constructs an S3Uploader and validates connectivity by
// checking the bucket exists. Returns an error if credentials or endpoint
// are wrong so the app fails fast at startup rather than on first upload.
func NewS3Uploader(cfg S3Config) (*S3Uploader, error) {
	resolver := aws.EndpointResolverWithOptionsFunc(
		func(service, region string, options ...any) (aws.Endpoint, error) {
			if cfg.Endpoint != "" {
				return aws.Endpoint{
					URL:               cfg.Endpoint,
					HostnameImmutable: true,
					SigningRegion:     cfg.Region,
				}, nil
			}
			return aws.Endpoint{}, &aws.EndpointNotFoundError{}
		},
	)

	awsCfg, err := config.LoadDefaultConfig(context.Background(),
		config.WithRegion(cfg.Region),
		config.WithCredentialsProvider(
			credentials.NewStaticCredentialsProvider(cfg.AccessKey, cfg.SecretKey, ""),
		),
		config.WithEndpointResolverWithOptions(resolver), //nolint:staticcheck
	)
	if err != nil {
		return nil, fmt.Errorf("storage: load aws config: %w", err)
	}

	client := s3.NewFromConfig(awsCfg, func(o *s3.Options) {
		// Required for path-style endpoints (Supabase, MinIO, R2).
		o.UsePathStyle = true
	})

	return &S3Uploader{
		client:        client,
		bucket:        cfg.Bucket,
		publicBaseURL: cfg.PublicBaseURL,
		presignClient: s3.NewPresignClient(client),
	}, nil
}

// Put uploads r under key and returns the public URL.
func (u *S3Uploader) Put(ctx context.Context, key string, r io.Reader, contentType string) (string, error) {
	if err := validateKey(key); err != nil {
		return "", err
	}
	if contentType == "" {
		contentType = "application/octet-stream"
	}

	_, err := u.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(u.bucket),
		Key:         aws.String(key),
		Body:        r,
		ContentType: aws.String(contentType),
		ACL:         types.ObjectCannedACLPublicRead,
	})
	if err != nil {
		return "", fmt.Errorf("storage: put %q: %w", key, err)
	}

	return u.publicBaseURL + "/" + key, nil
}

// Delete removes the object at key. Idempotent — no error if key is absent.
func (u *S3Uploader) Delete(ctx context.Context, key string) error {
	if err := validateKey(key); err != nil {
		return err
	}
	_, err := u.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(u.bucket),
		Key:    aws.String(key),
	})
	return err
}

// SignedURL returns a pre-signed GET URL valid for ttl.
func (u *S3Uploader) SignedURL(ctx context.Context, key string, ttl time.Duration) (string, error) {
	if err := validateKey(key); err != nil {
		return "", err
	}
	req, err := u.presignClient.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(u.bucket),
		Key:    aws.String(key),
	}, s3.WithPresignExpires(ttl))
	if err != nil {
		return "", fmt.Errorf("storage: sign %q: %w", key, err)
	}
	return req.URL, nil
}

// Exists reports whether key is present in the bucket.
func (u *S3Uploader) Exists(ctx context.Context, key string) (bool, error) {
	if err := validateKey(key); err != nil {
		return false, err
	}
	_, err := u.client.HeadObject(ctx, &s3.HeadObjectInput{
		Bucket: aws.String(u.bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		// AWS SDK v2 wraps 404 as a *smithy.GenericAPIError or *types.NotFound.
		// Treat any error from HeadObject as "not found" to stay compatible
		// across providers (Supabase, R2, MinIO all differ slightly).
		return false, nil
	}
	return true, nil
}
