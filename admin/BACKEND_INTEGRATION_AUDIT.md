# Backend Integration Audit — SakAI Admin Panel

**Date:** 2026-04-22
**Scope:** All admin & superadmin pages (`admin/src/pages/**/*.tsx`) cross-referenced against the Go backend (`backend/internal/**`), OpenAPI contract (`openapi/swagger.yaml`), and Postgres migrations.
**Status legend:** 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low

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

Backend implementation coverage (by endpoint group): Auth 100%, Rides 100%, Admin Users/Roles 100%, Fares 100%, Payments 100%, Passenger Payments 100%, Admin Dashboard 83%, Driver Ops 60%, Incidents/Safety 50%, Reports/Audit 33%, Admin System 0%. Aggregate: **76% real, 24% stub/missing**.

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
| 39 | `INFRA_METRICS` hardcoded client-side: P50 112ms, P95 340ms, WS 1842, DB P99 45ms | SASystemHealth.tsx:39-44 | Fake data | 🔴 | 1 |
| 40 | Service list from backend is mock (see backend §3.J) | — | Upstream stub | 🔴 | 1 |

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
| `GET /admin/safety/kyc` | `SafetyHandler.ListKyc` | 🔴 **STUB** — mock rows, `uuid.New()` per request (safety_repo.go:20-35) |
| `PUT /admin/safety/kyc/{id}` | `SafetyHandler.UpdateKyc` | 🔴 **NO-OP** (safety_repo.go:38-40) |
| `POST /admin/safety/kyc/batch` | `SafetyHandler.BatchKyc` | 🔴 **NO-OP** — returns count, no DB write (safety_repo.go:52-74) |
| `GET /admin/safety/compliance` | `SafetyHandler.GetCompliance` | 🔴 **STUB** — hardcoded 94.5% / +1yr (safety_repo.go:42-49) |

#### System config — 0% real
| Endpoint | Status |
|----------|--------|
| `GET /admin/system/services` | 🔴 Mock list with fake latencies (system_repo.go:19-29) |
| `GET /admin/system/feature-flags` | 🔴 Hardcoded 9 flags (system_repo.go:32-43) |
| `PUT /admin/system/feature-flags/{key}` | 🔴 **NO-OP** (system_repo.go:46-49) |
| `GET /admin/system/integrations` | 🔴 Hardcoded 4 integrations (system_repo.go:51-58) |
| `PUT /admin/system/integrations/{service}` | 🔴 **NO-OP** (system_repo.go:61-62) |
| `POST /admin/system/integrations/{service}/test` | 🔴 **STUB** — always returns success (system_repo.go:77-89) |
| `GET /admin/system/notification-templates` | 🔴 Hardcoded 5 templates (system_repo.go:65-72) |
| `PUT /admin/system/notification-templates/{event}` | 🔴 **NO-OP** (system_repo.go:75-76) |

#### Reports & audit
| Endpoint | Status |
|----------|--------|
| `GET /admin/reports/list` | 🔴 Hardcoded 7 reports (report_repo.go:20-34) |
| `GET /admin/reports/chart/{type}` | 🔴 Hardcoded per type (report_repo.go:35-63) |
| `POST /admin/reports/export/{type}` | 🔴 Hardcoded CSV (report_repo.go:67-86) |
| `GET /admin/audit`, `POST /admin/audit`, `GET /admin/audit/export` | ✅ Real DB |

### Group C — Driver documents
| Endpoint | Status |
|----------|--------|
| `POST /drivers/documents` | ⚠️ Writes to local `./uploads`; URL builder stubs `storage.example.com` (document_handler.go:20-31, 74-77) |
| `GET /drivers/documents` | ✅ Real DB |
| `GET /drivers/documents/{id}` | ✅ Real DB |

---

## Section 4 — OpenAPI vs Go drift

### Swagger endpoints with NO Go handler
| Endpoint | operationId | swagger.yaml line |
|----------|-------------|-------------------|
| `GET /service-area` | `getServiceAreas` | 111-126 |
| `GET /driver/earnings` | `driverGetEarnings` | 571-630 |

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
- **Phase 1** (P0) — real dashboard/report/system/KYC/LTFRB queries, driver earnings endpoint, doc uploader interface, system health probes, real `TestIntegration`.
- **Phase 2** (P1) — modals, date-range wiring, per-provider integration form, gateway section mount, DriverHeatmap mount, small UI nits.
- **Phase 3** (P2) — SOS timeline, surge-zone drawer + PostGIS calc, alert rules, LGU partnerships + `/service-area`.
- **Phase 4** — port fix in TEST_ACCOUNTS.md, cast cleanup, final lint + test sweep.
