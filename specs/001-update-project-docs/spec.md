# Feature Specification: Update Project Documentation

**Feature Branch**: `001-update-project-docs`
**Created**: 2026-04-11
**Status**: Draft
**Input**: User description: "The current readme and docs are quite behind on the current code implementations. You can check docs/ readme, and openapi/ for context. Update the README accordingly. Be very comprehensive"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Developer Onboards via README (Priority: P1)

A new developer clones the repository and reads the README to set up their local environment, understand the project structure, and start contributing. They need accurate, up-to-date information about the tech stack, setup steps, available endpoints, and project conventions.

**Why this priority**: The README is the first document every contributor sees. If it is stale, onboarding fails, time is wasted, and trust in the project erodes.

**Independent Test**: A developer with no prior knowledge of SakAI can follow the README from scratch, start all services (backend, mobile, infrastructure), access Swagger UI, and understand where to find further documentation — without encountering outdated instructions or missing sections.

**Acceptance Scenarios**:

1. **Given** a fresh checkout of the repository, **When** a developer follows the "Getting Started" section, **Then** all services start without errors and the Swagger UI is accessible.
2. **Given** a developer wants to understand the project architecture, **When** they read the README, **Then** the described directory structure, layer conventions, and component roles match the actual codebase.
3. **Given** a developer wants to know what API endpoints exist, **When** they check the API documentation section, **Then** the listed endpoint groups and counts match the current OpenAPI spec.

---

### User Story 2 — Developer Navigates Internal Docs (Priority: P2)

A contributor who is past initial setup needs to understand the current project status, outstanding work, architectural decisions, and requirements. They navigate from the README to internal docs (`docs/` directory).

**Why this priority**: Internal docs must accurately reflect the current implementation state so developers can make informed decisions about what to build next and what is already done.

**Independent Test**: A developer can open each document in `docs/` and find information that matches the current codebase — no references to incomplete features as if they were complete, no missing major components that have been built.

**Acceptance Scenarios**:

1. **Given** a developer opens `docs/roadmap.md`, **When** they check Phase 2 status, **Then** completed audit fixes are marked complete and remaining items reflect actual pending work.
2. **Given** a developer opens `docs/codebase_architecture.md`, **When** they read the directory structure, **Then** it lists all current packages and handlers that actually exist in the codebase.
3. **Given** a developer opens `docs/requirements.md`, **When** they read Phase 4 Admin Dashboard requirements, **Then** the listed requirements match the admin endpoints currently defined in the OpenAPI spec.

---

### User Story 3 — Agent/Bot Consumes Repo Context (Priority: P3)

An AI coding agent or automation tool reads `AGENTS.md`, `docs/agent_playbook.md`, and `docs/agent_context.json` to understand project conventions before making changes.

**Why this priority**: Agents are an active part of the development workflow. Stale agent docs cause incorrect code suggestions and convention violations.

**Independent Test**: An agent following the documented workflows can successfully navigate the codebase, run the correct commands, and produce changes that pass all verification checks.

**Acceptance Scenarios**:

1. **Given** an agent reads `docs/agent_context.json`, **When** it checks critical paths, **Then** all listed file paths exist in the repository.
2. **Given** an agent reads `docs/agent_playbook.md`, **When** it follows the add-or-change-REST-API workflow, **Then** the steps produce working code that passes `go test -race ./...` and `flutter analyze`.

---

### Edge Cases

- What happens when a document references a file or directory that was renamed or deleted? (Stale links reduce trust.)
- How does the README handle features that are "in progress" vs "not started"? (Must clearly distinguish to avoid confusion.)
- What if the OpenAPI spec lists endpoints that have no backend implementation yet? (Docs should clarify what is spec-only vs fully implemented.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The README.md MUST accurately describe the current repository structure, including all top-level directories and their purposes.
- **FR-002**: The README MUST list the complete tech stack: Go + Gin (backend), Flutter (mobile), PostgreSQL + PostGIS (database), Redis (cache/pubsub), WebSockets (real-time), OpenAPI (contract), Docker Compose (infrastructure).
- **FR-003**: The README "Getting Started" section MUST include working setup instructions for all three components: infrastructure (Docker Compose), backend (Go), and mobile (Flutter apps).
- **FR-004**: The README MUST reference all current documentation files in `docs/` with accurate one-line descriptions.
- **FR-005**: The README API documentation section MUST reflect the current endpoint inventory from `openapi/swagger.yaml` (System, Auth, Users, Driver, Rides, Admin endpoint groups).
- **FR-006**: The README architecture section MUST describe the actual Clean Architecture layer structure (`domain`, `usecase`, `repository`, `delivery`) and the mobile feature-first MVVM layout.
- **FR-007**: The `docs/roadmap.md` MUST be updated to reflect completed Phase 2 items and current remaining blockers.
- **FR-008**: The `docs/codebase_architecture.md` MUST describe all current packages, handlers, and usecases that exist in the codebase.
- **FR-009**: The `docs/tech_stack.md` MUST include all technologies currently in use, including the admin dashboard framework (if chosen).
- **FR-010**: All cross-references between documents (README → overview.md → docs/*) MUST resolve to existing files.
- **FR-011**: The README MUST document the admin seeding workflow (`go run ./cmd/seed-admin`) and role-based access control (`passenger`, `driver`, `admin`, `superadmin`).
- **FR-012**: The README MUST describe the Git & PR strategy with current branch naming conventions and PR requirements.

### Key Entities

- **README.md**: Root-level project entry point. Contains tech stack, repo structure, key features, setup instructions, API docs overview, architecture summary, and links to internal docs.
- **docs/roadmap.md**: Phase-by-phase plan with task status. Must reflect what is done, in progress, and not started.
- **docs/codebase_architecture.md**: Narrative description of the codebase structure, layer conventions, and module organization.
- **docs/tech_stack.md**: Comprehensive technology breakdown with rationale.
- **docs/requirements.md**: Functional requirements and acceptance criteria per phase. Must align with the current OpenAPI spec.
- **openapi/swagger.yaml**: OpenAPI 3.0.3 spec — the single source of truth for all REST endpoints (~45 operationIds across 6+ tags).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new developer can follow the README from a fresh clone to a running backend with Swagger UI accessible in under 10 minutes, without encountering any outdated or broken instructions.
- **SC-002**: 100% of top-level directories referenced in the README exist and are described with accurate, current purpose statements.
- **SC-003**: All `docs/*.md` files contain information that matches the current codebase state — zero references to deleted files, renamed modules, or non-existent features.
- **SC-004**: The README API documentation section covers all 6 endpoint groups defined in the OpenAPI spec (System, Auth, Users, Driver, Rides, Admin) with accurate descriptions.
- **SC-005**: The roadmap accurately reflects the completion status of Phase 1 (complete), Phase 2 (in progress with specific remaining items listed), and Phases 3-7.
- **SC-006**: All internal cross-references between documents resolve correctly — zero broken links.

## Assumptions

- The OpenAPI spec (`openapi/swagger.yaml`) is the authoritative source for what endpoints exist. Documentation should describe what the spec defines, not what might be planned.
- The admin dashboard web framework (React vs Vue) has not yet been chosen — the docs should reflect this as "in progress" rather than asserting a specific framework.
- The mobile apps (passenger and driver) are in active development but not yet complete — docs should describe the architecture and conventions, not claim full implementation.
- Phase 2 security/bug fixes are partially complete — the roadmap and audit documents need reconciliation between what the audit found and what has been fixed.
- The target audience for the README includes: new developers, contributing developers, technical leads reviewing architecture, and AI coding agents.
- Documentation should be written in English and use GitHub-flavored Markdown.
