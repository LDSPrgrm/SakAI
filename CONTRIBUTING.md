# Contributing to SakAI

This guide covers everything you need to get your development environment running, write code that fits the project conventions, run the test suite, and keep API clients in sync.

---

## 📋 Prerequisites

| Tool                                  | Version       | Install                                                                              |
| ------------------------------------- | ------------- | ------------------------------------------------------------------------------------ |
| Go                                    | 1.21+         | [go.dev/dl](https://go.dev/dl/)                                                      |
| Flutter / Dart                        | 3.x           | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Docker + Docker Compose               | Latest stable | [docs.docker.com/get-docker](https://docs.docker.com/get-docker/)                    |
| `mockgen` (Go mock codegen)           | Latest        | `go install go.uber.org/mock/mockgen@latest`                                         |
| `openapi-generator-cli` (Dart client) | 7.x           | See [Dart Client Generation](#dart-client-generation)                                |

---

## 🚀 Local Setup

### 1. Start Infrastructure

```bash
# From repo root — starts PostgreSQL (PostGIS) on :5432 and Redis on :6379
docker-compose up -d
```

### 2. Configure the Backend

```bash
cd backend
cp .env.example .env
# .env is pre-filled with defaults that match docker-compose.yml — no edits needed for local dev
```

### 3. Run the Backend

```bash
# From backend/
go mod download
go run cmd/api/main.go
```

The server starts on `http://localhost:8080`. Migrations run automatically on startup.

- **Swagger UI:** `http://localhost:8080/swagger/index.html`
- **Health check:** `http://localhost:8080/health`

### 4. Run the Mobile Apps

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
cd mobile/passenger   # or mobile/driver
flutter pub get
flutter run
```

---

## 🧪 Running Tests

### Backend (Go)

```bash
cd backend

# Run all tests
go test ./...

# Run with race detector (recommended before PRs)
go test -race ./...

# Run a specific package
go test ./internal/usecase/...

# Run with verbose output
go test -v ./internal/usecase/...

# Run a specific test function
go test -v -run TestRequestRide ./internal/usecase/...
```

> Tests are located alongside the code they test, e.g. `internal/usecase/ride_usecase_test.go`.

### Mobile (Flutter)

```bash
cd mobile/passenger   # or mobile/driver or mobile/shared

# Run unit/widget tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 🤖 Mock Generation (Go)

The backend uses `go.uber.org/mock` (mockgen) for dependency injection in tests. Mocks are generated from domain interfaces.

```bash
cd backend

# Regenerate all mocks (run after changing interfaces in internal/domain/)
go generate ./...
```

Mock files follow the naming pattern `mock_*.go` and are committed to the repository.

> **When to regenerate:** Any time you add or change a method signature in `internal/domain/ports.go`.

---

## 🎯 Dart Client Generation

The Flutter apps use an auto-generated Dart HTTP client from `openapi/swagger.yaml`. This guarantees the mobile apps stay in sync with the backend contract.

### Prerequisites

Install the OpenAPI Generator CLI (requires Java 11+):

```bash
# Using NPM (recommended)
npm install @openapitools/openapi-generator-cli -g

# Or using Homebrew (macOS/Linux)
brew install openapi-generator
```

### Generate the Client

```bash
# From repo root — runs OpenAPI Generator, a small Dart 3 enum patch, then build_runner (*.g.dart)
./scripts/generate-client.sh
```

Or manually:

```bash
openapi-generator-cli generate \
  -i openapi/swagger.yaml \
  -g dart-dio \
  -o mobile/shared/lib/api_client \
  --additional-properties=pubName=sakai_api_client,nullableFields=true

cd mobile/shared/lib/api_client && dart pub get \
  && dart run build_runner build --delete-conflicting-outputs
```

> **When to regenerate:** Any time `openapi/swagger.yaml` is modified. The client lives in `mobile/shared/lib/api_client/` and is depended on by `sakai_shared` (both apps get it transitively). Use `SakaiApiSupport.createClient` / `SakaiApiEndpoints` from `package:sakai_shared/sakai_shared.dart` for defaults and JWT wiring.

---

## 🏛 Architecture Conventions

### Backend (Go) — Clean Architecture Layers

| Layer          | Location                      | Rule                                                                     |
| -------------- | ----------------------------- | ------------------------------------------------------------------------ |
| **Domain**     | `internal/domain/`            | Pure Go structs + interfaces (ports). Zero external dependencies.        |
| **Use-Case**   | `internal/usecase/`           | Business logic. Depends only on domain interfaces — never on infra.      |
| **Repository** | `internal/repository/`        | PostgreSQL/Redis adapters. Implement domain repository interfaces.       |
| **Delivery**   | `internal/delivery/`          | Gin HTTP handlers, WebSocket hub, background workers.                    |
| **DTO**        | `internal/delivery/http/dto/` | Request/response mapping. Domain entities never escape to the API layer. |

**Never** import from `delivery` into `usecase` or `domain`. Dependency direction: `delivery → usecase → domain ← repository`.

### Mobile (Flutter) — Clean Architecture + MVVM

| Layer           | Location                                                  |
| --------------- | --------------------------------------------------------- |
| `domain/`       | Entities + abstract repository/use-case interfaces        |
| `data/`         | API client calls, DTO mapping, repository implementations |
| `presentation/` | Widgets, Pages, ViewModels (Cubits/Providers)             |

---

## 📝 Code Standards

- **Go:** Follow standard Go conventions (`gofmt`, `golint`). All new use-case logic must have unit tests.
- **Flutter:** Run `flutter analyze` before committing. No suppressed lints without explanation.
- **API changes:** Update `openapi/swagger.yaml` **first**, then implement backend, then regenerate the Dart client.
- **Commits:** Use conventional commit format — `feat:`, `fix:`, `chore:`, `docs:`, `test:`.

---

## 🌲 Branching & PR Rules

| Branch type     | Pattern                       | Notes                                                    |
| --------------- | ----------------------------- | -------------------------------------------------------- |
| Backend feature | `feature/backend/<name>`      | Scope to one use-case or layer                           |
| Mobile feature  | `feature/mobile/<name>`       | Scope to one screen or feature                           |
| API contract    | `feature/api-contract/<name>` | Must be reviewed by both teams                           |
| Bug fix         | `fix/<scope>/<name>`          | Reference audit ID (e.g. `fix/backend/C1-expiry-notify`) |

**PR Requirements:**

- All Go tests pass (`go test -race ./...`).
- Flutter analyzer clean (`flutter analyze`).
- PRs touching `openapi/` must be reviewed by both Backend and Mobile teams.
- Link to a GitHub Issue or audit finding (e.g. `Closes #12` or `Fixes C1`).

---

## 🐛 Reporting Bugs

Use GitHub Issues. Include:

- Backend logs: `docker-compose logs backend`
- Flutter console output (copy the full stack trace)
- Steps to reproduce
- Expected vs actual behaviour
