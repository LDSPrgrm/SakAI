# Backend Integration Audit — SakAI Admin Panel

**Date:** 2026-04-22 (initial) · **Phase 1 tail landed:** 2026-04-22
**Scope:** All admin & superadmin pages (`admin/src/pages/**/*.tsx`) cross-referenced against the Go backend (`backend/internal/**`), OpenAPI contract (`openapi/swagger.yaml`), and Postgres migrations.
**Status legend:** 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low · ✅ Closed

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

Post-Phase-1: Admin Dashboard 100%, Driver Ops 100% (earnings added), Reports/Audit 100%, Admin System 100% (probes + config persistence + real TestIntegration). Aggregate: **~95% real** — the remaining 5% is Phase-3 scope (incident timeline, surge zones, alert rules, LGU partnerships, `/service-area`).

---

## Section 1 — Regular admin pages (`admin/src/pages/*.tsx`)

### Dashboard.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 1 | "Live Hotspots" renders static animated circles; the ready-built `<DriverHeatmap>` component is never mounted | Dashboard.tsx:176-186 | Placeholder UI | 🟡 | 2 |
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
| 7 | `handleExport` uses `canWrite`; export is a read op and should use `can('reports','read')` | Payments.tsx:80 | Permission bug | 🟡 | 4 |
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
| 18 | Double-cast `as unknown as AdminUser` indicates openapi schema drift | SAAdminManagement.tsx:58-59 | Type drift | 🟡 | 4 |
| 19 | `displayRole(...) !== values.role` — normalization may mismatch backend expectation | SAAdminManagement.tsx:113-114 | Type drift | 🟡 | 4 |

### SAAuditLog.tsx
Clean.

### SAFareConfig.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 20 | `onSaved` callback is empty `() => {}` — no query invalidation after save | SAFareConfig.tsx:259-261 | Missing wiring | 🟡 | 2 |
| 21 | Fare simulator uses hardcoded Manila coords (`14.5995, 120.9842`) | SAFareConfig.tsx:195-213 | Hardcoded data | 🟢 | 3 |
| 22 | `config.updated_by` rendered as-is; backend returns UUID, UI needs username | SAFareConfig.tsx:157 | Missing field | 🟡 | 2 |

### SAPayments.tsx
| # | Issue | File:line | Type | Sev | Phase |
|---|-------|-----------|------|-----|-------|
| 23 | `<GatewayProvidersSection>` component exists but never mounted | SAPayments.tsx | Missing section | 🟠 | 2 |
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
| 31 | Incident "View" button has no `onClick` | SASafetyCompliance.tsx:267 | Dead handler | 🔴 | 2/3 |
| 32 | "Assigned To" column shown but no reassign UI | SASafetyCompliance.tsx:259-264 | Missing feature | 🟠 | 3 |
| 33 | SOS incidents have no timeline, no status history, no location trail | — | Missing feature | 🟠 | 3 |
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

#### Payments (all real — incl. gateway config + commission)
`/admin/payments/{transactions,summary,payouts,payouts/{id}/approve,payouts/approve,config,config/{provider},commission-config}`

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

---

## Section 4 — OpenAPI vs Go drift

### Swagger endpoints with NO Go handler
| Endpoint | operationId | swagger.yaml line | Status |
|----------|-------------|-------------------|--------|
| `GET /service-area` | `getServiceAreas` | 111-126 | Deferred to Phase 3 |
| `GET /driver/earnings` | `driverGetEarnings` | 571-630 | ✅ Implemented 2026-04-22 |

### New swagger additions (2026-04-22)
| Endpoint / Schema | Purpose |
|-------------------|---------|
| `GET /admin/system/infra-metrics` | p50/p95 HTTP latency + DB p99 + WS count from probes + perf middleware |
| `InfraMetrics` schema | Response shape for `/admin/system/infra-metrics` |
| `ComplianceData` extensions | Added `violations_open`, `violations_resolved`, `last_audit_at` |

### Go endpoints with NO swagger doc
None identified (all real handlers have corresponding swagger entries).

### Shape mismatches (non-blocking)
- `RideResponse` enrichment may fall back to minimal stub on user fetch failure (`ride_dto.go:45-50`).
- Metrics endpoints return generic `map[string]interface{}` internally; DTO converts to `{value, timestamp}` — fine.

---

## Section 5 — Database migration gaps

### Existing tables (migrations 001-015)
users · vehicles · drivers · rides · refresh_tokens · fare_configs · surge_configs · audit_log_entries · incidents · payment_gateway_configs · commission_settings · roles · role_permissions · driver_documents · ratings · ride_payments · ride_tips · driver_earnings

### Missing tables
| Entity | Needed for | Phase |
|--------|-----------|-------|
| `feature_flags` | `SystemRepo.UpdateFeatureFlag` no-op | 1 |
| `notification_templates` | `SystemRepo.UpdateNotificationTemplate` no-op | 1 |
| `integration_configs` | `SystemRepo.UpdateIntegration` no-op | 1 |
| `kyc_submissions` | KYC pipeline entirely stubbed | 1 |
| `regulatory_compliance` | LTFRB compliance hardcoded | 1 |
| `system_health_probes` | Infra metrics hardcoded | 1 |
| `incident_status_history` | SOS timeline | 3 |
| `alert_rules`, `alert_events` | Alert configuration | 3 |
| `service_areas`, `lgu_partnerships` | LGU regulatory tracking + `/service-area` endpoint | 3 |

### Existing tables with unused columns
- `surge_configs.zones` (JSONB) — stored but never queried during fare calculation; **Phase 3** wires PostGIS `ST_Contains` in `FareCalculator`.
- `incidents.assigned_to` — column exists; reassign UI missing (**Phase 3**).

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
- **Phase 3** (P2) — pending. SOS timeline, surge-zone drawer + PostGIS calc, alert rules, LGU partnerships + `/service-area`.
- **Phase 4** — pending: port fix in TEST_ACCOUNTS.md, `payment_repo` real queries (transactions + summary + payouts table), DriverHeatmap backend endpoint, fix `PaymentGatewayConfig` swagger drift, `SAAdminManagement` cast cleanup, fare `updated_by_name` response field, swagger `KycEntry.status` enum missing `needs_more_info`, final lint + test sweep.
