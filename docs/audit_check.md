# SakAI API Contract Alignment Audit

**Spec version:** OpenAPI 3.0.3 — `openapi/swagger.yaml` v1.2.0  
**Audit date:** 2026-04-19  
**Scope:** `admin/src/api/`, `admin/src/types/`, `admin/src/hooks/`, `admin/src/lib/api.ts`  
**Auditor role:** Senior backend architect / API governance

---

## ✅ Fully Aligned Areas

The following endpoints and schema types are correctly implemented: HTTP method, path, request shape, response shape, and status codes all match the spec.

### Non-Admin API Layer (`src/lib/api.ts`)

| Area | Endpoints |
|---|---|
| Auth | `POST /auth/login`, `POST /auth/register`, `POST /auth/refresh`, `POST /auth/logout` |
| Ride lifecycle | `POST /rides`, `GET /rides/{id}`, `POST /rides/{id}/start`, `POST /rides/{id}/complete`, `POST /rides/{id}/cancel`, `GET /rides/{id}/route` |
| Health | `GET /health` |

### Admin API Layer (`src/api/super-admin/`, `src/api/admin/`)

| Area | Endpoints |
|---|---|
| Roles (CRUD) | `GET /admin/roles`, `POST /admin/roles`, `PUT /admin/roles/{id}`, `DELETE /admin/roles/{id}` |
| Roles (sub-resources) | `GET /admin/roles/{id}/permissions`, `GET /admin/roles/{id}/admins` |
| System config (reads) | `GET /admin/system/services`, `GET /admin/system/feature-flags`, `GET /admin/system/integrations`, `GET /admin/system/notification-templates` |
| System config (writes) | `PUT /admin/system/integrations/{service}`, `PUT /admin/system/notification-templates/{event}` |
| Payments (reads) | `GET /admin/payments/transactions`, `GET /admin/payments/payouts`, `GET /admin/payments/commission-config`, `GET /admin/payments/config` |
| Safety (reads) | `GET /admin/incidents`, `GET /admin/safety/kyc`, `GET /admin/safety/compliance` |
| Reports | `GET /admin/reports/chart/{type}`, `GET /admin/reports/list`, `POST /admin/reports/export/{type}` |
| Dashboard aggregate | `GET /admin/dashboard` |

### Schema Types (generated from spec, used correctly)

`FareConfig`, `SurgeConfig`, `DriverPayout`, `Transaction`, `CommissionConfig`, `Incident`, `KycEntry`, `ComplianceData`, `SystemService`, `FeatureFlag`, `Integration`, `NotificationTemplate`, `Role`, `Permission`

---

## ❌ Misalignments

28 discrete issues. Each entry follows the format:

> **Type** | **Severity** | Description  
> **Contract definition** (what the spec says)  
> **Frontend behavior** (what the code does)  
> **Recommended fix**

---

### Critical — Must Fix Before Production

---

**[C1]** `src/api/super-admin/audit.ts` — `exportCsv()`

| Field | Detail |
|---|---|
| **Type** | Endpoint mismatch (method + path + content-type + response shape all wrong) |
| **Severity** | Critical |
| **Contract definition** | `GET /admin/audit/export` → `200 text/csv` binary stream |
| **Frontend behavior** | `POST /admin/reports/export/audit` expecting `{ url: string }` JSON response |
| **Recommended fix** | Change to `adminRequest('GET', '/audit/export')` with `Accept: text/csv` header; handle the response as a `Blob` and trigger a browser download via `URL.createObjectURL()` |

---

**[C2]** `src/api/super-admin/payments.ts` — local `PaymentSummary` interface

| Field | Detail |
|---|---|
| **Type** | Schema field name mismatch + undocumented field |
| **Severity** | Critical |
| **Contract definition** | `PaymentSummary: { total_revenue, payouts, commission, pending_settlements }` |
| **Frontend behavior** | Local interface uses `{ total_revenue, total_driver_payouts, platform_commission, pending_settlements, failed_transactions }` — two fields renamed, one field (`failed_transactions`) added with no spec equivalent |
| **Recommended fix** | Delete the local `PaymentSummary` interface and use the generated type from `src/types/openapi.d.ts`. Rename all UI consumers from `total_driver_payouts` → `payouts` and `platform_commission` → `commission`. Remove all references to `failed_transactions` |

---

**[C3]** `src/hooks/useAuditLog.ts` — `useAuditedMutation()`

| Field | Detail |
|---|---|
| **Type** | Hardcoded URL bypassing env config + undocumented endpoint |
| **Severity** | Critical |
| **Contract definition** | No `POST /admin/audit` endpoint exists in the spec |
| **Frontend behavior** | POSTs to the literal string `/api/admin/audit`, ignoring `VITE_API_BASE_URL` env var; this call will silently break in staging/production if the API is not on `/api` |
| **Recommended fix** | Either (a) remove the feature entirely if audit logging is server-side, or (b) add `POST /admin/audit` to the spec and use `adminRequest('POST', '/audit', payload)` via the shared `_request.ts` helper |

---

### High — Fix Before Feature Completion

---

**[H1]** `src/api/super-admin/fares.ts`, `safety.ts`, `system.ts` — 5 mutation endpoints

| Field | Detail |
|---|---|
| **Type** | Response code mismatch (204 vs typed body expectation) |
| **Severity** | High |
| **Contract definition** | `PUT /admin/fares` → 204, `PUT /admin/surge` → 204, `PUT /admin/incidents/{id}/resolve` → 204, `PUT /admin/system/feature-flags/{key}` → 204, `PUT /admin/safety/kyc/{id}` → 204 (no response body) |
| **Frontend behavior** | `adminRequest<FareConfig[]>`, `adminRequest<SurgeConfig>`, `adminRequest<Incident>`, `adminRequest<FeatureFlag>`, `adminRequest<KycEntry>` — all typed to expect response bodies; `_request.ts` returns `undefined as T` on 204, causing silent `undefined` to flow where an object is expected |
| **Recommended fix** | Change return type of all 5 to `adminRequest<void>(...)`. In React Query mutations, refetch the resource via `queryClient.invalidateQueries()` after success rather than using the mutation response for cache updates |

---

**[H2]** `src/api/super-admin/auth.ts` — `authApi.me()`

| Field | Detail |
|---|---|
| **Type** | Undocumented endpoint |
| **Severity** | High |
| **Contract definition** | No `GET /admin/users/me` path in spec; spec defines `GET /users/me` for non-admin user profiles only |
| **Frontend behavior** | `adminRequest('GET', '/users/me')` → resolves to `GET /admin/users/me` (due to `/admin` prefix prepend in `_request.ts`) |
| **Recommended fix** | Either add `GET /admin/users/me` to the spec returning `AdminUser`, or re-route this call through the non-admin base URL using `apiClient.get('/users/me')` from `src/lib/api.ts` |

---

**[H3]** `src/api/super-admin/admins.ts` — `adminsApi.create()`

| Field | Detail |
|---|---|
| **Type** | Response schema mismatch |
| **Severity** | High |
| **Contract definition** | `POST /admin/users` → `201 UserProfile` (role: `passenger \| driver`) |
| **Frontend behavior** | `adminRequest<AdminUser>('POST', '/users', data)` — `AdminUser` includes `role_id`, `role_name`, `status` fields not present in `UserProfile` |
| **Recommended fix** | Either update the spec to return `AdminUser` on create (preferred — semantically correct since this creates an admin), or cast the `UserProfile` response to `AdminUser` with explicit null defaults for the extended fields |

---

**[H4]** `src/api/super-admin/admins.ts` — `adminsApi.update()`

| Field | Detail |
|---|---|
| **Type** | Response code mismatch (204 vs typed body expectation) |
| **Severity** | High |
| **Contract definition** | `PUT /admin/users/{id}` → 204 No Content |
| **Frontend behavior** | `adminRequest<AdminUser>('PUT', '/users/${id}', data)` — expects `AdminUser` body; receives `undefined` at runtime |
| **Recommended fix** | Change return type to `adminRequest<void>(...)`. Use `queryClient.invalidateQueries(['admins'])` after mutation to refresh list state |

---

**[H5]** `src/api/admin/rides.ts`, `src/api/admin/users.ts` — list endpoints

| Field | Detail |
|---|---|
| **Type** | Missing request parameters |
| **Severity** | High |
| **Contract definition** | `GET /admin/rides`, `GET /admin/users/passengers`, `GET /admin/users/drivers` all accept `page: integer` and `limit: integer` query parameters |
| **Frontend behavior** | No `page` or `limit` parameters are forwarded; every call fetches the backend default (page 1, 20 items) — UI cannot paginate |
| **Recommended fix** | Accept `{ page?: number; limit?: number }` params in each function and forward them as query string: `?page=${page}&limit=${limit}` |

---

**[H6]** `src/api/admin/rides.ts`, `src/api/admin/users.ts` — `extractArray` usage

| Field | Detail |
|---|---|
| **Type** | Response data loss |
| **Severity** | High |
| **Contract definition** | `AdminRideListResponse { items: Ride[], meta: PaginationMeta }`, `AdminUserListResponse { items: UserProfile[], meta: PaginationMeta }` where `PaginationMeta = { total, page, limit, total_pages }` |
| **Frontend behavior** | `extractArray<T>(response)` strips the `meta` envelope — total record count and page count are unavailable to any UI component |
| **Recommended fix** | Replace `extractArray` with a typed unwrap that returns `{ items: T[], meta: PaginationMeta }`. Thread `meta` through to page components for correct pagination controls |

---

**[H7]** `src/types/super-admin/admin.ts` — `AdminRole` enum

| Field | Detail |
|---|---|
| **Type** | Enum value missing + case inconsistency |
| **Severity** | High |
| **Contract definition** | `CreateAdminRequest.role` enum: `[admin, superadmin, operations, finance, support]` |
| **Frontend behavior** | `AdminRole = 'super_admin' \| 'operations' \| 'finance' \| 'support'` — missing `'admin'`; uses `super_admin` (underscore) vs spec's `superadmin` (no underscore); `toBackendRole()` only normalizes `super_admin → superadmin` outbound, no inbound normalization |
| **Recommended fix** | Add `'admin'` to the union. Rename `super_admin` to `superadmin` throughout, or keep `super_admin` for UI display and ensure `toBackendRole()` is called on every outbound payload and a symmetric `fromBackendRole()` is called on every inbound response |

---

**[H8]** (missing) — `PUT /admin/auth/password`

| Field | Detail |
|---|---|
| **Type** | Spec endpoint not implemented |
| **Severity** | High |
| **Contract definition** | `PUT /admin/auth/password` (operationId: `adminChangePassword`) with `ChangePasswordRequest { old_password: string, new_password: string }` → 204 |
| **Frontend behavior** | No implementation in any API module or hook |
| **Recommended fix** | Add `authApi.changePassword(payload: ChangePasswordRequest): Promise<void>` in `src/api/super-admin/auth.ts` and wire it to an account settings UI |

---

**[H9]** (missing) — `POST /admin/payments/payouts/approve` (batch)

| Field | Detail |
|---|---|
| **Type** | Spec endpoint not implemented |
| **Severity** | High |
| **Contract definition** | `POST /admin/payments/payouts/approve` with `BatchApproveRequest { ids: string[] }` (UUIDs) → 200 |
| **Frontend behavior** | Only single-payout `PUT /admin/payments/payouts/{id}/approve` exists; no batch variant |
| **Recommended fix** | Add `paymentsApi.batchApprovePayouts(ids: string[]): Promise<void>` in `src/api/super-admin/payments.ts`; add bulk-select UI to the payouts table |

---

**[H10]** `src/api/super-admin/audit.ts` — `auditApi.getLogs()`

| Field | Detail |
|---|---|
| **Type** | Undocumented request parameters |
| **Severity** | High |
| **Contract definition** | `GET /admin/audit` — no query parameters defined in the spec |
| **Frontend behavior** | Sends `limit`, `offset`, `actor_id` as query params — this is useful behavior but entirely undocumented, meaning the backend may silently ignore them or break them in a future release |
| **Recommended fix** | Add `limit`, `offset`, and `actor_id` query parameters to the `GET /admin/audit` path in the spec, or remove them from the frontend call until the spec is updated |

---

### Medium — Fix in Next Sprint

---

**[M1]** `src/api/super-admin/fares.ts` — `faresApi.getSurge()`

| Field | Detail |
|---|---|
| **Type** | Wrong endpoint used |
| **Severity** | Medium |
| **Contract definition** | `GET /admin/fares/surge` (operationId: `adminGetSurge`) returns `SurgeConfig` directly |
| **Frontend behavior** | Calls `GET /admin/fares` then extracts `response.surge` — relies on a non-spec field being embedded in the fares list response |
| **Recommended fix** | Replace with `adminRequest<SurgeConfig>('GET', '/fares/surge')` |

---

**[M2]** (missing) — `GET /admin/roles/{id}`

| Field | Detail |
|---|---|
| **Type** | Spec endpoint not implemented |
| **Severity** | Medium |
| **Contract definition** | `GET /admin/roles/{id}` (operationId: `adminGetRole`) → `Role` |
| **Frontend behavior** | `rolesApi` has no `get(id)` method; role detail can only be derived from list data |
| **Recommended fix** | Add `rolesApi.get(id: string): Promise<Role>` in `src/api/super-admin/roles.ts` |

---

**[M3]** `src/api/super-admin/roles.ts` — `rolesApi.duplicate()`

| Field | Detail |
|---|---|
| **Type** | Undocumented endpoint called |
| **Severity** | Medium |
| **Contract definition** | No `POST /admin/roles/{id}/duplicate` path in spec |
| **Frontend behavior** | Calls `POST /admin/roles/${id}/duplicate` |
| **Recommended fix** | Add the endpoint to the spec, or implement duplication client-side by reading the role and POSTing a new one via the documented `POST /admin/roles` |

---

**[M4]** `src/api/super-admin/admins.ts` — `adminsApi.resetPassword()`

| Field | Detail |
|---|---|
| **Type** | Undocumented endpoint called |
| **Severity** | Medium |
| **Contract definition** | No admin "reset another user's password" endpoint in spec; spec only defines self-service `PUT /admin/auth/password` |
| **Frontend behavior** | Calls `PUT /admin/users/${id}/password` — not in spec |
| **Recommended fix** | Add `PUT /admin/users/{id}/password` to the spec with a `ResetPasswordRequest { new_password }` body, or remove this feature from the UI until the spec is updated |

---

**[M5]** (missing) — `POST /admin/safety/kyc/batch`

| Field | Detail |
|---|---|
| **Type** | Spec endpoint not implemented |
| **Severity** | Medium |
| **Contract definition** | `POST /admin/safety/kyc/batch` (operationId: `adminBatchKyc`) with `KycBatchRequest { ids: string[], action: 'approve' \| 'reject' }` |
| **Frontend behavior** | No implementation; only individual KYC updates are possible |
| **Recommended fix** | Add `safetyApi.batchKyc(payload: KycBatchRequest): Promise<void>` in `src/api/super-admin/safety.ts`; add bulk-select to the KYC queue UI |

---

**[M6]** (missing) — `POST /admin/system/integrations/{service}/test`

| Field | Detail |
|---|---|
| **Type** | Spec endpoint not implemented |
| **Severity** | Medium |
| **Contract definition** | `POST /admin/system/integrations/{service}/test` → `IntegrationTestResult { success: boolean, message: string, latency_ms: number }` |
| **Frontend behavior** | No "test connection" action in `systemApi` or Settings UI |
| **Recommended fix** | Add `systemApi.testIntegration(service: string): Promise<IntegrationTestResult>` and surface a "Test" button per integration card in the Settings page |

---

**[M7]** (missing) — individual metrics endpoints

| Field | Detail |
|---|---|
| **Type** | Spec endpoints not implemented |
| **Severity** | Medium |
| **Contract definition** | 5 endpoints: `GET /admin/metrics/riders`, `GET /admin/metrics/drivers`, `GET /admin/metrics/rides`, `GET /admin/metrics/revenue`, `GET /admin/metrics/wait-time` each returning `MetricResponse { value, change_pct, trend: 'up' \| 'down' \| 'stable' }` |
| **Frontend behavior** | Only `GET /admin/dashboard` (aggregate) is used; individual metric drill-down unavailable |
| **Recommended fix** | Add individual metric fetching to `src/api/super-admin/metrics.ts` and use them to drive the KPI cards on the Dashboard page for granular refresh control |

---

**[M8]** `src/api/super-admin/reports.ts` — `reportsApi.exportCsv()`

| Field | Detail |
|---|---|
| **Type** | Partial response consumption |
| **Severity** | Medium |
| **Contract definition** | `POST /admin/reports/export/{type}` → `200 { url: string, data: string }` (both fields required) |
| **Frontend behavior** | Only reads `r.url`; the `data` field (base64 or raw CSV string) is silently discarded |
| **Recommended fix** | Update the return type to the full spec shape and expose `data` to callers; this may be needed for in-browser preview or offline export |

---

**[M9]** `src/types/super-admin/audit.ts` — `AuditLog` type extension

| Field | Detail |
|---|---|
| **Type** | Non-spec field added to schema |
| **Severity** | Medium |
| **Contract definition** | `AuditLog` schema fields: `id, timestamp, actor_id, ip_address, action, resource_type, resource_id, before_state, after_state, reason` |
| **Frontend behavior** | TypeScript interface extends with `actor_name?: string` — field not in spec; if the backend never returns it the UI silently shows nothing |
| **Recommended fix** | Add `actor_name` to the spec (as a `readOnly` optional field that the backend resolves via JOIN), or derive it client-side by cross-referencing the admin list by `actor_id` |

---

### Low — Address in Backlog / Tech Debt

---

**[L1]** `src/api/super-admin/metrics.ts` — `metricsApi.getDashboard()` field fallbacks

| Field | Detail |
|---|---|
| **Type** | Defensive multi-fallback masking potential renames |
| **Severity** | Low |
| **Contract definition** | `DashboardResponse` field names are deterministic |
| **Frontend behavior** | `raw.total_riders ?? raw.active_riders ?? 0` and similar dual-access patterns — if the backend renames a field the wrong fallback silently wins |
| **Recommended fix** | Use the generated type directly with no fallback chains; if the spec is ambiguous, clarify field names and regenerate |

---

**[L2]** (missing) — `PUT /admin/payments/config/{provider}`

| Field | Detail |
|---|---|
| **Type** | Spec endpoint not implemented |
| **Severity** | Low |
| **Contract definition** | `PUT /admin/payments/config/{provider}` (operationId: `adminUpdatePaymentConfig`) |
| **Frontend behavior** | Only `GET /admin/payments/config` is implemented; payment provider configuration is read-only in the UI |
| **Recommended fix** | Add `paymentsApi.updateConfig(provider: string, payload: PaymentConfigRequest): Promise<void>` |

---

**[L3]** `src/types/super-admin/audit.ts` — `before_state` / `after_state` type

| Field | Detail |
|---|---|
| **Type** | Generated type is too narrow; manual override widens incorrectly |
| **Severity** | Low |
| **Contract definition** | `before_state: object, nullable: true`, `after_state: object, nullable: true` |
| **Frontend behavior** | Generated type is `Record<string, never>` (empty object — unsound); manually overridden to `Record<string, unknown> \| null` (correct intent but shouldn't be needed) |
| **Recommended fix** | Fix the `openapi-typescript` generation config or postprocess script so `object` schemas generate as `Record<string, unknown>` instead of `Record<string, never>` |

---

**[L4]** `src/api/super-admin/admins.ts` — `GET /admin/users` response schema

| Field | Detail |
|---|---|
| **Type** | Spec-level semantic issue surfaced by frontend |
| **Severity** | Low |
| **Contract definition** | `GET /admin/users` → `array of UserProfile` (role enum: `passenger \| driver`) — semantically wrong for an admin list endpoint |
| **Frontend behavior** | Frontend casts to `AdminUser` — more correct semantically, but diverges from the spec schema |
| **Recommended fix** | Update the spec so `GET /admin/users` returns `array of AdminUser` with the correct role enum |

---

**[L5]** `src/api/super-admin/admins.ts` — `toBackendRole()` one-way normalization

| Field | Detail |
|---|---|
| **Type** | Missing reverse normalization |
| **Severity** | Low |
| **Contract definition** | Role enum values from backend: `[admin, superadmin, operations, finance, support]` |
| **Frontend behavior** | `toBackendRole()` converts `super_admin → superadmin` outbound; no `fromBackendRole()` converts `superadmin → super_admin` inbound — role display in lists may show raw backend strings |
| **Recommended fix** | Add a symmetric `fromBackendRole()` that maps `superadmin → super_admin` and call it when ingesting admin list and profile responses |

---

**[L6]** `src/lib/api.ts:1` — stale version comment

| Field | Detail |
|---|---|
| **Type** | Documentation drift |
| **Severity** | Low |
| **Contract definition** | Spec is `openapi/swagger.yaml` v1.2.0 |
| **Frontend behavior** | File header comment reads `swagger.yaml v1.1.0` |
| **Recommended fix** | Update comment to v1.2.0; consider automating this via a codegen postprocess step |

---

## ⚠️ Risks

### R1 — Silent 204 propagation (affects C2, H1, H4)

`_request.ts` returns `undefined as T` on HTTP 204. Because the return type still reflects the expected generic `T`, TypeScript does not flag consumers. At runtime, any code that destructures or accesses properties on these "responses" will silently receive `undefined`, producing NaN, blank UI sections, or stale cache data with no console error. This is particularly dangerous for surge and fare config updates because the UI is optimistic and does not re-fetch.

### R2 — Hardcoded environment URL (C3)

`useAuditedMutation` posts to the literal string `/api/admin/audit`. This bypasses `VITE_API_BASE_URL`. In any deployment where the API lives at a different path or origin (staging, production behind a CDN, Docker compose), audit mutation calls will silently 404 while all other API calls succeed. No test currently catches this because tests mock `adminRequest`, not `fetch` directly.

### R3 — Pagination never surfaced to UI (H5, H6)

Every admin list endpoint fetches exactly page 1 with 20 items. As the SakAI platform scales (more riders, drivers, rides), only the first 20 records will ever appear in admin tables. This is a data visibility regression that will become critical once any list grows beyond 20 entries. The fix requires both the API layer (H5) and the component layer (H6) to be updated together.

### R4 — Role enum mismatch breaks admin creation (H7)

If an admin is created with `role: 'super_admin'` (frontend value), the backend receives the literal string `super_admin`. Because `toBackendRole()` is not called consistently across all creation paths, some flows will send the un-normalized value. If the backend validates strictly against the enum `[admin, superadmin, ...]`, these requests will return 400 and admin creation will fail silently or with a generic error.

### R5 — Undocumented endpoints are a maintenance liability (C3, M3, M4, H2, H10)

Five frontend endpoints call paths not present in the spec. These will not be tested by contract testing tools (Dredd, Pact), will not appear in generated SDK clients, and will not benefit from spec-driven validation. A backend refactor that renames or removes one of these paths will break the frontend with no warning during spec-level CI checks.

### R6 — Export audit endpoint will return 405/404 in production (C1)

The audit export call uses `POST` against a path that the spec defines as `GET`. Some API gateways and backend frameworks respond to method mismatches with 405 Method Not Allowed rather than routing to the handler. Even if the backend is lenient, the response content type (`text/csv` vs `application/json`) will cause the frontend JSON parser to throw, making export always broken.

---

## 📊 Alignment Score

**57 / 100**

### Scoring Rationale

| Dimension | Weight | Score | Notes |
|---|---|---|---|
| Endpoint coverage (40 spec paths) | 30% | 16/30 | ~15 spec endpoints missing from frontend; ~4 undocumented frontend endpoints |
| HTTP method + path correctness | 20% | 15/20 | C1 is a complete method+path failure; H2/M3/M4 are undocumented paths |
| Response schema accuracy | 20% | 10/20 | C2 (field renames), H1 (5× 204 typed as body), H3/H4 (wrong response types), H6 (meta stripped) |
| Request parameter correctness | 15% | 9/15 | H5 (no pagination params), H10 (undocumented params), C3 (wrong body + wrong URL) |
| Type safety and generated type usage | 10% | 5/10 | H7 (incomplete enum), L3 (bad generated type), L5 (one-way normalization) |
| Operational concerns (env, versioning) | 5% | 2/5 | C3 (hardcoded URL), L6 (stale comment) |
| **Total** | **100%** | **57/100** | |

### Summary

The non-admin ride lifecycle and authentication layer are solid. The RBAC role management and system configuration reads are well-aligned. The significant gaps are concentrated in: (1) mutation endpoints that ignore 204 semantics, (2) pagination being completely absent from list endpoints, (3) the audit export endpoint being entirely wrong, and (4) approximately 15 spec-defined endpoints with no frontend implementation. Addressing the 3 Critical and 10 High issues would bring the score to approximately 80/100.
