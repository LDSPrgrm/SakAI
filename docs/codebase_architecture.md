# SakAI Codebase Structure and Architecture

Based on the current state of the repository, here is a high-level and comprehensive description of the **SakAI** codebase and its architectural structure. The project is designed as a modern, scalable ride-hailing system.

## 🌟 High-Level Architecture Overview

The **SakAI** codebase follows a **Monorepo** structure. It cleanly separates the backend services, database migrations, API contracts, mobile applications, and administrative dashboards into their respective modules.

The core technology stack consists of:

- **Backend:** Go (Golang) powered by the Gin framework (Clean Architecture).
- **Mobile Apps:** Flutter (Cross-platform) using Clean Architecture (Domain, Data, Presentation) and MVVM.
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

- **`cmd/`**: Contains the entry points for the application (e.g., `cmd/api/main.go` starts the server).
- **`configs/`**: Handles environment configurations.
- **`pkg/`**: Stores shared middleware (like Authentication, Logging, CORS, and Rate Limiting) and utilities that can be imported by different internals.
- **`internal/`**: The core application logic.
  - **`domain/`**: The very core. Defines business objects (`driver.go`, `ride.go`) AND the interfaces (ports) for repositories and usecases (`ports.go`). This ensures strict dependency inversion — all other layers depend on domain, not on each other.
  - **`usecase/`**: Holds the pure business logic and rules for ride matching, user management, etc. It implements the interfaces defined in the domain layer.
  - **`repository/`**: Handles data access (PostgreSQL/Redis adapters). It implements the repository interfaces defined in the domain layer.
  - **`delivery/`**: Exposes the backend to the outside world. Divided into:
    - `http/` for standard REST APIs (using Gin handlers).
      - `dto/` for Data Transfer Objects, ensuring pure domain entities are not leaked to the API and handling validation and response mapping.
    - `ws/` for WebSocket handlers dealing with real-time location and event updates.
    - `infrastructure/` mapping background workers (like expiry workers) or external systems.

### 2. `migrations/` (Database State Management)

Contains raw SQL scripts that define the PostgreSQL schema and PostGIS dependencies.

- Includes sequential rollouts like `001_create_users.sql`, `002_create_vehicles.sql`, `create_drivers`, `create_rides`, and adding active ride constraints.
- This approach ensures deterministic database structures, critical for spatial data management (tracking lat/lng locations accurately).

### 3. `openapi/` (The API Contract)

Contains `swagger.yaml` which defines every REST API endpoint, request payloads, and response data structures.

- Acts as the binding agreement between the frontend and the backend.
- Allows you to automatically generate Dart API clients for the Flutter app, guaranteeing that the mobile apps are perfectly in sync with the Go backend API.

### 4. `mobile/` (The Flutter Client Apps)

Intended to store the cross-platform Dart code using Flutter. It is split into:

- **`passenger/`**: The app used by riders to track ETA, request rides, and see prices.
- **`driver/`**: The app used by drivers to navigate, accept ride assignments, and manage availability.
- **`shared/`**: Contains the generated API client, shared mobility models (Ride, User), and utilities common across both applications to avoid rewriting similar logic.

Both `passenger/` and `driver/` apps strictly adhere to **Clean Architecture** combined with MVVM for the presentation layer. Inside each app's `lib/` folder, you will find:

- **`domain/`**: Enterprise logic, including core Entities and abstract Repository/UseCase interfaces (no dependency on Flutter/UI).
- **`data/`**: Implementations of the repositories, API clients (data sources), and DTO mapping.
- **`presentation/`**: UI components (Widgets, Pages) and state management (ViewModels/Cubits/Providers).

### 5. `admin/` (Operations Web App)

Reserved for the web-based administrative dashboard (React/Vue). This module will consume secured, versioned backend APIs to manage driver approvals, view analytics, and handle dispute resolutions.

### 6. `docs/` & Project Files

- **`docs/`**: Includes historical session logs, the `roadmap.md`, and system audit reports.
- **`overview.md`**: The main README essentially, containing the architectural reasoning above and instructions for scaling the microservices as they grow.

---

## 🧠 Strategic System Flows

1.  **Standard API Flow:** A mobile request hits the `delivery/http` (Gin Route) ➡️ Validated through a the `dto` layer (Data Transfer Object) ➡️ Passed to `usecase` (Business logic interface) ➡️ Interacts with `repository` interface ➡️ Queries PostgreSQL (via adapter) ➡️ Mapped back through `dto` ➡️ Returns response.
2.  **Real-Time Flow:** A driver's mobile app sends a stream of location coordinates to a `delivery/ws` (WebSocket connection) ➡️ It gets published to Redis (Pub/Sub) ➡️ The exact location gets broadcasted to the passenger's connected WebSocket.
3.  **Hot Data Management:** Postgres acts as the ultimate permanent source of truth, while **Redis** acts as an intermediary for ultra-fast cache loops (e.g., fetching a driver's instantaneous status or handling active connection tokens).
