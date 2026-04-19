# SakAI Codebase Structure and Architecture

Based on the current state of the repository, here is a high-level and comprehensive description of the **SakAI** codebase and its architectural structure. The project is designed as a modern, scalable ride-hailing system.

## 🌟 High-Level Architecture Overview

The **SakAI** codebase follows a **Monorepo** structure. It cleanly separates the backend services, database migrations, API contracts, mobile applications, and administrative dashboards into their respective modules.

The core technology stack consists of:

- **Backend:** Go (Golang) powered by the Gin framework (Clean Architecture).
- **Mobile Apps:** Flutter (Cross-platform) using feature-first MVVM (Hungrimind pattern).
- **Database:** PostgreSQL with PostGIS for high-performance geospatial queries.
- **Caching & Fast Data:** Redis (for driver status, live locations, and Pub/Sub event distribution).
- **Real-time Features:** WebSockets for live driver/rider location tracking and ride status updates.
- **API Contract:** OpenAPI (Swagger) serving as the single source of truth for all client-to-server interactions.

---

## 📂 Directory Structure Breakdown

```text
SakAI/
├── backend/       # Go + Gin backend services
├── migrations/    # PostgreSQL SQL migration files
├── openapi/       # API contract definition
├── mobile/        # Flutter mobile applications
├── admin/         # Web admin dashboard
├── docs/          # Project documentation & session logs
├── scripts/       # Automation and deployment scripts
└── overview.md    # High-level architecture and status document
```

### 1. `backend/` (The Go Backend Services)

The backend is built with **Go** and uses **Gin** for routing. It strictly follows a **Clean Architecture** pattern to ensure testability and separation of concerns:

- **`cmd/`**: Contains the entry points for the application.
  - `cmd/api/` — Main server entry point (`main.go` starts the HTTP + WebSocket server).
  - `cmd/seed-admin/` — CLI tool to bootstrap the first `superadmin` account.
- **`configs/`**: Handles environment-based configuration loading (`.env` files, defaults, validation).
- **`pkg/`**: Shared utilities that can be imported across internal layers.
  - `jwt/jwt.go` — JWT token generation, parsing, and validation.
  - `testutil/fixtures.go` — Test helpers and fixtures.
  - *(Note: Middleware was moved to `internal/delivery/http/middleware/`.)*
- **`internal/`**: The core application logic.
  - **`domain/`** (10 files): The very core. Defines business entities AND the interfaces (ports) for repositories and usecases. Zero external dependencies.
    - `admin.go`, `audit.go`, `driver.go`, `errors.go`, `incident.go`, `location.go`, `ports.go`, `ride.go`, `user.go`, `vehicle.go`
  - **`usecase/`** (13 files): Holds the pure business logic and rules. Implements domain interfaces.
    - `admin_usecase.go`, `auth_usecase.go` (+ test), `driver_usecase.go` (+ test), `metrics_usecase.go`, `payment_usecase.go`, `report_usecase.go`, `ride_usecase.go` (+ test), `role_usecase.go`, `safety_usecase.go`, `system_usecase.go`
  - **`repository/`** (10 files): Handles data access via PostgreSQL/Redis adapters. Implements domain repository interfaces.
    - `admin_repo.go`, `driver_repo.go`, `metrics_repo.go`, `payment_repo.go`, `report_repo.go`, `ride_repo.go`, `role_repo.go`, `safety_repo.go`, `system_repo.go`, `user_token_repo.go`
  - **`delivery/`**: Exposes the backend to the outside world.
    - `http/` — REST API handlers (10 handlers):
      - `admin_handler.go`, `auth_handler.go`, `driver_handler.go`, `metrics_handler.go`, `payment_handler.go`, `report_handler.go`, `ride_handler.go`, `role_handler.go`, `safety_handler.go`, `system_handler.go`
      - `dto/` — Data Transfer Objects (4 files: `admin_dto.go`, `auth_dto.go`, `driver_dto.go`, `ride_dto.go`) for request/response mapping.
      - `middleware/` — HTTP middleware (3 files: `auth.go`, `rate_limit.go`, `security.go`).
      - `router/` — Gin route registration and middleware wiring.
      - `response.go` — Shared response helpers.
    - `ws/` — WebSocket handlers (3 files: `handler.go`, `hub.go`, `redis_dispatcher.go`).
  - **`infrastructure/`**: Background workers and database connectivity.
    - `database/` — PostgreSQL connection setup, migration execution, transaction helpers (`postgres.go`, `migrate.go`, `tx.go`).
    - `expiry/` — Background worker for stale ride offer cleanup (`worker.go`).

### 2. `migrations/` (Database State Management)

Contains raw SQL scripts that define the PostgreSQL schema and PostGIS dependencies. Currently **10 migration files** (001–010):

- `001_create_users.up.sql` — User accounts table.
- `002_create_vehicles.up.sql` — Vehicle information table.
- `003_create_drivers.up.sql` — Driver profiles with PostGIS location column.
- `004_create_rides.up.sql` — Ride lifecycle table with state machine.
- `005_create_refresh_tokens.up.sql` — JWT refresh token storage.
- `006_add_active_ride_constraints.up.sql` — Partial unique index preventing duplicate active rides.
- `007_add_admin_roles.up.sql` — Admin role schema.
- `008_super_admin_schema.up.sql` — Superadmin capabilities.
- `009_create_roles.up.sql` — General RBAC roles table (+ down migration).
- `010_add_role_id_to_users.up.sql` — Links users to RBAC roles (+ down migration).

Migrations are embedded into the Go binary via `go:embed` and executed automatically at server startup.

### 3. `openapi/` (The API Contract)

Contains `swagger.yaml` which defines every REST API endpoint, request payloads, and response data structures.

- Acts as the binding agreement between the frontend and the backend.
- Allows you to automatically generate Dart API clients for the Flutter app, guaranteeing that the mobile apps are perfectly in sync with the Go backend API.

### 4. `mobile/` (The Flutter Client Apps)

Intended to store the cross-platform Dart code using Flutter. It is split into:

- **`passenger/`**: The app used by riders to track ETA, request rides, and see prices.
- **`driver/`**: The app used by drivers to navigate, accept ride assignments, and manage availability.
- **`shared/`**: Contains the generated API client, shared mobility models (Ride, User), and utilities common across both applications to avoid rewriting similar logic.

Both `passenger/` and `driver/` apps follow a **feature-first MVVM (Hungrimind)** structure. Inside each app's `lib/` folder:

- **`features/<feature>/models/`**: Feature entities/value objects/exceptions; keep UI concerns out.
- **`features/<feature>/repositories/`**: Repository contracts and implementations side-by-side; API client calls and mapping live here (including service classes like `GeocodingService`).
- **`features/<feature>/view_models/`**: `ChangeNotifier` state/action orchestrators for views.
- **`features/<feature>/views/`**: Widgets/screens only.
- **`app/`**: Root widget only (theme + routing entry, no business logic).

#### MVVM Layer Rules (Hungrimind)

| Rule | Detail |
|---|---|
| **1 View : 1 ViewModel** | Every screen has exactly one `*_view_model.dart` |
| **ViewModel = `ChangeNotifier`** | Exposes state via getters; calls `notifyListeners()` on changes |
| **View = `ListenableBuilder`** | All reactive rebuilds via `ListenableBuilder(listenable: vm, ...)` |
| **Constructor injection** | Repositories/services injected into VM constructor; never instantiated inside VM |
| **No UI in ViewModel** | No `BuildContext`, no `Navigator`, no widget types |
| **No business logic in View** | Views call VM methods; they do NOT call repositories directly |
| **No raw network in widgets** | All HTTP stays in `features/*/repositories/`; views read from VM |
| **Navigation stays in View** | Routing decisions happen in `_onVmChanged()` listener or in action handlers, not in VM |

### 5. `admin/` (Operations Web App)

Reserved for the web-based administrative dashboard (React/Vue). This module will consume secured, versioned backend APIs to manage driver approvals, view analytics, and handle dispute resolutions.

### 6. `docs/` & Project Files

- **`docs/`**: Includes historical session logs, the `roadmap.md`, system audit reports, and **agent-oriented** references: [`agent_playbook.md`](agent_playbook.md), [`agent_context.json`](agent_context.json) (machine-readable). Repo root [`AGENTS.md`](../AGENTS.md) indexes these for tools.
- **`overview.md`**: The main README essentially, containing the architectural reasoning above and instructions for scaling the microservices as they grow.

---

## 🧠 Strategic System Flows

1.  **Standard API Flow:** A mobile request hits the `delivery/http` (Gin Route) ➡️ Validated through a the `dto` layer (Data Transfer Object) ➡️ Passed to `usecase` (Business logic interface) ➡️ Interacts with `repository` interface ➡️ Queries PostgreSQL (via adapter) ➡️ Mapped back through `dto` ➡️ Returns response.
2.  **Real-Time Flow:** A driver's mobile app sends a stream of location coordinates to a `delivery/ws` (WebSocket connection) ➡️ It gets published to Redis (Pub/Sub) ➡️ The exact location gets broadcasted to the passenger's connected WebSocket.
3.  **Hot Data Management:** Postgres acts as the ultimate permanent source of truth, while **Redis** acts as an intermediary for ultra-fast cache loops (e.g., fetching a driver's instantaneous status or handling active connection tokens).
