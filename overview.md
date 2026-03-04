# Project Status

> **Latest Session:** [Backend Hardening](docs/sessions/20260219-backend-hardening.md) | **Audit Report:** [System Audit](docs/system_audit.md) | **Roadmap:** [docs/roadmap.md](docs/roadmap.md)

---

🚀 Tech Stack Overview

For a modern, scalable ride-hailing app you’ve chosen:

Mobile (Cross-platform): Flutter

Backend Framework: Gin

Database: PostgreSQL (with PostGIS for geospatial queries)

API Contract: OpenAPI / Swagger for API definition & client code generation

Real-time: WebSockets for live location and ride updates

Mobility Logic: Designed for high concurrency and geospatial proximity matching

This stack balances performance, scalability, maintainability, and productivity.

📦 Monorepo Structure (Recommended)
myapp/
├── backend/ # Go + Gin backend services
│ ├── cmd/api/main.go
│ ├── internal/
│ │ ├── domain/ # Core business objects and interfaces (ports)
│ │ │ └── mocks/ # Generated mocks for unit testing
│ │ ├── repository/ # DB implementations (Postgres/PostGIS adapters)
│ │ ├── usecase/ # Business logic and use case implementations
│ │ ├── delivery/
│ │ │ ├── http/ # REST APIs and Gin handlers
│ │ │ │ └── dto/ # Data Transfer Objects (Request/Response mapping)
│ │ │ └── ws/ # WebSockets for real-time
│ │ └── infrastructure/ # Background workers and utilities
│ ├── pkg/middleware/ # auth, logging, CORS, rate limiting
│ └── configs/ # environment configs
│
├── migrations/ # PostgreSQL / PostGIS migrations
├── openapi/ # swagger.yaml (API contract)
│
├── mobile/ # Flutter apps + shared models/client
│ ├── passenger/ # Passenger Flutter app
│ │ └── lib/
│ │ ├── domain/ # Core entities, use cases, repo interfaces
│ │ ├── data/ # API clients, DTOs, repo implementations
│ │ └── presentation/ # UI views and ViewModels
│ ├── driver/ # Driver Flutter app
│ │ └── lib/
│ │ ├── domain/
│ │ ├── data/
│ │ └── presentation/
│ └── shared/ # Shared API client + models
│
├── admin/ # Web admin dashboard (React/Vue)
├── scripts/ # Client generation, DB migrate scripts
├── docker-compose.yml # Backend + Postgres + Redis
├── Dockerfile # Backend container
└── README.md

🧠 Why This Structure Works
📱 Frontends

You ship:

You ship:

Passenger mobile app – for riders

Driver mobile app – for drivers

Admin dashboard web app – for operations and analytics

Each mobile app adheres to **Clean Architecture** (separating `domain`, `data`, and `presentation` layers) utilizing MVVM for UI state. They communicate via a strongly typed API client generated from your OpenAPI spec. This keeps business logic completely decoupled from Flutter widgets.

🧍 Shared Code

A shared Flutter package holds:

API client generated from swagger.yaml

Shared models (Ride, User, Payment)

Utilities common to all apps

This avoids duplication and ensures consistency.

🧠 OpenAPI / Swagger

Your openapi/swagger.yaml defines all REST API endpoints and data contracts.
You generate:

Go server stubs (optional)

Dart API client used by Flutter MVVM repositories

This keeps both backend and frontend in sync without guessing field names or response formats.

🗺 Real-Time + Ride Logic

A ride-hailing system needs:

🚘 Real-Time Features

Continuous driver location updates

Live matching and ETA updates

Ride status transitions (requested → accepted → en route → complete)

## Current State

The SakAI project is currently in the **Development Phase**.

**Backend (MVP-Ready):**

- **Architecture**: Fully migrated to Clean Architecture.
- **API**: Contracts defined via OpenAPI (`openapi/swagger.yaml`).
- **Database**: PostgreSQL with PostGIS configured via migration scripts.
- **Real-Time**: WebSocket Hub implemented with a highly scalable cluster-ready Redis Pub/Sub Dispatcher.
- **Logic**: Auth, Ride, and Driver UseCases implemented with complete unit test coverage. Go backend builds and tests cleanly.
- **Docker**: Local `docker-compose.yml` available for bringing up PostGIS and Redis for API development.

**Mobile Apps:**

- Project boilerplate initialized for both Passenger and Driver apps (`passenger_app/`, `driver_app/`).

Driver locations (lat/lng) updated often

Spatial queries to find nearby drivers efficiently

Geo data stored via PostGIS drastically improves geospatial search performance .

🧠 Caching and Hot Data

Since driver locations and availability change rapidly:

Use Redis for:

Driver status

Real-time location caching

Pub/Sub for events

Redis keeps hot data out of Postgres, reducing database load.

🧮 Admin Dashboard

You also have a web-based admin dashboard (typically React or Vue) that:

Manages drivers, users, routes

Views analytics and ride history

Handles dispute resolution and payments

Admin consumes backend APIs (versioned and secured via RBAC).

🧪 Why Two Mobile Apps?

Ride-hailing isn’t one-size-fits-all:

Passenger app — shows prices, requests rides, tracks driver

Driver app — sees ride assignments, navigates to pickup/drop-off

Both have distinct workflows and UIs. Having two apps maximizes clarity and keeps ViewModel logic clean.

🧠 Tips for Success
📊 Versioning

Keep API versioned (e.g., /api/v1/...) so new features don’t break old apps.

🔐 Auth

Use JWT with role-based access control and expiration.

📈 Workloads

Separate REST traffic from real-time WebSocket traffic so neither blocks the other.

📦 Docker & CI/CD

Containerize and use docker-compose locally. In production, orchestrate with Kubernetes or managed cloud services.

🤖 Scalability & Production Readiness

A system like this can grow into:

Microservices (auth, ride matching, payments, notifications)

API Gateway + rate limiting

Observability & metrics

Horizontal scaling and fault tolerance

Many companies build each module as an independent service for separation and resilience
