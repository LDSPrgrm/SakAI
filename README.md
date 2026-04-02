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
- **Real-Time Tracking**: Ultra-low latency location updates via WebSockets backed by Redis.
- **Strongly Typed Clients**: Automatic Dart API client generation from the OpenAPI spec.
- **Graceful Reliability**: Backend handles SIGINT/SIGTERM with graceful shutdowns and background worker synchronization.
- **Containerized Development**: Full local environment parity using Docker Compose.
- **API Documentation**: How to access Swagger/OpenAPI.
- **Parallel Development**: Guide for Backend/Mobile synchronization.

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

- **Feature Branches**: Should be scoped to a specific module.
  - `feature/backend/[name]`
  - `feature/mobile/[name]`
  - `feature/api-contract/[name]`
- **Atomic Commits**: Keep backend and frontend changes in separate commits even if they are in the same PR.

### **Pull Requests (PRs)**

- **API Visibility**: Any PR modifying `openapi/` must be reviewed by both Backend and Mobile teams to ensure compatibility.
- **CI Checks**: PRs must pass all Go linting/tests and Flutter analyzer/tests before merging.
- **Scoped Reviews**: Mobile devs review mobile code; Backend devs review backend code.

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

Ensure you have a simulator/emulator running:

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

The API is fully documented via OpenAPI. Once the backend is running, you can explore the endpoints and contracts:

- **Raw Spec:** [`openapi/swagger.yaml`](openapi/swagger.yaml)
- **Swagger UI:** `http://localhost:8080/swagger/index.html`
- **Health Check:** `http://localhost:8080/health`

See [`overview.md`](overview.md) for a full platform summary, environment variable reference, and Phase 2 blocker status.

---

## 🏗️ Architecture Summary

### Use-Case Flow

1. **Request**: Handled by Gin (`delivery/http`) or WebSockets (`delivery/ws`).
2. **Logic**: Use-cases (`usecase/`) orchestrate business rules using domain ports.
3. **Data**: Repositories (`repository/`) interact with PostGIS or Redis.
4. **Events**: Redis Dispatcher broadcasts real-time updates across the cluster.

---

## 🤝 Contributing

We welcome contributions! Please follow our code standards:

- Adhere to **Clean Architecture** patterns.
- Ensure all new features include unit tests in the `internal/usecase` layer.
- Update the `openapi/swagger.yaml` for any API changes.

---
