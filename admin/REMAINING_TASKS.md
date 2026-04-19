# SakAI Admin — Remaining Tasks

Last updated: 2026-04-19

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

## Deferred
- Driver Heatmap (`src/components/super-admin/dashboard/DriverHeatmap.tsx`) — needs Google Maps / Mapbox API key
- `FareConfig` vehicle type `'car'` vs spec `'other'` — minor naming drift, low priority
- `before_state`/`after_state` openapi-typescript codegen fix — needs codegen config change
