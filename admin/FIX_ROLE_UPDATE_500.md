# Fix: `PUT /admin/users/:id` 500s when assigning a custom (non-system) role

> **Status:** ✅ Completed 2026-04-22 — verified end-to-end across backend DTO/ports/repo/usecase/handler/mocks/tests, OpenAPI, generated types, and frontend call sites (`SAAdminManagement.tsx`, `AdminsTab.tsx`).

## Context

Superadmin updates admin's role via the admin-management UI. Picking a
**premade system role** (`operations`, `finance`, `support`) works; picking
a **newly created custom role** (e.g. "Marketing Manager") returns 500.

Root cause chain:

1. `admin/src/api/super-admin/admins.ts:30-31` sends
   `PUT /admin/users/:id` with `{ role: <role name string> }`.
2. Handler at `backend/internal/delivery/http/admin_handler.go:75-92` binds
   the body into `dto.UpdateAdminStatusRequest{ Role domain.UserRole }`
   and forwards to usecase.
3. Usecase `admin_usecase.go:130-172` calls repo
   `UpdateAdminStatus(ctx, id, status)`.
4. Repo `admin_repo.go:46-49` runs
   `UPDATE users SET role = $1 WHERE id = $2` against a Postgres `user_role`
   **ENUM** whose only valid values are `passenger, driver, admin,
   superadmin, operations, finance, support` (migrations 001 + 007).
5. `"Marketing Manager"` is **not** in that ENUM → Postgres rejects →
   `respondError` maps the unknown pg error to a generic 500
   `INTERNAL_SERVER_ERROR`. System role names happen to be in the ENUM, so
   they succeed.
6. The same query **never updates `users.role_id`** — so even when the
   ENUM happens to accept the name, the FK into `roles` stays stale and
   `/admin/me/permissions` returns the wrong role's permissions on the
   affected admin's next login.

Intended outcome: a superadmin can change an admin's role to any role
row in `roles` (system or custom), and can also edit the admin's name
and email from the edit modal — all in one `PUT`. Backend updates
`users.name`, `users.email`, `users.role` (ENUM bucket), and
`users.role_id` (FK) atomically. Audit trail records all four.

## Approach

Switch the PUT payload from role **name** to role **UUID**, and extend
it with optional `name` / `email` so the AdminsTab edit modal's fields
actually persist (they were silently dropped before). The backend looks
up the `roles` row, derives the ENUM bucket via the existing
`roleNameToEnum` helper (custom roles → `admin` bucket), validates email
uniqueness only when it changes, and writes all four columns in one
statement.

The role picker in the UI already fetches `roleDefinitions` from
`/admin/roles` with `{id, name}` — so the frontend already has the UUID
at hand; it just needs to send it on update the same way `CreateAdmin`
already does.

### 1. Backend — DTO

- **`backend/internal/delivery/http/dto/admin_dto.go:18-20`**
  Replace:
  ```go
  type UpdateAdminStatusRequest struct {
      Role domain.UserRole `json:"role" binding:"required"`
  }
  ```
  with:
  ```go
  type UpdateAdminStatusRequest struct {
      Name   *string   `json:"name,omitempty"   binding:"omitempty,min=1,max=120"`
      Email  *string   `json:"email,omitempty"  binding:"omitempty,email"`
      RoleID uuid.UUID `json:"role_id"          binding:"required"`
  }
  ```
  `Name` / `Email` are pointers so "field absent" is distinguishable from
  "empty string" — absent → keep old value. Import `github.com/google/uuid`.

### 2. Backend — domain interfaces

- **`backend/internal/domain/ports.go:191`** (`AdminRepository`): replace
  `UpdateAdminStatus(ctx, id, status UserRole) error` with:
  ```go
  UpdateAdminProfile(ctx context.Context, id uuid.UUID, name, email string, role UserRole, roleID uuid.UUID) error
  ```
  Single atomic write of all four mutable columns.
- **`backend/internal/domain/ports.go:390`** (`AdminUseCase`): change
  `UpdateAdminStatus(ctx, actorID, targetID uuid.UUID, status UserRole) error`
  →
  ```go
  UpdateAdminStatus(ctx context.Context, actorID, targetID uuid.UUID, name, email *string, roleID uuid.UUID) error
  ```
  Keep the usecase method name — audit `Action` string (`UPDATE_STATUS`)
  and the handler symbol stay untouched.

### 3. Backend — repository

- **`backend/internal/repository/postgres/admin_repo.go:46-49`**
  Replace `UpdateAdminStatus` with:
  ```go
  func (r *adminRepo) UpdateAdminProfile(ctx context.Context, id uuid.UUID, name, email string, role domain.UserRole, roleID uuid.UUID) error {
      const q = `UPDATE users SET name = $1, email = $2, role = $3, role_id = $4 WHERE id = $5`
      _, err := r.db.Exec(ctx, q, name, email, string(role), roleID, id)
      return err
  }
  ```
  All four columns written in one statement → atomic under concurrent reads.
  If the usecase passes old values for unchanged fields, this is a no-op
  for those columns.

### 4. Backend — usecase

- **`backend/internal/usecase/admin_usecase.go:130-172`** rewrite
  `UpdateAdminStatus` body:
  1. Keep the self-modification guard (`actorID == targetID`).
  2. Fetch target: `oldUser, err := uc.userRepo.GetByID(ctx, targetID)`.
  3. Look up the role:
     `role, err := uc.roleRepo.GetRoleByID(ctx, roleID)` — on error return
     `fmt.Errorf("invalid role_id: %w", err)` (or passthrough
     `domain.ErrNotFound`).
  4. Derive ENUM: `enumRole := roleNameToEnum(role.Name)` (helper already
     exists at `admin_usecase.go:54-69`).
  5. **Preserve the existing last-superadmin guard**, reading against
     `enumRole`: if `oldUser.Role == domain.RoleSuperadmin && enumRole !=
     domain.RoleSuperadmin` → count superadmins; block if ≤ 1.
  6. **New guard — reject privilege escalation to superadmin:** if
     `oldUser.Role != domain.RoleSuperadmin && enumRole ==
     domain.RoleSuperadmin` → return
     `errors.New("cannot promote to superadmin via role update")`.
     Rationale: the picker can surface the seeded `super_admin` row from
     `/admin/roles`; without this guard any superadmin could demote a
     peer and promote anyone to superadmin. Superadmin provisioning must
     stay out-of-band.
  7. **Resolve name/email** (new scope from this fix):
     ```go
     newName  := oldUser.Name
     newEmail := oldUser.Email
     if name  != nil { newName  = strings.TrimSpace(*name) }
     if email != nil { newEmail = strings.TrimSpace(*email) }
     ```
     If `newEmail != oldUser.Email`, check collision — `uc.userRepo.GetByEmail(ctx, newEmail)`:
     - `errors.Is(err, domain.ErrNotFound)` → ok.
     - `err == nil && other.ID != targetID` → return
       `domain.ErrEmailAlreadyRegistered`.
     - other errors → propagate.
     (Mirror the pattern at `admin_usecase.go:87-93` in `CreateAdmin`.)
  8. Persist:
     ```go
     uc.adminRepo.UpdateAdminProfile(ctx, targetID, newName, newEmail, enumRole, roleID)
     ```
  9. Audit — keep `BeforeState: json.Marshal(oldUser)`, replace
     `AfterState`:
     ```go
     AfterState: []byte(fmt.Sprintf(
       `{"name":%q,"email":%q,"role":%q,"role_id":%q}`,
       newName, newEmail, enumRole, roleID))
     ```
     so the trail survives renames of both role *and* profile.

### 5. Backend — handler

- **`backend/internal/delivery/http/admin_handler.go:75-92`**
  Pass `req.Name, req.Email, req.RoleID` to the usecase call. Gin's
  `binding:"required,uuid"` on `RoleID` + `omitempty,email` on
  `Email` + `omitempty,min=1,max=120` on `Name` returns 400 on malformed
  input automatically.

### 6. Backend — wiring

- **`backend/cmd/api/main.go`** — no change. The usecase constructor at
  `admin_usecase.go:26-43` already takes `roleRepo`.

### 7. Backend — gomock regeneration

Mocks at `backend/internal/domain/mocks/mock_ports.go:654-665, 2343-2354`
reference the old signatures. Regenerate with whichever gomock command
the repo uses (likely `go generate ./...` via a `//go:generate` directive
in `ports.go`).

### 8. Backend — tests

- **`backend/internal/usecase/admin_usecase_test.go`**: for
  `TestUpdateAdminStatus` (or equivalent), switch mock expectation from
  `UpdateAdminStatus` to `UpdateAdminProfile`; add `roleRepo.GetRoleByID`
  expectation. Cases:
  - success, role only — system role (`operations` → ENUM `operations`,
    role_id = seeded UUID, name/email unchanged).
  - success, role only — custom role (`is_system=false`, e.g.
    `"Marketing"`) → ENUM = `admin`, role_id = custom UUID.
  - success, name + email updated, role unchanged → repo sees new values,
    `GetByEmail` called to check collision.
  - email collides with another user → `ErrEmailAlreadyRegistered`.
  - email unchanged → no `GetByEmail` lookup (confirms dupe check only
    fires on change).
  - `roleID` not found → error wrapping `domain.ErrNotFound`.
  - last-superadmin guard still fires when moving away from superadmin.
  - new escalation guard fires when moving non-super → super.
- **`backend/internal/delivery/http/admin_handler_test.go`**: replace
  `role` payload with `role_id`. Add cases:
  - 400 on malformed uuid,
  - 400 on malformed email,
  - success with name + email + role_id,
  - success with only role_id.

### 9. OpenAPI spec

- **`openapi/swagger.yaml`** — find `UpdateAdminStatusRequest:` under
  `components/schemas`. Replace with:
  ```yaml
  UpdateAdminStatusRequest:
    type: object
    required: [role_id]
    properties:
      name:
        type: string
        minLength: 1
        maxLength: 120
      email:
        type: string
        format: email
      role_id:
        type: string
        format: uuid
  ```
- Regenerate admin types:
  ```
  cd C:\Users\EDWARD\Documents\SakAI\admin
  npm run generate:types
  ```
  Do **not** hand-edit `src/types/openapi.d.ts`.

### 10. Frontend — API client

- **`admin/src/api/super-admin/admins.ts:29-31`** rewrite:
  ```ts
  export interface UpdateAdminPayload {
    name?:    string;
    email?:   string;
    role_id:  string;
  }

  /** PUT /admin/users/:id — updates name / email / role_id. Returns 204. */
  update: (id: string, data: UpdateAdminPayload) =>
    adminRequestVoid('PUT', `/users/${id}`, {
      ...(data.name  !== undefined ? { name:  data.name  } : {}),
      ...(data.email !== undefined ? { email: data.email } : {}),
      role_id: data.role_id,
    }),
  ```

### 11. Frontend — call sites

- **`admin/src/pages/super-admin/SAAdminManagement.tsx`**
  - Line 114 (edit flow, no role change — still calls `update`):
    ```ts
    const def = roleDefs.find(r => r.name === values.role);
    if (!def) { setApiError('Selected role not found. Refresh and retry.'); return; }
    await adminsApi.update(editingAdmin.id, {
      name:    values.name,
      email:   values.email,
      role_id: def.id,
    });
    ```
    Pattern mirrors existing `create` flow at lines 117-127.
  - Line 149-150 (role-change confirmation):
    ```ts
    const def = roleDefs.find(r => r.name === confirmModal.pendingData!.role);
    if (!def) { /* error */ return; }
    await adminsApi.update(admin.id, {
      name:    confirmModal.pendingData!.name,
      email:   confirmModal.pendingData!.email,
      role_id: def.id,
    });
    ```
- **`admin/src/pages/settings/AdminsTab.tsx:63-69`** — already prepares
  `name`, `email`, `role_id`; just route them through the new signature:
  ```ts
  await adminsApi.update(modal.admin.id, {
    name:    values.name,
    email:   values.email,
    role_id: selectedRoleDef.id,
  });
  ```
  Name/email now actually persist (they were silently dropped before).

### 12. Frontend — tests

Run `npm test` after the above. Most tests stub `adminsApi.update` as a
mock, so the signature change lands cleanly. If a test asserts on body
shape, update it to `{ role_id: <uuid> }`.

## Out of scope (do not fold in — surface in commit message)

- **`DeactivateAdmin` has the same class of bug.**
  `admin_repo.go:52-55` does `UPDATE users SET role = 'deactivated'` but
  `'deactivated'` is **not** in the `user_role` ENUM (grep across
  migrations found zero matches). Deactivate is latent-500 on any admin.
  Fix separately — likely by introducing a `status` column on `users`
  instead of overloading the role ENUM.
- **Middleware role-gating.** `RequireRole(domain.RoleOperations)` etc.
  at `router.go:99-154` matches on JWT ENUM. Custom-role admins bucket
  into `admin`, so they won't pass operations-/finance-/support-gated
  routes even if their custom role has the right permission. The
  permission-based alternative (`/admin/me/permissions`) is already wired
  for the sidebar. Migrating the middleware gates to permission keys is
  a separate refactor.
- **JWT contents.** JWT carries only the ENUM `role`. A target admin
  whose role changes keeps their old JWT until next login. Pre-existing.
- **`role_name` missing in admin list response.** Frontend `AdminUser`
  type has `role_name?: string` but the backend `UserResponse` doesn't
  populate it — UI shows the ENUM bucket instead of the actual role
  name. Cosmetic, not caused by this fix.

## Verification

Backend:
```
cd C:\Users\EDWARD\Documents\SakAI\backend
go generate ./...           # regenerate mocks
go build ./...
go test ./internal/...
```

OpenAPI + frontend types:
```
cd C:\Users\EDWARD\Documents\SakAI\admin
npm run generate:types
```
Confirm `src/types/openapi.d.ts` `UpdateAdminStatusRequest` exposes
`role_id: string` (UUID), not `role`.

Frontend:
```
npm run lint
npm test
npm run dev
```

Browser E2E (http://localhost:3000 + backend running):
1. Log in as superadmin.
2. Create a custom role via `/admin/super-admin/roles` (e.g.
   "Marketing", with `user_management:read`).
3. Go to SA Admin Management. Pick any non-superadmin admin; switch role
   to "Marketing"; confirm.
   - Network: `PUT /admin/users/:id` body `{ role_id: "<uuid>" }` →
     **204**.
   - Row reflects new role after refetch.
4. In an incognito window, log in as that admin. Sidebar shows only the
   `user_management` entry.
5. Back as superadmin, try to change any admin (including self — already
   blocked) to the seeded `super_admin` role. Expect error: "cannot
   promote to superadmin via role update".
6. Change back to `support`. Sidebar on that admin's next login reverts.
7. Edit the same admin's name + email (without touching role). `GET
   /admin/users` shows the new values. Try saving an email already used
   by another admin → expect 409-style error ("email already registered").
8. `/admin/super-admin/audit-logs` → latest `UPDATE_STATUS` entry's
   `after_state` contains `name`, `email`, `role`, `role_id`.

## Critical files

- `backend/internal/delivery/http/dto/admin_dto.go`
- `backend/internal/delivery/http/admin_handler.go`
- `backend/internal/delivery/http/admin_handler_test.go`
- `backend/internal/usecase/admin_usecase.go`
- `backend/internal/usecase/admin_usecase_test.go`
- `backend/internal/domain/ports.go`
- `backend/internal/domain/mocks/mock_ports.go` *(regenerated)*
- `backend/internal/repository/postgres/admin_repo.go`
- `openapi/swagger.yaml`
- `admin/src/types/openapi.d.ts` *(generated)*
- `admin/src/api/super-admin/admins.ts`
- `admin/src/pages/super-admin/SAAdminManagement.tsx`
- `admin/src/pages/settings/AdminsTab.tsx`
