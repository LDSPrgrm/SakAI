# Documentation Contracts

**Date**: 2026-04-11
**Feature**: `specs/001-update-project-docs`

## Contract 1: README.md Structure

The README.md file MUST conform to the following section structure:

```markdown
# SakAI 🚕
[Tagline paragraph]

## 🚀 Tech Stack
[7-item list with links]

## 📂 Repository Structure
[Directory tree — must reflect current file system]

## ✨ Key Features
[Bullet list of architectural highlights]

## 🏎️ Parallel Development Workflow
[Contract-first guide — 2 subsections]

## 🌲 Git & PR Strategy
[Branching strategy + PR requirements]

## 🔍 QA & Issue Tracking
[Bug reporting + feedback loops]

## 🛠️ Getting Started
[Prerequisites → Infrastructure → Backend → Mobile → Admin]

## 📖 API Documentation
[Endpoint group summary + Swagger UI link]

## 🏗️ Architecture Summary
[Use-case flow — 4 steps]

## AI assistants and automation
[Link to AGENTS.md + playbook]

## 🤝 Contributing
[Code standards + test requirements]
```

**Invariant**: Every file path referenced in the README must exist in the repository.

---

## Contract 2: API Documentation Accuracy

The README's API Documentation section MUST accurately reflect the OpenAPI spec:

| Endpoint Group | Count in swagger.yaml | Must appear in README |
|---|---|---|
| System | 1 | ✅ |
| Auth | 4 | ✅ |
| Users | 1 | ✅ |
| Driver | 3 | ✅ |
| Rides | 8 | ✅ |
| Admin | ~49 | ✅ (summarized, not enumerated) |

**Invariant**: No endpoint group may be omitted. No endpoint counts may be fabricated.

---

## Contract 3: Internal Docs Cross-Reference Integrity

All internal links in README.md and between docs/*.md files MUST resolve to existing files:

| Source Document | Links To | Must Exist |
|---|---|---|
| README.md | overview.md | ✅ |
| README.md | docs/roadmap.md | ✅ |
| README.md | docs/requirements.md | ✅ |
| README.md | docs/codebase_architecture.md | ✅ |
| README.md | docs/tech_stack.md | ✅ |
| README.md | docs/system_audit.md | ✅ |
| README.md | docs/agent_playbook.md | ✅ |
| README.md | AGENTS.md | ✅ |
| README.md | CONTRIBUTING.md | ✅ |
| README.md | openapi/swagger.yaml | ✅ |

**Invariant**: Adding a new link requires verifying the target file exists.

---

## Contract 4: Roadmap Accuracy

docs/roadmap.md MUST accurately reflect:

1. Phase 1: All items marked complete (verified against git history)
2. Phase 2: 12 completed items, 5 critical open, 8+ high open
3. Phase 3: Marked "Not Started"
4. Phase 4: Backend APIs defined in spec; frontend "In Progress"
5. Phases 5-7: As defined in current plan

**Invariant**: No item may be marked complete that does not have corresponding code or spec definition.

---

## Contract 5: Architecture Description Accuracy

docs/codebase_architecture.md MUST list all current packages:

| Layer | Current File Count | Must Be Listed |
|---|---|---|
| Handlers (delivery/http) | 10 | ✅ |
| Usecases | 13 (incl. tests) | ✅ |
| Repositories | 10 | ✅ |
| Domain entities | 10 | ✅ |
| DTOs | 4 | ✅ |
| Middleware | 3 | ✅ |
| WebSocket | 3 | ✅ |
| Infrastructure | 4 files in 2 dirs | ✅ |
| pkg/ | 2 files in 2 dirs | ✅ |
| Migrations | 10 SQL files | ✅ |

**Invariant**: File counts must match the actual directory listing at time of update.
