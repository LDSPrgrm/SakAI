# SakAI Project Roadmap

> **Last Updated:** 2026-04-11 | **Status:** Phase 2 nearly complete — 3 items remaining

This roadmap is structured around two key milestones:

- **MVP (Phases 1–4):** A fully working ride-hailing system end-to-end — passenger requests a ride, driver accepts, ride completes — with mobile apps and a basic admin dashboard.
- **Functional App (Phases 5–6):** Reliability, polish, and real-world readiness.
- **Production (Phase 7):** Scale, observability, and deployment.

---

## 🚀 Phase 1: Backend Foundation ✅

> **Status:** Complete

- [x] Project scaffolding (Go + Gin + Postgres + PostGIS)
- [x] Clean Architecture structure (Domain → UseCase → Repository → Delivery)
- [x] Database schema & migrations (users, vehicles, drivers, rides, refresh_tokens, active ride constraints, RBAC — 10 migrations total)
- [x] Domain models (User, Ride, Driver, Vehicle, Location, Admin, Audit, Incident, Role)
- [x] Auth system (JWT access tokens, refresh token rotation, logout)
- [x] Core ride flow (Request, Accept, Decline, Arrive, Start, Complete, Cancel)
- [x] Ride state machine with `CanTransitionTo` guard
- [x] Idempotency keys on ride requests
- [x] WebSocket hub with event broadcasting + Redis Pub/Sub dispatcher
- [x] Background expiry worker for stale ride offers (emits `ride.offer_expired` via dispatcher)
- [x] OpenAPI/Swagger spec (comprehensive — 3400+ lines, 66 endpoints across 6 tags)
- [x] Unit tests for auth, driver, and ride use cases
- [x] Admin backend APIs (~49 endpoints: users, fares, surge, incidents, payments, reports, metrics, roles, safety/KYC, system config)
- [x] Metrics, payment, report, role, and safety use-cases, repositories, and handlers

---

## 🛡️ Phase 2: Security & Bug Fixes

> **Goal:** Address system audit findings to make the backend safe for real client connections.

### ✅ Completed (13 of 16)

- [x] Race condition fix — DB partial index for `RequestRide`
- [x] `Decline` properly clears `driver_id` (ClearDriver)
- [x] Driver location updates sent only to the correct passenger
- [x] Vehicle data included in driver responses
- [x] Self-healing background worker for ride offer expiry (emits `ride.offer_expired` via Redis dispatcher)
- [x] LatLng validation bounds checks
- [x] Auth rate limiting (10 rpm / IP)
- [x] `FindNearbyOnline` limited to 1 closest driver
- [x] Transactional user registration (`CreateWithTokens`)
- [x] JWT weak-secret panic guard for production
- [x] Logging for critical async failures
- [x] `GetByID` — verifies caller is ride participant (passenger or assigned driver), returns `403 Forbidden` otherwise
- [x] Request body size limit middleware (`MaxBodySize`, 1 MiB)
- [x] Security headers middleware (X-Frame-Options: DENY, X-Content-Type-Options: nosniff, CSP: default-src 'self')
- [x] Cancel — enforces per-role state validation (passenger/driver ownership checks)
- [x] GiST index on `drivers.location` column (present in `003_create_drivers.up.sql`)
- [x] Admin backend with RBAC (~49 endpoints defined in spec with handler/usecase/repo implementations)

### 🚧 To Do — High (Important but not blocking MVP)

- [ ] **H2:** WebSocket read deadlines & read limit (`SetReadDeadline`, `SetReadLimit`, `PongHandler`) ([REQ-2.7](requirements.md#req-27-websocket-connection-hardening))
- [ ] **H3:** Embed migrations into binary (`go:embed`) to avoid path-resolution issues ([REQ-2.8](requirements.md#req-28-embedded-migrations))
- [ ] **H5:** Wrap refresh token rotation in a DB transaction (`Transact` around `Delete` + `Store`) ([REQ-2.9](requirements.md#req-29-transactional-token-rotation))

### ℹ️ Deferred / Mitigated

- ~~**H1:** Delete dead `SendToDriver` alias~~ — Alias is still present but documented as intentional convenience method; low risk. Can be cleaned up opportunistically.
- ~~**L1:** Server-side re-dispatch after driver decline~~ — Passenger client re-calls `POST /rides` with same idempotency key as mitigation. Auto re-dispatch deferred to Phase 5.
- ~~**S1:** Config-driven WebSocket allowed origins~~ — `CheckOrigin: true` is acceptable for mobile-only clients (no browser CSRF vector). Should be revisited if a web admin dashboard is built.
- ~~**D2:** Verify FK cascade on `refresh_tokens.user_id`~~ — Migration `005_create_refresh_tokens.up.sql` includes FK constraint; verified.

---

## 📱 Phase 3: Flutter Mobile Apps (MVP-Critical)

> **Goal:** Build working Passenger and Driver apps that connect to the backend.

### Shared Module (`mobile/shared/`)

- [ ] Dart API client generated from OpenAPI spec
- [ ] Shared models (User, Ride, Driver, Vehicle, Location)
- [ ] Shared utilities (token storage, auth interceptor, error handling)
- [ ] WebSocket client wrapper (connect, auto-reconnect, event parsing)
- [ ] Shared theme / design tokens

### Passenger App (`mobile/passenger/`)

- [ ] **Auth screens:** Login, registration (email/password)
- [ ] **Home screen:** Map view with current location
- [ ] **Ride request flow:** Set pickup/destination → confirm → ride requested
- [ ] **Waiting state:** Show "Finding driver…" with expiry handling
- [ ] **Active ride screen:** Real-time driver location on map, ride status updates
- [ ] **Ride complete screen:** Trip summary
- [ ] **Ride cancellation:** Cancel button during appropriate states
- [ ] **Reconnection:** Restore active ride on app reopen (`GET /rides/active`)

### Driver App (`mobile/driver/`)

- [ ] **Auth screens:** Login, registration with vehicle info
- [ ] **Online/Offline toggle:** Set driver availability status
- [ ] **Location streaming:** Send GPS coordinates to backend (every 3–5 sec)
- [ ] **Incoming ride screen:** Accept / Decline ride offer with timer
- [ ] **Active ride flow:** Navigate to passenger → Arrive → Start → Complete
- [ ] **Ride state display:** Show pickup/destination addresses and passenger info
- [ ] **Reconnection:** Restore active ride on app reopen

### Definition of Done — Phase 3

> A passenger can register, request a ride, see a driver accept, track the driver in real-time, and see the ride complete. A driver can register with a vehicle, go online, accept a ride, navigate through the state machine, and complete the ride.

---

## 🖥️ Phase 4: Admin Dashboard (MVP Baseline)

> **Goal:** Basic web dashboard for operational visibility. Backend APIs are defined in the OpenAPI spec (~49 endpoints) with handler/usecase/repo implementations in place.

- [ ] Choose framework (React or Vue.js — TBD)
- [ ] Auth flow (admin-only role or super-user JWT)
- [x] **Backend APIs:** All admin endpoints defined in OpenAPI spec and implemented (users CRUD, fares, surge, incidents, rides list, passengers, drivers, payments, metrics, roles, safety/KYC, reports, system config)
- [ ] **Dashboard overview:** Active rides count, online drivers count, total users
- [x] **Ride list:** Searchable table with status filters, ride details view (Backend Done)
- [x] **User list:** Browse passengers and drivers, view profiles (Backend Done)
- [ ] **Driver management:** Approve/suspend drivers, view vehicle info

### Definition of Done — Phase 4

> An admin can log in, see real-time operational stats, browse rides and users, and manage driver status.

---

## ⬆️ MVP Milestone

> At this point, the system is a **working ride-hailing MVP:**
>
> - Backend handles the full ride lifecycle with auth and real-time events.
> - Passenger and Driver mobile apps are functional and connected.
> - Admin has basic visibility into the platform.
> - Critical bugs and security issues from the audit are resolved.

---

## 🔌 Phase 5: Real-Time Resilience & Reliability

> **Goal:** Make WebSocket communication reliable for production-grade mobile usage.

- [ ] **Event replay:** `ride_events` table + `GET /rides/:id/events?since=<seq>` for reconnection replay
- [ ] **Graceful eviction:** Send `CloseMessage` to old connection before replacing
- [ ] **Slow consumer protection:** Buffer overflow handling with event replay fallback
- [ ] **Redis Pub/Sub:** Multi-instance WebSocket support (horizontally scalable hub)
- [ ] **Message ordering:** Sequence numbers on events
- [ ] **Client heartbeat:** Mobile-side ping/reconnect logic

---

## ✨ Phase 6: Polish & UX

> **Goal:** Make the app feel production-quality for end users.

### Backend

- [ ] Structured error codes (standardize `{code, field, message}` format)
- [ ] Pagination on list endpoints (cursor-based)
- [ ] Ride history endpoint (`GET /rides?status=completed&page=...`)
- [ ] Driver earnings summary endpoint
- [ ] Push notification integration (Firebase Cloud Messaging)
- [ ] Fare estimation endpoint
- [ ] Fare calculation on ride completion

### Mobile

- [ ] Push notifications (ride accepted, driver arrived, ride completed)
- [ ] Ride history screen (past trips)
- [ ] Profile editing (name, phone)
- [ ] In-app fare display and estimation
- [ ] Loading states, skeleton screens, error states
- [ ] Offline handling and graceful degradation
- [ ] App icon, splash screen, onboarding

### Admin

- [ ] Real-time ride monitoring (live map)
- [ ] Ride analytics (daily volume, avg duration, completion rate)
- [ ] User/driver search and dispute handling
- [ ] Export data (CSV)

---

## 🏭 Phase 7: Production Readiness

> **Goal:** Deploy and operate at scale.

- [ ] CI/CD pipeline (Go tests, Flutter analyzer, Docker build)
- [ ] Dockerfile for backend (multi-stage build)
- [ ] Kubernetes manifests or cloud deployment config
- [ ] Environment-based config management (staging / production)
- [ ] Logging aggregation (structured JSON logs → ELK or Loki)
- [ ] Metrics and monitoring (Prometheus + Grafana)
- [ ] Database backups and recovery plan
- [ ] Load testing (k6 or similar)
- [ ] SSL/TLS termination
- [ ] Rate limiting on all public endpoints

---

## Summary Table

| Phase | Name                 | Focus            | Status                  |
| ----- | -------------------- | ---------------- | ----------------------- |
| 1     | Backend Foundation   | Core API         | ✅ Complete             |
| 2     | Security & Bug Fixes | Audit fixes      | 🚧 3 items remaining    |
| 3     | Flutter Mobile Apps  | Client apps      | ⬜ Not Started          |
| 4     | Admin Dashboard      | Operations UI    | 🚧 Backend done, frontend TBD |
| —     | **MVP Milestone**    | **End-to-end**   | —                       |
| 5     | Real-Time Resilience | WS reliability   | ⬜ Not Started          |
| 6     | Polish & UX          | Production UX    | ⬜ Not Started          |
| 7     | Production Readiness | Deploy & operate | ⬜ Not Started          |
