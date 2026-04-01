# SakAI Project Roadmap

> **Last Updated:** 2026-03-05 | **Status:** Phase 2 in progress

This roadmap is structured around two key milestones:

- **MVP (Phases 1–4):** A fully working ride-hailing system end-to-end — passenger requests a ride, driver accepts, ride completes — with mobile apps and a basic admin dashboard.
- **Functional App (Phases 5–6):** Reliability, polish, and real-world readiness.
- **Production (Phase 7):** Scale, observability, and deployment.

---

## 🚀 Phase 1: Backend Foundation ✅

> **Status:** Complete

- [x] Project scaffolding (Go + Gin + Postgres + PostGIS)
- [x] Clean Architecture structure (Domain → UseCase → Repository → Delivery)
- [x] Database schema & migrations (users, vehicles, drivers, rides, refresh_tokens, active ride constraints)
- [x] Domain models (User, Ride, Driver, Vehicle, Location)
- [x] Auth system (JWT access tokens, refresh token rotation, logout)
- [x] Core ride flow (Request, Accept, Decline, Arrive, Start, Complete, Cancel)
- [x] Ride state machine with `CanTransitionTo` guard
- [x] Idempotency keys on ride requests
- [x] WebSocket hub with event broadcasting
- [x] Background expiry worker for stale ride offers
- [x] OpenAPI/Swagger spec (comprehensive — 1300+ lines)
- [x] Unit tests for auth, driver, and ride use cases

---

## 🛡️ Phase 2: Security & Bug Fixes (Current)

> **Goal:** Address system audit findings to make the backend safe for real client connections.

### ✅ Completed

- [x] Race condition fix — DB partial index for `RequestRide`
- [x] `Decline` properly clears `driver_id` (ClearDriver)
- [x] Driver location updates sent only to the correct passenger
- [x] Vehicle data included in driver responses
- [x] Self-healing background worker for ride offer expiry
- [x] LatLng validation bounds checks
- [x] Auth rate limiting (10 rpm / IP)
- [x] `FindNearbyOnline` limited to 1 closest driver
- [x] Transactional user registration (`CreateWithTokens`)
- [x] JWT weak-secret panic guard for production
- [x] Logging for critical async failures

### 🚧 To Do — Critical (Blocks Phase 3 / MVP)

> These must be completed before Flutter mobile development begins.

- [ ] **C1:** Notify passenger via WebSocket when offer expires — inject Hub into expiry worker, emit `ride.offer_expired` ([REQ-2.1](requirements.md#req-21-expired-offer-passenger-notification))
- [ ] **C2:** Exclude drivers with active rides from `FindNearbyOnline` — add `NOT EXISTS` subquery ([REQ-2.2](requirements.md#req-22-exclude-busy-drivers-from-matching))
- [ ] **L3:** `GetByID` — verify caller is ride participant, return `403` otherwise ([REQ-2.3](requirements.md#req-23-ride-participant-authorization))
- [ ] **H4:** Request body size limit middleware (`MaxBytesReader`, 1 MiB) ([REQ-2.4](requirements.md#req-24-request-body-size-limit))
- [ ] **SC1:** Add GIST index on `drivers.location` column (new migration `007_...`) ([REQ-2.5](requirements.md#req-25-geospatial-index))

### 🚧 To Do — High (Important but not blocking MVP)

- [ ] **H1:** Delete dead `SendToDriver` alias from `hub.go` ([REQ-2.6](requirements.md#req-26-remove-dead-code))
- [ ] **H2:** WebSocket read deadlines & read limit (`SetReadDeadline`, `SetReadLimit`) ([REQ-2.7](requirements.md#req-27-websocket-connection-hardening))
- [ ] **H3:** Embed migrations into binary (`go:embed`) ([REQ-2.8](requirements.md#req-28-embedded-migrations))
- [ ] **H5:** Wrap refresh token rotation in a DB transaction ([REQ-2.9](requirements.md#req-29-transactional-token-rotation))
- [ ] **L1:** Server-side re-dispatch after driver decline
- [ ] **L2:** Cancel — enforce per-role state validation ([REQ-2.10](requirements.md#req-210-cancel-role-enforcement))
- [ ] **S1:** Config-driven WebSocket allowed origins ([REQ-2.11](requirements.md#req-211-config-driven-websocket-origins))
- [ ] **S3:** Security headers middleware (X-Frame-Options, CSP, etc.) ([REQ-2.12](requirements.md#req-212-security-headers-middleware))
- [ ] **D2:** Verify FK cascade on `refresh_tokens.user_id`

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

> **Goal:** Basic web dashboard for operational visibility. Lightweight — enough to manage the MVP.

- [ ] Choose framework (React or Vue.js)
- [ ] Auth flow (admin-only role or super-user JWT)
- [ ] **Dashboard overview:** Active rides count, online drivers count, total users
- [ ] **Ride list:** Searchable table with status filters, ride details view
- [ ] **User list:** Browse passengers and drivers, view profiles
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

| Phase | Name                 | Focus            | Status         |
| ----- | -------------------- | ---------------- | -------------- |
| 1     | Backend Foundation   | Core API         | ✅ Complete    |
| 2     | Security & Bug Fixes | Audit fixes      | 🚧 In Progress |
| 3     | Flutter Mobile Apps  | Client apps      | ⬜ Not Started |
| 4     | Admin Dashboard      | Operations UI    | ⬜ Not Started |
| —     | **MVP Milestone**    | **End-to-end**   | —              |
| 5     | Real-Time Resilience | WS reliability   | ⬜ Not Started |
| 6     | Polish & UX          | Production UX    | ⬜ Not Started |
| 7     | Production Readiness | Deploy & operate | ⬜ Not Started |
