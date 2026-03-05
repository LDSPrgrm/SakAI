# SakAI — Requirements & Acceptance Criteria

> **Version:** 1.0 | **Date:** 2026-03-05 | **Scope:** MVP (Phases 2–4)

This document defines the functional requirements, non-functional requirements, and acceptance criteria for each component of SakAI. It maps directly to the [roadmap](roadmap.md) phases and uses the [OpenAPI spec](../openapi/swagger.yaml) as the source of truth for API contracts.

---

## Table of Contents

1. [Glossary](#glossary)
2. [System Context](#system-context)
3. [Phase 2 — Security & Bug Fixes](#phase-2--security--bug-fixes)
4. [Phase 3 — Flutter Mobile Apps](#phase-3--flutter-mobile-apps)
   - [Shared Module](#31-shared-module)
   - [Passenger App](#32-passenger-app)
   - [Driver App](#33-driver-app)
5. [Phase 4 — Admin Dashboard](#phase-4--admin-dashboard)
6. [Non-Functional Requirements](#non-functional-requirements)
7. [Ride State Machine](#ride-state-machine)

---

## Glossary

| Term                | Definition                                                                            |
| ------------------- | ------------------------------------------------------------------------------------- |
| **Passenger**       | A user with `role=passenger` who requests and takes rides.                            |
| **Driver**          | A user with `role=driver` who accepts rides and provides transportation.              |
| **Ride**            | A single trip lifecycle from request to completion or cancellation.                   |
| **Offer**           | A ride in `requested` status assigned to a specific driver.                           |
| **Active Ride**     | A ride in any non-terminal status: `requested`, `accepted`, `arrived`, `in_progress`. |
| **Terminal State**  | `completed` or `cancelled` — no further transitions allowed.                          |
| **Idempotency Key** | Client-generated UUID header to prevent duplicate ride creation.                      |
| **Hub**             | In-memory WebSocket connection manager that routes events to users.                   |

---

## System Context

```
┌──────────────┐          ┌──────────────────────┐          ┌──────────────┐
│  Passenger   │◄────────►│    Go + Gin Backend   │◄────────►│    Driver     │
│  Flutter App │  REST +   │  (Clean Architecture) │  REST +   │  Flutter App │
└──────────────┘  WS       │                      │  WS       └──────────────┘
                           │  ┌────────────────┐  │
                           │  │  PostgreSQL +   │  │
                           │  │  PostGIS        │  │
                           │  └────────────────┘  │
                           │  ┌────────────────┐  │
                           │  │  Redis (cache,  │  │
                           │  │  pub/sub)       │  │
                           │  └────────────────┘  │
                           └──────────────────────┘
                                     ▲
                                     │ REST
                           ┌──────────────────┐
                           │  Admin Dashboard  │
                           │  (Web)            │
                           └──────────────────┘
```

---

## Phase 2 — Security & Bug Fixes

These are backend-only requirements derived from the [system audit](system_audit.md).

---

### REQ-2.1: Expired Offer Passenger Notification

> **Audit Ref:** C1 | **Priority:** Critical

The backend MUST notify the passenger in real-time when their ride offer expires due to timeout.

**Acceptance Criteria:**

- [ ] When the expiry worker cancels a ride, a `ride.offer_expired` WebSocket event is sent to the affected `passenger_id`.
- [ ] The event payload includes `ride_id` and `reason: "timeout"`.
- [ ] If the passenger is not connected via WebSocket, the event is silently dropped (no crash, no error).
- [ ] The expiry worker continues processing remaining expired rides even if one notification fails.

---

### REQ-2.2: Exclude Busy Drivers from Matching

> **Audit Ref:** C2 | **Priority:** Critical

The `FindNearbyOnline` query MUST exclude drivers who already have an active (non-terminal) ride.

**Acceptance Criteria:**

- [ ] The SQL query includes `AND NOT EXISTS (SELECT 1 FROM rides WHERE driver_id = d.user_id AND status NOT IN ('completed', 'cancelled'))`.
- [ ] A driver with an `accepted`, `arrived`, or `in_progress` ride is never returned by the matching query.
- [ ] Existing unit tests for `FindNearbyOnline` are updated with a test case that validates exclusion.

---

### REQ-2.3: Ride Participant Authorization

> **Audit Ref:** L3 | **Priority:** Critical

`GET /rides/:rideId` MUST verify that the requesting user is either the `passenger_id` or `driver_id` of the ride.

**Acceptance Criteria:**

- [ ] If the authenticated user is neither the passenger nor the assigned driver, the endpoint returns `403 Forbidden` with code `FORBIDDEN`.
- [ ] A ride with no assigned driver (`driver_id IS NULL`) is accessible only to the passenger.
- [ ] Unit test: User A cannot read User B's ride by UUID.

---

### REQ-2.4: Request Body Size Limit

> **Audit Ref:** H4 | **Priority:** High

All HTTP endpoints MUST enforce a maximum request body size.

**Acceptance Criteria:**

- [ ] A global Gin middleware applies `http.MaxBytesReader` with a 1 MiB limit.
- [ ] Requests exceeding the limit receive `413 Request Entity Too Large`.
- [ ] The middleware is applied before route handlers.

---

### REQ-2.5: Geospatial Index

> **Audit Ref:** SC1 | **Priority:** High

The `drivers` table MUST have a GIST index on the geospatial location column.

**Acceptance Criteria:**

- [ ] A new migration file (e.g., `007_add_driver_location_gist_index.up.sql`) creates the index.
- [ ] `EXPLAIN ANALYZE` on `FindNearbyOnline` shows an index scan, not a sequential scan.

---

### REQ-2.6: Remove Dead Code

> **Audit Ref:** H1 | **Priority:** Medium

The `SendToDriver` method on the WebSocket Hub MUST be deleted.

**Acceptance Criteria:**

- [ ] The method is removed from `hub.go`.
- [ ] No callers reference `SendToDriver` anywhere in the codebase.
- [ ] Build passes with no compilation errors.

---

### REQ-2.7: WebSocket Connection Hardening

> **Audit Ref:** H2 | **Priority:** High

WebSocket connections MUST have read deadlines and read size limits to prevent resource exhaustion.

**Acceptance Criteria:**

- [ ] `conn.SetReadLimit(4096)` is set on each WebSocket connection.
- [ ] `conn.SetReadDeadline` is set to `2 × pingInterval` and reset on each pong.
- [ ] A pong handler refreshes the read deadline.
- [ ] A client that stops responding is disconnected within `2 × pingInterval`.

---

### REQ-2.8: Embedded Migrations

> **Audit Ref:** H3 | **Priority:** High

Migrations MUST be embedded into the Go binary using `go:embed` to avoid path-resolution issues.

**Acceptance Criteria:**

- [ ] Migration `.sql` files are embedded using `//go:embed migrations/*.sql`.
- [ ] `iofs.New(migrationFS, "migrations")` is passed to `golang-migrate`.
- [ ] The binary runs migrations correctly regardless of the working directory.
- [ ] Docker container starts and runs migrations successfully.

---

### REQ-2.9: Transactional Token Rotation

> **Audit Ref:** H5 | **Priority:** High

Refresh token rotation MUST be atomic — delete-old and store-new in one DB transaction.

**Acceptance Criteria:**

- [ ] `Refresh` use-case wraps `Delete(old)` + `Store(new)` inside `database.Transact`.
- [ ] A crash between the two operations does not leave the user in a broken state.
- [ ] Unit test: simulated failure after `Delete` does not commit the transaction.

---

### REQ-2.10: Cancel Role Enforcement

> **Audit Ref:** L2 | **Priority:** Medium

Ride cancellation MUST enforce per-role state rules.

**Acceptance Criteria:**

- [ ] A passenger can cancel rides in states: `requested`, `accepted`, `arrived`.
- [ ] A driver can cancel rides in states: `accepted`, `arrived`.
- [ ] Neither role can cancel an `in_progress` ride (returns `409`).
- [ ] The `cancelled_by` field accurately records `"passenger"`, `"driver"`, or `"system"`.

---

### REQ-2.11: Config-Driven WebSocket Origins

> **Audit Ref:** S1 | **Priority:** Medium

`CheckOrigin` MUST validate WebSocket upgrade requests against a configurable allow-list.

**Acceptance Criteria:**

- [ ] `ALLOWED_ORIGINS` is read from environment config (comma-separated).
- [ ] In `development` mode, all origins are allowed if `ALLOWED_ORIGINS` is empty.
- [ ] In `production` mode, requests from unlisted origins are rejected with HTTP 403.

---

### REQ-2.12: Security Headers Middleware

> **Audit Ref:** S3 | **Priority:** Medium

The backend MUST set standard security headers on all HTTP responses.

**Acceptance Criteria:**

- [ ] `X-Frame-Options: DENY` is set.
- [ ] `X-Content-Type-Options: nosniff` is set.
- [ ] `Content-Security-Policy: default-src 'self'` is set.
- [ ] `Strict-Transport-Security: max-age=63072000; includeSubDomains` is set (production only).

---

## Phase 3 — Flutter Mobile Apps

### 3.1 Shared Module

**Module:** `mobile/shared/`

---

#### REQ-3.1.1: Generated API Client

An auto-generated Dart HTTP client from the OpenAPI spec MUST be the sole means of communicating with the backend.

**Acceptance Criteria:**

- [ ] The Dart client is generated from `openapi/swagger.yaml` using `openapi-generator-cli` or equivalent.
- [ ] All 14 REST endpoints are covered: `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `GET /users/me`, `PUT /driver/status`, `PUT /driver/location`, `GET /driver/rides/incoming`, `GET /rides/active`, `POST /rides`, `GET /rides/:id`, `POST /rides/:id/accept`, `POST /rides/:id/decline`, `POST /rides/:id/arrive`, `POST /rides/:id/start`, `POST /rides/:id/complete`, `POST /rides/:id/cancel`, `GET /health`.
- [ ] Error responses are deserialized into typed `ErrorResponse` objects with `code` and `message`.
- [ ] A script (`scripts/generate-client.sh` or equivalent) regenerates the client in one command.

---

#### REQ-3.1.2: Token Storage & Auth Interceptor

Tokens MUST be persisted locally and auto-attached to every authenticated request.

**Acceptance Criteria:**

- [ ] Access and refresh tokens are stored using `flutter_secure_storage`.
- [ ] An HTTP interceptor automatically attaches `Authorization: Bearer <access_token>` to all protected requests.
- [ ] When a `401` is received, the interceptor attempts a silent token refresh via `POST /auth/refresh`.
- [ ] If the refresh also fails (`401`), the user is logged out and redirected to the login screen.
- [ ] Concurrent requests during a `401` queue and retry after the refresh completes (no thundering herd).

---

#### REQ-3.1.3: WebSocket Client Wrapper

A shared WebSocket client MUST handle connection, reconnection, and event parsing.

**Acceptance Criteria:**

- [ ] Connects to `ws://<host>/ws` with the JWT access token as a query parameter or header.
- [ ] Automatically reconnects with exponential backoff (1s, 2s, 4s, 8s, max 30s).
- [ ] On reconnect, calls `GET /rides/active` to resync state before processing new events.
- [ ] Incoming messages are parsed as `{ "event": "<type>", "payload": { ... } }`.
- [ ] Exposes a typed event stream (e.g., `Stream<WsEvent>`) that UI layers can subscribe to.
- [ ] Events supported: `ride.requested`, `ride.accepted`, `ride.declined`, `ride.arrived`, `ride.status_changed`, `ride.cancelled`, `ride.offer_expired`, `driver.location_updated`.

---

#### REQ-3.1.4: Shared Models

Domain models MUST be shared between Passenger and Driver apps to avoid duplication.

**Acceptance Criteria:**

- [ ] Models exist for: `User`, `Ride`, `Driver`, `Vehicle`, `LatLng`, `DriverLocation`, `ErrorResponse`.
- [ ] Models include JSON serialization/deserialization (`fromJson` / `toJson`).
- [ ] Enum types: `UserRole` (`passenger`, `driver`), `RideStatus` (6 values), `DriverStatus` (`online`, `offline`), `CancelledBy` (`passenger`, `driver`, `system`).

---

### 3.2 Passenger App

**Module:** `mobile/passenger/`

---

#### REQ-3.2.1: Passenger Registration

A new user MUST be able to create a passenger account.

**Acceptance Criteria:**

- [ ] Registration form collects: name (2–100 chars), email (valid format), password (≥8 chars).
- [ ] `role` is hardcoded to `"passenger"` — no role picker shown.
- [ ] On success (`201`), tokens are stored and user navigates to the home screen.
- [ ] On `409` (email taken), a user-facing error message is displayed.
- [ ] On validation errors (`400`), field-level errors are shown inline.
- [ ] Loading state is shown during the API call; the submit button is disabled.

---

#### REQ-3.2.2: Passenger Login

A registered passenger MUST be able to sign in.

**Acceptance Criteria:**

- [ ] Login form collects: email, password.
- [ ] On success (`200`), tokens are stored, `GET /users/me` is called to hydrate profile, and user navigates to the home screen.
- [ ] On `401` (invalid credentials), an error message is shown.
- [ ] Rate-limited responses (`429`) show a "Please wait" message with the `Retry-After` value.

---

#### REQ-3.2.3: Session Restoration

On app cold-start, the app MUST automatically restore an active session.

**Acceptance Criteria:**

- [ ] On launch, the app checks for a stored access token.
- [ ] If a token exists, `GET /users/me` is called to validate it.
- [ ] If the token is expired (`401`), a silent refresh is attempted.
- [ ] If the refresh succeeds, the session is restored; if it fails, the user sees the login screen.
- [ ] If an active ride exists (`GET /rides/active` returns `200`), the app opens directly to the active ride screen.

---

#### REQ-3.2.4: Ride Request Flow

A passenger MUST be able to request a ride by specifying pickup and destination.

**Acceptance Criteria:**

- [ ] The home screen displays a map (Google Maps or Mapbox) centered on the user's current location.
- [ ] The user can set a pickup location (defaults to current GPS position).
- [ ] The user can set a destination (text input or map tap).
- [ ] Optional notes field (max 500 chars) is available.
- [ ] On submit, `POST /rides` is called with a client-generated `Idempotency-Key` UUID.
- [ ] On `201`, the app transitions to the "Waiting for driver" screen.
- [ ] On `409` (already has an active ride), a message directs the user to their existing ride.
- [ ] On `503` (no drivers available), a user-facing message is shown with a retry option.
- [ ] The idempotency key is cached so that network retries do not create duplicate rides.

---

#### REQ-3.2.5: Waiting for Driver State

While in `requested` status, the passenger MUST see a waiting indicator.

**Acceptance Criteria:**

- [ ] A loading/animation screen displays "Finding a driver…".
- [ ] The app listens for the `ride.accepted` WebSocket event.
- [ ] On `ride.accepted`, the screen transitions to the active ride view with driver info.
- [ ] On `ride.offer_expired`, a message informs the passenger ("No driver found") with a retry option.
- [ ] On `ride.declined`, a message informs the passenger ("Driver declined, finding another…").
- [ ] A cancel button is available. On tap, `POST /rides/:id/cancel` is called.

---

#### REQ-3.2.6: Active Ride Screen (Passenger)

During an active ride (`accepted` → `arrived` → `in_progress`), the passenger MUST see real-time ride state.

**Acceptance Criteria:**

- [ ] A map displays the driver's live location, updated on each `driver.location_updated` WS event.
- [ ] The current ride status is displayed prominently: "Driver is on the way", "Driver has arrived", "Ride in progress".
- [ ] Driver info is shown: name and vehicle details (make, model, plate, color).
- [ ] Pickup and destination addresses are displayed.
- [ ] On `ride.status_changed` with status `arrived`, the UI updates to "Driver has arrived".
- [ ] On `ride.status_changed` with status `in_progress`, the UI updates to "Ride in progress".
- [ ] Cancel button is available in `accepted` and `arrived` states, hidden during `in_progress`.

---

#### REQ-3.2.7: Ride Completion Screen

On ride completion, the passenger MUST see a trip summary.

**Acceptance Criteria:**

- [ ] On `ride.status_changed` with status `completed`, the app navigates to a summary screen.
- [ ] Summary displays: origin address, destination address, ride duration (calculated from timestamps).
- [ ] A "Done" button returns the passenger to the home screen.

---

#### REQ-3.2.8: Ride Cancellation (Passenger)

A passenger MUST be able to cancel their ride during permitted states.

**Acceptance Criteria:**

- [ ] Cancel is available in `requested`, `accepted`, and `arrived` states.
- [ ] On confirmation, `POST /rides/:id/cancel` is called.
- [ ] On success, the app returns to the home screen with a "Ride cancelled" message.
- [ ] On `409` (cannot cancel `in_progress`), an error message is shown.
- [ ] A `ride.cancelled` WebSocket event also triggers the cancelled state (for driver-initiated cancels).

---

### 3.3 Driver App

**Module:** `mobile/driver/`

---

#### REQ-3.3.1: Driver Registration

A new user MUST be able to create a driver account with vehicle information.

**Acceptance Criteria:**

- [ ] Registration collects: name, email, password, and vehicle details (make, model, year, color, plate_number).
- [ ] `role` is hardcoded to `"driver"`.
- [ ] Vehicle fields are validated: all are required, `year` is a number ≥ 1990.
- [ ] On success (`201`), tokens are stored and user navigates to the driver home screen.
- [ ] Error handling matches passenger registration (409, 400).

---

#### REQ-3.3.2: Driver Login

A registered driver MUST be able to sign in (same behavior as passenger login, REQ-3.2.2).

---

#### REQ-3.3.3: Online/Offline Toggle

A driver MUST be able to toggle their availability status.

**Acceptance Criteria:**

- [ ] The driver home screen has a prominent online/offline toggle.
- [ ] Going online calls `PUT /driver/status` with `{ "status": "online" }`.
- [ ] Going offline calls `PUT /driver/status` with `{ "status": "offline" }`.
- [ ] On `409` (has active ride), the toggle is rejected with a message: "Cannot go offline during an active ride".
- [ ] When online, the app begins streaming GPS coordinates to the backend.
- [ ] When offline, location streaming stops.
- [ ] The WebSocket connection is established when going online and disconnected when offline.

---

#### REQ-3.3.4: Location Streaming

While online, the driver app MUST continuously send its GPS location to the backend.

**Acceptance Criteria:**

- [ ] `PUT /driver/location` is called every 3–5 seconds.
- [ ] Payload includes `lat`, `lng`, and optional `heading` (compass bearing).
- [ ] Coordinates are validated client-side: lat ∈ [-90, 90], lng ∈ [-180, 180].
- [ ] On `429` (rate limited), the app backs off for the `Retry-After` duration.
- [ ] Location updates stop when the app is backgrounded or the driver goes offline.

---

#### REQ-3.3.5: Incoming Ride Offer

A driver MUST be notified of incoming ride offers in real-time.

**Acceptance Criteria:**

- [ ] On `ride.requested` WebSocket event, an offer screen is displayed with:
  - Pickup address and destination address.
  - Passenger name.
  - Distance to pickup (calculated client-side or from payload).
- [ ] The offer screen shows Accept and Decline buttons.
- [ ] If the offer expires before the driver responds, the screen dismisses automatically (detected via `ride.offer_expired` or a client-side 30-second timer).
- [ ] As a fallback, `GET /driver/rides/incoming` is polled on app reconnect to check for missed offers.

---

#### REQ-3.3.6: Accept Ride

A driver MUST be able to accept a ride offer.

**Acceptance Criteria:**

- [ ] On tap, `POST /rides/:id/accept` is called.
- [ ] On `200`, the app navigates to the active ride screen.
- [ ] On `409` (offer expired or already handled), an error message is shown and the driver returns to idle.

---

#### REQ-3.3.7: Decline Ride

A driver MUST be able to decline a ride offer.

**Acceptance Criteria:**

- [ ] On tap, `POST /rides/:id/decline` is called.
- [ ] On `200`, the offer screen dismisses and the driver returns to idle/online state.
- [ ] The driver remains online and eligible for future offers.

---

#### REQ-3.3.8: Active Ride Flow (Driver)

During an active ride, the driver MUST be able to progress through the ride state machine.

**Acceptance Criteria:**

- [ ] After accepting: Screen shows pickup address with a "Navigate" option and an "I've Arrived" button.
- [ ] On "I've Arrived" tap: `POST /rides/:id/arrive` is called. Status updates to `arrived`.
- [ ] After arriving: Screen shows a "Start Ride" button while waiting for the passenger to board.
- [ ] On "Start Ride" tap: `POST /rides/:id/start` is called. Status updates to `in_progress`.
- [ ] During ride: Screen shows destination address with a "Complete Ride" button.
- [ ] On "Complete Ride" tap: `POST /rides/:id/complete` is called. Status updates to `completed`. Driver returns to online/idle.
- [ ] Cancel button is available in `accepted` and `arrived` states (calls `POST /rides/:id/cancel`).
- [ ] Each state transition button is only shown when the state permits it.

---

#### REQ-3.3.9: Reconnection & State Restoration (Driver)

On app relaunch, the driver MUST resume their previous state.

**Acceptance Criteria:**

- [ ] On cold start, if the driver was previously online, their status is checked via `GET /users/me`.
- [ ] `GET /rides/active` is called to check for an in-progress ride.
- [ ] If an active ride exists, the app opens directly to the correct step in the ride flow.
- [ ] If an incoming offer was missed, `GET /driver/rides/incoming` is polled.
- [ ] The WebSocket connection is re-established with exponential backoff.

---

## Phase 4 — Admin Dashboard

---

#### REQ-4.1: Admin Authentication

Only authorized admin users MUST access the dashboard.

**Acceptance Criteria:**

- [ ] Login screen authenticates via the same `POST /auth/login` endpoint (requires admin-capable account).
- [ ] JWT is stored in memory (or `HttpOnly` cookie) — never in `localStorage`.
- [ ] Token refresh is handled silently.
- [ ] Unauthenticated access redirects to the login page.

---

#### REQ-4.2: Dashboard Overview

The admin MUST see a top-level operational snapshot.

**Acceptance Criteria:**

- [ ] Displays: total active rides, total online drivers, total registered users.
- [ ] Data refreshes on page load (polling or manual refresh).
- [ ] Numbers are sourced from backend aggregate endpoints (to be created).

---

#### REQ-4.3: Ride Management

The admin MUST be able to browse and search rides.

**Acceptance Criteria:**

- [ ] A paginated table lists rides with columns: ID, passenger name, driver name, status, created_at.
- [ ] Filter by status: `requested`, `accepted`, `arrived`, `in_progress`, `completed`, `cancelled`.
- [ ] Clicking a ride opens a detail view with full ride information (addresses, timestamps, notes, cancelled_by).
- [ ] Rides are sorted by `created_at` descending by default.

---

#### REQ-4.4: User Management

The admin MUST be able to browse users.

**Acceptance Criteria:**

- [ ] Two tabs or filters: Passengers, Drivers.
- [ ] Columns: name, email, role, created_at.
- [ ] Clicking a driver shows their vehicle details and current status (online/offline).
- [ ] Search by name or email.

---

## Non-Functional Requirements

---

### NFR-1: API Response Time

- All REST endpoints MUST respond within **200ms** at the 95th percentile under normal load.
- `FindNearbyOnline` (geospatial) MUST respond within **100ms** with the GIST index.

---

### NFR-2: WebSocket Latency

- Location updates from driver to passenger MUST be delivered within **500ms** end-to-end (driver HTTP call → backend → passenger WS push).

---

### NFR-3: Mobile App Startup

- Cold start to interactive state MUST be under **3 seconds** on mid-range devices.
- Session restoration (token validation + state rehydration) MUST complete within **2 seconds**.

---

### NFR-4: Security

- Passwords MUST be hashed with bcrypt (cost ≥ 10).
- Access tokens MUST expire within 15–30 minutes.
- Refresh tokens MUST be rotated on every use (invalidate the old token).
- All API input MUST be validated (LatLng bounds, string lengths, required fields).
- The backend MUST enforce rate limiting: 10 rpm on auth endpoints, 30 rpm on location updates.

---

### NFR-5: Reliability

- The backend MUST handle graceful shutdown on SIGINT/SIGTERM.
- The background expiry worker MUST not crash the server on failure.
- Mobile apps MUST recover from network interruptions without data loss.
- WebSocket reconnection MUST use exponential backoff without overwhelming the server.

---

### NFR-6: Data Integrity

- A passenger MUST NOT have more than one active ride at a time (DB-enforced constraint).
- Ride state transitions MUST follow the state machine — invalid transitions MUST return `409`.
- Idempotency keys MUST prevent duplicate ride creation on retry.

---

## Ride State Machine

```
                    ┌──────────────┐
                    │  requested   │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              ▼            │            ▼
        ┌──────────┐       │     ┌─────────────┐
        │ accepted │       │     │  cancelled   │
        └────┬─────┘       │     └─────────────┘
             │             │            ▲
             ▼             │            │
        ┌──────────┐       │            │
        │ arrived  │───────┼────────────┘
        └────┬─────┘       │
             │             │
             ▼             │
        ┌──────────────┐   │
        │ in_progress  │   │
        └──────┬───────┘   │
               │           │
               ▼           │
        ┌──────────────┐   │
        │  completed   │   │
        └──────────────┘   │
```

**Valid transitions:**

| From          | To            | Triggered By        |
| ------------- | ------------- | ------------------- |
| `requested`   | `accepted`    | Driver accepts      |
| `requested`   | `cancelled`   | Passenger, system   |
| `accepted`    | `arrived`     | Driver arrives      |
| `accepted`    | `cancelled`   | Passenger or driver |
| `arrived`     | `in_progress` | Driver starts ride  |
| `arrived`     | `cancelled`   | Passenger or driver |
| `in_progress` | `completed`   | Driver completes    |

> **Invariant:** `in_progress` → `cancelled` is **not permitted**. Neither party can cancel once the ride has started.
