// Package jwt provides JWT generation and validation for access tokens.
// Refresh tokens are opaque strings stored in the database (see TokenRepository).
package jwt

import (
	"errors"
	"time"

	gojwt "github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
)

// Claims are the custom JWT payload fields embedded in every access token.
type Claims struct {
	UserID uuid.UUID       `json:"uid"`
	Role   domain.UserRole `json:"role"`
	gojwt.RegisteredClaims
}

// GenerateAccessToken creates a signed JWT for the given user.
func GenerateAccessToken(userID uuid.UUID, role domain.UserRole, secret string, expiry time.Duration) (string, time.Time, error) {
	expiresAt := time.Now().Add(expiry)
	claims := Claims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: gojwt.RegisteredClaims{
			ExpiresAt: gojwt.NewNumericDate(expiresAt),
			IssuedAt:  gojwt.NewNumericDate(time.Now()),
		},
	}
	token := gojwt.NewWithClaims(gojwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(secret))
	return signed, expiresAt, err
}

// ValidateAccessToken parses and validates a signed JWT string.
// Returns the claims if valid, or domain.ErrTokenInvalid.
func ValidateAccessToken(tokenStr, secret string) (*Claims, error) {
	token, err := gojwt.ParseWithClaims(tokenStr, &Claims{}, func(t *gojwt.Token) (any, error) {
		if _, ok := t.Method.(*gojwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(secret), nil
	})
	if err != nil || !token.Valid {
		return nil, domain.ErrTokenInvalid
	}
	claims, ok := token.Claims.(*Claims)
	if !ok {
		return nil, domain.ErrTokenInvalid
	}
	return claims, nil
}
