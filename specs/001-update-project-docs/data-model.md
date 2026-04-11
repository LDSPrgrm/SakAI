# Data Model: Documentation Entities

**Date**: 2026-04-11
**Feature**: `specs/001-update-project-docs`

## Overview

This feature operates on **documentation entities** — the Markdown files that constitute the project's public-facing and internal documentation. There are no database models or code entities to define. Instead, this section maps the documentation artifacts and their relationships.

## Documentation Entities

### 1. README.md (Root Entry Point)

**Purpose**: First document every contributor sees. Serves as the navigation hub.

**Sections (target structure)**:
| Section | Content |
|---|---|
| Header | Project name, tagline, emoji |
| Tech Stack | 7 technologies with links |
| Repository Structure | Directory tree with current packages |
| Key Features | Bullet list of architectural highlights |
| Parallel Development Workflow | Contract-first guide |
| Git & PR Strategy | Branching, PR rules |
| QA & Issue Tracking | Bug reporting, feedback loops |
| Getting Started | Prerequisites, infra, backend, mobile, admin seeding |
| API Documentation | Endpoint group summary + Swagger UI link |
| Architecture Summary | Use-case flow diagram |
| AI Assistants | Link to AGENTS.md |
| Contributing | Code standards, test requirements |

**Dependencies**: All sections must reference files that exist. Endpoint counts must match swagger.yaml.

---

### 2. docs/roadmap.md (Phase Plan)

**Purpose**: Phase-by-phase development plan with completion tracking.

**Key relationships**:
- References `docs/requirements.md` for acceptance criteria
- References `docs/system_audit.md` for audit findings
- Maps to `openapi/swagger.yaml` for endpoint completion status

**Update targets**:
| Section | Action |
|---|---|
| Phase 2 Completed | Verify all 12 items against audit report |
| Phase 2 Critical (5 items) | Keep as-is (still open) |
| Phase 2 High (8 items) | Keep as-is (still open) |
| Phase 3 (Mobile) | Keep as "Not Started" |
| Phase 4 (Admin) | Update to reflect backend APIs are spec-defined |

---

### 3. docs/codebase_architecture.md (Structure Narrative)

**Purpose**: Describes the codebase organization and architectural patterns.

**Update targets**:
| Section | Current State | Required Update |
|---|---|---|
| Backend handlers | Lists ~4 handlers | Update to 10 handlers (add admin, metrics, payment, report, role, safety) |
| Backend usecases | Lists ~3 usecases | Update to 13 usecases |
| Backend repositories | Lists ~3 repos | Update to 10 repos |
| Backend domain | Lists 4 entities | Update to 10 domain files |
| Backend middleware | Mentions auth, rate limit | Add security middleware |
| WebSocket | Mentions hub | Add redis_dispatcher |
| pkg/ | May reference old structure | Update to jwt + testutil (middleware moved to delivery) |
| Mobile MVVM | Describes Hungrimind pattern | ✅ Already accurate |

---

### 4. docs/tech_stack.md (Technology Breakdown)

**Purpose**: Comprehensive technology list with rationale.

**Update targets**:
| Section | Current State | Required Update |
|---|---|---|
| Backend | Go + Gin + Clean Architecture | ✅ Accurate |
| Mobile | Flutter + MVVM | ✅ Accurate |
| Database | PostgreSQL + PostGIS | ✅ Accurate |
| Cache | Redis | ✅ Accurate |
| Real-time | WebSockets | ✅ Accurate |
| API Contract | OpenAPI | ✅ Accurate |
| Deployment | Docker + Docker Compose | ✅ Accurate |
| Admin Dashboard | "React or Vue.js — To-Be" | Update to "planned — framework TBD; backend APIs defined" |

---

## Relationships Between Documentation Entities

```
README.md
├── links to → overview.md (platform summary)
├── links to → docs/roadmap.md (phase plan)
├── links to → docs/requirements.md (acceptance criteria)
├── links to → docs/codebase_architecture.md (structure)
├── links to → docs/tech_stack.md (technologies)
├── links to → docs/system_audit.md (audit findings)
├── links to → docs/agent_playbook.md (agent workflows)
├── links to → AGENTS.md (agent index)
├── links to → CONTRIBUTING.md (setup guide)
└── links to → openapi/swagger.yaml (API contract)

overview.md
├── links to → docs/roadmap.md
├── links to → docs/system_audit.md
├── links to → docs/requirements.md
└── links to → CONTRIBUTING.md

docs/agent_playbook.md
├── links to → docs/codebase_architecture.md
├── links to → docs/agent_context.json
└── links to → AGENTS.md
```

## Validation Rules

| Rule | Verification Method |
|---|---|
| All `docs/*.md` links from README resolve | `test -f` for each referenced path |
| Endpoint counts per tag match swagger.yaml | `grep -c` operationId per tag section |
| Handler/usecase/repo file counts match codebase | `dir /b` counts in each directory |
| Migration count matches migrations/*.sql | `dir /b migrations\*.sql \| find /c` |
| No references to deleted files | Scan all docs for paths that no longer exist |
