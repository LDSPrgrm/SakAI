# Backend Integration Audit — SakAI Admin Panel

**Date:** 2026-04-22 (initial) · **Phase 1 tail landed:** 2026-04-22 · **Phase 3 landed:** 2026-04-22 · **Phase 4a landed:** 2026-04-23 · **Phase 4b landed:** 2026-04-23
**Scope:** All admin & superadmin pages (`admin/src/pages/**/*.tsx`) cross-referenced against the Go backend (`backend/internal/**`), OpenAPI contract (`openapi/swagger.yaml`), and Postgres migrations.
**Status legend:** 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low · ✅ Closed

## Phase 4b closure (2026-04-23)

- SOS location trail — ✅ migration 025 adds `driver_location_history(id, driver_id, incident_id, lat, lng, recorded_at)` + partial index `idx_incidents_active_driver ON incidents(driver_id) WHERE resolved_at IS NULL` so the hot-path `FindActiveByDriver` check is index-only in the empty case. `driverUseCase.UpdateLocation` now calls `captureIncidentTrail` after a successful location write; trail rows append per unresolved incident. Domain gains `IncidentLocationPoint`; `IncidentRepository` + `adminUseCase.GetIncident` + `IncidentDetailDTO` all carry the new `location_trail`. Swagger `IncidentDetail` extended with `location_trail: IncidentLocationPoint[]`. `IncidentDetailModal.tsx` renders the trail as a scrollable list of `lat, lng · timestamp`.
- Alert notification dispatch — ✅ migration 026 adds `notification_outbox(id, channel, recipient, subject, body, status, attempts, last_error, sent_at, created_at)` with pending-only partial index, plus four seeded `alert.*` templates in `notification_templates`. New `internal/infrastructure/notifications` package exposes `AlertNotifier` (renders `{{var}}` + fans one outbox row per superadmin/operations admin) + `Dispatcher` (30s tick, batch of 20, log-only `send()`, 5-attempt cap). `alerting.Evaluator.record` checks `RowsAffected()==1` so dispatch only runs when the cooldown guard let the event through.
- `ride_payments.method` ENUM — ✅ migration 027 runs `ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'gcash'/'paymaya'` (PG12+ transaction-safe). `domain.PaymentMethod` gains `PaymentMethodGcash`/`PaymentMethodPaymaya` + `IsValid()` update. Swagger enum widened at four call-sites plus the `PaymentMethod` schema. Down migration recreates the narrow type with rename + coerce + drop (lossy — gcash/paymaya rows coerce to cash).
- `SurgeConfig.updated_by_name` parity — ✅ `fareRepo.GetSurgeConfig` now `LEFT JOIN users`. `domain.SurgeConfig` gains `UpdatedByName`. Swagger `SurgeConfig` schema gets `id`, `updated_at`, `updated_by`, `updated_by_name`. `SAFareConfig.tsx` renders "Last updated by …" under the Save Surge Settings button.
- Mock regen — ✅ `go generate ./internal/domain/...` ran cleanly; `mock_ports.go` rewritten by the canonical generator, replacing the hand-extended copy from Phase 4a.
- Verification green: `go build ./...`, `go test ./...` (all packages, including updated `TestDriverUseCase_UpdateLocation_OnlineDriver` that now asserts `FindActiveByDriver`), `npm run generate:types`, `npm run lint`, `npm test` (136/136).

### Phase 4b caveats ⚠️

- **SOS trail capture ships dormant.** No SOS-trigger endpoint currently creates rows in `incidents`; `admin/incidents/*` is still read-only. Trail capture activates the moment mobile (or a future backend endpoint) creates an incident — until then the table stays empty and `location_trail` renders the "no GPS pings" empty state.
- **Notification dispatcher is log-only.** `send()` emits `[NOTIFY] channel=… to=… subject=… body=…` and flips status to `sent`. Plug a real SMS/email/push provider into the single `send()` call-site when one exists. `notification_outbox` rows are durable in the meantime so replay is possible.
- **`migrate down` cycle not exercised** for 025/026/027. 027 down is lossy by design.
- **Not browser-smoke-tested.** Updated `IncidentDetailModal` + `SAFareConfig` surge update-by line compile + pass vitest but not clicked through in `npm run dev` (autonomous + database-less session).

## Phase 4a closure (2026-04-23)

- #7 Payments export permission — already `can('reports','read')` (fixed in Phase 2, verified).
- #18/#19 SAAdminManagement casts — ✅ dropped. `adminsApi.list()` + `rolesApi.list()` already typed correctly; `as unknown as AdminUser[]` / `as unknown as AdminRoleDefinition[]` removed.
- #22 SAFareConfig `config.updated_by` UUID → username — ✅ `fare_configs` repo query now `LEFT JOIN users`, `domain.FareConfig.UpdatedByName` exposed, swagger `FareConfig` schema rewritten to carry `id, updated_at, updated_by, updated_by_name`. UI renders `updated_by_name || updated_by || '—'`.
- Payment gateway swagger drift — ✅ `PaymentGatewayConfig` rewritten from `{name, center, radius}` service-area drift to the real `{id, provider (gcash|paymaya|card|cash), config_fields (object), is_active, updated_at, updated_by}` shape. `domain.PaymentGatewayConfig.ConfigFields` retyped `[]byte` → `map[string]string` so JSON marshals as object instead of base64. Secret-like keys masked via new `maskGatewaySecrets` helper; `UpdateGatewayConfig` merges JSONB with `||` and drops `****`-prefixed values so unchanged secrets aren't overwritten.
- GatewayProvidersSection mount — ✅ component rewritten schema-driven against `PaymentGatewayConfig`. Per-provider `FieldSchema` map (gcash/paymaya/card/cash) drives labels + secret toggles. Mounted on `SAPayments.tsx` after commission config.
- `payment_repo` stubs — ✅ all three replaced. `ListTransactions` joins `ride_payments → rides → users (rider+driver) → commission_settings`, computing commission as `amount × rate_percent / 100` clamped to `min_commission`. `GetPaymentSummary` is one aggregate SELECT over `ride_payments` + `driver_earnings` + new `driver_payouts`. `ListPayouts` / `ApprovePayout` now read/write the new table (idempotent `UPDATE ... WHERE id=$1 AND status='pending'`). In-memory `payoutsStore` deleted. `GetCommissionSettings` stub-fallback removed — rows must come from migration seeds.
- Migration `024_create_driver_payouts` — ✅ shipped. `driver_payouts(batch UNIQUE, period_label, status CHECK in pending|approved|paid|cancelled, approved_at/by)` + `driver_payout_lines` junction (UNIQUE per payout+driver).
- `KycEntry.status` enum — ✅ swagger extended to include `needs_more_info`.
- DriverHeatmap real backend — ✅ `GET /admin/drivers/heatmap` (operations/support/superadmin) returns online drivers with PostGIS `ST_X/ST_Y` coords + vehicle type + availability + actual lat/lng bounds. `MetricsRepository`/`MetricsUseCase` extended; mocks hand-extended; `metrics.ts.getDriverHeatmap` now calls the real endpoint (Metro-Manila fallback on empty/error). Swagger gains `DriverHeatmap`, `HeatmapPosition`, `HeatmapBounds`.
- Alert evaluator dedup — ✅ `cooldownMinutes(rule.Config)` (default 60). `evaluator.record` now a conditional `INSERT ... WHERE NOT EXISTS (... fired_at >= NOW() - cooldown)` — concurrent ticks can't double-emit. Cooldown stored in `rule.Config.cooldown_minutes`; no schema migration needed.
- `TEST_ACCOUNTS.md` UI port — ✅ bumped `5173 → 3000`.

### Phase 4a caveats ⚠️

- **Not browser-smoke-tested.** GatewayProvidersSection, DriverHeatmap mount, SAFareConfig updated-by rendering compile + type-check + pass 136/136 vitest; click-through in `npm run dev` was skipped (autonomous + database-less session). Hit these before merging.
- **ride_payments.method ENUM is still `('cash','card')`.** `ListTransactions` now reads real rows, but gcash/paymaya transactions will not appear in the admin list until the e-wallet pipeline writes into `ride_payments` (or the ENUM is extended with those values).
- **Mocks regenerated manually.** New `MetricsRepository.GetDriverHeatmap` / `MetricsUseCase.GetDriverHeatmap` stubs added by hand to `mock_ports.go`. Run full `mockgen` once the toolchain is available to pick up ordering tweaks.
- **Forward migrations verified; `migrate down` + `migrate up` cycle not exercised** this session.

### Phase 4a deferred → Phase 4b (all landed 2026-04-23)

- ✅ **SOS location trail** (plan §3.1 sub-bullet). Migration 025 + partial index + `driverUseCase.captureIncidentTrail` + `IncidentDetailModal` trail list. Dormant until mobile creates incidents.
- ✅ **Alert notification dispatch** via `notification_templates`. Migration 026 + `notifications` package + log-only dispatcher + four seeded alert templates.
- ✅ **`SurgeConfig` updated_by_name** parity — repo `LEFT JOIN users`, domain + swagger + UI all updated.
- ✅ **`ride_payments` ENUM extension**. Migration 027 `ALTER TYPE payment_method ADD VALUE gcash/paymaya`; swagger enums widened; domain constants + `IsValid()` updated.

## Phase 3 closure (2026-04-22)

All Phase-3 scope shipped except two subsections deferred to Phase 4 (rationale below):

- #31 SASafetyCompliance incident "View" — ✅ `IncidentDetailModal` wired. Opens from row click + icon button.
- Migration `021_create_incident_status_history` — trigger captures INSERT + status/assignee UPDATE on `incidents`. Backfill row per existing incident. Timeline reads via `GET /admin/incidents/{id}` → `{incident, status_history[]}`.
- `PUT /admin/incidents/{id}/assign` — reassign dropdown in modal; body `{"assignee_id": "<uuid>" | null}`.
- Migration `022_create_service_areas` — `service_areas(boundary JSONB, active)` + `lgu_partnerships(service_area_id FK, status CHECK)`. `GET /service-area` public, `/admin/service-areas` + `/admin/lgu-partnerships` CRUD superadmin-only. New `SALguPartnerships` page in sidebar under "LGU & Coverage".
- Migration `023_create_alert_rules` — `alert_rules(type CHECK in four values, config JSONB)` + `alert_events`. CRUD at `/admin/alerts/rules`, events at `/admin/alerts/events`. Evaluator goroutine ticks every 5 min, four switch branches, one parametric SQL per type. `AlertRulesTab` mounted in `SASystemConfig`.
- Surge zone polygon editor (`SurgeZoneEditor`) mounted on `SAFareConfig`. Reused as boundary editor on `SALguPartnerships` area modal. `FareCalculator.SimulateFare` now applies zone multiplier when origin sits inside a configured polygon (ray-casting, `usecase.FindZoneMultiplier`); falls back to global `max_multiplier` otherwise. `surge_configs.zones` retyped `[]byte` → `json.RawMessage` so Gin's JSON binder accepts arrays.
- Map adapter — `src/lib/maps/` exposes `MapProvider` interface with SVG default + Mapbox/Google stubs; toggle via `VITE_MAP_PROVIDER`. `SurgeZoneEditor` consumes `activeMapProvider.PolygonEditor`.
- Swagger regen + openapi.d.ts regen. Added 10 paths + 11 schemas; rewrote `ServiceArea` from legacy `{center, radius}` to `{boundary, active}` (see §4 drift table).

### Phase 3 caveats ⚠️

- **Not browser-smoke-tested.** IncidentDetailModal, SurgeZoneEditor, SALguPartnerships page + modals, AlertRulesTab all compile + type-check + pass unit tests, but were not exercised in `npm run dev` this session (autonomous, database-less). Hit these before merging.
- **Alert evaluator is write-without-dedup.** Every 5-min tick inserts a fresh `alert_events` row per still-tripping rule — ~288/day per matching subject. Phase 4 adds cooldown + dedupe.
- **Migration rollback not tested.** Forward only this session; run `migrate down` + `migrate up` as part of CI or release checklist.

### Phase 3 deferred → Phase 4

- **SOS location trail.** Plan §3.1 asked for `sos_location_trail[]` derived from driver location pings. No `driver_location_history` table exists and `drivers.location` is a single current-position row. Adding location capture + retention during active SOS incidents is a Phase-4 follow-up.
- **Alert notification dispatch.** Plan §3.3 said "optionally dispatches via notification_templates". Evaluator only records `alert_events` rows; no SMS/email/push push yet. Phase 4.
- **PostGIS `ST_Contains`** replaced by Go ray-casting. PostGIS is already available (drivers use geometry) so migration is one-query if scale demands it — not now.

## Phase 2 closure (2026-04-22)

All Phase-2 P1 UI gaps closed:

- #3/#4/#5 UserManagement dead buttons — `RiderDetailModal`, `DriverDetailModal`, `DriverDocumentsModal` shipped.
- #6 RideManagement row click — `RideDetailModal` shipped.
- #7 Payments export permission bug — now gates on `can('reports','read')`.
- #8/#9/#10 Payments.tsx missing polish — confirm modal, pagination, date-range filter all shipped (client-side date filter; backend param pipeline wired but filters a stubbed transactions list — see §3 note).
- #16 SADashboard refresh — now calls `refetch()` on all metric queries.
- #20 SAFareConfig onSaved — invalidates fare cache keys.
- #24 SAPayments transaction detail — `TransactionDetailModal` shipped.
- #26 CommissionConfigCard missing `car` row — added.
- #34 KycDocPreview key collision — already fixed upstream; verified.
- #36 Per-provider integration fields — `INTEGRATION_SCHEMAS` schema-driven form; secrets toggle, mask-preservation on save.
- #1 DriverHeatmap mount on Dashboard — mounted. **Note:** backend `getDriverHeatmap` still returns deterministic mock points (`metrics.ts:82` comment); real endpoint tracked in Phase 4.

### Phase 2 discovery — `payment_repo.go` is still a stub

Audit §3 "Payments (all real)" claim is overstated. `payment_repo.go:37-57` hardcodes 3 transaction rows; `GetPaymentSummary` returns hardcoded KPI values; `ListPayouts` seeds from an in-memory `payoutsStore`. Phase 2.3 wired a date-range filter + pagination, so the UI reads real params through the handler — but they filter stub rows. Rewriting these three methods against `ride_payments`, `driver_earnings`, and a new `driver_payouts` table is deferred to Phase 4.

## Phase 1 closure (2026-04-22)

All P0 backend-integration gaps are now closed:

- #2 dashboard revenue/wait/uptime — real SQL in `admin_repo.go`.
- #12/#13/#14 Reports fake fallbacks — removed, real aggregations in `report_repo.go`.
- #17 SADashboard trends — backend computed server-side.
- #27/#28 SAReports date-range + canonical chart ids — wired end-to-end.
- #35 LtfrbReportsSection type drift — retyped to `components['schemas']['ComplianceData']`; dropped insurance/inspection/report-schedule fields the backend doesn't own.
- #39 SASystemHealth hardcoded `INFRA_METRICS` — replaced by `GET /admin/system/infra-metrics` fed by the perf middleware + health-probe goroutine.
- #40 System service stubs — replaced by `system_health_probes` writer loop.
- Backend §3.J system config stubs — persisted via `feature_flags`, `notification_templates`, `integration_configs`.
- Swagger gap: `/driver/earnings` — handler + route shipped; `/service-area` deferred to Phase 3.
- Storage: `document_handler.go` now uses `Uploader` interface; authenticated `GET /api/files/*filepath` serves the local uploads dir with path-traversal + RBAC guards.
- `TestIntegration` — dials the real providers (stripe/twilio/mapbox/gcash/paymaya/firebase) with `SKIP_EXTERNAL_PINGS=true` to short-circuit CI/dev.

---

## Executive summary

| Category | Count |
|----------|-------|
| Hardcoded backend values rendered as real data | 8 |
| Backend endpoints that return mock / no-op data | 23 |
| Dead UI handlers (button with no onClick) | 7 |
| Date/filter inputs that never reach the backend | 3 |
| OpenAPI endpoints with no Go handler | 2 |
| DB tables referenced by UI that don't exist | 7 |
| Type casts that hide schema drift | 3 |
| UI-only fallback / placeholder mock data | 4 |

Backend implementation coverage (pre-Phase-1): Auth 100%, Rides 100%, Admin Users/Roles 100%, Fares 100%, Payments 100%, Passenger Payments 100%, Admin Dashboard 83%, Driver Ops 60%, Incidents/Safety 50%, Reports/Audit 33%, Admin System 0%. Aggregate: **76% real, 24% stub/missing**.

Post-Phase-1: Admin Dashboard 100%, Driver Ops 100% (earnings added), Reports/Audit 100%, Admin System 100% (probes + config persistence + real TestIntegration). Aggregate: **~95% real** — the remaining 5% was Phase-3 scope (incident timeline, surge zones, alert rules, LGU partnerships, `/service-area`).

Post-Phase-3: Incidents 100% (timeline + reassign + detail), Fares 100% (zone-aware simulation), Service areas + LGU 100% (new surface), Alerts 100% as CRUD + periodic evaluator. Aggregate: **~98% real**.

Post-Phase-4a: Payments 100% real (transactions/summary/payouts now query `ride_payments + driver_earnings + driver_payouts`), DriverHeatmap 100% real (PostGIS-backed `/admin/drivers/heatmap`), Alerts 100% with dedup (no duplicate firings inside per-rule cooldown). Aggregate: **~99% real**. Remaining ~1% = SOS location trail capture, alert notification dispatch, `SurgeConfig.updated_by_name` parity, e-wallet ENUM extension — all Phase 4b.

Post-Phase-4b: SOS location trail captured (dormant until mobile creates incidents), alert-event notifications fan into `notification_outbox` per admin recipient (log-only dispatcher), `payment_method` ENUM widened to include gcash/paymaya, SurgeConfig join parity with FareConfig. Aggregate: **~100% real / integrated**. Remaining work is the SOS-trigger write-path on mobile, a real SMS/email/push provider for the notification dispatcher, and rollback exercise for migrations 025–027.

---

## Section 1 — Regular admin pages (`admin/src/pages/*.tsx`)

### Dashboard.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 1 | ~~"Live Hotspots" renders static animated circles; the ready-built `<DriverHeatmap>` component is never mounted~~ → mounted Phase 2; backend `getDriverHeatmap` now real (PostGIS `/admin/drivers/heatmap`) Phase 4a | Dashboard.tsx:176-186 | ✅ Fixed 2026-04-23 | 🟡 | 2/4a |
| 2 | Dashboard numbers come from `/admin/dashboard`, but backend hardcodes `RevenueToday=0`, `AvgWaitTimeSeconds=0`, `SystemUptime=99.99` | backend/internal/repository/postgres/admin_repo.go:365-370 | Fake data | 🔴 | 1 |

### UserManagement.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 3 | "View Profile" on rider row has no `onClick` | UserManagement.tsx:165 | Dead handler | 🟠 | 2 |
| 4 | "Review Documents" (CheckCircle) on driver row has no `onClick` | UserManagement.tsx:238 | Dead handler | 🟠 | 2 |
| 5 | "View Profile" on driver row has no `onClick` | UserManagement.tsx:239 | Dead handler | 🟠 | 2 |

### RideManagement.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 6 | Row has `cursor-pointer hover:bg-surface-hover/80` but no click handler | RideManagement.tsx:136 | Dead handler | 🟠 | 2 |

### Payments.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 7 | ~~`handleExport` uses `canWrite`; export is a read op and should use `can('reports','read')`~~ — already gated on `can('reports','read')` (Phase 2). Verified Phase 4a. | Payments.tsx:80 | ✅ Fixed | 🟡 | 2/4 |
| 8 | No confirm modal before payout approval | Payments.tsx | Missing safety | 🟡 | 2 |
| 9 | No pagination on transactions table | Payments.tsx | Missing feature | 🟡 | 2 |
| 10 | No date-range filter wired to `?from=&to=` | Payments.tsx | Missing filter | 🟡 | 2 |

### FareSurge.tsx
No issues — correctly calls `useSurgeConfig()` and populates state from backend.

### SafetyCompliance.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 11 | `compliance` typed inline; should use `components['schemas']['RegulatoryCompliance']` from openapi.d.ts | SafetyCompliance.tsx:95-100 | Type drift | 🟢 | 1 |

### Reports.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 12 | `displayVehicleData` hardcoded fallback (motorcycle 65%, tricycle 20%, car 15%) displayed when API empty | Reports.tsx:42-46 | Fake data | 🟠 | 1 |
| 13 | `displayPaymentData` hardcoded fallback (GCash 50%, Cash 30%, PayMaya 15%, Card 5%) | Reports.tsx:48-53 | Fake data | 🟠 | 1 |
| 14 | `displayReports` hardcoded fallback (4 report definitions) | Reports.tsx:55-60 | Fake data | 🟠 | 1 |
| 15 | Static "Last 30 Days" badge — no date-range picker | Reports.tsx:69 | Dead filter | 🟠 | 1 |

### Settings tabs
Clean. All handlers wired.

### Login.tsx
Clean.

---

## Section 2 — Super-admin pages (`admin/src/pages/super-admin/*.tsx`)

### SADashboard.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 16 | Refresh button calls `invalidateQueries(...)` — marks stale but doesn't force a refetch | SADashboard.tsx:54 | Dead handler | 🟡 | 1 |
| 17 | Trend fields (riders/drivers/rides/revenue/wait_trend) rendered without backend computation — currently absent or hardcoded | backend/internal/repository/postgres/admin_repo.go | Missing logic | 🟠 | 1 |

### SAAdminManagement.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 18 | ~~Double-cast `as unknown as AdminUser` indicates openapi schema drift~~ → cast removed; api types already correct | SAAdminManagement.tsx:58-59 | ✅ Fixed 2026-04-23 Phase 4a | 🟡 | 4 |
| 19 | `displayRole(...) !== values.role` — normalization works (verified) but worth a unit test on the role-rename path | SAAdminManagement.tsx:113-114 | Open (test only) | 🟢 | 4b |

### SAAuditLog.tsx
Clean.

### SAFareConfig.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 20 | `onSaved` callback is empty `() => {}` — no query invalidation after save | SAFareConfig.tsx:259-261 | Missing wiring | 🟡 | 2 |
| 21 | Fare simulator uses hardcoded Manila coords (`14.5995, 120.9842`) | SAFareConfig.tsx:195-213 | Hardcoded data | 🟢 | 3 |
| 22 | ~~`config.updated_by` rendered as-is; backend returns UUID, UI needs username~~ → repo `LEFT JOIN users`, `domain.FareConfig.UpdatedByName` exposed, swagger updated, UI renders `updated_by_name || updated_by || '—'` | SAFareConfig.tsx:126 | ✅ Fixed 2026-04-23 Phase 4a | 🟡 | 4a |

### SAPayments.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 23 | ~~`<GatewayProvidersSection>` component exists but never mounted~~ → swagger `PaymentGatewayConfig` rewritten to real shape, component rewritten schema-driven against new shape, mounted on SAPayments | SAPayments.tsx | ✅ Fixed 2026-04-23 Phase 4a | 🟠 | 4a |
| 24 | No transaction detail modal / row click | SAPayments.tsx | Dead handler | 🟠 | 2 |
| 25 | CSV export manually reconstructs headers client-side; backend should own format | SAPayments.tsx:125-137 | Brittle export | 🟢 | 3 |
| 26 | `CommissionConfigCard` renders only motorcycle/tricycle/other; missing `car` row | CommissionConfigCard.tsx:68 | Missing vehicle | 🟡 | 2 |

### SAReports.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 27 | Date-range picker state (`dateRange`) never passed to any API call | SAReports.tsx:39,83 | Dead filter | 🔴 | 1 |
| 28 | Chart query uses `payment-method` (singular); backend canonical is `payment-methods` (plural) | SAReports.tsx:44 | Key mismatch | 🟠 | 1 |
| 29 | `selectedReport` tracked but only "Download CSV" reads it — no other interaction | SAReports.tsx:282-294 | Minor | 🟢 | — |

### SARoleManagement.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 30 | `fromPermissions(role.permissions)` assumes all permission keys present; incomplete arrays silently drop | SARoleManagement.tsx:94-95 | Missing validation | 🟢 | 4 |

### SASafetyCompliance.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 31 | ~~Incident "View" button has no `onClick`~~ → wired to `IncidentDetailModal` | SASafetyCompliance.tsx:267 | ✅ Fixed 2026-04-22 Phase 3 | 🔴 | 3 |
| 32 | ~~"Assigned To" column shown but no reassign UI~~ → reassign dropdown inside modal, backed by `PUT /admin/incidents/{id}/assign` | SASafetyCompliance.tsx | ✅ Fixed 2026-04-22 Phase 3 | 🟠 | 3 |
| 33 | ~~SOS incidents have no timeline, no status history, no location trail~~ → timeline shipped Phase 3; location trail shipped Phase 4b (migration 025 + driverUseCase.captureIncidentTrail + IncidentDetailModal trail list). Dormant until mobile SOS-trigger endpoint exists. | — | ✅ Fixed 2026-04-23 Phase 4b | 🟠 | 3/4b |
| 34 | `KycDocPreview` key collides when same `doc.type` appears twice (use `${type}-${idx}`) | KycDocPreview.tsx:38-40 | Bug | 🟡 | 2 |
| 35 | `LtfrbReportsSection` interface assumes fields backend doesn't return; `violations_open` etc. render NaN | LtfrbReportsSection.tsx:8-18 | Type drift | 🟠 | 1 |

### SASystemConfig.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 36 | Integration card reads only `config.api_key`; Firebase/Twilio/Stripe need different fields | SASystemConfig.tsx:84 | Feature gap | 🟠 | 2 |
| 37 | Template body accepts any vars; no validation against backend-supported set | SASystemConfig.tsx:318-320 | Missing validation | 🟢 | 4 |
| 38 | Feature flag toggles have no "are you sure" except for `maintenance_mode` | SASystemConfig.tsx:241-248 | UX | 🟢 | 4 |

### SASystemHealth.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 39 | ~~`INFRA_METRICS` hardcoded client-side~~ → now reads `GET /admin/system/infra-metrics` (perf middleware + probe goroutine) | SASystemHealth.tsx | ✅ Fixed 2026-04-22 | 🔴 | 1 |
| 40 | ~~Service list from backend is mock~~ → now streams from `system_health_probes` written every 30s | — | ✅ Fixed 2026-04-22 | 🔴 | 1 |

---

## Section 3 — Backend endpoint inventory

Total: **75 implemented Go routes**, **80+ swagger-defined operations**, **~76% real / 24% stub**.

### Group A — Auth · Rides · Passenger Payments · Driver Ops (mostly real)

| Group | Endpoint | Status |
|-------|----------|--------|
| Auth | `POST /auth/{register,login,refresh,logout}` | ✅ Real DB |
| Rides | `GET/POST /rides`, `/rides/{id}/{accept,decline,arrive,start,complete,cancel,rating,receipt,tip}` (13 routes) | ✅ Real DB |
| Passenger | `/users/me/payment-methods` CRUD + `/payments/process` | ✅ Real DB + Stripe |
| Driver | `PUT /driver/status`, `PUT /driver/location`, `GET /driver/rides/incoming`, `GET /drivers/nearby`, `GET /drivers/nearby/all` | ✅ Real DB |
| WebSocket | `GET /ws` | ✅ Real hub + Redis |

### Group B — Admin (mixed)

#### Dashboard & metrics
| Endpoint | Handler | Status |
|----------|---------|--------|
| `GET /admin/dashboard` | `AdminHandler.GetDashboard` | ⚠️ Mixed — counts real, revenue/wait/uptime hardcoded |
| `GET /admin/metrics/{riders,drivers,rides,revenue,wait-time}` | `MetricsHandler.*` | ✅ Real DB |

#### User & role management (all real)
`/admin/users` CRUD + activity + password · `/admin/roles` CRUD + permissions + admins + duplicate

#### Ride / user browsing (all real)
`/admin/rides`, `/admin/users/{passengers,drivers}`

#### Fares & surge (all real)
`GET/PUT /admin/fares`, `GET /admin/fares/surge`, `PUT /admin/surge`, `POST /admin/fares/simulate`

#### Payments (all real — Phase 4a)
`/admin/payments/{transactions,summary,payouts,payouts/{id}/approve,payouts/approve,config,config/{provider},commission-config}`

- `transactions`: real `ride_payments JOIN rides JOIN users (rider+driver) LEFT JOIN commission_settings`. Commission = `amount × rate_percent / 100` clamped to `min_commission`.
- `summary`: one aggregate SELECT — `total_revenue` from completed `ride_payments`, `payouts` from `driver_earnings`, `commission` = revenue − payouts (clamped ≥ 0), `pending_settlements` from `driver_payouts` (status pending|approved).
- `payouts` / `payouts/{id}/approve`: backed by new `driver_payouts` table (migration 024); approve is idempotent `UPDATE ... WHERE status='pending'`.
- `config` (gateway list/update): `payment_gateway_configs.config_fields` JSONB ↔ `map[string]string`; secrets masked on read; UPDATE merges with `||` so unchanged secrets persist.
- `commission-config`: real read/upsert; stub fallback removed (rows must come from migration seeds).

#### Incidents & safety
| Endpoint | Handler | Status |
|----------|---------|--------|
| `GET /admin/incidents` | `AdminHandler.ListIncidents` | ✅ Real DB |
| `PUT /admin/incidents/{id}/resolve` | `AdminHandler.ResolveIncident` | ✅ Real DB |
| `GET /admin/safety/kyc` | `SafetyHandler.ListKyc` | ✅ Joins `kyc_submissions` + `driver_documents` |
| `PUT /admin/safety/kyc/{id}` | `SafetyHandler.UpdateKyc` | ✅ Real UPDATE on `kyc_submissions` |
| `POST /admin/safety/kyc/batch` | `SafetyHandler.BatchKyc` | ✅ Real batch UPDATE |
| `GET /admin/safety/compliance` | `SafetyHandler.GetCompliance` | ✅ Reads `regulatory_compliance` singleton, derives compliance_rate |

#### System config — 100% real (Phase 1 tail, 2026-04-22)
| Endpoint | Status |
|----------|--------|
| `GET /admin/system/services` | ✅ Latest probe per service from `system_health_probes` |
| `GET /admin/system/infra-metrics` | ✅ NEW — p50/p95 HTTP latency + WS count + DB p99 |
| `GET /admin/system/feature-flags` | ✅ `SELECT` on `feature_flags` table |
| `PUT /admin/system/feature-flags/{key}` | ✅ UPSERT with audit log |
| `GET /admin/system/integrations` | ✅ `SELECT` on `integration_configs` with secret masking |
| `PUT /admin/system/integrations/{service}` | ✅ UPSERT with audit log |
| `POST /admin/system/integrations/{service}/test` | ✅ Real provider pings, `SKIP_EXTERNAL_PINGS` guard, writes `last_tested_*` |
| `GET /admin/system/notification-templates` | ✅ `SELECT` on `notification_templates` |
| `PUT /admin/system/notification-templates/{event}` | ✅ Real UPDATE with audit log |

#### Reports & audit — 100% real (Phase 1)
| Endpoint | Status |
|----------|--------|
| `GET /admin/reports/list` | ✅ Report definitions (metadata, not data) |
| `GET /admin/reports/chart/{type}` | ✅ Real queries per type, `from/to` passthrough |
| `POST /admin/reports/export/{type}` | ✅ Real CSV via `encoding/csv` |
| `GET /admin/audit`, `POST /admin/audit`, `GET /admin/audit/export` | ✅ Real DB |

### Group C — Driver documents
| Endpoint | Status |
|----------|--------|
| `POST /drivers/documents` | ✅ Uses `storage.Uploader`; `LocalUploader` writes to `./uploads`, returns `{UPLOAD_PUBLIC_BASE_URL}/{key}` (default `/api/files/...`) |
| `GET /drivers/documents` | ✅ Real DB |
| `GET /drivers/documents/{id}` | ✅ Real DB |
| `GET /api/files/*filepath` | ✅ NEW — authenticated static-file route, path-traversal + RBAC guards |

### Group D — Driver earnings (new 2026-04-22)
| Endpoint | Status |
|----------|--------|
| `GET /driver/earnings?from=&to=&page=&limit=` | ✅ Paginated read from `driver_earnings`, ISO-date range filter |

### Group E — Driver heatmap (new 2026-04-23 Phase 4a)
| Endpoint | Status |
|----------|--------|
| `GET /admin/drivers/heatmap` | ✅ PostGIS `ST_X/ST_Y` over online drivers + vehicle join + ride availability; bounds = actual extents or Metro Manila default. Roles: superadmin/operations/support. |

---

## Section 4 — OpenAPI vs Go drift

### Swagger endpoints with NO Go handler
| Endpoint | operationId | swagger.yaml line | Status |
|----------|-------------|-------------------|--------|
| `GET /service-area` | `getServiceAreas` | 111-126 | ✅ Implemented 2026-04-22 Phase 3 (shape rewritten — see drift note) |
| `GET /driver/earnings` | `driverGetEarnings` | 571-630 | ✅ Implemented 2026-04-22 |

### New swagger additions (2026-04-22)
| Endpoint / Schema | Purpose |
|-------------------|---------|
| `GET /admin/system/infra-metrics` | p50/p95 HTTP latency + DB p99 + WS count from probes + perf middleware |
| `InfraMetrics` schema | Response shape for `/admin/system/infra-metrics` |
| `ComplianceData` extensions | Added `violations_open`, `violations_resolved`, `last_audit_at` |

### Phase 3 swagger additions (2026-04-22)
| Endpoint / Schema | Purpose |
|-------------------|---------|
| `GET /admin/incidents/{id}` | Incident detail + status-history timeline |
| `PUT /admin/incidents/{id}/assign` | Reassign incident operator (body `{assignee_id}`) |
| `GET/POST/PUT/DELETE /admin/service-areas` | Service-area CRUD (admin — includes inactive) |
| `GET/POST/GET/PUT/DELETE /admin/lgu-partnerships` | LGU partnership CRUD |
| `GET/POST/PUT/DELETE /admin/alerts/rules` | Alert rule CRUD |
| `GET /admin/alerts/events` | Recent alert event list |
| `IncidentDetail`, `IncidentStatusEvent` schemas | Timeline payload |
| `ServiceArea` (rewritten) | **Breaking shape change** from `{center, radius}` → `{boundary, active}`. Boundary reuses `SurgeZone` shape. |
| `ServiceAreaInput` | POST/PUT body |
| `SurgeZone` schema | Named polygon + multiplier; consumed by fare calc + reused as service-area boundary |
| `LGUPartnership` + `LGUPartnershipInput` schemas | Partnership CRUD payload |
| `AlertRule` + `AlertRuleInput` + `AlertEvent` schemas | Alert CRUD payload |

### Phase 4a swagger additions (2026-04-23)
| Endpoint / Schema | Purpose |
|-------------------|---------|
| `GET /admin/drivers/heatmap` | DriverHeatmap snapshot — PostGIS-backed online driver positions |
| `DriverHeatmap`, `HeatmapPosition`, `HeatmapBounds` schemas | Heatmap response shape |
| `FareConfig` (rewritten) | Now exposes `id, updated_at, updated_by, updated_by_name` joined from `users` |
| `PaymentGatewayConfig` (rewritten) | **Breaking shape change** from drifted `{name, center, radius}` → real `{id, provider, config_fields, is_active, updated_at, updated_by}` |
| `KycEntry.status` enum | Extended to include `needs_more_info` |

### Swagger drift ⚠️
- `ServiceArea` shape changed from `{id, name, center, radius, is_active}` to `{id, name, lgu_code, boundary: SurgeZone, active}` in Phase 3. Any mobile client code reading the old shape must be updated alongside this release.
- `SurgeConfig.zones` rewritten from `GeoJSONFeatureCollection` (never written this way by backend) to `SurgeZone[]` — matches what `surge_configs.zones` actually stores and what the fare calculator consumes. Brings swagger in sync with runtime. Regen ran; no hand-edited openapi.d.ts casts remain.

### Go endpoints with NO swagger doc
None identified (all real handlers have corresponding swagger entries).

### Shape mismatches (non-blocking)
- `RideResponse` enrichment may fall back to minimal stub on user fetch failure (`ride_dto.go:45-50`).
- Metrics endpoints return generic `map[string]interface{}` internally; DTO converts to `{value, timestamp}` — fine.

---

## Section 5 — Database migration gaps

### Existing tables (migrations 001-027)
users · vehicles · drivers · rides · refresh_tokens · fare_configs · surge_configs · audit_log_entries · incidents · payment_gateway_configs · commission_settings · roles · role_permissions · driver_documents · ratings · ride_payments · ride_tips · driver_earnings · feature_flags · notification_templates · integration_configs · kyc_submissions · regulatory_compliance · system_health_probes · http_request_timings · incident_status_history (021) · service_areas (022) · lgu_partnerships (022) · alert_rules (023) · alert_events (023) · driver_payouts (024) · driver_payout_lines (024) · **driver_location_history** (025) · **notification_outbox** (026) · **payment_method ENUM extended** (027 — +gcash, +paymaya)

### Missing tables — Phase 3 closed
| Entity | Needed for | Status |
|--------|-----------|--------|
| `feature_flags` | `SystemRepo.UpdateFeatureFlag` no-op | ✅ Phase 1 |
| `notification_templates` | `SystemRepo.UpdateNotificationTemplate` no-op | ✅ Phase 1 |
| `integration_configs` | `SystemRepo.UpdateIntegration` no-op | ✅ Phase 1 |
| `kyc_submissions` | KYC pipeline entirely stubbed | ✅ Phase 1 |
| `regulatory_compliance` | LTFRB compliance hardcoded | ✅ Phase 1 |
| `system_health_probes` | Infra metrics hardcoded | ✅ Phase 1 |
| `incident_status_history` | SOS timeline | ✅ Phase 3 (021) |
| `alert_rules`, `alert_events` | Alert configuration | ✅ Phase 3 (023) |
| `service_areas`, `lgu_partnerships` | LGU regulatory tracking + `/service-area` endpoint | ✅ Phase 3 (022) |
| `driver_payouts`, `driver_payout_lines` | Real backing for `/admin/payments/payouts` (replaces in-memory store) | ✅ Phase 4a (024) |
| `driver_location_history` | SOS location trail | ✅ Phase 4b (025) |
| `notification_outbox` | Alert notification dispatch pipe | ✅ Phase 4b (026) |
| `payment_method` ENUM ext | gcash/paymaya values so e-wallet rows land in ride_payments | ✅ Phase 4b (027) |

### Existing tables with unused columns
- ~~`surge_configs.zones` (JSONB) — stored but never queried during fare calculation~~ → ✅ Phase 3: read via `usecase.ParseSurgeZones` + ray-casting in `FareCalculator.SimulateFare`. Shape = `[{name, multiplier, polygon:[[lat,lng]...]}, ...]`.
- ~~`incidents.assigned_to` — column exists; reassign UI missing~~ → ✅ Phase 3: reassign dropdown in `IncidentDetailModal` + `PUT /admin/incidents/{id}/assign`.

---

## Section 6 — Cross-cutting frontend issues

1. **`as unknown as X` casts** (SAAdminManagement.tsx:58-59) indicate schema drift — rerun `npm run generate:types` after every swagger update and drop casts.
2. **Mixed chart-type strings** — `payment-method` vs `payment-methods`. Canonicalize to plural.
3. **Date-range pickers rendered but not wired** — SAReports, Reports, Payments all have UI but never pass values to query hooks.
4. **Missing "detail modal" pattern** — Incident, Ride, Transaction, Rider, Driver all need modals that don't exist yet.
5. **Map-based features placeholder** — DriverHeatmap ships SVG stub; SurgeZoneEditor absent. Needs a provider-agnostic adapter so swap to Mapbox / Google / Leaflet is a one-file change.

---

## Fix plan reference

Full phased plan lives at `~/.claude/plans/task-notification-task-id-ry2iub3hu-tas-buzzing-toast.md`. Summary:

- **Phase 0** — this document (✅ done).
- **Phase 1** (P0) — ✅ done 2026-04-22 (including tail: earnings endpoint, probes goroutine, perf middleware + `infra-metrics`, real `TestIntegration` with `SKIP_EXTERNAL_PINGS`, authenticated `/api/files/*` route, swagger + openapi regen, `SASystemHealth`/`LtfrbReportsSection` retype).
- **Phase 2** (P1) — ✅ done 2026-04-22. Modals (Rider/Driver/Docs/Ride/Transaction), date-range + pagination + payout confirm on Payments, per-provider integration form, small UI nits, DriverHeatmap mount. Deferred: `GatewayProvidersSection` mount (swagger `PaymentGatewayConfig` schema drifted to `{name, center, radius}`), fare `updated_by` username join, `SAAdminManagement` cast cleanup, `SASafetyCompliance` incident "View" (rolls into Phase 3).
- **Phase 3** (P2) — ✅ done 2026-04-22. SOS timeline + reassign (021), surge zones via Go ray-casting + `SurgeZoneEditor` + `MapProvider` adapter, alert rules CRUD + evaluator goroutine (023), LGU partnerships + service areas CRUD + `/service-area` (022). Deferred: SOS location trail, alert notification dispatch.
- **Phase 4a** — ✅ done 2026-04-23. TEST_ACCOUNTS.md port (5173 → 3000), `KycEntry.status` enum + `needs_more_info`, `SAAdminManagement` cast cleanup, fare `updated_by_name` (FareConfig schema rewrite + repo JOIN + UI render), `PaymentGatewayConfig` swagger rewrite (drifted shape → real `{provider, config_fields, …}`) + schema-driven `GatewayProvidersSection` mount, `payment_repo` real queries (`ListTransactions`, `GetPaymentSummary`, `ListPayouts`/`ApprovePayout` against new `driver_payouts` table), migration 024, DriverHeatmap real backend (`GET /admin/drivers/heatmap` PostGIS), alert evaluator dedup via per-rule `cooldown_minutes`. Verification: `go build`, `go test ./...`, `npm run lint`, `npm test` (136/136). Not browser-smoke-tested.
- **Phase 4b** — ✅ done 2026-04-23. Migration 025 (`driver_location_history` + partial index on `incidents(driver_id) WHERE resolved_at IS NULL`), SOS trail capture in `driverUseCase.UpdateLocation`, trail exposed through `IncidentDetail` + rendered in `IncidentDetailModal`. Migration 026 (`notification_outbox` + seeded `alert.*` templates), `internal/infrastructure/notifications` package (`AlertNotifier` + `Dispatcher` goroutine), evaluator wired via `WithNotifier` + RowsAffected guard. Migration 027 (`ALTER TYPE payment_method ADD VALUE gcash/paymaya`), domain constants + `IsValid()` updated, swagger enums widened. `SurgeConfig` `LEFT JOIN users` + `UpdatedByName` + swagger + UI parity with FareConfig. Mocks regenerated via `go generate`. Verification: `go build`, `go test ./...`, `npm run generate:types`, `npm run lint`, `npm test` (136/136). Not browser-smoke-tested. Log-only dispatcher + dormant SOS trail flagged as caveats.
- **Phase 4c** — pending: real SMS/email/push provider swap in `notifications.Dispatcher.send()`, SOS-trigger write-path on mobile (until then trail capture stays dormant), `migrate down` cycle exercise for 025/026/027, browser smoke test of Phase 4a/4b UI, plus audit 🟢 polish bucket: #19 SAAdminManagement role-rename unit test, #21 SAFareConfig hardcoded Manila sim coords, #25 SAPayments CSV export server-side, #29 SAReports `selectedReport` surface, #30 SARoleManagement `fromPermissions` validation, #37 Template body var validation, #38 Feature flag confirm-modals beyond `maintenance_mode`.
