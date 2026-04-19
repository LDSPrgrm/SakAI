# Quickstart: Updating SakAI Documentation

**Date**: 2026-04-11
**Feature**: `specs/001-update-project-docs`

## What This Feature Does

Updates 4 documentation files to accurately reflect the current SakAI codebase:
1. **README.md** — Root entry point (comprehensive rewrite)
2. **docs/roadmap.md** — Phase 2 reconciliation
3. **docs/codebase_architecture.md** — Full package inventory
4. **docs/tech_stack.md** — Admin status update

## Prerequisites

- Access to the repository
- Ability to read current file state
- Knowledge of the OpenAPI spec (`openapi/swagger.yaml`) as the endpoint authority

## How to Execute

### Step 1: Gather Current State

Run these commands to get the actual file counts:
```bash
# Backend structure
ls backend/internal/delivery/http/*_handler.go
ls backend/internal/usecase/*.go
ls backend/internal/repository/postgres/*.go
ls backend/internal/domain/*.go
ls backend/internal/delivery/http/dto/*.go
ls backend/internal/delivery/http/middleware/*.go
ls backend/internal/delivery/ws/*.go
ls backend/internal/infrastructure/**/*.go
ls backend/pkg/**/*.go
ls backend/cmd/*/
ls migrations/*.sql
```

### Step 2: Update README.md

Follow the structure defined in `contracts/documentation-contracts.md` (Contract 1). Key changes from current README:
- Update repository structure tree to include all current directories
- Ensure API documentation section mentions all 6 endpoint groups
- Verify all Getting Started steps work
- Confirm all internal doc links resolve

### Step 3: Update docs/codebase_architecture.md

Update the directory structure breakdown section to list:
- All 10 handlers (admin, auth, driver, metrics, payment, report, ride, role, safety, system)
- All 13 usecases
- All 10 repositories
- All 10 domain files
- All 3 WebSocket files (add redis_dispatcher)
- All 3 middleware files (add security)
- Updated pkg/ structure (jwt, testutil)

### Step 4: Update docs/roadmap.md

Verify Phase 2 completed items against `docs/system_audit.md`. Keep remaining open items as-is.

### Step 5: Update docs/tech_stack.md

Update admin dashboard section to reflect "backend APIs defined in spec, frontend framework TBD."

### Step 6: Validate

Run the validation checklist:
- [ ] All README links resolve
- [ ] Endpoint counts per group match swagger.yaml
- [ ] File counts in architecture doc match actual directories
- [ ] Migration count matches migrations/ directory
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Roadmap Phase 2 status matches system_audit.md

## Verification

After updates, a developer should be able to:
1. Clone the repo
2. Read the README and understand the project structure
3. Follow Getting Started to a running backend
4. Navigate from README to any internal doc without broken links
5. Open any docs/*.md file and find information matching the current codebase
