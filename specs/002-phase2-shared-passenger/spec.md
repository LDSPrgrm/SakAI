# Feature Specification: Phase 2 Fixes + Shared Module + Passenger App

**Feature Branch**: `002-phase2-shared-passenger`
**Created**: 2026-04-11
**Status**: Draft
**Input**: User description: "1 Phase 2 (3 fixes) → Shared Module → Passenger App"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Backend Security Hardening (Priority: P0)

Three remaining Phase 2 audit items are fixed to make the backend safe for real client connections: WebSocket read deadlines/limits, embedded migrations, and transactional refresh token rotation.

**Why this priority**: These block Phase 3. Without WebSocket hardening, a rogue client can exhaust server memory. Without embedded migrations, the binary breaks outside the development CWD. Without transactional token rotation, a crash between Delete and Store permanently locks users out.

**Independent Test**: Backend passes `go test -race ./...` with all three fixes in place. Manual verification: WebSocket connections enforce read limits and deadlines; migrations run from a binary built in any working directory; a simulated crash between token Delete and Store does not leave the user in a broken state.

**Acceptance Scenarios**:

1. **Given** a WebSocket connection is established, **When** the client stops sending data, **Then** the server closes the connection within `2 × pingInterval` and no goroutine leaks occur.
2. **Given** the backend binary is built and run from any working directory, **When** it starts, **Then** migrations execute successfully without path-resolution errors.
3. **Given** a refresh token rotation is in progress, **When** the server crashes between Delete and Store, **Then** the user can still log in with their password (no permanent session loss).

---

### User Story 2 — Shared Module Foundation (Priority: P1)

A shared Flutter module (`mobile/shared/`) provides authentication, API client, WebSocket, token storage, and domain models that both the Passenger and Driver apps depend on.

**Why this priority**: The Passenger App cannot make any authenticated request or receive real-time events without these shared components. All mobile development depends on this layer.

**Independent Test**: A minimal Flutter test app imports `package:sakai_shared/sakai_shared.dart`, registers a user via the generated API client, stores tokens securely, attaches them to subsequent requests, connects to the WebSocket endpoint, and parses an incoming event — all without any Passenger or Driver app code.

**Acceptance Scenarios**:

1. **Given** a fresh Flutter project depends on `sakai_shared`, **When** a user registers via `POST /auth/register`, **Then** access and refresh tokens are stored securely and returned to the caller.
2. **Given** valid stored tokens, **When** an authenticated request is made (e.g., `GET /users/me`), **Then** the `Authorization: Bearer <token>` header is auto-attached by the interceptor.
3. **Given** an access token has expired, **When** a `401` is received, **Then** the interceptor silently refreshes via `POST /auth/refresh` and retries the original request.
4. **Given** a refresh token has also expired (`401` on refresh), **When** the refresh fails, **Then** the user is logged out and redirected to login.
5. **Given** a WebSocket connection is established, **When** the server sends `{ "event": "ride.accepted", "payload": { ... } }`, **Then** the client exposes a typed event stream that listeners can subscribe to.
6. **Given** a WebSocket disconnects, **When** the app is in the foreground, **Then** the client reconnects with exponential backoff and calls `GET /rides/active` to resync state.

---

### User Story 3 — Passenger Registration & Login (Priority: P1)

A new user creates a passenger account and signs in, with automatic session restoration on app restart.

**Why this priority**: Without authentication, no other passenger feature is accessible. This is the entry point for the entire passenger experience.

**Independent Test**: A fresh app instance displays a login screen. The user registers with name/email/password, is auto-logged in, and sees the home screen. On app restart, the session is restored without re-login.

**Acceptance Scenarios**:

1. **Given** the app is launched for the first time, **When** no stored token exists, **Then** the login screen is displayed.
2. **Given** the registration form, **When** the user submits valid name (2–100 chars), email, and password (≥8 chars), **Then** the account is created, tokens are stored, and the user navigates to the home screen.
3. **Given** the registration form, **When** the email is already taken, **Then** a `409` error is shown as a user-friendly message.
4. **Given** valid stored tokens, **When** the app cold-starts, **Then** the session is auto-restored (token validation + `GET /users/me`) and the user sees the home screen without re-login.
5. **Given** an expired access token on cold-start, **When** the silent refresh succeeds, **Then** the session is restored transparently.

---

### User Story 4 — Passenger Ride Request Flow (Priority: P1) 🎯 MVP

A passenger sets a pickup location and destination, confirms the ride request, and enters a "Waiting for driver" state.

**Why this priority**: This is the core MVP action — without it, the passenger app is just a login screen. The entire ride-hailing value proposition starts here.

**Independent Test**: A logged-in passenger opens the home screen, sets pickup and destination locations, submits the ride request, and sees a "Finding driver…" waiting screen — all without errors.

**Acceptance Scenarios**:

1. **Given** the passenger home screen, **When** the app loads, **Then** a map is displayed centered on the user's current GPS location with a default pickup pin.
2. **Given** pickup and destination are set, **When** the user taps "Request Ride", **Then** `POST /rides` is called with a client-generated `Idempotency-Key` UUID.
3. **Given** a successful ride creation (`201`), **When** the response returns, **Then** the app transitions to the "Waiting for driver" screen.
4. **Given** the passenger already has an active ride, **When** they attempt to request another, **Then** a `409` response shows a message directing them to their existing ride.
5. **Given** no drivers are available (`503`), **When** the request fails, **Then** a user-friendly message is shown with a retry option.
6. **Given** a network error during submission, **When** the user retries, **Then** the same `Idempotency-Key` is reused so no duplicate ride is created.

---

### User Story 5 — Waiting for Driver & Active Ride (Priority: P2)

A passenger sees real-time updates while waiting for a driver, tracks the driver on a map during the active ride, and sees a trip summary on completion.

**Why this priority**: Completes the end-to-end passenger experience. Without this, the ride request flow has no payoff.

**Independent Test**: A passenger requests a ride, receives a driver acceptance event via WebSocket, sees the driver's live location on the map, watches status transitions (accepted → arrived → in_progress → completed), and sees a trip summary screen.

**Acceptance Scenarios**:

1. **Given** the "Waiting for driver" screen, **When** a `ride.accepted` WebSocket event arrives, **Then** the screen transitions to the active ride view showing driver name and vehicle details.
2. **Given** the waiting state, **When** a `ride.offer_expired` event arrives, **Then** the passenger is informed ("No driver found") with a retry option.
3. **Given** an active ride, **When** a `driver.location_updated` event arrives, **Then** the driver's position is updated on the map.
4. **Given** an active ride, **When** a `ride.status_changed` event with status `arrived` arrives, **Then** the UI updates to "Driver has arrived".
5. **Given** an active ride, **When** a `ride.status_changed` event with status `completed` arrives, **Then** the app navigates to a summary screen showing origin, destination, and duration.
6. **Given** the ride completion screen, **When** the user taps "Done", **Then** the app returns to the home screen.

---

### User Story 6 — Passenger Ride Cancellation (Priority: P3)

A passenger cancels their ride during permitted states (requested, accepted, arrived) and returns to the home screen.

**Why this priority**: Important for real-world usability but not required to demonstrate the core ride-hailing flow.

**Independent Test**: A passenger with an active ride in `requested` or `accepted` state taps "Cancel Ride", confirms, and is returned to the home screen with a confirmation message.

**Acceptance Scenarios**:

1. **Given** a ride in `requested` or `accepted` state, **When** the passenger taps "Cancel", **Then** `POST /rides/:id/cancel` is called after confirmation.
2. **Given** a successful cancellation, **When** the response returns, **Then** the app returns to the home screen with a "Ride cancelled" message.
3. **Given** a ride in `in_progress` state, **When** the passenger attempts to cancel, **Then** no cancel button is shown.
4. **Given** the driver cancels the ride, **When** a `ride.cancelled` WebSocket event arrives, **Then** the passenger is notified and returned to the home screen.

---

### Edge Cases

- What happens when the WebSocket disconnects while the passenger is on the "Waiting for driver" screen? (The app should resync via `GET /rides/active` on reconnect and show current state.)
- How does the app handle background/foreground transitions? (Location permissions and WebSocket reconnection must survive these.)
- What if the passenger's GPS is unavailable or inaccurate? (The app should allow manual map-pin placement as a fallback.)
- What if the backend is unreachable during ride request? (The app should show a clear error with retry, not hang indefinitely.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Backend — WebSocket connections MUST enforce a `SetReadLimit(4096)` and `SetReadDeadline` reset on each pong with `2 × pingInterval` timeout.
- **FR-002**: Backend — Migration SQL files MUST be embedded into the Go binary via `go:embed` and passed to golang-migrate via `iofs.New(migrationFS, "migrations")`.
- **FR-003**: Backend — Refresh token rotation MUST wrap `Delete(old)` + `Store(new)` inside a single database transaction (`database.Transact`).
- **FR-004**: Mobile shared module — Access and refresh tokens MUST be stored using `flutter_secure_storage`.
- **FR-005**: Mobile shared module — An HTTP interceptor MUST auto-attach `Authorization: Bearer <access_token>` to all authenticated requests.
- **FR-006**: Mobile shared module — On `401`, the interceptor MUST attempt a silent refresh via `POST /auth/refresh`; on refresh failure, the user is logged out.
- **FR-007**: Mobile shared module — A WebSocket client MUST connect to `ws://<host>/ws?token=<access_token>`, auto-reconnect with exponential backoff (1s, 2s, 4s, max 30s), and resync state via `GET /rides/active` on reconnect.
- **FR-008**: Mobile shared module — Incoming WebSocket messages MUST be parsed as `{ "event": "<type>", "payload": { ... } }` and exposed as a typed event stream.
- **FR-009**: Mobile shared module — Shared domain models MUST exist for: User, Ride, Driver, Vehicle, LatLng, ErrorResponse, with JSON serialization.
- **FR-010**: Passenger app — Registration form MUST collect name (2–100 chars), email (valid format), password (≥8 chars) with `role` hardcoded to `"passenger"`.
- **FR-011**: Passenger app — Login form MUST collect email and password; on success, call `GET /users/me` to hydrate profile.
- **FR-012**: Passenger app — On cold-start with stored token, the app MUST validate the token via `GET /users/me` and attempt silent refresh if expired.
- **FR-013**: Passenger app — Home screen MUST display a map centered on GPS location with pickup pin and destination input.
- **FR-014**: Passenger app — Ride request MUST call `POST /rides` with a client-generated `Idempotency-Key` UUID that is cached for network retries.
- **FR-015**: Passenger app — "Waiting for driver" screen MUST listen for `ride.accepted`, `ride.offer_expired`, and `ride.declined` WebSocket events and update UI accordingly.
- **FR-016**: Passenger app — Active ride screen MUST display driver live location on map, current ride status text, driver info (name, vehicle), and pickup/destination addresses.
- **FR-017**: Passenger app — Ride completion screen MUST show origin, destination, and calculated ride duration.
- **FR-018**: Passenger app — Cancel button MUST be available in `requested`, `accepted`, and `arrived` states and hidden during `in_progress`.
- **FR-019**: Passenger app — WebSocket connection MUST be established after successful login and disconnected on logout.
- **FR-020**: All mobile screens MUST show loading states during API calls and disable the submit button while in progress.

### Key Entities

- **User**: Passenger account with id, name, email, role. Created via `POST /auth/register`.
- **Ride**: Ride lifecycle entity with id, passenger_id, driver_id, pickup, destination, status, timestamps. Created via `POST /rides`.
- **Driver**: Assigned driver info displayed on active ride screen (name, vehicle make/model/color, plate number).
- **WebSocket Event**: Typed envelope `{ event: string, payload: any }` with known event types: `ride.accepted`, `ride.declined`, `ride.offer_expired`, `ride.arrived`, `ride.status_changed`, `ride.cancelled`, `driver.location_updated`.
- **Token Pair**: Access token (short-lived JWT) + refresh token (long-lived, stored securely).

### Backend Dependencies (already implemented)

The following backend endpoints and features are already built and must NOT be modified:
- `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`
- `GET /users/me`, `GET /users/me` (profile hydration)
- `POST /rides` (with Idempotency-Key support), `GET /rides/:id`, `GET /rides/active`, `POST /rides/:id/cancel`
- WebSocket hub with event broadcasting (`ride.accepted`, `ride.offer_expired`, `ride.declined`, `ride.arrived`, `ride.status_changed`, `ride.cancelled`, `driver.location_updated`)
- OpenAPI spec at `openapi/swagger.yaml` (source of truth for all request/response shapes)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can register, log in, and reach the passenger home screen in under 30 seconds on a mid-range device.
- **SC-002**: A passenger can complete a ride request (from home screen to "Waiting for driver") in under 10 seconds with valid pickup and destination.
- **SC-003**: Session restoration on cold-start completes in under 3 seconds (token validation + profile hydration).
- **SC-004**: WebSocket reconnection after a network drop completes within 5 seconds and resyncs ride state correctly.
- **SC-005**: All 3 Phase 2 backend fixes pass their respective acceptance criteria from `docs/requirements.md` (REQ-2.7, REQ-2.8, REQ-2.9).
- **SC-006**: The end-to-end passenger flow (register → request ride → receive driver acceptance → see active ride → ride complete) works without manual backend intervention.
- **SC-007**: Zero crashes across the full passenger flow on both iOS simulator and Android emulator.
- **SC-008**: Idempotency-key retry behavior prevents duplicate ride creation — verified by simulating a network timeout and retrying the same request.

## Assumptions

- Google Maps or Mapbox is the map provider for the passenger app — selection is deferred to implementation but one must be chosen.
- The backend is running and accessible at a configurable base URL (default `http://localhost:8080/api` for development).
- The passenger app targets both iOS and Android via Flutter's cross-platform capabilities.
- GPS location permission is required from the user; if denied, the app allows manual map-pin placement.
- The Phase 2 fixes (H2, H3, H5) are the ONLY backend changes in this feature — no new endpoints or business logic changes on the server side.
- Design/UI uses the shared theme from `package:sakai_shared` for consistent styling across both future apps.
- Push notifications (Firebase Cloud Messaging) are out of scope — ride updates are delivered exclusively via WebSocket while the app is in the foreground.
- Fare calculation and display are out of scope for the MVP passenger app.
