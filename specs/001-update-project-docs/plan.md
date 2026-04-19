# Implementation Plan: Update Project Documentation

**Branch**: `dev` | **Date**: 2026-04-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-update-project-docs/spec.md`

## Summary

The SakAI project's documentation (README.md, docs/roadmap.md, docs/codebase_architecture.md, docs/tech_stack.md, and cross-references) is significantly behind the current codebase. The OpenAPI spec now defines ~45 endpoints across 6+ tags (System, Auth, Users, Driver, Rides, Admin), the backend has ~11 handler files and ~13 usecase files (including new admin, metrics, payment, report, role, and safety modules), but the public-facing docs still describe a much smaller system. This feature updates all documentation to accurately reflect the current implementation state.

## Technical Context

**Language/Version**: Markdown (documentation-only — no code changes)
**Primary Dependencies**: OpenAPI spec (`openapi/swagger.yaml`) as authoritative endpoint source; current backend file tree for structure accuracy
**Storage**: N/A — this is a documentation-only feature
**Testing**: Manual verification — all cross-references resolve, endpoint counts match swagger.yaml, directory trees match `ls` output, roadmap checkboxes match actual completion
**Target Platform**: GitHub-rendered Markdown (README.md + docs/*.md)
**Project Type**: Documentation update (monorepo: Go backend + Flutter mobile + admin web)
**Performance Goals**: N/A
**Constraints**: Must not change any code — only .md files. Must preserve existing document structure and headings. Must distinguish "spec-defined" vs "implemented" for endpoints that exist in OpenAPI but lack backend handlers.
**Scale/Scope**: 5 documents to update: README.md, docs/roadmap.md, docs/codebase_architecture.md, docs/tech_stack.md, and implicit cross-reference audit across all docs/*.md files.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Constitution Principle | Applicability | Compliance |
|---|---|---|
| I. Contract-First API | Documentation must describe endpoints from `openapi/swagger.yaml`, not invent new ones. | ✅ Will use swagger.yaml as the single source of truth for endpoint inventory. |
| II. Clean Architecture Layers | Directory structure descriptions must match actual layer layout. | ✅ Will verify all paths against current file tree before writing. |
| III. Test-First | Not applicable — documentation-only feature. No code changes. | ✅ N/A |
| IV. Generated Code Integrity | Not applicable — no generated files are being edited. | ✅ N/A |
| V. Error Contract Stability | Documentation must correctly describe `ErrorCode`-based error handling. | ✅ Will describe error contract as defined in spec. |
| Additional Constraints | Security section must not expose secrets; idempotency docs must match spec. | ✅ Will document existing security posture without introducing new claims. |
| Development Workflow | Branch naming, PR requirements must match current conventions. | ✅ Will document `feature/docs/<name>` branching and current PR gates. |

**Result**: All applicable gates pass. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-update-project-docs/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

No source code changes. This feature modifies documentation files only:

```text
E:\Projects\SakAI/
├── README.md                          # Update: tech stack, repo structure, setup, API overview, architecture, links
├── docs/
│   ├── roadmap.md                     # Update: Phase 2 completion status, remaining blockers
│   ├── codebase_architecture.md       # Update: current package/handler/usecase inventory
│   └── tech_stack.md                  # Update: admin framework status, any new tools
└── (no other files modified)
```

**Structure Decision**: Documentation-only update. No `src/`, `tests/`, or code directories are touched. The work operates on 4 `.md` files at known paths.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations. This is a documentation-only feature with no architectural complexity to justify.
