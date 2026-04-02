# SakAI — Platform Overview

> **Last Updated:** 2026-04-01 | **Phase:** 2 (Security & Bug Fixes — In Progress)

SakAI is a **ride-hailing platform** built as a production-grade monorepo. The system covers the full lifecycle of a ride: passenger requests → backend matches nearest driver → real-time tracking via WebSockets → ride completes.

---

## 🏗 Architecture at a Glance

```
┌──────────────┐   REST + WS   ┌──────────────────────────┐   REST + WS   ┌──────────────┐
│  Passenger   │◄─────────────►│    Go + Gin Backend      │◄─────────────►│    Driver    │
│  Flutter App │               │  (Clean Architecture)    │               │  Flutter App │
└──────────────┘               │                          │               └──────────────┘
                               │  ┌────────────────────┐  │
                               │  │PostgreSQL + PostGIS│  │
                               │  └────────────────────┘  │
                               │  ┌────────────────────┐  │
                               │  │  Redis (cache +    │  │
                               │  │  pub/sub)          │  │
                               │  └────────────────────┘  │
                               └──────────────────────────┘
                                            ▲
                                            │ REST
                               ┌────────────────────────┐
                               │   Admin Dashboard (Web)│
                               └────────────────────────┘
```

### Request Flow

1. **REST:** Gin handler → DTO validation → Use-case → Repository → PostgreSQL/Redis → DTO response.
2. **WebSocket:** Mobile client connects with JWT → Hub registers user → Backend broadcasts typed events.
3. **Real-time location:** Driver app PUTs location every 3–5 s → backend fan-outs to passenger's WS connection.

---

## 🔗 API Documentation (Swagger UI)

The backend exposes **Swagger UI** at runtime:

| Endpoint                 | URL                                            |
| ------------------------ | ---------------------------------------------- |
| Swagger UI (interactive) | `http://localhost:8080/swagger/index.html`     |
| Raw OpenAPI spec         | [`openapi/swagger.yaml`](openapi/swagger.yaml) |

> Start the backend first (`go run cmd/api/main.go` from `backend/`), then open the Swagger UI in your browser to explore and test all 18 endpoints.

---

## 📋 Current Phase Snapshot

| Phase | Name                 | Status         |
| ----- | -------------------- | -------------- |
| 1     | Backend Foundation   | ✅ Complete    |
| 2     | Security & Bug Fixes | 🚧 In Progress |
| 3     | Flutter Mobile Apps  | ⬜ Not Started |
| 4     | Admin Dashboard      | 🚧 In Progress (Roles & APIs added) |

See [`docs/roadmap.md`](docs/roadmap.md) for full detail and [`docs/system_audit.md`](docs/system_audit.md) for outstanding bugs.

### Admin Capabilities Built
We have added `admin` and `superadmin` roles. To seed the first superadmin, run:
`go run ./cmd/seed-admin -role superadmin -email superadmin@sakai.com -name SuperAdmin`
Subsequent admins can be programmatically created via `POST /admin/users` by an existing superadmin.

### Phase 2 — Remaining Critical Blockers

These must be resolved before Phase 3 begins:

| ID      | Issue                                                           | File                                          |
| ------- | --------------------------------------------------------------- | --------------------------------------------- |
| **C1**  | Expiry worker does not notify passenger via WS on offer timeout | `internal/infrastructure/expiry/worker.go`    |
| **C2**  | `FindNearbyOnline` doesn't exclude drivers already on a ride    | `internal/repository/postgres/driver_repo.go` |
| **L3**  | `GET /rides/:id` — no participant authorization check           | `internal/delivery/http/ride_handler.go`      |
| **H4**  | No request body size limit (DoS vector)                         | `internal/delivery/http/router/router.go`     |
| **SC1** | Missing GIST index on driver location column                    | `migrations/` (new migration needed)          |

---

## 📂 Monorepo Structure

```
SakAI/
├── backend/          # Go + Gin API (Clean Architecture)
│   ├── cmd/api/      # Entry point (main.go)
│   ├── configs/      # Env-based config loading
│   ├── internal/
│   │   ├── domain/       # Entities + port interfaces
│   │   ├── usecase/      # Business logic
│   │   ├── repository/   # PostgreSQL + Redis adapters
│   │   └── delivery/     # HTTP handlers, WS hub, expiry worker
│   └── pkg/          # Shared middleware (auth, logging, rate limiting)
├── migrations/       # Sequential SQL migration files (PostGIS schema)
├── openapi/          # swagger.yaml — single source of truth for API contracts
├── mobile/
│   ├── shared/       # Generated Dart client, shared models, token storage
│   ├── passenger/    # Flutter passenger app (Clean Arch + MVVM)
│   └── driver/       # Flutter driver app (Clean Arch + MVVM)
├── admin/            # [In Progress] Web admin dashboard (React/Vue)
├── scripts/          # Utility scripts (client codegen, etc.)
└── docs/             # Project documentation
    ├── requirements.md       # Acceptance criteria per feature
    ├── roadmap.md            # Phase-by-phase plan
    ├── system_audit.md       # Audit findings (priority-ranked)
    ├── codebase_architecture.md
    ├── tech_stack.md
    └── sessions/             # Per-session development logs
```

---

## ⚙️ Environment Configuration

Copy `backend/.env.example` to `backend/.env` and adjust:

| Variable                      | Default                                                             | Notes                                   |
| ----------------------------- | ------------------------------------------------------------------- | --------------------------------------- |
| `PORT`                        | `8080`                                                              | HTTP server port                        |
| `DATABASE_URL`                | `postgres://postgres:postgres@localhost:5432/sakai?sslmode=disable` | PostGIS connection                      |
| `MIGRATIONS_DIR`              | `../migrations`                                                     | Relative path from `backend/` directory |
| `JWT_SECRET`                  | `change-me-...`                                                     | **Must be overridden in production**    |
| `ACCESS_TOKEN_EXPIRY`         | `60m`                                                               | Go duration string                      |
| `REFRESH_TOKEN_EXPIRY`        | `720h`                                                              | 30 days                                 |
| `WS_PING_INTERVAL`            | `30s`                                                               | WebSocket keepalive                     |
| `LOCATION_RATE_LIMIT_PER_MIN` | `30`                                                                | Driver location update rate limit       |

---

## 🔗 Key Documents

| Document                                       | Purpose                                 |
| ---------------------------------------------- | --------------------------------------- |
| [`README.md`](README.md)                       | Quickstart, workflows, git strategy     |
| [`docs/requirements.md`](docs/requirements.md) | Full acceptance criteria for all phases |
| [`docs/roadmap.md`](docs/roadmap.md)           | Phase plan and task status              |
| [`docs/system_audit.md`](docs/system_audit.md) | Audit findings and fixes                |
| [`CONTRIBUTING.md`](CONTRIBUTING.md)           | Dev setup, testing, code generation     |
| [`openapi/swagger.yaml`](openapi/swagger.yaml) | API contract (source of truth)          |
| [`AGENTS.md`](AGENTS.md)                       | Index for AI assistants / automation    |
| [`docs/agent_playbook.md`](docs/agent_playbook.md) | Workflows, paths, verification checklist |
| [`docs/agent_context.json`](docs/agent_context.json) | Machine-readable repo facts (JSON)   |
