# SakAI 🚕

SakAI is a modern, high-performance **ride-hailing platform** built with a focus on scalability, real-time interactivity, and clean architectural principles. It leverages a robust Go backend and the cross-platform power of Flutter to deliver a seamless experience for both passengers and drivers.

---

## 🚀 Tech Stack

- **Backend**: [Go](https://go.dev/) + [Gin Framework](https://gin-gonic.com/) (Clean Architecture)
- **Mobile**: [Flutter](https://flutter.dev/) (MVVM + Clean Architecture)
- **Database**: [PostgreSQL](https://www.postgresql.org/) + [PostGIS](https://postgis.net/) (Geospatial queries)
- **Real-time**: [WebSockets](https://en.wikipedia.org/wiki/WebSocket) + [Redis Pub/Sub](https://redis.io/)
- **Caching**: [Redis](https://redis.io/)
- **API Spec**: [OpenAPI / Swagger](https://swagger.io/)
- **Infrastructure**: [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)

---

## 📂 Repository Structure

SakAI is organized as a **monorepo** to maintain tight synchronization between the API contracts and all client/server implementations:

```text
SakAI/
├── backend/       # Go backend services (REST API & WebSockets)
├── mobile/        # Flutter mobile apps (Passenger & Driver)
├── migrations/    # PostGIS database schema migrations
├── openapi/       # Swagger/OpenAPI API definitions
├── scripts/       # Utility scripts for code generation and maintenance
├── docs/          # Architecture guides and project roadmap
└── admin/         # [In Progress] Web-based administration dashboard
```

---

## ✨ Key Features

- **Clean Architecture**: Decoupled layers (`domain`, `usecase`, `repository`, `delivery`) for maximum testability and maintainability.
- **Geospatial Intelligence**: Real-time driver matching and proximity searching using PostGIS.
- **Real-Time Tracking**: Ultra-low latency location updates via WebSockets backed by Redis Pub/Sub.
- **Role-Based Access Control (RBAC)**: Four-tier role system (`passenger`, `driver`, `admin`, `superadmin`) with granular permissions and role management APIs.
- **Admin Platform**: ~49 administrative endpoints covering user management, fare/surge pricing, incident resolution, payment processing, audit logging, reporting, metrics dashboards, safety/KYC, and system configuration.
- **Security Hardening**: Rate-limited auth endpoints, security headers middleware, request body size limits, and JWT secret validation.
- **Strongly Typed Clients**: Automatic Dart API client generation from the OpenAPI spec.
- **Graceful Reliability**: Backend handles SIGINT/SIGTERM with graceful shutdowns and background worker synchronization.
- **Containerized Development**: Full local environment parity using Docker Compose.
- **API Documentation**: Comprehensive OpenAPI spec with Swagger UI for interactive exploration.
- **Parallel Development**: Contract-first workflow enables backend and mobile teams to work simultaneously.

---

## 🏎️ Parallel Development Workflow

SakAI is designed for **contract-first development**. This allows backend and mobile teams to work in parallel without blocking each other.

### 📜 1. The Contract (OpenAPI)

The `openapi/swagger.yaml` is the **single source of truth**.

- Any change to the API must first be reflected in the spec.
- **Backend Developers**: Implement the server interfaces defined by the spec.
- **Mobile Developers**: Run the Dart client generator to update their API client.

### 👥 2. Role-Based Workflows

#### **For Backend Developers**

1. Update `swagger.yaml` with required changes.
2. Implement logic in `internal/usecase` and PostgreSQL/Redis adapters.
3. Expose the functionality in `delivery/http` using the agreed DTOs.
4. Verify using unit tests and integration tests.

#### **For Mobile Developers**

1. Generate the Dart client from the updated `swagger.yaml`.
2. Use Mock data providers to implement UI and ViewModels while backend is in progress.
3. Switch to the real API client once the backend endpoint is ready.

---

## 🌲 Git & PR Strategy

To maintain a clean and stable monorepo, we follow these guidelines:

### **Branching Strategy**

- **Feature Branches**: Scoped to a specific module.
  - `feature/backend/[name]`
  - `feature/mobile/[name]`
  - `feature/api-contract/[name]`
  - `feature/docs/[name]`
- **Bug Fixes**: `fix/<scope>/<name>` — reference audit IDs (e.g., `fix/backend/C1-expiry-notify`).
- **Atomic Commits**: Keep backend and frontend changes in separate commits even if they are in the same PR.

### **Pull Requests (PRs)**

- **API Visibility**: Any PR modifying `openapi/` must be reviewed by both Backend and Mobile teams to ensure compatibility.
- **CI Checks**: PRs must pass all Go tests (`go test -race ./...`) and Flutter analyzer checks (`flutter analyze`) before merging.
- **Scoped Reviews**: Mobile devs review mobile code; Backend devs review backend code.
- **Issue Linking**: Every PR must link to a GitHub Issue or audit finding (e.g., `Closes #12`, `Fixes C1`).
- **Conventional Commits**: Use `feat:`, `fix:`, `chore:`, `docs:`, `test:` prefixes. Scope optional (e.g., `feat(backend):`, `fix(mobile):`).

---

## 🔍 QA & Issue Tracking

We use **GitHub Issues** as our central hub for quality assurance:

- **Bug Reporting**: Use the provided templates to report bugs. Include logs from `docker-compose logs backend` or Flutter console output.
- **QA Feedback Loops**:
  1. A feature is implemented and a PR is opened.
  2. QA/Lead reviews the PR and creates Issues for any discovered edge cases or bugs.
  3. Issues are linked to the original PR for traceability.
- **Requirement Mapping**: Each PR should link to a GitHub Issue (Task/Bug) to ensure every line of code has a purpose.

---

## 🛠️ Getting Started

### Prerequisites

- **Go** 1.21+
- **Flutter** 3.x
- **Docker** & **Docker Compose**
- **Git**

### 1. Local Infrastructure

Bring up the required database and caching services:

```bash
docker-compose up -d
```

_Note: This starts PostgreSQL (PostGIS) on port 5432 and Redis on port 6379._

### 2. Backend Setup

Navigate to the backend directory and run the server:

```bash
cd backend
go mod download
go run cmd/api/main.go
```

_The server will automatically run pending migrations at startup._

### 3. Mobile Apps

Ensure you have a simulator/emulator running. We provide convenient root-level helper scripts to fetch dependencies and run the desired app:

**On macOS / Linux:**
```bash
./run-mobile.sh passenger
# or
./run-mobile.sh driver
```

**On Windows:**
```bat
run-mobile.bat passenger
:: or
run-mobile.bat driver
```

Alternatively, you can run manually:
```bash
cd mobile/passenger # or mobile/driver
flutter pub get
flutter run
```

### 4. Admin Initialization

The system uses role-based access control. Public registration (`/auth/register`) only permits `passenger` and `driver` accounts. To bootstrap higher-privileged identities:

Run the administrative seed CLI tool from `backend/`:
```bash
go run ./cmd/seed-admin -role superadmin -name "SuperAdmin" -email "superadmin@sakai.com" -password "admin123"
```
Once seeded, you can create additional admins using the built-in REST endpoint `POST /admin/users` by passing a valid `superadmin` JWT in the Authorization header.

---

## 📖 API Documentation

The API is fully documented via OpenAPI 3.0.3 with **66 endpoints** across 6 endpoint groups. Once the backend is running, you can explore the endpoints and contracts:

- **Raw Spec:** [`openapi/swagger.yaml`](openapi/swagger.yaml)
- **Swagger UI:** `http://localhost:8080/swagger/index.html`
- **Health Check:** `http://localhost:8080/health`

### Endpoint Overview

| Group | Count | Description |
|-------|-------|-------------|
| **System** | 1 | Health checks and operational status |
| **Auth** | 4 | Registration, login, token refresh, logout |
| **Users** | 1 | Authenticated user profile (`GET /users/me`) |
| **Driver** | 3 | Availability status, location updates, incoming ride offers |
| **Rides** | 8 | Full ride lifecycle: request, accept, decline, arrive, start, complete, cancel |
| **Admin** | ~49 | User management, fare/surge pricing, incident resolution, ride browsing, passenger/driver lists, payment processing, audit logging, role-based access control, safety/KYC, reporting, metrics dashboards, system configuration (feature flags, integrations, notifications) |

> **Note:** Admin endpoints are defined in the OpenAPI spec. Backend implementation status varies — check [`docs/roadmap.md`](docs/roadmap.md) for current completion status.

See [`overview.md`](overview.md) for a full platform summary, environment variable reference, and Phase 2 blocker status.

---

## 🏗️ Architecture Summary

### Use-Case Flow

1. **Request**: Handled by Gin (`delivery/http`) or WebSockets (`delivery/ws`).
2. **Logic**: Use-cases (`usecase/`) orchestrate business rules using domain ports.
3. **Data**: Repositories (`repository/`) interact with PostGIS or Redis.
4. **Events**: Redis Dispatcher (`delivery/ws/redis_dispatcher.go`) broadcasts real-time updates across the cluster.

### Backend Structure

| Layer | Directory | Files | Responsibility |
|-------|-----------|-------|----------------|
| **Domain** | `internal/domain/` | 10 | Pure Go entities + port interfaces |
| **Use-Case** | `internal/usecase/` | 13 | Business logic (auth, ride, driver, admin, metrics, payment, report, role, safety, system) |
| **Repository** | `internal/repository/postgres/` | 10 | PostgreSQL/Redis adapters |
| **Delivery** | `internal/delivery/http/` | 10 handlers | REST API (admin, auth, driver, metrics, payment, report, ride, role, safety, system) |
| **Delivery** | `internal/delivery/ws/` | 3 | WebSocket hub + Redis Pub/Sub dispatcher |
| **Infrastructure** | `internal/infrastructure/` | 4 | Database connections + expiry worker |

### Mobile Architecture

Feature-first MVVM: `features/<feature>/{models,repositories,view_models,views}`. All HTTP lives in `repositories/`, UI in `views/`. Shared package (`mobile/shared/`) provides generated API client, theme, and `SakaiApiSupport`.

---

## AI assistants and automation

For coding agents and scripted tooling, start with [`AGENTS.md`](AGENTS.md), then the structured [`docs/agent_playbook.md`](docs/agent_playbook.md) and [`docs/agent_context.json`](docs/agent_context.json) (compact JSON for ingestion).

---

## 🤝 Contributing

We welcome contributions! Please follow our code standards:

- Adhere to **Clean Architecture** patterns (backend) and **feature-first MVVM** (mobile).
- Ensure all new use-case logic includes unit tests (`internal/usecase/*_test.go`).
- Update `openapi/swagger.yaml` **first** for any API changes, then implement backend, then regenerate the Dart client.
- Run `go test -race ./...` (backend) and `flutter analyze` (mobile) before committing.
- See [`.specify/memory/constitution.md`](.specify/memory/constitution.md) for our development principles.

---
