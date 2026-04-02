# SakAI — Agent playbook

**Audience:** Human developers, IDE agents, and CI assistants.  
**Purpose:** Cut ambiguity; every section is intentionally scannable and path-explicit.

---

## 1. What this repo is

| Axis | Detail |
|------|--------|
| Product | Ride-hailing: passenger + driver Flutter apps, Go+Gin backend, Postgres+PostGIS, Redis, WebSockets |
| Contract | **Design-first REST:** `openapi/swagger.yaml` is the source of truth for HTTP JSON APIs |
| Architecture | Backend: Clean Architecture (domain / usecase / repository / delivery). Mobile: feature-first MVVM (`features/<feature>/{models,repositories,view_models,views}`) + shared package |

Deeper narrative: [`overview.md`](../overview.md), [`codebase_architecture.md`](codebase_architecture.md).

---

## 2. Machine context (copy for prompts)

Use with agents as a preface:

```text
Repo: SakAI monorepo.
REST contract file: openapi/swagger.yaml (OpenAPI 3.0.3).
Dart OpenAPI client package: sakai_api_client at mobile/shared/lib/api_client/
(regenerated via ./scripts/generate-client.sh).
Flutter aggregate package: sakai_shared at mobile/shared (exports theme + SakaiApiSupport + re-exports client).
Backend: Go under backend/ with strict layer rules (delivery -> usecase -> domain <- repository).
Errors: clients must branch on ErrorResponse.code / ErrorCode enum, not human message strings.
```

Structured duplicate: [`agent_context.json`](agent_context.json).

---

## 3. Repository map (high signal)

| Path | Responsibility |
|------|----------------|
| `openapi/swagger.yaml` | All REST paths, schemas, `operationId`s, `BearerAuth`, documented WS envelope |
| `scripts/generate-client.sh` | Regenerate `sakai_api_client` + run `build_runner` |
| `scripts/patch-generated-api-client.sh` | Post-process generator output (Dart 3 SDK + enum mixin fix) |
| `mobile/shared/lib/sakai_shared.dart` | Public exports for both apps (theme, widgets, API helpers, client) |
| `mobile/shared/lib/api/sakai_api_support.dart` | `SakaiApiEndpoints`, `SakaiApiSupport.createClient`, bearer name constant |
| `mobile/passenger/`, `mobile/driver/` | Apps; depend on `sakai_shared`; keep feature contracts + implementations in `features/*/repositories/` |
| `backend/internal/domain/` | Entities + ports only; no framework imports |
| `backend/internal/usecase/` | Business rules; depends only on domain interfaces |
| `backend/internal/repository/` | Postgres/Redis adapters implementing domain ports |
| `backend/internal/delivery/http/` | Gin handlers, `dto/`, routing |
| `backend/internal/delivery/ws/` | WebSocket hub and realtime delivery |
| `migrations/` | SQL migrations (PostGIS) |

---

## 4. Workflows

### 4.1 Add or change a REST endpoint

1. Edit **`openapi/swagger.yaml`** (path, method, body, responses, `components/schemas`, `ErrorCode` if needed).
2. Implement **backend** end-to-end: DTO validation → usecase → repository; keep domain types inside domain.
3. Run **`./scripts/generate-client.sh`** from repo root.
4. Run **`cd mobile/shared && flutter pub get`** (and apps if they do not auto-resolve).
5. Implement **Flutter** in the appropriate app: repositories/data sources using `SakaiApiClient`; map `ErrorCode` for user-facing copy in presentation.
6. Verify **`go test -race ./...`** (backend) and **`flutter analyze`** (touched mobile packages).

### 4.2 Use the generated Dart client

- Import: `package:sakai_shared/sakai_shared.dart` (re-exports `SakaiApiClient` and models).
- Construct: `SakaiApiSupport.createClient(baseUrl: ..., accessToken: optional)`.
- JWT: after login/refresh, `client.setBearerAuth(SakaiApiSupport.bearerAuthName, accessToken)` (same scheme as OpenAPI `BearerAuth`).
- Base URL default: `SakaiApiEndpoints.defaultRestBaseUrl` (see `sakai_api_support.dart`). Override for staging/production via flavor or config, not hard-coded copies in many files.

### 4.3 WebSockets

- OpenAPI describes **envelope** shape and event names in prose/schemas; there is **no** generated WS client.
- Build a small feature repository module (`features/<feature>/repositories/`): connect to `SakaiApiEndpoints.webSocketUri(restBaseUrl, accessToken)`, parse `{ "event": "...", "payload": { ... } }`, switch on `event` with typed payloads where models exist in `sakai_api_client` (e.g. WS event schema models).

### 4.4 Database changes

- Add **`migrations/`** SQL; keep compatible with existing PostGIS usage.
- Wire migration execution per backend startup docs in **`CONTRIBUTING.md`**.

---

## 5. Conventions agents must respect

| Rule | Rationale |
|------|-----------|
| OpenAPI before Go/Dart for contract changes | Avoids drift between server and clients |
| No domain imports from `delivery` | Preserves Clean Architecture testability |
| Flutter: no raw `Dio` in widgets | Keeps views thin; use feature repositories/services |
| Handle **`ErrorCode`** from spec | Server message strings are not stable API |
| **`Idempotency-Key`** on ride creation | Required by contract for safe retries |
| Regen client after **`openapi/swagger.yaml`** changes | `sakai_api_client` must stay in sync |
| **Mobile: 1 View : 1 ViewModel** | Every screen is paired with a `*_view_model.dart` (`ChangeNotifier`) |
| **Mobile: no business logic in widgets** | Views call VM methods only — never call repositories directly from widgets |
| **Mobile: no network in widgets** | All HTTP lives in `features/*/repositories/` (including service classes like `GeocodingService`) |
| **Mobile: navigation stays in View** | `_onVmChanged()` listener fires routing; VMs must not hold `BuildContext` |
| **Mobile: inject, don't create** | Repositories/services are constructor-injected into ViewModels |

---

## 6. Verification checklist (before claiming “done”)

- [ ] `openapi/swagger.yaml` updated if HTTP API changed  
- [ ] `./scripts/generate-client.sh` run if spec changed  
- [ ] `go test -race ./...` (backend)  
- [ ] `flutter analyze` on affected `mobile/*` packages  
- [ ] Handlers enforce authz where spec marks `BearerAuth`  
- [ ] No secrets committed; use `backend/.env` from `.env.example`  

---

## 7. Audit and phase gates

Outstanding critical items and file hints: **`overview.md`** (Phase 2 table) and **`docs/system_audit.md`**. Agents should not silently “fix” audit items without following the same layers and tests as above.

---

## 8. Related documents

| File | Use when |
|------|----------|
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Local setup, mockgen, Flutter tests |
| [`../openapi/swagger.yaml`](../openapi/swagger.yaml) | Exact request/response shapes |
| [`agent_context.json`](agent_context.json) | Import into tools / RAG / scripted agents |
| [`../AGENTS.md`](../AGENTS.md) | Short index for agent tools |

---

## 9. Changelog for this playbook

| Date | Change |
|------|--------|
| 2026-04-02 | Initial playbook + `agent_context.json` + root `AGENTS.md` |
