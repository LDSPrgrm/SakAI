# SakAI Tech Stack

Here is the comprehensive breakdown of the technology stack utilized in the **SakAI** ride-hailing project. This stack has been strategically chosen to provide an optimal balance of performance, scalability, development speed, and maintainability.

## 📱 Mobile Platforms (Client Apps)

- **Framework:** Flutter
- **Language:** Dart
- **Architecture Pattern:** Clean Architecture (Domain, Data, Presentation layers) combined with MVVM for UI state management.
- **Role:** Used to build both the Passenger app and the Driver app from a unified, cross-platform codebase ensuring decoupled business logic and UI.

## 🧱 Backend Infrastructure

- **Language:** Go (Golang)
- **Web Framework:** Gin
- **Architecture Pattern:** Clean Architecture (Handler -> UseCase -> Repository)
- **Data Transfer Design:** Strict separation via DTO (Data Transfer Object) mapping ensures internal domain models are completely isolated from API contracts.
- **Testing Approach:** Test-Driven Development (TDD) leveraging `go.uber.org/mock` for dependency injection and automated mock generation.
- **Role:** High-performance, highly concurrent processing for ride-matching, authentication, REST requests, and business logic execution.

## 🗄️ Database & Spatial Processing

- **RDBMS:** PostgreSQL
- **Geospatial Extension:** PostGIS
- **Role:** Permanent source of truth for users, drivers, vehicles, rides, and complex geospatial queries (e.g., finding the nearest available drivers using actual geographic coordinates).

## 🚀 Caching & In-Memory Data

- **Software:** Redis
- **Use Cases:**
  - Lightning-fast driver status availability.
  - Caching active, real-time geographic locations.
  - Pub/Sub message broker for dispatching live events.
- **Role:** Offloads immense read/write pressure from PostgreSQL, absorbing the intense heartbeat of real-time location updates.

## 🔌 Real-Time Communications

- **Protocol:** WebSockets
- **Role:** Enables bi-directional, persistent connections between the drivers/riders and the server. Crucial for live location streaming and instant status updates (e.g., "Driver has arrived").

## 📄 API Contracts & Definitions

- **Specification:** OpenAPI (Swagger)
- **Role:** Serves as the ultimate layout for REST APIs. Ensures both backend models and mobile frontend clients agree on data structures. Allows code generation for API clients to eradicate manual boilerplate and bugs.

## 🧮 Administrative Web App (To-Be)

- **Framework Options:** React or Vue.js
- **Role:** Web dashboard for system operation tools, driver approvals, analytics, and business insights.

## 📦 Deployment & Containerization

- **Tooling:** Docker & Docker Compose
- **Role:** Guarantees localized development consistency. Backend, Postgres, and Redis are bundled into localized containers, easily replicable in a cloud-computing production environment (like AWS/GCP Kubernetes clusters).
