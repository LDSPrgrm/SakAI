---

description: "Task list for updating SakAI project documentation"
---

# Tasks: Update Project Documentation

**Input**: Design documents from `/specs/001-update-project-docs/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: No automated tests — this is a documentation-only feature. Verification is manual via link resolution and file count checks.

**Organization**: Tasks are grouped by user story to enable independent implementation and verification of each documentation target.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Documentation files at repository root: `README.md`, `docs/*.md`
- Reference data: `openapi/swagger.yaml`, `backend/internal/**`, `migrations/*.sql`

---

## Phase 1: Setup (Research & Inventory)

**Purpose**: Gather current codebase state to serve as the source of truth for all documentation updates.

- [x] T001 [P] Document current backend handler inventory (10 handlers) from `backend/internal/delivery/http/` — record in working notes
- [x] T002 [P] Document current usecase inventory (13 files) from `backend/internal/usecase/` — record in working notes
- [x] T003 [P] Document current repository inventory (10 files) from `backend/internal/repository/postgres/` — record in working notes
- [x] T004 [P] Document current domain entity inventory (10 files) from `backend/internal/domain/` — record in working notes
- [x] T005 [P] Document current endpoint inventory by tag from `openapi/swagger.yaml` — count operationIds per tag
- [x] T006 [P] Document current migration file list from `migrations/*.sql` — record count and purposes
- [x] T007 [P] Document current middleware, WebSocket, infrastructure, and pkg/ file inventories — record in working notes

**Checkpoint**: Complete inventory gathered — all documentation updates can reference accurate file counts.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the documentation contracts and cross-reference baseline that all user story phases depend on.

**⚠️ CRITICAL**: No user story documentation work can begin until this phase is complete.

- [x] T008 Audit all existing cross-references in README.md — verify every link resolves to an existing file
- [x] T009 Audit all existing cross-references in overview.md — verify every link resolves
- [x] T010 Audit all existing cross-references in docs/agent_playbook.md — verify every link resolves
- [x] T011 Count endpoints per tag in `openapi/swagger.yaml` and record canonical counts (System: 1, Auth: 4, Users: 1, Driver: 3, Rides: 8, Admin: ~49)

**Checkpoint**: Foundation audit complete — accurate source data available for all documentation updates.

---

## Phase 3: User Story 1 — Developer Onboards via README (Priority: P1) 🎯 MVP

**Goal**: A new developer can read README.md and get from a fresh clone to a running backend with Swagger UI, understand the full project structure, and know where to find further documentation — with zero outdated information.

**Independent Test**: A developer with no prior SakAI knowledge follows the README end-to-end and successfully starts all services, accesses Swagger UI, and navigates to every linked document without encountering broken links or stale descriptions.

### Implementation for User Story 1

- [x] T012 [P] [US1] Update Tech Stack section in `README.md` — verify all 7 technologies (Go+Gin, Flutter, PostgreSQL+PostGIS, Redis, WebSockets, OpenAPI, Docker Compose) are listed with current version notes and links
- [x] T013 [US1] Update Repository Structure section in `README.md` — rewrite directory tree to include all current top-level directories (`backend/`, `mobile/`, `migrations/`, `openapi/`, `scripts/`, `docs/`, `admin/`) with accurate one-line purpose statements matching the actual file system
- [x] T014 [P] [US1] Update Key Features section in `README.md` — add RBAC (roles: passenger, driver, admin, superadmin), admin API support, security middleware, and Redis pub/sub dispatcher to the feature list
- [x] T015 [US1] Update Getting Started section in `README.md` — verify all 4 subsections (Prerequisites, Local Infrastructure, Backend Setup, Mobile Apps) have current, working instructions; verify admin seeding instructions (`go run ./cmd/seed-admin`) are included
- [x] T016 [US1] Update API Documentation section in `README.md` — add all 6 endpoint groups (System: 1, Auth: 4, Users: 1, Driver: 3, Rides: 8, Admin: ~49) with brief descriptions; include Swagger UI and raw spec links
- [x] T017 [US1] Update Architecture Summary section in `README.md` — ensure the 4-step use-case flow (Request → Logic → Data → Events) accurately describes current components including Redis Dispatcher
- [x] T018 [US1] Update Git & PR Strategy section in `README.md` — verify branch naming patterns, PR requirements (go test -race, flutter analyze, openapi review), and conventional commit format are current
- [x] T019 [US1] Update QA & Issue Tracking section in `README.md` — verify bug reporting instructions and feedback loop descriptions match current GitHub workflow
- [x] T020 [US1] Update AI Assistants and Contributing sections in `README.md` — verify links to `AGENTS.md`, `docs/agent_playbook.md`, and code standards are current
- [x] T021 [US1] Final link audit of updated `README.md` — verify every internal reference resolves to an existing file

**Checkpoint**: README.md is fully updated. A new developer can clone, set up, and understand the project with zero stale information.

---

## Phase 4: User Story 2 — Developer Navigates Internal Docs (Priority: P2)

**Goal**: A contributor past initial setup can open any document in `docs/` and find information matching the current codebase state — accurate phase status, complete package inventory, and current technology list.

**Independent Test**: A developer opens `docs/roadmap.md`, `docs/codebase_architecture.md`, and `docs/tech_stack.md` and finds zero references to deleted files, renamed modules, or non-existent features. File counts and phase statuses match reality.

### Implementation for User Story 2

- [x] T022 [P] [US2] Update `docs/codebase_architecture.md` — backend handlers subsection: list all 10 handlers (admin, auth, driver, metrics, payment, report, ride, role, safety, system) with one-line descriptions
- [x] T023 [P] [US2] Update `docs/codebase_architecture.md` — backend usecases subsection: list all 13 usecase files (admin, auth+test, driver+test, metrics, payment, report, ride+test, role, safety, system)
- [x] T024 [P] [US2] Update `docs/codebase_architecture.md` — backend repositories subsection: list all 10 repo files (admin, driver, metrics, payment, report, ride, role, safety, system, user_token)
- [x] T025 [P] [US2] Update `docs/codebase_architecture.md` — backend domain subsection: list all 10 domain files (admin, audit, driver, errors, incident, location, ports, ride, user, vehicle)
- [x] T026 [US2] Update `docs/codebase_architecture.md` — DTOs subsection: list 4 DTO files (admin, auth, driver, ride); middleware subsection: list 3 files (auth, rate_limit, security)
- [x] T027 [US2] Update `docs/codebase_architecture.md` — WebSocket subsection: add `redis_dispatcher.go` to the 3 WS files (handler, hub, redis_dispatcher)
- [x] T028 [US2] Update `docs/codebase_architecture.md` — pkg/ subsection: update to reflect current structure (jwt/jwt.go, testutil/fixtures.go; note middleware moved to delivery)
- [x] T029 [US2] Update `docs/codebase_architecture.md` — migrations subsection: list all 10 migration files (001–010) with brief purpose statements including RBAC migrations (007–010)
- [x] T030 [US2] Update `docs/roadmap.md` — verify Phase 1 (Backend Foundation) all items remain correctly marked complete
- [x] T031 [US2] Update `docs/roadmap.md` — verify Phase 2 (Security & Bug Fixes) completed items (12) match `docs/system_audit.md` resolved list; keep remaining Critical (5) and High (8+) items as open
- [x] T032 [US2] Update `docs/roadmap.md` — Phase 4 (Admin Dashboard): note that backend admin APIs are defined in OpenAPI spec (~49 endpoints across users, fares, surge, incidents, payments, reports, metrics, roles, safety/KYC, system config); mark frontend framework as "TBD"
- [x] T033 [US2] Update `docs/tech_stack.md` — admin dashboard section: change "React or Vue.js — To-Be" to "planned — framework TBD; backend APIs defined in OpenAPI spec"
- [x] T034 [US2] Final link audit of updated `docs/*.md` files — verify every internal reference resolves

**Checkpoint**: All internal docs are current. File counts, phase statuses, and technology descriptions match the actual codebase.

---

## Phase 5: User Story 3 — Agent/Bot Consumes Repo Context (Priority: P3)

**Goal**: An AI coding agent reading `AGENTS.md`, `docs/agent_playbook.md`, and `docs/agent_context.json` finds all file paths valid, all workflow steps current, and all command references accurate.

**Independent Test**: An agent follows the documented workflows (add/change REST API, use generated Dart client, WebSocket handling) and produces code that passes `go test -race ./...` and `flutter analyze` without encountering stale path references or outdated commands.

### Implementation for User Story 3

- [x] T035 [P] [US3] Audit `docs/agent_context.json` critical_paths — verify every listed file path exists in the repository (openapi_spec, dart_client_output, backend_entry, backend_domain, backend_usecase, backend_repository, backend_delivery_http, backend_delivery_ws, etc.)
- [x] T036 [P] [US3] Audit `docs/agent_playbook.md` repository map — verify all listed paths exist and descriptions match current responsibilities
- [x] T037 [US3] Audit `docs/agent_playbook.md` workflows — verify the add-or-change-REST-API workflow steps (edit swagger → implement backend → generate client → implement mobile → verify) are current and accurate
- [x] T038 [US3] Audit `docs/agent_playbook.md` conventions table — verify all rules still apply (OpenAPI-first, no domain imports from delivery, ErrorCode handling, Idempotency-Key, mobile MVVM rules)
- [x] T039 [US3] Audit `AGENTS.md` — verify hard rules reference current file paths (swagger.yaml, generate-client.sh, patch-generated-api-client.sh, mobile/shared/lib/api_client/)
- [x] T040 [US3] Audit `AGENTS.md` one-line tasks table — verify commands and paths are current (go test -race, flutter analyze, swagger URL)
- [x] T041 [US3] Update any stale paths found in T035–T040 across agent docs

**Checkpoint**: All agent-facing documentation has valid paths, current workflows, and accurate command references.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation pass across all updated documentation.

- [x] T042 [P] Global cross-reference audit — scan all updated `.md` files for any remaining stale file/directory references
- [x] T043 [P] Verify README API endpoint group counts match `openapi/swagger.yaml` operationId counts per tag
- [x] T044 [P] Verify `docs/codebase_architecture.md` file counts match actual `dir /b` output for each backend layer
- [x] T045 [P] Verify migration count in docs matches `migrations/*.sql` file count (should be 10)
- [x] T046 [P] Verify "in progress" vs "not started" vs "complete" status labels are consistent across README, roadmap, and tech_stack docs
- [x] T047 [P] Verify no documentation file claims an endpoint is "implemented" when no corresponding handler exists (spec-defined vs implemented distinction)
- [x] T048 Final read-through of all 4 updated documents for tone, consistency, and formatting quality

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately. Gathers source-of-truth data.
- **Phase 2 (Foundational)**: Depends on Phase 1 inventories being gathered. BLOCKS all user story phases.
- **Phase 3 (US1 — README)**: Depends on Phase 2 audit completion. Independent of US2 and US3.
- **Phase 4 (US2 — Internal Docs)**: Depends on Phase 2 audit completion. Independent of US1 and US3.
- **Phase 5 (US3 — Agent Docs)**: Depends on Phase 2 audit completion. Independent of US1 and US2.
- **Phase 6 (Polish)**: Depends on Phases 3, 4, and 5 completion.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Phase 2 — no dependencies on US2 or US3. Delivers the MVP: an accurate README.
- **User Story 2 (P2)**: Can start after Phase 2 — no dependencies on US1 or US3. Delivers accurate internal docs.
- **User Story 3 (P3)**: Can start after Phase 2 — no dependencies on US1 or US2. Delivers accurate agent context.

### Within Each User Story

- Inventory/audit tasks (T001–T011, T008–T011) must complete before write tasks begin.
- Parallel write tasks ([P] marked) within a story can proceed simultaneously since they target different files/sections.
- Final link audit task in each story must come last (depends on all writes in that story).

### Parallel Opportunities

- **Phase 1**: All 7 inventory tasks (T001–T007) can run in parallel — each reads a different directory.
- **Phase 2**: All 4 audit tasks (T008–T011) can run in parallel — each audits a different file.
- **Phase 3 (US1)**: T012, T014 can run in parallel (different README sections). T015–T020 are sequential on README.md.
- **Phase 4 (US2)**: T022–T025 can run in parallel (different sections of codebase_architecture.md). T030–T033 are sequential on roadmap.md and tech_stack.md.
- **Phase 5 (US3)**: T035, T036 can run in parallel (different files). T037–T041 are sequential on playbook and AGENTS.md.
- **Cross-story**: Phases 3, 4, and 5 can all proceed in parallel once Phase 2 completes (different target files).

---

## Parallel Example: Phase 1 Setup

```bash
# Launch all inventory tasks together — each reads a different directory:
Task: T001 - Document handler inventory from backend/internal/delivery/http/
Task: T002 - Document usecase inventory from backend/internal/usecase/
Task: T003 - Document repository inventory from backend/internal/repository/postgres/
Task: T004 - Document domain inventory from backend/internal/domain/
Task: T005 - Document endpoint counts from openapi/swagger.yaml
Task: T006 - Document migrations from migrations/*.sql
Task: T007 - Document middleware, WS, infra, pkg inventories
```

## Parallel Example: Cross-Story Execution

```bash
# After Phase 2 completes, all 3 user story phases can run in parallel:
Developer A: Phase 3 (US1) — Update README.md (T012–T021)
Developer B: Phase 4 (US2) — Update docs/codebase_architecture.md, roadmap.md, tech_stack.md (T022–T034)
Developer C: Phase 5 (US3) — Audit and update agent docs (T035–T041)
# No conflicts — each targets different files.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup — gather file inventories
2. Complete Phase 2: Foundational — run cross-reference audits
3. Complete Phase 3: User Story 1 — update README.md
4. **STOP and VALIDATE**: Verify all README links resolve, endpoint counts match swagger.yaml, directory tree matches file system
5. Commit README changes

### Incremental Delivery

1. Complete Setup + Foundational → Accurate source data ready
2. Update README.md (US1) → Verify links and counts → Commit (MVP! New developers can now onboard)
3. Update internal docs (US2) → Verify file counts and phase status → Commit (Contributors have accurate docs)
4. Update agent docs (US3) → Verify paths and workflows → Commit (Agents produce correct code)
5. Polish pass (Phase 6) → Global validation → Final commit

### Parallel Team Strategy

With multiple developers:

1. Team completes Phase 1 (Setup) + Phase 2 (Foundational) together — shared source data
2. Once audits are done:
   - Developer A: Phase 3 (US1) — README.md updates
   - Developer B: Phase 4 (US2) — Internal docs updates
   - Developer C: Phase 5 (US3) — Agent docs updates
3. All 3 phases target different files — zero merge conflicts
4. Phase 6 (Polish) — any available developer runs global validation

---

## Notes

- [P] tasks = different files or sections, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group of related updates
- Stop at any checkpoint to validate that story independently
- Avoid: vague descriptions, stale file counts, inventing endpoint counts without checking swagger.yaml
- Total tasks: 48
- Task count per user story: US1 = 10, US2 = 13, US3 = 7
- Setup + Foundational = 11 tasks
- Polish = 7 tasks
