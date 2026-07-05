package usecase_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/domain/mocks"
	"github.com/sakai/backend/internal/usecase"
	"github.com/sakai/backend/pkg/testutil"
	"go.uber.org/mock/gomock"
)

func newAuthUC(ctrl *gomock.Controller) (domain.AuthUseCase, *mocks.MockUserRepository, *mocks.MockTokenRepository) {
	userRepo := mocks.NewMockUserRepository(ctrl)
	tokenRepo := mocks.NewMockTokenRepository(ctrl)
	uc := usecase.NewAuthUseCase(userRepo, tokenRepo, "test-secret", 15*time.Minute, 30*24*time.Hour)
	return uc, userRepo, tokenRepo
}

func TestAuthUseCase_Register_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)

	userRepo.EXPECT().GetByEmail(gomock.Any(), "new@example.com").Return(nil, domain.ErrNotFound)
	userRepo.EXPECT().CreateWithTokens(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Return(nil)

	out, err := uc.Register(context.Background(), "Alice", "new@example.com", "password123", domain.RolePassenger, nil)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if out.AccessToken == "" {
		t.Error("expected a non-empty access token")
	}
	if out.User.Email != "new@example.com" {
		t.Errorf("expected email new@example.com, got %s", out.User.Email)
	}
}

func TestAuthUseCase_Register_DuplicateEmail(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)
	existing := testutil.NewTestUser()

	userRepo.EXPECT().GetByEmail(gomock.Any(), existing.Email).Return(existing, nil)

	_, err := uc.Register(context.Background(), "Alice", existing.Email, "password123", domain.RolePassenger, nil)
	if err != domain.ErrEmailAlreadyRegistered {
		t.Errorf("expected ErrEmailAlreadyRegistered, got %v", err)
	}
}

func TestAuthUseCase_Login_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, tokenRepo := newAuthUC(ctrl)
	user := testutil.NewTestUser()

	userRepo.EXPECT().GetByEmail(gomock.Any(), user.Email).Return(user, nil)
	tokenRepo.EXPECT().Store(gomock.Any(), user.ID, gomock.Any(), gomock.Any()).Return(nil)

	// user fixture has bcrypt of "password" as the hash
	out, err := uc.Login(context.Background(), user.Email, "password")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if out.AccessToken == "" {
		t.Error("expected a non-empty access token")
	}
}

func TestAuthUseCase_Login_WrongPassword(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)
	user := testutil.NewTestUser()

	userRepo.EXPECT().GetByEmail(gomock.Any(), user.Email).Return(user, nil)

	_, err := uc.Login(context.Background(), user.Email, "wrongpassword")
	if err != domain.ErrInvalidCredentials {
		t.Errorf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestAuthUseCase_Login_Deactivated(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)
	user := testutil.NewTestUser()
	user.Role = domain.UserRoleDeactivated

	userRepo.EXPECT().GetByEmail(gomock.Any(), user.Email).Return(user, nil)

	// user fixture has bcrypt of "password" as the hash
	_, err := uc.Login(context.Background(), user.Email, "password")
	if err != domain.ErrInvalidCredentials {
		t.Errorf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestAuthUseCase_Login_UserNotFound(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)

	userRepo.EXPECT().GetByEmail(gomock.Any(), "missing@example.com").Return(nil, domain.ErrNotFound)

	_, err := uc.Login(context.Background(), "missing@example.com", "password")
	if err != domain.ErrInvalidCredentials {
		t.Errorf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestAuthUseCase_Refresh_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, tokenRepo := newAuthUC(ctrl)
	user := testutil.NewTestUser()
	token := "old-refresh-token"

	tokenRepo.EXPECT().GetUserID(gomock.Any(), token).Return(user.ID, nil)
	userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(user, nil)
	tokenRepo.EXPECT().Rotate(gomock.Any(), token, gomock.Any(), user.ID, gomock.Any()).Return(nil)

	out, err := uc.Refresh(context.Background(), token)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if out.RefreshToken == token {
		t.Error("expected a new refresh token to be issued after rotation")
	}
}

func TestAuthUseCase_Refresh_Deactivated(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, tokenRepo := newAuthUC(ctrl)
	user := testutil.NewTestUser()
	user.Role = domain.UserRoleDeactivated
	token := "old-refresh-token"

	tokenRepo.EXPECT().GetUserID(gomock.Any(), token).Return(user.ID, nil)
	userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(user, nil)

	_, err := uc.Refresh(context.Background(), token)
	if err != domain.ErrRefreshTokenInvalid {
		t.Errorf("expected ErrRefreshTokenInvalid, got %v", err)
	}
}

func TestAuthUseCase_Refresh_InvalidToken(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, tokenRepo := newAuthUC(ctrl)

	tokenRepo.EXPECT().GetUserID(gomock.Any(), "bad-token").Return(uuid.Nil, domain.ErrRefreshTokenInvalid)

	_, err := uc.Refresh(context.Background(), "bad-token")
	if err != domain.ErrRefreshTokenInvalid {
		t.Errorf("expected ErrRefreshTokenInvalid, got %v", err)
	}
}

func TestAuthUseCase_Logout(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, _, tokenRepo := newAuthUC(ctrl)

	tokenRepo.EXPECT().Delete(gomock.Any(), "refresh-token").Return(nil)

	if err := uc.Logout(context.Background(), "refresh-token"); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestAuthUseCase_Register_RepoError(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)

	userRepo.EXPECT().GetByEmail(gomock.Any(), "error@example.com").Return(nil, errors.New("db error"))

	_, err := uc.Register(context.Background(), "Alice", "error@example.com", "password123", domain.RolePassenger, nil)
	if err == nil || err.Error() != "db error" {
		t.Errorf("expected db error, got %v", err)
	}
}

func TestAuthUseCase_Login_RepoError(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)

	userRepo.EXPECT().GetByEmail(gomock.Any(), "error@example.com").Return(nil, errors.New("db error"))

	_, err := uc.Login(context.Background(), "error@example.com", "password")
	if err == nil || err.Error() != "db error" {
		t.Errorf("expected db error, got %v", err)
	}
}

func TestAuthUseCase_Refresh_UserRepoError(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, tokenRepo := newAuthUC(ctrl)
	uid := uuid.New()

	tokenRepo.EXPECT().GetUserID(gomock.Any(), "token").Return(uid, nil)
	userRepo.EXPECT().GetByID(gomock.Any(), uid).Return(nil, errors.New("db error"))

	_, err := uc.Refresh(context.Background(), "token")
	if err == nil || err.Error() != "db error" {
		t.Errorf("expected db error, got %v", err)
	}
}

func TestAuthUseCase_GetUserByID(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)
	user := testutil.NewTestUser()

	t.Run("Success", func(t *testing.T) {
		userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(user, nil)
		res, err := uc.GetUserByID(context.Background(), user.ID)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if res.ID != user.ID {
			t.Errorf("expected ID %v, got %v", user.ID, res.ID)
		}
	})

	t.Run("NotFound", func(t *testing.T) {
		userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(nil, domain.ErrNotFound)
		_, err := uc.GetUserByID(context.Background(), user.ID)
		if !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("expected ErrNotFound, got %v", err)
		}
	})
}

func TestAuthUseCase_ChangePassword(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	uc, userRepo, _ := newAuthUC(ctrl)
	user := testutil.NewTestUser() // password is "password"

	t.Run("Success", func(t *testing.T) {
		userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(user, nil)
		userRepo.EXPECT().UpdatePassword(gomock.Any(), user.ID, gomock.Any()).Return(nil)

		err := uc.ChangePassword(context.Background(), user.ID, "password", "newpassword")
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
	})

	t.Run("WrongOldPassword", func(t *testing.T) {
		userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(user, nil)

		err := uc.ChangePassword(context.Background(), user.ID, "wrongpassword", "newpassword")
		if !errors.Is(err, domain.ErrInvalidCredentials) {
			t.Errorf("expected ErrInvalidCredentials, got %v", err)
		}
	})

	t.Run("UserNotFound", func(t *testing.T) {
		userRepo.EXPECT().GetByID(gomock.Any(), user.ID).Return(nil, domain.ErrNotFound)

		err := uc.ChangePassword(context.Background(), user.ID, "password", "newpassword")
		if !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("expected ErrNotFound, got %v", err)
		}
	})
}
