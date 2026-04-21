# Fix: non-superadmin admin gets empty sidebar (403 on permissions load)

## Context

After login, the admin UI fires `GET /admin/roles/{role_id}/permissions` to
populate the sidebar. That backend route is currently gated to `superadmin`
only, so every non-superadmin admin persona (`admin`, `operations`,
`finance`, `support`) receives **403 FORBIDDEN**. The frontend swallows the
error silently, leaves `permissions` as `[]`, and `Sidebar` filters every
nav item out via `can()`, leaving the user on a blank shell.

Intended outcome: every logged-in admin fetches their own role's
permissions cleanly, and the sidebar renders only the items they have
`read` (or `write`) on. The existing role-management endpoints
(`/admin/roles/:id/...`) stay superadmin-only so admins can't inspect
other roles.

## Root Cause

- `backend/internal/delivery/http/router/router.go:113` wraps
  `/admin/roles/:id/permissions` in `middleware.RequireRole(RoleSuperadmin)`.
- `admin/src/contexts/AuthContext.tsx:35-36` triggers
  `loadPermissions(profile.role_id)` for every admin after login.
- `admin/src/hooks/usePermissions.ts:50-56` catches the 403 and stashes
  it in `error` but never renders anything.
- `admin/src/components/Sidebar.tsx:32` filters by `can(perm, 'read')`
  → no match → empty nav.

## Approach

Introduce a new **self-scoped** permissions endpoint that any authenticated
admin can call for their own role. Frontend switches to it. Old
superadmin-only endpoint stays for role-management screens. Add a thin
fallback + inline error banner in the Sidebar so future failures aren't
invisible.

### 1. Backend — new `GET /admin/me/permissions`

- **`backend/internal/delivery/http/role_handler.go`** — extend
  `RoleHandler` with `authUC domain.AuthUseCase` (needs `GetUserByID`),
  update `NewRoleHandler` signature, add method `GetMyPermissions`:
  - read `userID` from Gin ctx (same pattern as `AuthHandler.GetMe`
    at `auth_handler.go:88-100`),
  - call `h.authUC.GetUserByID(ctx, userID)`,
  - if `user.RoleID == nil` → respond `200` with
    `dto.RoleResponse{Permissions: []dto.RolePermissionDTO{}}` (frontend
    `adminRequest` rejects 204 — `_request.ts:118-120`),
  - else call existing `h.uc.GetRole(ctx, *user.RoleID)` and respond
    with `dto.NewRoleResponse(role)`. Reusing `GetRole` (not
    `GetRolePermissions`) returns the full `Role` shape so the
    `role?.name === 'superadmin'` bypass in `can()` keeps working.
- **`backend/cmd/api/main.go:153`** — update construction:
  `handler.NewRoleHandler(roleUC, authUC)`.
- **`backend/internal/delivery/http/router/router.go`** — inside the
  existing `admin := authed.Group("/admin")` block, insert **before** the
  `Role Management` group at line 107, with **no** `RequireRole` wrapper:
  ```go
  admin.GET("/me/permissions", d.Role.GetMyPermissions)
  ```
- **Tests** — add `backend/internal/delivery/http/role_handler_test.go`
  following the `setupAuthTest` pattern in `auth_handler_test.go:22-49`.
  Cover: success (admin with role), empty path (RoleID == nil returns
  `{permissions: []}`), user lookup error.

### 2. OpenAPI spec

- **`openapi/swagger.yaml`** — add a new path entry `/admin/me/permissions`
  next to the existing `/admin/users/me` block. Reuse the existing
  `Role` schema (already used by `adminGetRole`). `operationId:
  adminGetMyPermissions`. Security: `BearerAuth` only (no role tag).
- After editing, run in `admin/`:
  ```
  npm run generate:types
  ```
  Do **not** hand-edit `src/types/openapi.d.ts`.

### 3. Frontend — admin

- **`admin/src/hooks/usePermissions.ts`**
  - Lines 32, 47, 50: drop the `roleId: string` param from
    `loadPermissions` (declaration + implementation).
  - Lines 38-40: rename `fetchRolePermissions` → `fetchMyPermissions`
    and change path to `GET '/me/permissions'`.
- **`admin/src/contexts/AuthContext.tsx:33-38`** — drop the
  `profile.role_id` guard; just call
  `usePermissionsStore.getState().loadPermissions()`. Keep
  `AdminProfile.role_id` typing — other code may still read it.
- **`admin/src/components/Sidebar.tsx`** — around lines 28-32, also pull
  `error` from `usePermissions()`. After the `visibleItems` filter, if
  `error && user?.role !== 'superadmin' && visibleItems.length === 0`,
  render a small inline banner (use existing tailwind tokens — e.g.
  `text-danger`/`border-danger`, `role="alert"`) reading "Failed to
  load permissions. Please retry or contact a superadmin." and fall
  back to showing only the Dashboard link so the user isn't stranded.
  No toast library, no retry button — minimal.
- **Do not touch** `admin/src/api/super-admin/roles.ts` — its
  `getPermissions(id)` call powers the role-management UI and still
  needs the superadmin-only endpoint.

## Verification

Backend:
```
cd C:\Users\EDWARD\Documents\SakAI\backend
go build ./...
go test ./internal/delivery/http/...
```

OpenAPI + frontend types:
```
cd C:\Users\EDWARD\Documents\SakAI\admin
npm run generate:types
```
Confirm `src/types/openapi.d.ts` now contains `adminGetMyPermissions`.

Frontend:
```
npm run lint
npm test
npm run dev
```
Browser checks (http://localhost:3000):
1. Log in as a non-superadmin admin user from `TEST_ACCOUNTS.md`. DevTools
   Network: `GET /api/admin/me/permissions` → 200 with populated
   `permissions[]`. Sidebar lists only the items where that role has
   `read` or `write`.
2. Log in as superadmin. Sidebar shows all items (bypass still works).
3. Stop backend mid-session, re-login: Sidebar shows inline error banner
   + Dashboard fallback. Restart backend, re-login: banner gone, full
   sidebar back.

## Critical files

- `backend/internal/delivery/http/role_handler.go`
- `backend/internal/delivery/http/router/router.go`
- `backend/cmd/api/main.go`
- `backend/internal/delivery/http/role_handler_test.go` *(new)*
- `openapi/swagger.yaml`
- `admin/src/hooks/usePermissions.ts`
- `admin/src/contexts/AuthContext.tsx`
- `admin/src/components/Sidebar.tsx`
- `admin/src/types/openapi.d.ts` *(generated)*
