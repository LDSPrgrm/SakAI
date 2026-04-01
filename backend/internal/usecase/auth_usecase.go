package usecase

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/pkg/jwt"
	"golang.org/x/crypto/bcrypt"
)

type authUseCase struct {
	userRepo      domain.UserRepository
	tokenRepo     domain.TokenRepository
	jwtSecret     string
	accessExpiry  time.Duration
	refreshExpiry time.Duration
}

// NewAuthUseCase creates a new domain.AuthUseCase.
func NewAuthUseCase(
	userRepo domain.UserRepository,
	tokenRepo domain.TokenRepository,
	jwtSecret string,
	accessExpiry, refreshExpiry time.Duration,
) domain.AuthUseCase {
	return &authUseCase{
		userRepo:      userRepo,
		tokenRepo:     tokenRepo,
		jwtSecret:     jwtSecret,
		accessExpiry:  accessExpiry,
		refreshExpiry: refreshExpiry,
	}
}

func (uc *authUseCase) Register(ctx context.Context, name, email, password string, role domain.UserRole, vehicle *domain.Vehicle) (*domain.AuthOutput, error) {
	// Check for duplicate email first so we return a clean error
	// rather than relying on the DB unique constraint for the common case.
	if _, err := uc.userRepo.GetByEmail(ctx, email); !errors.Is(err, domain.ErrNotFound) {
		if err == nil {
			return nil, domain.ErrEmailAlreadyRegistered
		}
		return nil, err
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &domain.User{
		ID:        uuid.New(),
		Name:      name,
		Email:     email,
		Password:  string(hash),
		Role:      role,
		Vehicle:   vehicle,
		CreatedAt: time.Now(),
	}

	// Generate tokens BEFORE writing to the DB so a JWT-generation failure
	// doesn't produce a user with no token.
	accessToken, expiresAt, err := jwt.GenerateAccessToken(user.ID, user.Role, uc.jwtSecret, uc.accessExpiry)
	if err != nil {
		return nil, err
	}
	refreshToken, err := generateOpaqueToken()
	if err != nil {
		return nil, err
	}

	// Single atomic write: user row + initial refresh token.
	if err := uc.userRepo.CreateWithTokens(
		ctx, user, refreshToken, time.Now().Add(uc.refreshExpiry),
	); err != nil {
		return nil, err
	}

	return &domain.AuthOutput{
		AccessToken:          accessToken,
		RefreshToken:         refreshToken,
		AccessTokenExpiresAt: expiresAt,
		User:                 user,
	}, nil
}

func (uc *authUseCase) Login(ctx context.Context, email, password string) (*domain.AuthOutput, error) {
	user, err := uc.userRepo.GetByEmail(ctx, email)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, domain.ErrInvalidCredentials
	}
	if err != nil {
		return nil, err
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return nil, domain.ErrInvalidCredentials
	}
	return uc.issueTokens(ctx, user)
}

func (uc *authUseCase) Refresh(ctx context.Context, refreshToken string) (*domain.AuthOutput, error) {
	userID, err := uc.tokenRepo.GetUserID(ctx, refreshToken)
	if err != nil {
		return nil, domain.ErrRefreshTokenInvalid
	}
	// Rotate: invalidate old token before issuing new one.
	err = uc.tokenRepo.Delete(ctx, refreshToken)
	if err != nil {
		return nil, err
	}
	user, err := uc.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	return uc.issueTokens(ctx, user)
}

func (uc *authUseCase) Logout(ctx context.Context, refreshToken string) error {
	return uc.tokenRepo.Delete(ctx, refreshToken)
}

func (uc *authUseCase) GetUserByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	return uc.userRepo.GetByID(ctx, id)
}

// issueTokens generates a new access + refresh token pair and persists the refresh token.
func (uc *authUseCase) issueTokens(ctx context.Context, user *domain.User) (*domain.AuthOutput, error) {
	accessToken, expiresAt, err := jwt.GenerateAccessToken(user.ID, user.Role, uc.jwtSecret, uc.accessExpiry)
	if err != nil {
		return nil, err
	}
	refreshToken, err := generateOpaqueToken()
	if err != nil {
		return nil, err
	}
	if err := uc.tokenRepo.Store(ctx, user.ID, refreshToken, time.Now().Add(uc.refreshExpiry)); err != nil {
		return nil, err
	}
	return &domain.AuthOutput{
		AccessToken:          accessToken,
		RefreshToken:         refreshToken,
		AccessTokenExpiresAt: expiresAt,
		User:                 user,
	}, nil
}

// generateOpaqueToken creates a cryptographically random 32-byte hex token.
func generateOpaqueToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
