# Refactoring Super Admin Panel to Match Spec

> **Status:** ✅ Completed 2026-04-22 — all 5 phases shipped: backend contract sync, deps (zustand / react-query / react-table), dynamic RBAC hooks, route-guard cleanup, API + types modularization, full component extraction.

This implementation plan bridges the gap between the current state of the admin application and the `superadmin.md` specification. It covers backend contract sync, dynamic RBAC, architecture modularity, API layer decoupling, and required dependencies.

## User Review Required

> [!WARNING]
> **Dependencies Check**
> The spec dictates the use of `Zustand` for client state, `TanStack Query` for server state, `TanStack Table` (React Table v8), and `openapi-typescript` for backend contract generation. Checking `package.json` reveals `zustand`, `@tanstack/react-query`, and `@tanstack/react-table` are currently missing. Phase 0 also installs `openapi-typescript` to generate types from the shared OpenAPI contract rather than hand-writing them. Are you okay with introducing these dependencies?

## Proposed Changes

---

### Phase 0: Backend Contract Sync (NEW)

The Go backend exposes an OpenAPI contract at `../openapi/swagger.yaml`. All frontend types must be generated from this contract — not hand-written — to prevent drift.

#### `npm install --save-dev openapi-typescript`

#### Generate types
- Run `npx openapi-typescript ../openapi/swagger.yaml -o src/types/openapi.d.ts`
- Add this as an `npm run generate:types` script in `package.json`.
- The generated `openapi.d.ts` becomes the source of truth; the manually authored `src/types/super-admin/*` files in Phase 4 will re-export and extend from it instead of defining their own interfaces.

> [!NOTE]
> Whenever the backend swagger changes, run `npm run generate:types` to sync. The TypeScript compiler will surface any mismatch at build time.

---

### Phase 1: Dependencies & Initialization

Install missing runtime libraries defined in the specification.

#### `npm install`
- Install `zustand` (Spec: "Zustand for client state")
- Install `@tanstack/react-query` (Spec: "React Query for server state")
- Install `@tanstack/react-table` (Spec: "TanStack Table")

---

### Phase 2: Core React Hooks & State Management

Develop the specific dynamic RBAC hooks and caching logic. The spec defines these hooks at `src/hooks/` (not in a `super-admin/` subdirectory).

> [!WARNING]
> **Existing hook collision:** `src/hooks/usePermission.ts` (singular) currently wraps `AuthContext.hasPermission` using the static `Permission` type. This file must be **deleted** after the new `usePermissions.ts` (plural, dynamic) is in place — see Phase 3 ordering note.

#### [NEW] [usePermissions.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/usePermissions.ts)
- Utilize Zustand to cache user roles and permission sets fetched from `GET /api/admin/roles/:id/permissions` on auth.
- Supply the `can(key: string, scope: 'read' | 'write'): boolean` helper function.
- Returns `{ can, permissions, role }`.

#### [NEW] [useAuth.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/useAuth.ts)
- Abstract authentication API calls; triggers the `usePermissions` Zustand store to load permissions on successful login or page refresh.

#### [NEW] [useRoles.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/useRoles.ts)
- CRUD operations for roles and permission sets (React Query mutations).

#### [NEW] [useAuditLog.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/useAuditLog.ts)
- Provides a `logAction` function that posts to the audit endpoint.
- Wraps React Query mutations to capture before/after states for critical actions.

#### [NEW] [useFareConfig.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/useFareConfig.ts)
- React Query hooks for reading and updating fare/surge settings.

#### [NEW] [useMetrics.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/useMetrics.ts)
- React Query hooks for the dashboard KPI endpoints; auto-refresh every 60s for live metrics.

#### [NEW] [useRealTimeUpdates.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/hooks/useRealTimeUpdates.ts)
- WebSocket or polling wrapper for the activity feed.

---

### Phase 3: Route Guard Cleanup

> [!IMPORTANT]
> **Order of operations:** Remove `ROLE_PERMISSIONS` (permissions.ts) **only after** replacing all call sites of `usePermission.ts` (singular) with `usePermissions.ts` (plural). Deleting the static matrix first will break `usePermission.ts` before its replacement is ready.

1. Migrate call sites from `usePermission` (singular) → `usePermissions` + `can()`.
2. Delete `src/hooks/usePermission.ts` (singular).
3. Remove `ROLE_PERMISSIONS` matrix from `src/lib/permissions.ts`.
4. Modify `App.tsx` and `AuthContext.tsx` as below.

#### [MODIFY] [App.tsx](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/App.tsx)
- Remove `<ProtectedRoute allowedRoles={['super_admin']}>` wrapper (currently `src/App.tsx:94`).
- Ensure `RootRedirect()` (`:60`) relies on dynamic role checking, unblocking roles like `finance` and `operations` when they possess required feature permissions.

#### [MODIFY] [AuthContext.tsx](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/contexts/AuthContext.tsx)
- Remove `deriveAdminRole` (`:26`) static generation and the `mockRoles` (`:56`) override.
- Rely fully on the backend JWT payload (`{ sub: adminId, role_id: "uuid", exp: ... }`) and the dynamic permission fetch in `usePermissions`.

#### [MODIFY] [permissions.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/lib/permissions.ts)
- Remove `ROLE_PERMISSIONS` matrix (`:62`), keeping only the permission key constants (used as identifiers).

---

### Phase 4: API & Types Modularization

> [!IMPORTANT]
> **Import migration before deletion.** The following non-super-admin pages also import from `@/lib/admin-api` and will break if it is deleted before they are migrated:
> `Dashboard.tsx`, `UserManagement.tsx`, `RideManagement.tsx`, `Payments.tsx`, `FareSurge.tsx`, `SafetyCompliance.tsx`, `Reports.tsx`, `Settings.tsx`
>
> Migration order: (1) create `src/api/super-admin/*`, (2) update SA page imports, (3) create `src/api/admin/*` for the regular pages, (4) update regular page imports, (5) delete `admin-api.ts`.

#### [DELETE] [admin-api.ts](file:///c:/Users/EDWARD/Documents/SakAI/admin/src/lib/admin-api.ts)
- Remove only after all imports across all pages are migrated.

#### [NEW] `src/api/super-admin/*`
- `auth.ts`, `metrics.ts`, `admins.ts`, `roles.ts`, `fares.ts`, `payments.ts`, `safety.ts`, `reports.ts`, `system.ts`, `audit.ts`.
- Each file exports typed `fetch` functions using `BASE_URL` + `tokenStore`.
- Function signatures must align with the OpenAPI operation IDs from `swagger.yaml`.
- `roles.ts` must include the `GET /api/admin/roles/:id/permissions` call consumed by `usePermissions`.

#### [NEW] `src/types/super-admin/*`
- `admin.ts`, `role.ts`, `fare.ts`, `payment.ts`, `incident.ts`, `audit.ts`, `system.ts`, `enums.ts`.
- **Do not define raw interfaces here.** Re-export and extend types from the generated `src/types/openapi.d.ts` (Phase 0).
- Example: `export type AdminUser = components['schemas']['AdminUser']`

---

### Phase 5: Component Extraction, Forms & Modals

Refactor SA pages into the component structure required by `superadmin.md §2`.

#### [NEW] `src/components/super-admin/dashboard/`
- `KPICard.tsx` — metric card with trend arrow and percentage change.
- `RidesChart.tsx` — line chart (7d/30d/90d toggle), previous period overlay.
- `RevenueChart.tsx` — stacked bar chart by payment method (Cash/GCash/PayMaya/Card), values in ₱.
- `DriverHeatmap.tsx` — map widget with real-time driver density.
- `VehicleTypeDonut.tsx` — motorcycle / tricycle / other breakdown.
- `ActivityFeed.tsx` — real-time event stream (sign-ups, SOS, payment failures, AC1 violations, API alerts).

#### [NEW] `src/components/super-admin/tables/`
- `DataTable.tsx` — reusable TanStack Table wrapper (sorting, pagination, filtering).
- `TransactionTable.tsx` — transaction history with filterable columns (spec §4.5).
- `AdminTable.tsx` — admin user list (spec §4.2).
- `IncidentTable.tsx` — emergency incident log (spec §4.6).
- `KYCQueue.tsx` — driver document verification queue.

#### [NEW] `src/components/super-admin/modals/`
- `ConfirmationModal.tsx` — reusable prompt for all destructive/high-impact actions.
- `CreateAdminModal.tsx` — name, email, role dropdown (from `GET /api/admin/roles`), temporary password.
- `CreateRoleModal.tsx` — wraps `RolePermissionForm` below.
- `FareChangePreview.tsx` — before/after comparison required for all fare changes.
- `PayoutApprovalModal.tsx` — batch payout approval confirmation.

#### [NEW] `src/components/super-admin/forms/`
All forms use **React Hook Form + Zod** for validation (both already installed).
- `FareConfigForm.tsx` — base fare table per vehicle type.
- `SurgeConfigForm.tsx` — surge multiplier range and trigger thresholds.
- `CommissionForm.tsx` — platform commission rate per vehicle type + promo overrides.
- `NotificationTemplateForm.tsx` — system notification template editor.
- `IntegrationConfigForm.tsx` — API key fields (masked, last 4 chars only via `maskApiKey.ts`).
- `RolePermissionForm.tsx` — permission toggle grid (read/write columns per permission key, spec §4.3).

#### [NEW] `src/components/super-admin/shared/`
- `StatusBadge.tsx`, `CurrencyDisplay.tsx` (₱ formatting), `DateDisplay.tsx` (PHT timezone), `RoleBadge.tsx`, `ServiceHealthIndicator.tsx`, `DateRangePicker.tsx`.

#### [MODIFY] Page Components
- Extract inline tables into the `tables/` components above.
- Extract dashboard widgets into `dashboard/` components above.
- Apply `usePermissions` + `can()` checks inside components (e.g. hide "Edit Role" button if `!can('role_management', 'write')`).
- Replace inline forms with the RHF-backed `forms/` components above.

#### [NEW] `src/utils/`
- `formatCurrency.ts` — PHP formatting (₱12,345.67).
- `formatDate.ts` — PHT (Asia/Manila, UTC+8) display.
- `maskApiKey.ts` — show last 4 characters only for API keys.

#### [NEW] `src/constants/`
- `roles.ts`, `permissions.ts`, `routes.ts`, `featureFlags.ts`.

---

## Verification Plan

### Type Safety
- Run `npm run generate:types` to ensure `openapi.d.ts` is up to date.
- Run `npm run build` (which runs `tsc --noEmit` then Vite build) to verify type safety across all refactored components and generated types.

> [!NOTE]
> `npm run lint` currently maps to `tsc --noEmit` only — there is no ESLint step. Consider adding one separately; for now the typecheck + build is the verification gate.

### Manual Verification
- Deploy to local dev server (`npm run dev`).
- Verify new libraries (`zustand`, `@tanstack/react-query`, `@tanstack/react-table`) do not crash the app bundle.
- Test login with the backend endpoint: confirm a non-`super_admin` with relevant permissions can access `/super-admin/*` pages under dynamic RBAC.
- Open a high-impact action (deleting a role) to confirm `ConfirmationModal.tsx` appears.
- Verify API key fields in `IntegrationConfigForm.tsx` show only the last 4 characters.
- Verify all monetary values display as ₱ with 2 decimal places and thousands separator.
- Verify all datetimes display in PHT (UTC+8).
