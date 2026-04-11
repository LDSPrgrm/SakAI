# Research: Update Project Documentation

**Date**: 2026-04-11
**Feature**: `specs/001-update-project-docs`

## Research Task 1: Current Backend File Inventory

### Finding

The backend has grown significantly beyond what the current docs describe:

| Layer | Files Found | What docs say | Gap |
|---|---|---|---|
| **Domain** (`internal/domain/`) | 10 files: `admin.go`, `audit.go`, `driver.go`, `errors.go`, `incident.go`, `location.go`, `ports.go`, `ride.go`, `user.go`, `vehicle.go` | Docs mention user, ride, driver, vehicle only | Missing: admin, audit, incident domain entities |
| **Use-Cases** (`internal/usecase/`) | 13 files: admin, auth (+ test), driver (+ test), metrics, payment, report, ride (+ test), role, safety, system | Docs mention auth + ride only | Missing: admin, metrics, payment, report, role, safety, system usecases |
| **Repositories** (`internal/repository/postgres/`) | 10 files: admin, driver, metrics, payment, report, ride, role, safety, system, user_token | Docs mention ride + driver + user_token only | Missing: admin, metrics, payment, report, role, safety, system repos |
| **Handlers** (`internal/delivery/http/`) | 10 handlers: admin, auth, driver, metrics, payment, report, ride, role, safety, system + dto/, middleware/, response.go | Docs mention auth, ride, driver, system only | Missing: admin, metrics, payment, report, role, safety handlers |
| **DTOs** | 4 files: admin, auth, driver, ride | Same as handlers | ✅ Matches |
| **Middleware** | 3 files: auth, rate_limit, security | Docs mention rate limiting but not security middleware | Missing: security headers middleware |
| **WebSocket** (`internal/delivery/ws/`) | 3 files: handler.go, hub.go, redis_dispatcher.go | Docs mention hub only | Missing: redis_dispatcher |
| **Infrastructure** | `database/` (migrate.go, postgres.go, tx.go), `expiry/` (worker.go) | Docs mention expiry worker | ✅ Mostly accurate |
| **pkg/** | `jwt/jwt.go`, `testutil/fixtures.go` (middleware was moved to delivery) | Docs may reference old location | Needs update |
| **cmd/** | `api/` (main entry), `seed-admin/` (admin seeding CLI) | README mentions seed-admin | ✅ Accurate |

### Decision
Update all documentation to reflect the full 10-handler, 13-usecase, 10-repository backend structure. Explicitly list the new admin, metrics, payment, report, role, and safety modules.

---

## Research Task 2: OpenAPI Endpoint Inventory

### Finding

The OpenAPI spec defines **66 endpoints** across these tags:

| Tag | Endpoint Count | Examples |
|---|---|---|
| **System** | 1 | `GET /health` |
| **Auth** | 4 | register, login, refresh, logout |
| **Users** | 1 | `GET /users/me` |
| **Driver** | 3 | status, location, incoming rides |
| **Rides** | 8 | active, request, get, accept, decline, arrive, start, complete, cancel |
| **Admin** | **~49** | dashboard, users CRUD, fares, surge, incidents, rides list, passengers, drivers, audit, payments (transactions, payouts, config, commission), system (services, feature flags, integrations, notifications), safety (KYC, compliance), reports (list, chart, export), metrics (riders, drivers, rides, revenue, wait-time), roles, auth (password change) |

### Decision
The README API section must reflect that the Admin tag is the largest group (~49 endpoints), covering: user management, fare/surge management, incident resolution, payment processing, audit logging, role-based access control, safety/KYC, reporting, metrics, and system configuration. Docs should clarify that many admin endpoints are **spec-defined** but may not have full backend implementations yet.

---

## Research Task 3: Database Migration State

### Finding

10 migration files exist (001–010), significantly more than the 3–4 the old docs imply:

| Migration | Purpose |
|---|---|
| 001 | Create users table |
| 002 | Create vehicles table |
| 003 | Create drivers table |
| 004 | Create rides table |
| 005 | Create refresh_tokens table |
| 006 | Add active ride constraints (partial unique index) |
| 007 | Add admin roles schema |
| 008 | Super admin schema |
| 009 | Create roles table (+ down) |
| 010 | Add role_id to users table (+ down) |

### Decision
Update docs to reflect that the schema now includes RBAC (roles, role-based users, admin/superadmin hierarchy) beyond the basic ride-hailing tables.

---

## Research Task 4: Roadmap Phase 2 Reconciliation

### Finding

From the system audit report (12 resolved issues, 16 open issues) and the roadmap:

**Roadmap Phase 2 "Completed" items** (12 checked):
- Race condition fix, Decline clears driver_id, driver location routing, vehicle in responses, expiry worker, LatLng validation, rate limiting, FindNearbyOnline LIMIT 1, transactional registration, JWT weak-secret guard, logging for async failures

**Roadmap Phase 2 "To Do — Critical" (5 items)**:
- C1 (expiry WS notify), C2 (exclude busy drivers), L3 (ride participant auth), H4 (body size limit), SC1 (GIST index)

**Roadmap Phase 2 "To Do — High" (8 items)**:
- H1 (dead code), H2 (WS deadlines), H3 (embed migrations), H5 (tx token rotation), L1 (re-dispatch), L2 (cancel role), S1 (WS origins), S3 (security headers), D2 (FK cascade)

**System audit "Resolved" items** (12): Match the roadmap's completed list.

### Decision
The roadmap is approximately accurate for Phase 2 structure but needs: the "Completed" section verified against actual code (all 12 are confirmed in audit), remaining items kept as-is since they are still open per the audit. No structural changes needed — just verification that the audit report and roadmap are consistent (they are).

---

## Research Task 5: Mobile App State

### Finding

Per the overview.md and roadmap:
- Phase 3 (Flutter Mobile Apps) is "Not Started"
- The mobile directory structure exists: `mobile/passenger/`, `mobile/driver/`, `mobile/shared/`
- Shared package has the generated API client infrastructure
- No actual app screens are implemented yet

### Decision
Docs should describe the mobile **architecture and conventions** (feature-first MVVM, generated client, shared package) but clearly mark Phase 3 as "Not Started" — no claim of working mobile apps.

---

## Research Task 6: Admin Dashboard Framework

### Finding

- The roadmap says "Choose framework (React or Vue.js)" — no decision made yet
- The `admin/` directory exists but is marked "[In Progress]" in the README
- The backend has full admin API support (49 endpoints in spec, admin_handler.go exists)

### Decision
Docs must describe the admin dashboard as "planned — framework TBD" while documenting the **backend admin APIs** as fully spec-defined.

---

## Research Task 7: Cross-Reference Audit

### Finding

Current cross-references between documents:
- README → overview.md ✅ exists
- README → AGENTS.md ✅ exists
- README → docs/agent_playbook.md ✅ exists
- README → openapi/swagger.yaml ✅ exists
- overview.md → docs/roadmap.md ✅ exists
- overview.md → docs/system_audit.md ✅ exists
- overview.md → docs/requirements.md ✅ exists
- overview.md → CONTRIBUTING.md ✅ exists
- agent_playbook.md → codebase_architecture.md ✅ exists
- agent_playbook.md → AGENTS.md ✅ exists
- agent_playbook.md → agent_context.json ✅ exists

All current cross-references resolve. No broken links found in existing docs.

### Decision
No broken links to fix. New references added during this update must follow the same pattern of using relative paths that resolve correctly.

---

## Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| Create a new `docs/` file for endpoint inventory | Unnecessary — the swagger.yaml is the source of truth; README should summarize, not duplicate |
| Mark every admin endpoint as "implemented" or "not implemented" | Too granular for documentation — better to describe what the spec defines and note implementation status at a high level |
| Rewrite all docs from scratch | Too disruptive — better to update existing docs in-place to preserve structure and minimize review friction |
