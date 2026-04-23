# SakAI Admin — Remaining Tasks

Last updated: 2026-04-22

## Completed ✅

### 1. Wire `testIntegration` to UI
**File:** `src/pages/super-admin/SASystemConfig.tsx`
- "Test Connection" button wired to `systemApi.testIntegration(service)`
- Shows inline `IntegrationTestResult` (success/fail badge, latency_ms, message)

### 2. Wire `batchApprovePayouts` to UI
**File:** `src/pages/super-admin/SAPayments.tsx`
- Row checkboxes added to pending payouts
- "Approve Selected (N)" toolbar button → `paymentsApi.batchApprovePayouts(ids)`

### 3. Wire `batchKyc` to UI
**File:** `src/pages/super-admin/SASafetyCompliance.tsx`
- Checkboxes added to pending KYC cards
- "Approve Selected (N)" / "Reject Selected (N)" bulk toolbar → `safetyApi.batchKyc(payload)`

### 4. Add Change Password UI
**File:** `src/pages/super-admin/SASystemConfig.tsx` (Account tab)
- New "Account" tab with old/new/confirm password fields
- Calls `authApi.changePassword({ old_password, new_password })`
- Client-side validation (min 8 chars, confirm match) + success/error feedback

### 5. Global Error Boundary
**Files:** `src/components/ErrorBoundary.tsx` + `src/App.tsx`
- Already implemented and wired before this session

### 6. Bundle Split
**File:** `vite.config.ts`
- Already implemented (`manualChunks: { recharts: ['recharts'] }`) before this session

### 7. `before_state` / `after_state` codegen fix (2026-04-22)
**Files:** `openapi/swagger.yaml`, `src/types/openapi.d.ts`, `src/types/super-admin/audit.ts`
- Added `additionalProperties: true` to AuditLog schema (swagger.yaml:4323-4328)
- Regenerated `src/types/openapi.d.ts` — `before_state`/`after_state` now emit `{ [key: string]: unknown } | null` directly
- Removed manual `Omit<>` widening wrapper in `src/types/super-admin/audit.ts`; type is now a thin alias adding only `actor_name?` for the UI

### 8. Driver Heatmap scaffold (2026-04-22)
**Files:** `src/components/super-admin/dashboard/DriverHeatmap.tsx`, `src/types/super-admin/heatmap.ts`, `src/api/super-admin/metrics.ts`, `src/hooks/useMetrics.ts`
- Provider-agnostic SVG density grid renders over Metro Manila bounds (no Maps API key needed for development)
- Types added: `DriverPosition`, `HeatmapBounds`, `HeatmapResponse`, `METRO_MANILA_BOUNDS`
- Hook `useDriverHeatmap()` (React Query, 30s refetch) wired to `metricsApi.getDriverHeatmap()`
- API client returns deterministic mock positions; swap one line to the real `GET /admin/drivers/heatmap` endpoint when backend ships it
- Component accepts `positions` / `bounds` props for testing or external data sources
- See top-of-file comment in `DriverHeatmap.tsx` for the 3-step swap to Google Maps / Mapbox

## Deferred

- **Backend endpoint `GET /admin/drivers/heatmap`** — frontend ready, backend needs to query active driver locations + bounds, document in `openapi/swagger.yaml`. Replace mock in `metricsApi.getDriverHeatmap` with a real `adminRequest` call.
- **Real map provider for Driver Heatmap** — current SVG grid is functional but visually abstract. To swap in Google Maps / Mapbox GL JS:
  1. Install provider SDK (`@vis.gl/react-google-maps` or `mapbox-gl` + `react-map-gl`)
  2. Replace `<HeatmapCanvas />` body in `DriverHeatmap.tsx` with the provider's heatmap layer fed by the same `positions` prop
  3. Read API key from `import.meta.env.VITE_MAPS_API_KEY`; expose configuration in System Config → Integrations
- **Wire Driver Heatmap into Dashboard** — component is built but not yet rendered in `src/pages/Dashboard.tsx`. Add to the dashboard grid alongside `RidesChart` / `RevenueChart`.
- **`FareConfig` vehicle type 'car'** — backend swagger uses `enum: [motorcycle, car, tricycle]` (canonical). Update `superadmin.md` spec doc to match (it currently says 'other'). No code change needed.
