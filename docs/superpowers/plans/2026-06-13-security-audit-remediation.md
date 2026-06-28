# SakAI Backend Security Audit Remediation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close all 14 findings from `docs/SECURITY_AUDIT_2026-06-13.md` plus the SOS live-location opt-in, via code fixes (TDD where behavioral), and document operator-only actions in a runbook.

**Architecture:** A Go (Gin) clean-architecture monolith: router → middleware → handler → use-case → repository. Fixes touch config, middleware, use-cases, one handler, one new repository + migration, and CI. Each fix is independent and committed separately on branch `security/audit-remediation`.

**Tech Stack:** Go 1.26, Gin, pgx/Postgres, golang-migrate (`0NN_name.{up,down}.sql`), `go.uber.org/mock/gomock` for mocks, stdlib `testing` (`t.Fatalf`) for use-case tests and `testify/assert` for middleware/router tests.

**Conventions (read once):**
- Run all Go commands from the `backend/` directory.
- Test framework: gomock. Build a usecase via its `NewXxx(...)` constructor with `mocks.NewMockYyy(ctrl)`. Set `EXPECT()` per call. Use `.Times(0)` to assert a call must NOT happen.
- Commit after every task. Conventional Commits, normal prose (not caveman).
- Branch once before Task 1: `git checkout -b security/audit-remediation`.

---

## File map

| File | Change |
|---|---|
| `backend/configs/config.go` | Extract `validateJWTSecret`; fail-closed guard (C1/H5); DSN `sslmode=require` (L4); add `AllowedOrigins` (L1/L2) |
| `backend/configs/config_test.go` | **Create** — `validateJWTSecret` table test |
| `backend/.gitignore` (root `.gitignore`) | Ignore `**/.env` (H5) |
| `backend/internal/usecase/admin_usecase.go` | Reject superadmin in `CreateAdmin` (H2) + `ResetUserPassword` (H3); CSV escaping in `ExportLogs` (L3) |
| `backend/internal/usecase/admin_usecase_test.go` | Add H2/H3/L3 tests |
| `backend/internal/delivery/http/middleware/auth.go` | Delete `[DEBUG-AUTH]`/`[auth]` logs (H1); restrict query token to WS (M4) |
| `backend/internal/delivery/http/middleware/auth_test.go` | **Create** — `extractToken` WS-only query test (M4) |
| `backend/internal/delivery/http/router/router.go` | `SetTrustedProxies(nil)` via helper (H4); rate-limit `/auth/refresh` (L5); KYC perm-gate on `/files/*` (M1); pass `AllowedOrigins` to CORS (L1) |
| `backend/internal/delivery/http/router/proxies_test.go` | **Create** — trusted-proxy / ClientIP test (H4) |
| `backend/internal/delivery/http/files_handler_test.go` | **Create** — KYC perm-gate test (M1) |
| `backend/internal/usecase/payment_processing_usecase.go` | Ownership + idempotency short-circuit in `ChargeRide` (M2) |
| `backend/internal/usecase/payment_processing_usecase_test.go` | Add M2 tests; fix existing success test's new `GetByRideID` expectation |
| `backend/internal/delivery/http/driver_handler.go`, `repository/postgres/driver_repo.go`, `usecase/driver_usecase.go`, `usecase/ride_usecase.go` | Remove precise-geo logs (M3) |
| `backend/internal/delivery/http/middleware/security.go` | CORS allowlist (L1) |
| `backend/internal/delivery/ws/handler.go` | `CheckOrigin` allowlist (L2) |
| `backend/internal/repository/postgres/report_repo.go` | CSV formula-escape (L3) |
| `backend/internal/infrastructure/database/migrations/031_create_sos_safety_prefs.{up,down}.sql` | **Create** — opt-in table (SOS) |
| `backend/internal/domain/ports.go` + `repository/postgres/sos_prefs_repo.go` | **Create** — opt-in repo (SOS) |
| `backend/internal/delivery/http/ride_handler.go` | Enforce opt-in in `AppendIncidentLocation` (SOS) |
| `backend/go.mod` | `go` directive bump (M5) |
| `.github/workflows/*` or CI config | `govulncheck` gate (M5) |
| `docs/SECURITY_REMEDIATION_RUNBOOK.md` | **Create** — operator runbook |

---

## Phase 0: Branch

- [ ] **Step 1: Create the working branch**

Run (from repo root):
```bash
git checkout -b security/audit-remediation
```
Expected: `Switched to a new branch 'security/audit-remediation'`

---

## Phase 1 — Auth / secrets

### Task 1: Harden the JWT secret guard (C1 + H5)

**Files:**
- Create: `backend/configs/config_test.go`
- Modify: `backend/configs/config.go:86-90` (the guard) + new `validateJWTSecret` func

**Context:** Current guard (`config.go:88`) only blocks the exact literal `change-me-in-production` and only when `APP_ENV` is explicitly non-`development`. Because `getEnv("APP_ENV","development")` defaults to `development`, an unset `APP_ENV` silences it (C1). And the committed `backend/.env` value `change-me-in-production-use-a-long-random-string` is not that literal, so it passes (H5). Fix: a denylist + min-length predicate, evaluated as non-dev whenever `APP_ENV != "development"` (unset ⇒ non-dev ⇒ fail closed).

- [ ] **Step 1: Write the failing test**

Create `backend/configs/config_test.go`:
```go
package configs

import (
	"strings"
	"testing"
)

// panics reports whether validateJWTSecret panicked for the given inputs.
func panics(secret, appEnv string) (panicked bool) {
	defer func() {
		if r := recover(); r != nil {
			panicked = true
		}
	}()
	validateJWTSecret(secret, appEnv)
	return false
}

func TestValidateJWTSecret(t *testing.T) {
	strong := strings.Repeat("a", 40) // 40 chars, not denylisted

	cases := []struct {
		name       string
		secret     string
		appEnv     string
		wantPanic  bool
	}{
		{"dev allows weak default", "change-me-in-production", "development", false},
		{"dev allows short", "x", "development", false},
		{"prod rejects sentinel", "change-me-in-production", "production", true},
		{"prod rejects committed long value", "change-me-in-production-use-a-long-random-string", "production", true},
		{"prod rejects short", "tooshort", "production", true},
		{"prod rejects empty", "", "production", true},
		{"prod accepts strong", strong, "production", false},
		{"unset env treated as non-dev, rejects weak", "change-me-in-production", "", true},
		{"unset env accepts strong", strong, "", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := panics(tc.secret, tc.appEnv); got != tc.wantPanic {
				t.Fatalf("validateJWTSecret(%q,%q): panic=%v want %v", tc.secret, tc.appEnv, got, tc.wantPanic)
			}
		})
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run (from `backend/`): `go test ./configs/ -run TestValidateJWTSecret -v`
Expected: FAIL — `undefined: validateJWTSecret`.

- [ ] **Step 3: Add `validateJWTSecret` and call it from `Load`**

In `backend/configs/config.go`, add this function (above or below `Load`):
```go
// validateJWTSecret fails closed: in any non-development environment it panics
// when the secret is a known weak/default value or shorter than 32 chars.
// An unset APP_ENV (empty string) is treated as non-development.
func validateJWTSecret(secret, appEnv string) {
	if appEnv == "development" {
		return
	}
	weak := map[string]bool{
		"change-me-in-production":                          true,
		"change-me-in-production-use-a-long-random-string": true,
	}
	if weak[secret] || len(secret) < 32 {
		panic("JWT_SECRET must be a strong (>=32 char, non-default) secret in non-development environments")
	}
}
```

Replace the existing guard block (`config.go:86-90`):
```go
	// Security: refuse to start with the default JWT secret outside of local dev.
	// A leaked or guessable secret allows any client to forge valid JWTs.
	if cfg.JWTSecret == "change-me-in-production" && getEnv("APP_ENV", "development") != "development" {
		panic("JWT_SECRET must be set to a strong secret value in non-development environments")
	}
```
with:
```go
	// Security: fail closed on weak/default JWT secrets outside local dev.
	// Note the empty-string default for APP_ENV: an unset APP_ENV must NOT
	// silence the guard (that was the original bypass).
	validateJWTSecret(cfg.JWTSecret, getEnv("APP_ENV", ""))
```

- [ ] **Step 4: Run test to verify it passes**

Run (from `backend/`): `go test ./configs/ -run TestValidateJWTSecret -v`
Expected: PASS (all 9 sub-tests ok).

- [ ] **Step 5: Commit**

```bash
git add backend/configs/config.go backend/configs/config_test.go
git commit -m "fix(security): fail closed on weak/default JWT secret (C1, H5)"
```

---

### Task 2: Stop tracking `.env`; ignore it (H5)

**Files:**
- Modify: root `.gitignore`

**Context:** `git ls-files` tracks `.env`, `backend/.env`, `mobile/.env`. Removing from the index + ignoring stops future leaks. **Value rotation is operator action — see runbook Task 18.** This task only de-tracks and ignores.

- [ ] **Step 1: Add ignore rules**

Append to root `.gitignore`:
```gitignore
# Secrets — never commit env files
.env
**/.env
```

- [ ] **Step 2: Remove tracked env files from the index (keep on disk)**

Run (from repo root):
```bash
git rm --cached .env backend/.env mobile/.env
```
Expected: `rm '.env'`, `rm 'backend/.env'`, `rm 'mobile/.env'` (if a path doesn't exist, drop it from the command).

- [ ] **Step 3: Verify nothing tracked, files still on disk**

Run:
```bash
git ls-files | grep -E '(^|/)\.env$'   # expect: no output
git check-ignore backend/.env           # expect: backend/.env
ls backend/.env                         # expect: file still present on disk
```

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore(security): untrack and gitignore .env files (H5)"
```

> Rotation of `JWT_SECRET`, the DB password, and the Maps key is mandatory and tracked in the runbook (Task 18). De-tracking alone does not invalidate the already-leaked values.

---

## Phase 2 — Privilege escalation

### Task 3: `CreateAdmin` must refuse to mint a superadmin (H2)

**Files:**
- Modify: `backend/internal/usecase/admin_usecase.go` (`CreateAdmin`, after role resolution ~line 86)
- Test: `backend/internal/usecase/admin_usecase_test.go`

**Context:** After role resolution, `role` may be `RoleSuperadmin` both via the bare-enum path (`:82-83` lists it) and via `roleNameToEnum` for a role named `super_admin`/`superadmin`. Block it. `CreateAdmin` signature:
`CreateAdmin(ctx, actorID uuid.UUID, name, email, password string, role domain.UserRole, roleID *uuid.UUID) (*domain.User, error)`.

- [ ] **Step 1: Write the failing tests**

Add to `backend/internal/usecase/admin_usecase_test.go`:
```go
func TestCreateAdmin_RejectsSuperadminByEnum(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, _ := newAdminUC(ctrl)

	_, err := uc.CreateAdmin(context.Background(), uuid.New(),
		"Evil", "evil@sakai.ph", "password123", domain.RoleSuperadmin, nil)
	if err == nil {
		t.Fatal("expected superadmin creation to be rejected")
	}
}

func TestCreateAdmin_RejectsSuperadminByRoleID(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	roleID := uuid.New()
	m.role.EXPECT().GetRoleByID(gomock.Any(), roleID).Return(&domain.Role{
		ID: roleID, Name: "super_admin",
	}, nil)

	_, err := uc.CreateAdmin(context.Background(), uuid.New(),
		"Evil", "evil@sakai.ph", "password123", domain.RoleAdmin, &roleID)
	if err == nil {
		t.Fatal("expected superadmin-by-role_id creation to be rejected")
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run (from `backend/`): `go test ./internal/usecase/ -run TestCreateAdmin_RejectsSuperadmin -v`
Expected: FAIL — both proceed to email lookup / succeed (no rejection).

> Note: `TestCreateAdmin_RejectsSuperadminByRoleID` sets only the `GetRoleByID` expectation. Because the fix returns immediately after role resolution, no `userRepo`/`auditRepo` calls happen — gomock would fail on unexpected calls, which is what we want.

- [ ] **Step 3: Add the guard**

In `CreateAdmin`, immediately AFTER the role-resolution `if roleID != nil { … } else { … }` block and BEFORE the email-exists check, insert:
```go
	// Superadmin must never be provisioned through the admin API (H2).
	if role == domain.RoleSuperadmin {
		return nil, errors.New("superadmin provisioning is out-of-band only")
	}
```

- [ ] **Step 4: Run tests to verify they pass**

Run (from `backend/`): `go test ./internal/usecase/ -run TestCreateAdmin -v`
Expected: PASS (new tests green; any existing CreateAdmin tests still green).

- [ ] **Step 5: Commit**

```bash
git add backend/internal/usecase/admin_usecase.go backend/internal/usecase/admin_usecase_test.go
git commit -m "fix(security): block superadmin creation via CreateAdmin (H2)"
```

---

### Task 4: `ResetUserPassword` must refuse a superadmin target (H3)

**Files:**
- Modify: `backend/internal/usecase/admin_usecase.go` (`ResetUserPassword`, after `GetByID` ~line 266)
- Test: `backend/internal/usecase/admin_usecase_test.go`

**Context:** Real method is `ResetUserPassword(ctx, actorID, targetID uuid.UUID, newPassword string) error`. It already fetches `target` via `GetByID` (used only for audit). Add a target-role check right after.

- [ ] **Step 1: Write the failing test**

Add to `backend/internal/usecase/admin_usecase_test.go`:
```go
func TestResetUserPassword_RejectsSuperadminTarget(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	uc, m := newAdminUC(ctrl)

	actor := uuid.New()
	target := uuid.New()
	m.user.EXPECT().GetByID(gomock.Any(), target).
		Return(adminFixture(target, domain.RoleSuperadmin), nil)

	err := uc.ResetUserPassword(context.Background(), actor, target, "newpassword123")
	if err == nil {
		t.Fatal("expected reset of a superadmin password to be rejected")
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/usecase/ -run TestResetUserPassword_RejectsSuperadminTarget -v`
Expected: FAIL — currently proceeds to hash + `UpdatePassword` (gomock fails on the unexpected `UpdatePassword`, or the call succeeds). Either way, no rejection error.

- [ ] **Step 3: Add the guard**

In `ResetUserPassword`, immediately AFTER:
```go
	target, err := uc.userRepo.GetByID(ctx, targetID)
	if err != nil {
		return err
	}
```
insert:
```go
	// A lower-privileged admin must not be able to reset a superadmin's
	// password and then log in as superadmin (H3).
	if target.Role == domain.RoleSuperadmin {
		return errors.New("cannot reset a superadmin password here")
	}
```

- [ ] **Step 4: Run test to verify it passes**

Run (from `backend/`): `go test ./internal/usecase/ -run TestResetUserPassword -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/internal/usecase/admin_usecase.go backend/internal/usecase/admin_usecase_test.go
git commit -m "fix(security): block resetting a superadmin password (H3)"
```

---

## Phase 3 — Token exposure / brute-force

### Task 5: Delete bearer-token logging (H1)

**Files:**
- Modify: `backend/internal/delivery/http/middleware/auth.go:21-26, 44`

**Context:** Five `log.Printf` lines dump the path, full Authorization header, raw `?token=`, token length, and `userID/role`. Delete the credential-bearing ones. Keep auth behavior unchanged.

- [ ] **Step 1: Remove the log lines**

Delete these lines from `auth.go` (around 21-26):
```go
	log.Printf("[DEBUG-AUTH] URL path: %s", c.Request.URL.Path)
	log.Printf("[DEBUG-AUTH] Header Auth: %s", c.GetHeader("Authorization"))
	log.Printf("[DEBUG-AUTH] Query token: %s", c.Query("token"))
	log.Printf("[DEBUG-AUTH] Extracted token length: %d", len(tokenStr))
```
and the line around 44:
```go
	log.Printf("[auth] userID=%s role=%s", claims.UserID.String(), string(claims.Role))
```
Keep the `tokenStr := extractToken(c)` assignment. If `log` becomes an unused import, remove it.

- [ ] **Step 2: Verify no debug-auth logging remains and it compiles**

Run (from `backend/`):
```bash
grep -rn 'DEBUG-AUTH' . ; echo "---"
grep -n 'log.Printf("\[auth\]' internal/delivery/http/middleware/auth.go
go build ./...
```
Expected: no `DEBUG-AUTH` matches; no `[auth]` match; build succeeds.

- [ ] **Step 3: Verify auth tests still pass**

Run (from `backend/`): `go test ./internal/delivery/http/... -v`
Expected: PASS (existing auth/middleware tests green).

- [ ] **Step 4: Commit**

```bash
git add backend/internal/delivery/http/middleware/auth.go
git commit -m "fix(security): stop logging bearer/WS tokens (H1)"
```

---

### Task 6: Ignore `X-Forwarded-For` so the rate limiter can't be bypassed (H4)

**Files:**
- Modify: `backend/internal/delivery/http/router/router.go` (`New`, ~line 70) — add a helper and call it
- Create: `backend/internal/delivery/http/router/proxies_test.go`

**Context:** `RateLimit` buckets on `c.ClientIP()`. With no `SetTrustedProxies`, Gin trusts client `X-Forwarded-For`, so each spoofed XFF gets a fresh bucket. `SetTrustedProxies(nil)` makes `ClientIP()` return `RemoteAddr` and ignore XFF. We wrap it in a tiny exported-to-package helper so it's unit-testable without standing up full `Deps`.

- [ ] **Step 1: Write the failing test**

Create `backend/internal/delivery/http/router/proxies_test.go`:
```go
package router

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

// With trusted proxies disabled, ClientIP must equal RemoteAddr and ignore XFF,
// so a rotating X-Forwarded-For cannot mint fresh rate-limit buckets (H4).
func TestTrustedProxiesIgnoreXForwardedFor(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	if err := configureTrustedProxies(r); err != nil {
		t.Fatalf("configureTrustedProxies: %v", err)
	}
	var got string
	r.GET("/ip", func(c *gin.Context) { got = c.ClientIP() })

	for _, xff := range []string{"1.1.1.1", "2.2.2.2", "3.3.3.3"} {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/ip", nil)
		req.RemoteAddr = "10.0.0.5:12345"
		req.Header.Set("X-Forwarded-For", xff)
		r.ServeHTTP(w, req)
		if got != "10.0.0.5" {
			t.Fatalf("ClientIP=%q with XFF=%q; want 10.0.0.5 (XFF ignored)", got, xff)
		}
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/delivery/http/router/ -run TestTrustedProxiesIgnoreXForwardedFor -v`
Expected: FAIL — `undefined: configureTrustedProxies`.

- [ ] **Step 3: Add the helper and call it in `New`**

In `backend/internal/delivery/http/router/router.go`, add:
```go
// configureTrustedProxies disables X-Forwarded-For trust so ClientIP() resolves
// to the real RemoteAddr. If the service runs behind a known proxy/LB, replace
// nil with that proxy's CIDRs (see SECURITY_REMEDIATION_RUNBOOK.md).
func configureTrustedProxies(r *gin.Engine) error {
	return r.SetTrustedProxies(nil)
}
```
In `New`, right after `r := gin.New()`:
```go
	if err := configureTrustedProxies(r); err != nil {
		panic(err)
	}
```

- [ ] **Step 4: Run test to verify it passes**

Run (from `backend/`): `go test ./internal/delivery/http/router/ -run TestTrustedProxiesIgnoreXForwardedFor -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/internal/delivery/http/router/router.go backend/internal/delivery/http/router/proxies_test.go
git commit -m "fix(security): ignore X-Forwarded-For to harden rate limiting (H4)"
```

---

## Phase 4 — Medium

### Task 7: Restrict query-parameter tokens to the WebSocket upgrade (M4)

**Files:**
- Modify: `backend/internal/delivery/http/middleware/auth.go` (`extractToken`, ~line 56)
- Create: `backend/internal/delivery/http/middleware/auth_test.go`

**Context:** `extractToken` accepts `?token=` for any route. Query strings leak into logs/history/Referer. Allow the query fallback only for the WS upgrade path. **Confirm the WS route path during Step 3** (grep `ServeWS` registration in `router.go`); the helper below matches any path ending in `/ws`.

- [ ] **Step 1: Write the failing test**

Create `backend/internal/delivery/http/middleware/auth_test.go`:
```go
package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func ctxFor(path, query string) *gin.Context {
	gin.SetMode(gin.TestMode)
	c, _ := gin.CreateTestContext(httptest.NewRecorder())
	c.Request = httptest.NewRequest(http.MethodGet, path+"?"+query, nil)
	return c
}

func TestExtractToken_QueryOnlyForWS(t *testing.T) {
	// REST path: query token must be ignored.
	if got := extractToken(ctxFor("/api/v1/rides", "token=leaky")); got != "" {
		t.Fatalf("REST path returned query token %q; want empty", got)
	}
	// WS path: query token accepted.
	if got := extractToken(ctxFor("/api/ws", "token=wstok")); got != "wstok" {
		t.Fatalf("WS path returned %q; want wstok", got)
	}
}

func TestExtractToken_HeaderStillWorks(t *testing.T) {
	c := ctxFor("/api/v1/rides", "")
	c.Request.Header.Set("Authorization", "Bearer abc123")
	if got := extractToken(c); got != "abc123" {
		t.Fatalf("header path returned %q; want abc123", got)
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/delivery/http/middleware/ -run TestExtractToken -v`
Expected: FAIL — `TestExtractToken_QueryOnlyForWS` fails because the REST path currently returns `leaky`.

- [ ] **Step 3: Gate the query fallback on the WS path**

First confirm the WS route suffix: `grep -rn 'ServeWS' internal/delivery/http/router/`. If it is not mounted at a path ending `/ws`, adjust `isWSUpgrade` accordingly.

In `auth.go`, add:
```go
func isWSUpgrade(path string) bool {
	return strings.HasSuffix(path, "/ws")
}
```
Change `extractToken` so the query fallback is guarded:
```go
	// Fallback to query parameter — ONLY for the WebSocket upgrade (M4).
	// Query strings leak into access logs, proxy logs, history and Referer.
	if isWSUpgrade(c.Request.URL.Path) {
		if t := c.Query("token"); t != "" {
			return strings.TrimPrefix(t, "Bearer ")
		}
	}
	return ""
```
(Keep the Authorization-header branch above it unchanged.)

- [ ] **Step 4: Run test to verify it passes**

Run (from `backend/`): `go test ./internal/delivery/http/middleware/ -run TestExtractToken -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/internal/delivery/http/middleware/auth.go backend/internal/delivery/http/middleware/auth_test.go
git commit -m "fix(security): accept query token only on WS upgrade (M4)"
```

---

### Task 8: Gate `/files/*` KYC reads behind the kyc_verification permission (M1)

**Files:**
- Modify: `backend/internal/delivery/http/router/router.go` (`/files/*` registration ~line 357)
- Modify: `backend/internal/delivery/http/files_handler.go` (`canReadKey` default → deny)
- Create: `backend/internal/delivery/http/files_handler_test.go`

**Context:** `/files/*filepath` sits on the `authed` group (auth only). `canReadKey`'s default returns `true`, so any admin-tier role reads any driver's KYC doc, ignoring the `kyc_verification` permission the dedicated admin KYC routes enforce. Fix: wrap the route so drivers keep the owns-prefix path while admin-tier roles must pass `requirePerm("kyc_verification","read")`; make `canReadKey` deny-by-default.

- [ ] **Step 1: Write the failing test**

Create `backend/internal/delivery/http/files_handler_test.go`. Reuse the permission-guard harness pattern (mock `AuthUC`/`RoleUC`). The test mounts the same wrapper the router will use:
```go
package http_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"

	deliveryhttp "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/middleware"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/mocks"
)

// mountFiles builds the wrapper exactly as router.go does (see Step 3).
func mountFiles(role domain.UserRole, userID uuid.UUID, requirePerm middleware.PermissionGuardFactory, filesRoot string) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set("userID", userID)
		c.Set("role", string(role))
		c.Next()
	})
	files := deliveryhttp.NewFilesHandler(filesRoot)
	r.GET("/files/*filepath", func(c *gin.Context) {
		if domain.UserRole(c.GetString("role")) == domain.RoleDriver {
			files.Serve(c)
			return
		}
		requirePerm("kyc_verification", "read")(c)
		if c.IsAborted() {
			return
		}
		files.Serve(c)
	})
	return r
}

func TestFiles_AdminWithoutKycPerm_Forbidden(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	authUC := mocks.NewMockAuthUseCase(ctrl)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	requirePerm := middleware.NewPermissionGuard(authUC, roleUC)

	// A finance admin lacking kyc_verification:read. The guard resolves the role
	// via authUC.GetUserByID → roleUC.GetRole and inspects role.Permissions
	// (see permission.go:69-100).
	userID := uuid.New()
	roleID := uuid.New()
	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{ID: roleID, Permissions: []domain.RolePermission{}}, nil)

	r := mountFiles(domain.RoleFinance, userID, requirePerm, t.TempDir())
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/files/documents/x/license/a.jpg", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestFiles_AdminWithKycPerm_Allowed(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	authUC := mocks.NewMockAuthUseCase(ctrl)
	roleUC := mocks.NewMockRoleUseCase(ctrl)
	requirePerm := middleware.NewPermissionGuard(authUC, roleUC)

	userID := uuid.New()
	roleID := uuid.New()
	authUC.EXPECT().GetUserByID(gomock.Any(), userID).
		Return(&domain.User{ID: userID, RoleID: &roleID}, nil)
	roleUC.EXPECT().GetRole(gomock.Any(), roleID).
		Return(&domain.Role{ID: roleID, Permissions: []domain.RolePermission{
			{PermissionKey: "kyc_verification", Read: true},
		}}, nil)

	// Empty temp dir → the guard passes, then Serve 404s the missing file.
	// We assert the guard did NOT 403 (i.e. the perm gate let it through).
	r := mountFiles(domain.RoleOperations, userID, requirePerm, t.TempDir())
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/files/documents/x/license/a.jpg", nil)
	r.ServeHTTP(w, req)
	assert.NotEqual(t, http.StatusForbidden, w.Code)
}
```
> `<MODULE>` is `github.com/sakai/backend`. Confirm the field names on `domain.RolePermission` (`PermissionKey`, `Read`, `Write`) and `domain.Role.Permissions` against `domain` — they are used verbatim in `permission.go:87,92,95`.

- [ ] **Step 2: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/delivery/http/ -run TestFiles_AdminWithoutKycPerm_Forbidden -v`
Expected: FAIL — without the wrapper the route is the old auth-only one; but since the test mounts its own wrapper, the failure at this step is the *unimplemented router change* surfacing only once we also flip `canReadKey`. To make this a true red→green, first confirm it fails because `canReadKey` default returns `true` (admin reads succeed). If the guard already 403s, the test passes early — that is acceptable; proceed to harden `canReadKey` in Step 3 regardless.

- [ ] **Step 3: Apply the route wrapper + deny-by-default**

In `router.go`, replace the `/files/*` registration:
```go
	files := handler.NewFilesHandler(d.FilesRoot)
	authed.GET("/files/*filepath", files.Serve)
```
with:
```go
	files := handler.NewFilesHandler(d.FilesRoot)
	authed.GET("/files/*filepath", func(c *gin.Context) {
		// Drivers may only read their own prefix (enforced in canReadKey).
		if domain.UserRole(c.GetString("role")) == domain.RoleDriver {
			files.Serve(c)
			return
		}
		// Admin-tier roles must hold kyc_verification:read (M1).
		requirePerm("kyc_verification", "read")(c)
		if c.IsAborted() {
			return
		}
		files.Serve(c)
	})
```
In `files_handler.go`, change `canReadKey`'s default branch from `return true` to deny — the route now authorizes admin-tier access, so the handler should only allow the driver-owns-prefix path and otherwise deny:
```go
	default:
		// Authorization for admin-tier roles is enforced at the route via
		// requirePerm("kyc_verification","read"); deny here by default (M1).
		return false
```
> If a non-driver admin path must still pass `canReadKey` after the route guard, instead keep `return true` in the default branch and rely solely on the route wrapper. Choose one: deny-by-default in `canReadKey` is the safer belt-and-suspenders. Ensure the chosen combination makes the test in Step 1 pass for BOTH the denied-admin (403) and a permitted-admin (200) — add the 200 case mirroring `permission_test.go`'s allowed-permission EXPECT.

- [ ] **Step 4: Run tests to verify they pass**

Run (from `backend/`): `go test ./internal/delivery/http/ -run TestFiles -v`
Expected: PASS. Also run the full package: `go test ./internal/delivery/http/...`

- [ ] **Step 5: Commit**

```bash
git add backend/internal/delivery/http/router/router.go backend/internal/delivery/http/files_handler.go backend/internal/delivery/http/files_handler_test.go
git commit -m "fix(security): require kyc_verification perm for admin file reads (M1)"
```

---

### Task 9: Verify ownership + idempotency before charging a card (M2)

**Files:**
- Modify: `backend/internal/usecase/payment_processing_usecase.go` (`ChargeRide`, before `:72`)
- Modify: `backend/internal/usecase/payment_processing_usecase_test.go` (new tests + fix existing success test)

**Context:** `ChargeRide(ctx, passengerID, rideID, paymentMethodID, idempotencyKey)` calls Stripe (`:72`) before any existence/ownership check. Add: (1) reject if `ride.PassengerID != passengerID` (`domain.ErrForbidden`, exists at `domain/errors.go:23`); (2) short-circuit no-op if a payment already exists (`paymentRepo.GetByRideID`). Both BEFORE the Stripe call.

- [ ] **Step 1: Write the failing tests**

Add to `backend/internal/usecase/payment_processing_usecase_test.go`:
```go
func TestChargeRide_RejectsForeignPassenger(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	owner := uuid.New()
	attacker := uuid.New()
	rideID := uuid.New()
	fare := 250.0

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)
	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{
		ID: rideID, PassengerID: owner, EstimatedFare: &fare,
	}, nil)
	// Must NOT charge a foreign passenger's ride.
	stripeClient.EXPECT().ChargePaymentMethod(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Times(0)

	err := uc.ChargeRide(context.Background(), attacker, rideID, "pm_x", "idem-x")
	if err != domain.ErrForbidden {
		t.Fatalf("got %v; want ErrForbidden", err)
	}
}

func TestChargeRide_ShortCircuitsWhenAlreadyPaid(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	passenger := uuid.New()
	rideID := uuid.New()
	fare := 250.0

	paymentRepo := mocks.NewMockRidePaymentRepository(ctrl)
	stripeClient := mocks.NewMockStripeClient(ctrl)
	rideRepo := mocks.NewMockRideRepository(ctrl)
	userRepo := mocks.NewMockUserRepository(ctrl)
	earningsRepo := mocks.NewMockEarningsRepository(ctrl)
	uc := usecase.NewPaymentProcessingUsecase(paymentRepo, stripeClient, rideRepo, userRepo, earningsRepo, &mockTxManager{})

	rideRepo.EXPECT().GetByID(gomock.Any(), rideID).Return(&domain.Ride{
		ID: rideID, PassengerID: passenger, EstimatedFare: &fare,
	}, nil)
	paymentRepo.EXPECT().GetByRideID(gomock.Any(), rideID).
		Return(&domain.Payment{ID: uuid.New(), RideID: rideID}, nil)
	// Already paid → no second charge.
	stripeClient.EXPECT().ChargePaymentMethod(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Times(0)

	if err := uc.ChargeRide(context.Background(), passenger, rideID, "pm_x", "idem-x"); err != nil {
		t.Fatalf("expected idempotent no-op, got %v", err)
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run (from `backend/`): `go test ./internal/usecase/ -run TestChargeRide_Rejects -v` and `-run TestChargeRide_ShortCircuits -v`
Expected: FAIL — Stripe is currently called (Times(0) violated) / no ErrForbidden.

- [ ] **Step 3: Add the checks before the Stripe call**

In `ChargeRide`, immediately AFTER the `ride, err := uc.rideRepo.GetByID(...)` block and BEFORE computing the amount / calling Stripe:
```go
	// Ownership: only the ride's passenger may pay for it (M2).
	if ride.PassengerID != passengerID {
		return domain.ErrForbidden
	}
	// Idempotency: if a payment already exists, do not charge again (M2).
	if existing, err := uc.paymentRepo.GetByRideID(ctx, rideID); err == nil && existing != nil {
		return nil
	}
```

- [ ] **Step 4: Fix the existing success test's new expectation**

`ChargeRide` now calls `GetByRideID` on the happy path. In the existing `TestPaymentProcessingUsecase_ChargeRide_Success`, add (before the Stripe EXPECT) an expectation that no prior payment exists:
```go
	paymentRepo.EXPECT().GetByRideID(gomock.Any(), rideID).
		Return(nil, domain.ErrNotFound)
```
> Confirm the repo's not-found sentinel. If `GetByRideID` returns `(nil, nil)` when absent rather than `ErrNotFound`, the short-circuit guard's `err == nil && existing != nil` still works (existing is nil ⇒ no short-circuit); set the EXPECT to `Return(nil, nil)` accordingly.

- [ ] **Step 5: Run the full payment package to verify green**

Run (from `backend/`): `go test ./internal/usecase/ -run TestChargeRide -v` and `-run TestPaymentProcessingUsecase -v`
Expected: PASS (new + existing tests green).

- [ ] **Step 6: Commit**

```bash
git add backend/internal/usecase/payment_processing_usecase.go backend/internal/usecase/payment_processing_usecase_test.go
git commit -m "fix(security): verify ride ownership + idempotency before charge (M2)"
```

---

### Task 10: Remove precise-geolocation logging (M3)

**Files:**
- Modify: `backend/internal/delivery/http/driver_handler.go:53`; `backend/internal/repository/postgres/driver_repo.go:112,129,132`; `backend/internal/usecase/driver_usecase.go:42`; `backend/internal/usecase/ride_usecase.go:48`

**Context:** Coordinates at ~1 m precision + driver UUIDs are logged on every location update / match. Remove these log statements (or guard behind an explicit debug flag). Simplest safe fix: delete the coordinate/UUID log lines.

- [ ] **Step 1: Locate the exact lines**

Run (from `backend/`):
```bash
grep -rn -E 'log\.(Printf|Println).*(Lat|Lng|lat|lng|location|Location)' internal/delivery/http/driver_handler.go internal/repository/postgres/driver_repo.go internal/usecase/driver_usecase.go internal/usecase/ride_usecase.go
```
Expected: the five locations from the audit (driver_handler.go:53; driver_repo.go:112,129,132; driver_usecase.go:42; ride_usecase.go:48).

- [ ] **Step 2: Delete each coordinate/UUID log line**

Remove the matched `log.Printf`/`log.Println` statements that include lat/lng and/or the driver UUID. If a file's `log` import becomes unused, remove the import.

- [ ] **Step 3: Verify removal + build**

Run (from `backend/`):
```bash
grep -rn -E 'log\.(Printf|Println).*(Lat|Lng|lat|lng)' internal/   # expect: no precise-coord logs
go build ./...
go test ./...
```
Expected: no matches; build + tests green.

- [ ] **Step 4: Commit**

```bash
git add backend/internal/delivery/http/driver_handler.go backend/internal/repository/postgres/driver_repo.go backend/internal/usecase/driver_usecase.go backend/internal/usecase/ride_usecase.go
git commit -m "fix(security): stop logging precise geolocation + user IDs (M3)"
```

---

### Task 11: Enforce SOS live-location opt-in server-side (SOS)

**Files:**
- Create: `backend/internal/infrastructure/database/migrations/031_create_sos_safety_prefs.up.sql` / `.down.sql`
- Modify: `backend/internal/domain/ports.go` (add `SosPrefsRepository` interface)
- Create: `backend/internal/repository/postgres/sos_prefs_repo.go`
- Modify: `backend/internal/delivery/http/ride_handler.go` (`AppendIncidentLocation` + `sosPrefsRepo` field + `WithSosPrefsRepo` builder)
- Modify: app startup wiring (where `.WithIncidentRepo(...)` is chained) to attach the repo

**Context:** `liveLocationOptIn` exists only in comments (`ride_handler.go:544-554`). `AppendIncidentLocation` (`:555-613`) records pings for any participant on an open incident — a participant who opted out can still be streamed. No `sos_safety_prefs` table exists. We add the table, a minimal repo, an opt-in default of **false** (fail closed), and a 403 in the handler when the actor's opt-in is false. `RideHandler` wires `incidentRepo` via an optional **builder** `WithIncidentRepo(repo)` (`ride_handler.go:41`), NOT the constructor — so we add a parallel `WithSosPrefsRepo(repo)` builder + `sosPrefsRepo` field, leaving `NewRideHandler`'s signature and all existing call sites untouched.

- [ ] **Step 1: Write the migration**

Create `031_create_sos_safety_prefs.up.sql`:
```sql
CREATE TABLE sos_safety_prefs (
    user_id              UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    live_location_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
Create `031_create_sos_safety_prefs.down.sql`:
```sql
DROP TABLE IF EXISTS sos_safety_prefs;
```

- [ ] **Step 2: Add the repo interface (domain/ports.go)**

Add to `backend/internal/domain/ports.go`:
```go
// SosPrefsRepository stores per-user SOS live-location opt-in.
type SosPrefsRepository interface {
	// GetLiveLocationOptIn returns false (fail closed) when no row exists.
	GetLiveLocationOptIn(ctx context.Context, userID uuid.UUID) (bool, error)
	SetLiveLocationOptIn(ctx context.Context, userID uuid.UUID, optIn bool) error
}
```
Then regenerate mocks (the repo uses `//go:generate mockgen`): run `go generate ./...` from `backend/`, or add a `mocks.MockSosPrefsRepository` mirroring an existing small repo mock. Verify `mocks.NewMockSosPrefsRepository` exists before writing the handler test.

- [ ] **Step 3: Implement the postgres repo**

Create `backend/internal/repository/postgres/sos_prefs_repo.go` (mirror an existing small repo in this package for pool type + error mapping):
```go
package postgres

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type sosPrefsRepo struct {
	pool *pgxpool.Pool
}

func NewSosPrefsRepo(pool *pgxpool.Pool) *sosPrefsRepo {
	return &sosPrefsRepo{pool: pool}
}

func (r *sosPrefsRepo) GetLiveLocationOptIn(ctx context.Context, userID uuid.UUID) (bool, error) {
	var optIn bool
	err := r.pool.QueryRow(ctx,
		`SELECT live_location_opt_in FROM sos_safety_prefs WHERE user_id = $1`, userID).
		Scan(&optIn)
	if err != nil {
		// No row → opt-in is false (fail closed). Match this package's
		// pgx.ErrNoRows handling convention from a sibling repo.
		if isNoRows(err) {
			return false, nil
		}
		return false, err
	}
	return optIn, nil
}

func (r *sosPrefsRepo) SetLiveLocationOptIn(ctx context.Context, userID uuid.UUID, optIn bool) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO sos_safety_prefs (user_id, live_location_opt_in, updated_at)
		 VALUES ($1, $2, now())
		 ON CONFLICT (user_id) DO UPDATE SET live_location_opt_in = EXCLUDED.live_location_opt_in, updated_at = now()`,
		userID, optIn)
	return err
}
```
> `isNoRows` is shorthand: use whatever this package already uses (`errors.Is(err, pgx.ErrNoRows)`). Copy the exact pattern from a sibling repo (e.g. `driver_repo.go`).

- [ ] **Step 4: Write the failing handler test**

Add a test that exercises `AppendIncidentLocation` with opt-in false → 403. Use the existing `ride_handler` test harness if present; otherwise build a `RideHandler` with mock `incidentRepo` + mock `sosPrefsRepo`. Core assertion:
```go
// Participant who opted OUT must be rejected with 403 (SOS).
func TestAppendIncidentLocation_OptOut_Forbidden(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	riderID := uuid.New()
	incidentID := uuid.New()

	incidentRepo := mocks.NewMockIncidentRepository(ctrl)
	sosPrefs := mocks.NewMockSosPrefsRepository(ctrl)
	// Build the handler, then attach the optional repos via the builders.
	// NewRideHandler(uc, userRideUC, upsert, rideRepo, userRepo, driverRepo, paymentRepo)
	// — pass nil for collaborators this test doesn't exercise.
	h := NewRideHandler(nil, nil, nil, nil, nil, nil, nil).
		WithIncidentRepo(incidentRepo).
		WithSosPrefsRepo(sosPrefs)

	incidentRepo.EXPECT().GetIncidentByID(gomock.Any(), incidentID).
		Return(&domain.Incident{ID: incidentID, RiderID: riderID, DriverID: uuid.New()}, nil)
	sosPrefs.EXPECT().GetLiveLocationOptIn(gomock.Any(), riderID).Return(false, nil)
	// Must NOT record a ping for an opted-out actor.
	incidentRepo.EXPECT().RecordIncidentLocation(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Times(0)

	// Build gin context: userID=riderID, param incidentId=incidentID, valid
	// lat/lng JSON body; call h.AppendIncidentLocation(c); assert w.Code == 403.
	_ = h
}
```
> This test lives in the `http` package (same package as `RideHandler`) so it can call `NewRideHandler`/builders directly. If a `ride_handler_test.go` already exists, mirror its context-construction helper.

- [ ] **Step 5: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/delivery/http/ -run TestAppendIncidentLocation_OptOut_Forbidden -v`
Expected: FAIL — handler has no opt-in field/check yet (won't compile until Step 6 wiring, which is the red state).

- [ ] **Step 6: Wire the repo + enforce in the handler**

In `ride_handler.go`: add `sosPrefsRepo domain.SosPrefsRepository` to the `RideHandler` struct (next to `incidentRepo`), and add a builder mirroring `WithIncidentRepo`:
```go
// WithSosPrefsRepo wires the SOS opt-in store used to enforce live-location
// consent on the incident-location endpoint. Optional — when nil the endpoint
// rejects pings (fail closed).
func (h *RideHandler) WithSosPrefsRepo(repo domain.SosPrefsRepository) *RideHandler {
	h.sosPrefsRepo = repo
	return h
}
```
In `AppendIncidentLocation`, AFTER the participant check:
```go
	userID := c.MustGet("userID").(uuid.UUID)
	if userID != incident.RiderID && userID != incident.DriverID {
		c.JSON(http.StatusForbidden, gin.H{"code": "NOT_PARTICIPANT", "message": "only ride participants may stream incident location"})
		return
	}
```
insert:
```go
	// Privacy: enforce live-location opt-in server-side (SOS). Opt-in defaults
	// to false; an opted-out participant cannot stream coordinates.
	if h.sosPrefsRepo == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": "FEATURE_DISABLED", "message": "live-location opt-in store not configured"})
		return
	}
	optIn, err := h.sosPrefsRepo.GetLiveLocationOptIn(ctx, userID)
	if err != nil {
		respondError(c, err)
		return
	}
	if !optIn {
		c.JSON(http.StatusForbidden, gin.H{"code": "LIVE_LOCATION_OPT_OUT", "message": "live location sharing is disabled for this user"})
		return
	}
```
Find where `NewRideHandler(...)` is built and `.WithIncidentRepo(...)` is chained (grep `WithIncidentRepo` outside the handler file), and append `.WithSosPrefsRepo(postgres.NewSosPrefsRepo(pool))` to the same chain. Build to confirm.

- [ ] **Step 7: Run test to verify it passes + build**

Run (from `backend/`):
```bash
go build ./...
go test ./internal/delivery/http/ -run TestAppendIncidentLocation -v
```
Expected: build green; test PASS. (Add a companion opt-in=true → 202 test if the harness allows, mirroring the existing success path.)

- [ ] **Step 8: Commit**

```bash
git add backend/internal/infrastructure/database/migrations/031_create_sos_safety_prefs.up.sql backend/internal/infrastructure/database/migrations/031_create_sos_safety_prefs.down.sql backend/internal/domain/ports.go backend/internal/repository/postgres/sos_prefs_repo.go backend/internal/delivery/http/ride_handler.go
git add -A backend/internal/mocks
git commit -m "feat(security): enforce SOS live-location opt-in server-side (SOS)"
```

---

## Phase 5 — Low

### Task 12: CORS allowlist instead of Origin reflection (L1)

**Files:**
- Modify: `backend/configs/config.go` (add `AllowedOrigins []string` from `ALLOWED_ORIGINS`)
- Modify: `backend/internal/delivery/http/middleware/security.go` (`CORS`)
- Modify: `backend/internal/delivery/http/router/router.go` (pass origins into `CORS`)

**Context:** `CORS()` reflects any `Origin` and sets `Allow-Credentials: true` (`security.go:33-34`). No origins config exists. Add a config-driven allowlist; reflect only allowlisted origins.

- [ ] **Step 1: Add the config field**

In `config.go` `Config` struct add:
```go
	// Comma-separated list of allowed browser origins for CORS / WS.
	AllowedOrigins []string
```
In `Load()`:
```go
		AllowedOrigins: splitAndTrim(getEnv("ALLOWED_ORIGINS", "")),
```
Add helper:
```go
func splitAndTrim(s string) []string {
	if s == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	out := parts[:0]
	for _, p := range parts {
		if t := strings.TrimSpace(p); t != "" {
			out = append(out, t)
		}
	}
	return out
}
```
(Add `"strings"` to imports if missing.)

- [ ] **Step 2: Write the failing CORS test**

Create `backend/internal/delivery/http/middleware/cors_test.go`:
```go
package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestCORS_AllowlistOnly(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(CORS([]string{"https://app.sakai.ph"}))
	r.GET("/x", func(c *gin.Context) { c.Status(200) })

	// Allowed origin is echoed.
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("Origin", "https://app.sakai.ph")
	r.ServeHTTP(w, req)
	assert.Equal(t, "https://app.sakai.ph", w.Header().Get("Access-Control-Allow-Origin"))

	// Untrusted origin is NOT echoed.
	w2 := httptest.NewRecorder()
	req2 := httptest.NewRequest(http.MethodGet, "/x", nil)
	req2.Header.Set("Origin", "https://evil.example")
	r.ServeHTTP(w2, req2)
	assert.Equal(t, "", w2.Header().Get("Access-Control-Allow-Origin"))
}
```

- [ ] **Step 3: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/delivery/http/middleware/ -run TestCORS_AllowlistOnly -v`
Expected: FAIL — `CORS` currently takes no args / reflects everything.

- [ ] **Step 4: Rewrite `CORS` to take an allowlist**

In `security.go`:
```go
func CORS(allowed []string) gin.HandlerFunc {
	allowSet := make(map[string]bool, len(allowed))
	for _, o := range allowed {
		allowSet[o] = true
	}
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		if origin != "" && allowSet[origin] {
			c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
			c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
			c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With, Idempotency-Key")
			c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, PATCH, DELETE")
		}
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}
```
In `router.go`, pass the origins (thread `d.AllowedOrigins` through `Deps`, sourced from config): change `r.Use(middleware.CORS())` to `r.Use(middleware.CORS(d.AllowedOrigins))`. Add `AllowedOrigins []string` to `Deps` and populate it where `Deps` is built from config.

- [ ] **Step 5: Run test + build**

Run (from `backend/`): `go test ./internal/delivery/http/middleware/ -run TestCORS_AllowlistOnly -v` then `go build ./...`
Expected: PASS; build green.

- [ ] **Step 6: Commit**

```bash
git add backend/configs/config.go backend/internal/delivery/http/middleware/security.go backend/internal/delivery/http/middleware/cors_test.go backend/internal/delivery/http/router/router.go
git commit -m "fix(security): restrict CORS to an explicit origin allowlist (L1)"
```

---

### Task 13: WebSocket `CheckOrigin` allowlist (L2)

**Files:**
- Modify: `backend/internal/delivery/ws/handler.go:14-25`

**Context:** `CheckOrigin` always returns `true`. Reuse the L1 allowlist. The upgrader is a package var; introduce a package-level allowlist set at startup.

- [ ] **Step 1: Add a configurable origin allowlist to the ws package**

In `handler.go`:
```go
var allowedWSOrigins = map[string]bool{}

// SetAllowedOrigins configures permitted WebSocket origins (call at startup).
func SetAllowedOrigins(origins []string) {
	m := make(map[string]bool, len(origins))
	for _, o := range origins {
		m[o] = true
	}
	allowedWSOrigins = m
}
```
Change the upgrader's `CheckOrigin`:
```go
	CheckOrigin: func(r *http.Request) bool {
		origin := r.Header.Get("Origin")
		// Same-origin / non-browser clients send no Origin → allow (auth still
		// requires a valid ?token=). Cross-site browser origins must be listed.
		if origin == "" {
			return true
		}
		return allowedWSOrigins[origin]
	},
```

- [ ] **Step 2: Write the test**

Create `backend/internal/delivery/ws/checkorigin_test.go`:
```go
package ws

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestCheckOrigin_Allowlist(t *testing.T) {
	SetAllowedOrigins([]string{"https://app.sakai.ph"})
	check := upgrader.CheckOrigin

	mk := func(origin string) *http.Request {
		r := httptest.NewRequest(http.MethodGet, "/ws", nil)
		if origin != "" {
			r.Header.Set("Origin", origin)
		}
		return r
	}
	if !check(mk("https://app.sakai.ph")) {
		t.Fatal("allowed origin rejected")
	}
	if check(mk("https://evil.example")) {
		t.Fatal("untrusted origin accepted")
	}
	if !check(mk("")) {
		t.Fatal("no-Origin client rejected")
	}
}
```

- [ ] **Step 3: Run test + wire startup**

Run (from `backend/`): `go test ./internal/delivery/ws/ -run TestCheckOrigin_Allowlist -v`
Expected: PASS. Then in app startup (where config is loaded and the ws handler is built — likely `main.go`), call `ws.SetAllowedOrigins(cfg.AllowedOrigins)`. Run `go build ./...`.

- [ ] **Step 4: Commit**

```bash
git add backend/internal/delivery/ws/handler.go backend/internal/delivery/ws/checkorigin_test.go backend/cmd/ # adjust path to where SetAllowedOrigins is wired
git commit -m "fix(security): restrict WebSocket CheckOrigin to allowlist (L2)"
```

---

### Task 14: CSV / formula-injection escaping in exports (L3)

**Files:**
- Modify: `backend/internal/repository/postgres/report_repo.go` (`ExportReport`, ~:107-110)
- Modify: `backend/internal/usecase/admin_usecase.go` (`ExportLogs`, ~:527-545 — switch to `csv.Writer`)

**Context:** `report_repo.go` already uses `csv.Writer` but writes raw cell values; `admin_usecase.go ExportLogs` hand-builds CSV with `fmt.Sprintf`, no quoting. Both need formula-escaping (`= + - @` → prefix `'`); `ExportLogs` also needs real CSV quoting.

- [ ] **Step 1: Write the failing test for the escape helper**

Create `backend/internal/repository/postgres/csv_escape_test.go`:
```go
package postgres

import "testing"

func TestEscapeCSVCell(t *testing.T) {
	cases := map[string]string{
		"=cmd()":  "'=cmd()",
		"+1":      "'+1",
		"-1":      "'-1",
		"@SUM(A)": "'@SUM(A)",
		"normal":  "normal",
		"":        "",
	}
	for in, want := range cases {
		if got := escapeCSVCell(in); got != want {
			t.Fatalf("escapeCSVCell(%q)=%q want %q", in, got, want)
		}
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run (from `backend/`): `go test ./internal/repository/postgres/ -run TestEscapeCSVCell -v`
Expected: FAIL — `undefined: escapeCSVCell`.

- [ ] **Step 3: Add the helper + apply in `ExportReport`**

In `report_repo.go`:
```go
// escapeCSVCell neutralizes spreadsheet formula injection: a leading
// = + - @ would execute in Excel/Sheets, so prefix such cells with a quote.
func escapeCSVCell(s string) string {
	if s == "" {
		return s
	}
	switch s[0] {
	case '=', '+', '-', '@':
		return "'" + s
	}
	return s
}
```
In `ExportReport`, change the cell build:
```go
			rec[i] = escapeCSVCell(fmt.Sprintf("%v", row[h]))
```

- [ ] **Step 4: Convert `ExportLogs` to `csv.Writer` + escaping**

In `admin_usecase.go` `ExportLogs`, replace the hand-built header/rows with:
```go
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)
	_ = w.Write([]string{"id", "timestamp", "actor_id", "actor_name", "action", "resource_type", "resource_id", "reason"})
	for _, e := range logs {
		_ = w.Write([]string{
			e.ID.String(),
			e.Timestamp.Format(time.RFC3339),
			e.ActorID.String(),
			escapeAuditCell(e.ActorName),
			string(e.Action),
			e.ResourceType,
			e.ResourceID,
			escapeAuditCell(e.Reason),
		})
	}
	w.Flush()
	return buf.Bytes(), nil
```
Add imports `bytes`, `encoding/csv`. Add a local `escapeAuditCell` mirroring `escapeCSVCell` (or export the postgres one; a small duplicate is fine to avoid a cross-layer import). Adjust `.String()`/`string()` conversions to the real field types.

- [ ] **Step 5: Run tests + build**

Run (from `backend/`): `go test ./internal/repository/postgres/ -run TestEscapeCSVCell -v` then `go build ./...` then `go test ./internal/usecase/ ./internal/repository/postgres/`
Expected: PASS; build green.

- [ ] **Step 6: Commit**

```bash
git add backend/internal/repository/postgres/report_repo.go backend/internal/repository/postgres/csv_escape_test.go backend/internal/usecase/admin_usecase.go
git commit -m "fix(security): escape CSV formula injection in exports (L3)"
```

---

### Task 15: Default DSN to `sslmode=require` (L4)

**Files:**
- Modify: `backend/configs/config.go:70`

- [ ] **Step 1: Change the default**

In `config.go`, change:
```go
		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/sakai?sslmode=disable"),
```
to:
```go
		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/sakai?sslmode=require"),
```

- [ ] **Step 2: Verify + note local-dev impact**

Run (from `backend/`): `go build ./...`
Expected: build green.
> Local dev without TLS must now set `DATABASE_URL` explicitly with `sslmode=disable`. Document in the runbook. (This is intended: the insecure default is the bug.)

- [ ] **Step 3: Commit**

```bash
git add backend/configs/config.go
git commit -m "fix(security): default database DSN to sslmode=require (L4)"
```

---

### Task 16: Rate-limit `/auth/refresh`; document cache lag (L5)

**Files:**
- Modify: `backend/internal/delivery/http/router/router.go:125-126`

**Context:** `/auth/refresh` and `/auth/logout` have no rate limit. Add `middleware.RateLimit` to `/auth/refresh` (logout is lower-value but add it too for symmetry). The 30 s permission-cache lag is accepted + documented (runbook), not changed here.

- [ ] **Step 1: Add the middleware**

In `router.go`, change:
```go
	auth.POST("/refresh", d.Auth.Refresh)
	auth.POST("/logout", d.Auth.Logout)
```
to:
```go
	auth.POST("/refresh", middleware.RateLimit, d.Auth.Refresh)
	auth.POST("/logout", middleware.RateLimit, d.Auth.Logout)
```

- [ ] **Step 2: Verify the route registers**

Run (from `backend/`): `go build ./...` then `go test ./internal/delivery/http/router/`
Expected: build green; `TestRouterRegistersWithoutPanic` still passes.

- [ ] **Step 3: Commit**

```bash
git add backend/internal/delivery/http/router/router.go
git commit -m "fix(security): rate-limit /auth/refresh and /auth/logout (L5)"
```

---

## Phase 6 — Dependencies + runbook

### Task 17: Bump Go toolchain + add `govulncheck` CI gate (M5)

**Files:**
- Modify: `backend/go.mod` (the `go` directive)
- Modify/Create: CI workflow (e.g. `.github/workflows/ci.yml`)

**Context:** `govulncheck` reports 11 reachable stdlib vulns on go1.26.1. Build on **go ≥ 1.26.3** and gate CI.

- [ ] **Step 1: Confirm current findings**

Run (from `backend/`):
```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```
Expected: reachable stdlib findings listed (baseline).

- [ ] **Step 2: Bump the `go` directive**

In `backend/go.mod`, set the `go` line to the patched minor (keep it valid for the installed toolchain — use `go 1.26.3` or higher per "Fixed in"):
```
go 1.26.3
```
Run (from `backend/`): `go build ./... && go test ./...`
Expected: build + tests green (no code changes needed).

- [ ] **Step 3: Re-run govulncheck on the patched toolchain**

Ensure the build/CI toolchain is ≥ 1.26.3, then:
```bash
govulncheck ./...
```
Expected: 0 reachable vulnerabilities.

- [ ] **Step 4: Add the CI gate**

Add a CI step (in the backend job) that fails the build on reachable vulns:
```yaml
      - name: govulncheck
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...
        working-directory: backend
```
Pin the CI Go version to ≥ 1.26.3.

- [ ] **Step 5: Commit**

```bash
git add backend/go.mod .github/workflows/
git commit -m "fix(security): bump Go toolchain >=1.26.3 + govulncheck CI gate (M5)"
```

---

### Task 18: Write the operator runbook

**Files:**
- Create: `docs/SECURITY_REMEDIATION_RUNBOOK.md`

**Context:** Captures actions code cannot perform. Mandatory follow-through for H5/H4/L4.

- [ ] **Step 1: Write the runbook**

Create `docs/SECURITY_REMEDIATION_RUNBOOK.md`:
```markdown
# SakAI Security Remediation — Operator Runbook

Actions the code fixes cannot perform. Do these in a maintenance window.

## 1. Rotate JWT_SECRET (mandatory — H5/C1)
- Generate a strong secret (>=32 chars): `openssl rand -base64 48`.
- Set `JWT_SECRET` via the secret manager / real env (NOT a committed file).
- **Breaking:** rotation invalidates all live access tokens → every user/admin
  must log in again. Schedule accordingly.
- The app now fails to boot in non-dev if the secret is weak/default (<32 chars
  or a known default). Set a strong secret before deploy.

## 2. Rotate the database password (mandatory — H5)
- Replace the leaked `postgres:postgres` credentials.
- Update `DATABASE_URL`; require TLS: `?sslmode=require` (or `verify-full`).
- The default DSN is now `sslmode=require`; production must supply an explicit
  TLS DSN. Local dev without TLS must set `DATABASE_URL` with `sslmode=disable`.

## 3. Rotate the Google Maps key (mandatory — H5)
- Revoke `AIzaSyAfzFWwxAOov-4DKulSFO-tCTOfYwdAq6w` (was in root `.env`).
- Issue a new key, restrict by HTTP referrer / IP / API.

## 4. Source secrets from a manager
- Never commit `.env` (now gitignored). Use the platform secret manager or real
  environment variables for JWT_SECRET, DATABASE_URL, STRIPE_SECRET_KEY, etc.
- Purge the secrets from git history if the repo is shared (e.g. `git filter-repo`),
  treating all previously committed secrets as compromised and rotated.

## 5. Trusted proxy CIDRs (H4)
- The app calls `SetTrustedProxies(nil)` → `ClientIP()` == RemoteAddr, ignoring
  X-Forwarded-For. Correct ONLY when NOT behind a proxy/LB.
- If behind a known proxy/LB, edit `configureTrustedProxies` in
  `internal/delivery/http/router/router.go` to list the proxy CIDRs so real
  client IPs are resolved for rate limiting.

## 6. Allowed origins (L1/L2)
- Set `ALLOWED_ORIGINS` (comma-separated) to the real app/admin origins.
  CORS and WebSocket now reject any origin not in this list.

## 7. CI / build (M5)
- Build and deploy on Go >= 1.26.3.
- CI runs `govulncheck ./...` as a gate.

## 8. Accepted residual risk
- Permission changes propagate within 30s (RBAC cache TTL); acceptable. To make
  revocation instant, invalidate the cache entry on role change.
```

- [ ] **Step 2: Commit**

```bash
git add docs/SECURITY_REMEDIATION_RUNBOOK.md
git commit -m "docs(security): operator runbook for rotation/proxy/CI actions"
```

---

## Final verification

- [ ] **Step 1: Full build + test**

Run (from `backend/`):
```bash
go build ./...
go test ./...
```
Expected: build green; all tests pass.

- [ ] **Step 2: Security spot-checks**

Run:
```bash
git ls-files | grep -E '(^|/)\.env$'            # expect: empty
grep -rn 'DEBUG-AUTH' backend/                   # expect: empty
govulncheck ./...                                # expect: 0 reachable (on go>=1.26.3)
```

- [ ] **Step 3: Confirm finding coverage**

Verify each of C1, H1–H5, M1–M5, L1–L5, SOS has a corresponding commit on the branch:
```bash
git log --oneline main..HEAD
```
Expected: ~17 commits, one per finding/task.

---

## Coverage check (plan ↔ spec ↔ audit)

| Finding | Task |
|---|---|
| C1 | 1 |
| H1 | 5 |
| H2 | 3 |
| H3 | 4 |
| H4 | 6 |
| H5 | 1 (guard) + 2 (untrack) + 18 (rotate) |
| M1 | 8 |
| M2 | 9 |
| M3 | 10 |
| M4 | 7 |
| M5 | 17 |
| L1 | 12 |
| L2 | 13 |
| L3 | 14 |
| L4 | 15 |
| L5 | 16 |
| SOS opt-in | 11 |
| Ops runbook | 18 |
