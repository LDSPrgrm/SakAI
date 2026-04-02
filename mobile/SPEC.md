# SakAI Mobile — Development Specification

> **Phase:** 3 — Flutter Mobile Apps  
> **Status:** Ready to begin (blocked on Phase 2 critical fixes: C1, C2, L3, H4, SC1)  
> **Source of truth:** [`docs/requirements.md`](../docs/requirements.md) §3 · [`openapi/swagger.yaml`](../openapi/swagger.yaml)  
> **Last sync:** 2026-04-02

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Architecture](#3-architecture)
4. [Module Map](#4-module-map)
5. [Shared Module (`sakai_shared`)](#5-shared-module-sakai_shared)
6. [Passenger App](#6-passenger-app)
7. [Driver App](#7-driver-app)
8. [API Reference](#8-api-reference)
9. [WebSocket Events](#9-websocket-events)
10. [Ride State Machine](#10-ride-state-machine)
11. [Non-Functional Requirements](#11-non-functional-requirements)
12. [Development Workflow](#12-development-workflow)
13. [Definition of Done](#13-definition-of-done)

---

## 1. Overview

SakAI is a ride-hailing platform. The mobile component is **two separate Flutter applications** that share a generated API client, design tokens, and base widgets via a common `sakai_shared` package.

```
Passenger App  ──┐
                 ├── sakai_shared ──► sakai_api_client (generated from openapi/swagger.yaml)
Driver App     ──┘
```

Both apps communicate with the **Go + Gin backend** via:
- **REST** (`http://localhost:8080/api/v1`) — standard CRUD and state transitions
- **WebSocket** (`ws://localhost:8080/ws`) — real-time events (ride status, driver location)

---

## 2. Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter / Dart | 3.x (SDK `^3.10.8`) | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| `openapi-generator-cli` | 7.x | `npm install @openapitools/openapi-generator-cli -g` |
| Java | 11+ | required by openapi-generator-cli |
| Docker + Compose | latest | [docs.docker.com](https://docs.docker.com/get-docker/) |
| Running backend | Phase 1 ✅ | `cd backend && go run cmd/api/main.go` |

**Backend must be running:**
```sh
# Start infrastructure
docker-compose up -d         # Postgres (PostGIS) on :5432, Redis on :6379

# Start backend (runs migrations automatically)
cd backend && go run cmd/api/main.go
# → http://localhost:8080
# → http://localhost:8080/swagger/index.html  (interactive API docs)
```

---

## 3. Architecture

Both apps follow **Clean Architecture + MVVM**. The dependency rule flows inward only:

```
presentation/  →  domain/  ←  data/
                    ↑
               sakai_shared (API client, theme, widgets)
```

### Layer Rules

| Layer | Owns | Must NOT import |
|-------|------|-----------------|
| `domain/` | Entities, abstract repository interfaces | Flutter, `dio`, `data/` |
| `data/` | Repository implementations, DTO↔domain mapping | `presentation/` |
| `presentation/` | Widgets, screens, ViewModels (`ChangeNotifier`) | `data/` directly (inject via constructor) |
| `app/` | `MaterialApp`, routes, DI composition | Business logic |

**ViewModel pattern:** ViewModels expose state via `ChangeNotifier`; screens call `notifyListeners()` after state changes. Screens must never call repositories directly — only through the ViewModel.

---

## 4. Module Map

```
mobile/
├── shared/                     # package: sakai_shared
│   └── lib/
│       ├── api/                # SakaiApiSupport.createClient() factory
│       ├── api_client/         # package: sakai_api_client (GENERATED — do not hand-edit)
│       ├── theme/              # Design tokens, semantic colors, theme config
│       ├── widgets/            # Shared reusable widgets
│       └── sakai_shared.dart   # Barrel export
│
├── passenger/                  # Rider-facing app
│   └── lib/
│       ├── main.dart
│       ├── app/                # MaterialApp + routes + DI
│       ├── domain/             # Auth entities + AuthRepository interface
│       ├── data/               # AuthRepositoryImpl
│       └── presentation/
│           ├── auth/           # LoginScreen, RegisterScreen, LoginViewModel, RegisterViewModel
│           └── home/           # HomeScreen (map + ride request)
│           └── ride/           # WaitingScreen, ActiveRideScreen, CompletionScreen
│
└── driver/                     # Driver-facing app
    └── lib/
        ├── main.dart
        ├── app/                # MaterialApp + routes + DI
        ├── domain/             # Driver entities + repository interfaces
        ├── data/               # DriverRepositoryImpl, LocationRepositoryImpl
        └── presentation/
            ├── auth/           # LoginScreen, RegisterScreen (+ vehicle fields)
            ├── home/           # DriverHomeScreen (online/offline toggle)
            ├── offer/          # OfferScreen (Accept/Decline + timer)
            └── ride/           # ActiveRideScreen (Arrive → Start → Complete)
```

---

## 5. Shared Module (`sakai_shared`)

> **Package name:** `sakai_shared` · **Path:** `mobile/shared/`  
> **REQ-3.1.1 through REQ-3.1.4**

### 5.1 Generated API Client

The Dart client lives in `lib/api_client/` and is generated from `openapi/swagger.yaml`. It is published as a sub-package (`sakai_api_client`) so it can be depended on independently.

**Regenerate after any `swagger.yaml` change:**
```sh
# From repo root
./scripts/generate-client.sh

# Manual equivalent
openapi-generator-cli generate \
  -i openapi/swagger.yaml \
  -g dart-dio \
  -o mobile/shared/lib/api_client \
  --additional-properties=pubName=sakai_api_client,nullableFields=true

cd mobile/shared/lib/api_client && dart pub get \
  && dart run build_runner build --delete-conflicting-outputs
```

**Important:** Never hand-edit files in `lib/api_client/`. They will be overwritten on regeneration.

Entry point for apps:
```dart
import 'package:sakai_shared/sakai_shared.dart';

final api = SakaiApiSupport.createClient(); // pre-configured Dio + base URL
```

### 5.2 Token Storage & Auth Interceptor

**REQ-3.1.2**

- Store `access_token` and `refresh_token` using `flutter_secure_storage`.
- A Dio interceptor auto-attaches `Authorization: Bearer <token>` to all protected requests.
- On `401`: silently call `POST /auth/refresh`. On success, retry original request. On failure, log out.
- **Thundering herd protection:** Queue concurrent requests during a refresh; replay all after the single refresh completes.
- On logout or failed refresh, clear stored tokens and navigate to login.

Recommended structure:
```
shared/lib/
└── auth/
    ├── token_storage.dart        # flutter_secure_storage wrapper
    └── auth_interceptor.dart     # Dio interceptor with refresh + retry logic
```

### 5.3 WebSocket Client

**REQ-3.1.3**

- Connect to `ws://<host>/ws?token=<access_token>` with JWT.
- Reconnect with **exponential backoff**: 1s → 2s → 4s → 8s → max 30s.
- On reconnect, call `GET /rides/active` to resync state before processing new WS events.
- Parse all messages as `{ "event": "<type>", "payload": { ... } }`.
- Expose `Stream<WsEvent>` so UI can `listen()` to typed events.

```
shared/lib/
└── websocket/
    ├── ws_client.dart            # Connection lifecycle, reconnect loop
    ├── ws_event.dart             # Sealed class / union for all event types
    └── ws_event_parser.dart      # JSON → WsEvent mapping
```

**Supported events** (see [§9 WebSocket Events](#9-websocket-events)):
`ride.requested`, `ride.accepted`, `ride.declined`, `ride.arrived`, `ride.status_changed`, `ride.cancelled`, `ride.offer_expired`, `driver.location_updated`

### 5.4 Shared Models

**REQ-3.1.4**

Models must be shared between both apps (no duplication):

| Model | Fields |
|-------|--------|
| `User` | `id`, `name`, `email`, `role` (`UserRole`) |
| `Ride` | `id`, `status` (`RideStatus`), `passengerId`, `driverId?`, `pickup` (`LatLng`), `destination` (`LatLng`), `pickupAddress`, `destinationAddress`, `notes?`, `createdAt`, `expiresAt?` |
| `Driver` | `userId`, `status` (`DriverStatus`), `vehicle` (`VehicleInfo`) |
| `VehicleInfo` | `make`, `model`, `year`, `color`, `plateNumber` |
| `LatLng` | `lat`, `lng` |

**Enums:**

| Enum | Values |
|------|--------|
| `UserRole` | `passenger`, `driver` |
| `RideStatus` | `requested`, `accepted`, `arrived`, `in_progress`, `completed`, `cancelled` |
| `DriverStatus` | `online`, `offline` |
| `CancelledBy` | `passenger`, `driver`, `system` |

### 5.5 Theme & Widgets

Already implemented. Use from `package:sakai_shared/sakai_shared.dart`:

| Export | Purpose |
|--------|---------|
| `SakaiTheme` | `ThemeData` for `MaterialApp` |
| `SakaiDesignTokens` | Colors, spacing, radii |
| `SakaiSemanticColors` | Semantic color mappings |
| `SakaiPrimaryButton` | Primary CTA button |
| `SakaiSecondaryButton` | Secondary action button |
| `SakaiScreenScaffold` | Standard screen scaffold |
| `SakaiSurfaceCard` | Card container |
| `SakaiTextField` | Styled text input |

---

## 6. Passenger App

> **Package:** `passenger` · **Path:** `mobile/passenger/`  
> **REQ-3.2.1 through REQ-3.2.8**

### 6.1 Screens & Navigation

| Route | Screen | ViewModel |
|-------|--------|-----------|
| `/login` | `LoginScreen` | `LoginViewModel` ✅ |
| `/register` | `RegisterScreen` | `RegisterViewModel` |
| `/` (home) | `HomeScreen` (map) | `HomeViewModel` |
| `/waiting` | `WaitingScreen` | `WaitingViewModel` |
| `/ride/active` | `ActiveRideScreen` | `ActiveRideViewModel` |
| `/ride/complete` | `CompletionScreen` | — |
| `/profile` | `ProfileScreen` | `ProfileViewModel` |

### 6.2 Feature Specs

#### Auth — Registration (REQ-3.2.1)

- Form fields: `name` (2–100 chars), `email` (valid format), `password` (≥8 chars)
- `role` hardcoded to `"passenger"` — not shown to user
- API call: `POST /auth/register` → `AuthResponse`
- Success `201`: store tokens → navigate to `/`
- Error `409`: show inline "Email already registered"
- Error `400`: show field-level validation errors
- Loading: disable submit button, show progress indicator

#### Auth — Login (REQ-3.2.2)

- Form fields: `email`, `password`
- API call: `POST /auth/login` → `AuthResponse`
- Success `200`: store tokens → call `GET /users/me` → navigate to `/`
- Error `401`: show "Invalid email or password"
- Error `429`: show "Too many attempts. Try again in `<Retry-After>` seconds"

#### Session Restoration (REQ-3.2.3)

On cold start (in `main.dart` or app initializer):
1. Check for stored access token
2. Call `GET /users/me`
   - Success → call `GET /rides/active`
     - `200` (active ride exists) → navigate to `/ride/active` or `/waiting` based on status
     - `404` → navigate to `/` (home)
   - Error `401` → attempt silent refresh → if fail, navigate to `/login`

#### Ride Request (REQ-3.2.4)

- Map centered on current GPS position (Google Maps or Mapbox)
- Pickup: defaults to GPS, user can move map pin
- Destination: text input with address search or map tap
- Notes: optional text field (max 500 chars)
- Generate `Idempotency-Key` UUID on first attempt; persist for retries
- API call: `POST /rides` with `Idempotency-Key` header
- Success `201`: navigate to `/waiting`
- Error `409` (already has active ride): prompt user to view existing ride
- Error `503` (no drivers): show "No drivers available right now" with retry

#### Waiting for Driver (REQ-3.2.5)

- Show animation "Finding a driver…"
- Listen for WS events:
  - `ride.accepted` → navigate to `/ride/active` with driver info
  - `ride.offer_expired` → show "No driver found" + retry option
  - `ride.declined` → show "Driver declined, finding another…" (stay on waiting screen)
- Cancel button visible: calls `POST /rides/:id/cancel` → navigate to `/`

#### Active Ride Screen (REQ-3.2.6)

- Map showing **driver's live position** — updated on every `driver.location_updated` WS event
- Status banner: "Driver is on the way" / "Driver has arrived" / "Ride in progress"
- Driver info: name, vehicle make/model/plate/color
- Pickup + destination addresses shown
- State transitions:
  - `ride.status_changed` with `arrived` → update banner to "Driver has arrived"
  - `ride.status_changed` with `in_progress` → update banner to "Ride in progress", hide cancel
  - `ride.status_changed` with `completed` → navigate to `/ride/complete`
- Cancel button visible in `accepted` and `arrived`; hidden in `in_progress`

#### Completion Screen (REQ-3.2.7)

- Summary: origin address, destination address, duration (computed from `created_at` to now)
- "Done" button → navigate to `/` (home)

#### Cancellation (REQ-3.2.8)

- Available in `requested`, `accepted`, `arrived` states
- Confirm dialog before calling `POST /rides/:id/cancel`
- Success → navigate to `/` with "Ride cancelled" snackbar
- Error `409` (can't cancel `in_progress`) → show error message

#### Profile Screen (REQ-3.2.9)

- Accessed via user menu / avatar from the home screen
- Displays the authenticated user's profile: `name`, `email`
- Provides access to **Logout** action → calls `POST /auth/logout` and navigates to `/login`

### 6.3 `pubspec.yaml` Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sakai_shared:
    path: ../shared
  flutter_secure_storage: ^9.x
  google_maps_flutter: ^2.x       # or mapbox_maps_flutter
  geolocator: ^13.x
  dio: ^5.x
  built_value: ^8.x
  cupertino_icons: ^1.x
```

---

## 7. Driver App

> **Package:** `driver` · **Path:** `mobile/driver/`  
> **REQ-3.3.1 through REQ-3.3.9**

### 7.1 Screens & Navigation

| Route | Screen | ViewModel |
|-------|--------|-----------|
| `/login` | `LoginScreen` | `LoginViewModel` |
| `/register` | `RegisterScreen` | `RegisterViewModel` |
| `/` (home) | `DriverHomeScreen` (online/offline toggle) | `DriverHomeViewModel` |
| `/offer` | `OfferScreen` (accept / decline + 30s timer) | `OfferViewModel` |
| `/ride/active` | `ActiveRideScreen` | `ActiveRideViewModel` |
| `/profile` | `ProfileScreen` | `ProfileViewModel` |

### 7.2 Feature Specs

#### Auth — Registration (REQ-3.3.1)

- Form fields: `name`, `email`, `password` + vehicle section:
  - `make`, `model`, `color`, `plateNumber` (all required strings)
  - `year` (number, ≥ 1990)
- `role` hardcoded to `"driver"`
- API call: `POST /auth/register` (same endpoint, includes `vehicle` object in payload)
- Same success/error behavior as passenger registration

#### Auth — Login (REQ-3.3.2)

Same as passenger login. Same endpoint: `POST /auth/login`.

#### Online / Offline Toggle (REQ-3.3.3)

- Prominent toggle on `DriverHomeScreen`
- **Going online:**
  1. Call `PUT /driver/status` `{ "status": "online" }`
  2. Start GPS location streaming (see §7.2 Location Streaming)
  3. Connect WebSocket
- **Going offline:**
  1. Stop GPS streaming
  2. Call `PUT /driver/status` `{ "status": "offline" }`
  3. Disconnect WebSocket
- Error `409` (has active ride): reject toggle, show "Cannot go offline during an active ride"

#### Location Streaming (REQ-3.3.4)

- `PUT /driver/location` every **3–5 seconds** while online
- Payload: `{ "lat": <double>, "lng": <double>, "heading": <double?> }`
- Client-side validation before sending: `lat ∈ [-90, 90]`, `lng ∈ [-180, 180]`
- On `429`: read `Retry-After` header, pause and back off
- Stop immediately when:
  - App is backgrounded
  - Driver goes offline

Recommended implementation: `Timer.periodic` in a `DriverLocationService` singleton, cancelled on offline/backgrounded events.

#### Incoming Ride Offer (REQ-3.3.5)

- Trigger: `ride.requested` WS event
- Show `OfferScreen` with:
  - Pickup address and destination address
  - Passenger name
  - Distance to pickup (calculate from current GPS to pickup `LatLng`, or use value from payload)
  - **30-second countdown timer**
- Actions:
  - **Accept** → `POST /rides/:id/accept` (see §7.2 Accept Ride)
  - **Decline** → `POST /rides/:id/decline` (see §7.2 Decline Ride)
- Auto-dismiss if timer expires (`ride.offer_expired` WS event OR local 30s timer)
- On reconnect fallback: call `GET /driver/rides/incoming` to check for missed offers

#### Accept Ride (REQ-3.3.6)

- API call: `POST /rides/:id/accept`
- Success `200` → navigate to `/ride/active` (pickup navigation phase)
- Error `409` (offer expired or already handled) → show error, return to idle home screen

#### Decline Ride (REQ-3.3.7)

- API call: `POST /rides/:id/decline`
- Success `200` → dismiss `OfferScreen`, return to idle home screen
- Driver remains online and eligible for next offer

#### Active Ride Flow (REQ-3.3.8)

State-driven screen — one screen, different UI per ride status:

| Status | Display | Action Button |
|--------|---------|---------------|
| `accepted` | Pickup address, map to pickup | **"I've Arrived"** → `POST /rides/:id/arrive` |
| `arrived` | Pickup address, waiting for passenger | **"Start Ride"** → `POST /rides/:id/start` |
| `in_progress` | Destination address | **"Complete Ride"** → `POST /rides/:id/complete` |

- Cancel button visible in `accepted` and `arrived` → `POST /rides/:id/cancel`
- Cancel button hidden in `in_progress`
- On complete: navigate to `/` (home, now online/idle)

#### Reconnection & State Restoration (REQ-3.3.9)

On cold start:
1. Call `GET /users/me` to check auth and previous driver status
2. Call `GET /rides/active`:
   - `200` → navigate to `/ride/active` at the correct step (based on `status`)
   - `404` → stay on `/` (home)
3. Call `GET /driver/rides/incoming` to catch any missed offers
4. Re-establish WebSocket connection with exponential backoff

#### Profile Screen (REQ-3.3.10)

- Accessed via user menu / avatar from the home screen
- Displays the driver's profile: `name`, `email`
- Displays registered `vehicle` info: make, model, color, plate number
- Provides access to **Logout** action → calls `POST /auth/logout` and navigates to `/login`

### 7.3 `pubspec.yaml` Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sakai_shared:
    path: ../shared
  flutter_secure_storage: ^9.x
  geolocator: ^13.x
  dio: ^5.x
  built_value: ^8.x
  cupertino_icons: ^1.x
```

---

## 8. API Reference

> Base URL: `http://localhost:8080/api/v1`  
> All authenticated endpoints require `Authorization: Bearer <access_token>`

### Auth Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/auth/register` | ❌ | Register passenger or driver |
| `POST` | `/auth/login` | ❌ | Login, receive tokens |
| `POST` | `/auth/refresh` | ❌ | Rotate refresh token |
| `POST` | `/auth/logout` | ✅ | Invalidate refresh token |

**`POST /auth/register` request:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "role": "passenger | driver",
  "vehicle": {               // required only for role=driver
    "make": "string",
    "model": "string",
    "year": 2020,
    "color": "string",
    "plate_number": "string"
  }
}
```

**`AuthResponse`:**
```json
{
  "access_token": "string",
  "refresh_token": "string",
  "user": { "id": "uuid", "name": "string", "email": "string", "role": "string" }
}
```

### User Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/users/me` | ✅ | Fetch authenticated user profile |

### Driver Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `PUT` | `/driver/status` | ✅ | Set `online` / `offline` |
| `PUT` | `/driver/location` | ✅ | Stream GPS location (rate-limited: 30/min) |
| `GET` | `/driver/rides/incoming` | ✅ | Poll for pending ride offer (reconnect fallback) |

**`PUT /driver/location` request:**
```json
{ "lat": 14.5995, "lng": 120.9842, "heading": 90.0 }
```

### Rides Endpoints

| Method | Path | Auth | Role | Description |
|--------|------|------|------|-------------|
| `POST` | `/rides` | ✅ | passenger | Request ride (requires `Idempotency-Key` header) |
| `GET` | `/rides/active` | ✅ | both | Get caller's current active ride |
| `GET` | `/rides/:rideId` | ✅ | participant | Get ride by ID |
| `POST` | `/rides/:rideId/accept` | ✅ | driver | Accept ride offer |
| `POST` | `/rides/:rideId/decline` | ✅ | driver | Decline ride offer |
| `POST` | `/rides/:rideId/arrive` | ✅ | driver | Signal arrival at pickup |
| `POST` | `/rides/:rideId/start` | ✅ | driver | Start ride |
| `POST` | `/rides/:rideId/complete` | ✅ | driver | Complete ride |
| `POST` | `/rides/:rideId/cancel` | ✅ | both | Cancel ride |

**`POST /rides` request:**
```json
{
  "pickup": { "lat": 14.5995, "lng": 120.9842 },
  "destination": { "lat": 14.6122, "lng": 121.0110 },
  "pickup_address": "string",
  "destination_address": "string",
  "notes": "string (optional, max 500 chars)"
}
```
Headers: `Idempotency-Key: <uuid>`

### System

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check — returns service + DB + Redis status |

### Error Response Format

All errors return:
```json
{
  "code": "VALIDATION_ERROR | UNAUTHORIZED | FORBIDDEN | NOT_FOUND | CONFLICT | NO_DRIVERS_AVAILABLE | ...",
  "message": "Human-readable description"
}
```

---

## 9. WebSocket Events

> **Endpoint:** `ws://localhost:8080/ws?token=<access_token>`  
> **Message envelope:** `{ "event": "<type>", "payload": { ... } }`

| Event | Who receives | Trigger | Payload key fields |
|-------|-------------|---------|-------------------|
| `ride.requested` | Driver | Matching engine assigns offer | `ride_id`, `passenger`, `pickup`, `destination`, `expires_at` |
| `ride.accepted` | Passenger | Driver accepts | `ride_id`, `driver`, `vehicle` |
| `ride.declined` | Passenger | Driver declines (re-matching in progress) | `ride_id` |
| `ride.status_changed` | Both | `arrive`, `start`, `complete` transitions | `ride_id`, `status` |
| `ride.cancelled` | Both | Either party or system cancels | `ride_id`, `cancelled_by` |
| `ride.offer_expired` | Both | Expiry worker times out the offer | `ride_id`, `reason: "timeout"` |
| `driver.location_updated` | Passenger | Driver sends location during active ride | `ride_id`, `lat`, `lng`, `heading?` |

### Client-side Handling Pattern

```dart
wsClient.eventStream.listen((event) {
  switch (event.type) {
    case WsEventType.rideAccepted:
      // passenger: navigate to active ride screen
    case WsEventType.rideStatusChanged:
      // update local ride status
    case WsEventType.driverLocationUpdated:
      // move driver marker on map
    case WsEventType.rideOfferExpired:
      // driver: dismiss offer screen; passenger: show "no driver found"
    // ...
  }
});
```

---

## 10. Ride State Machine

```
               ┌──────────────┐
               │  requested   │◄── POST /rides (passenger)
               └──────┬───────┘
                      │
       ┌──────────────┼──────────────────┐
       ▼              │                  ▼
 ┌──────────┐         │          ┌─────────────┐
 │ accepted │         │          │  cancelled  │
 └────┬─────┘         │          └─────────────┘
      │               │                 ▲
      ▼               └─────────────────┤
 ┌──────────┐                           │
 │ arrived  │───────────────────────────┘
 └────┬─────┘
      │
      ▼
 ┌─────────────┐
 │ in_progress │  ← cancel NOT allowed from here
 └──────┬──────┘
        │
        ▼
 ┌──────────────┐
 │  completed   │
 └──────────────┘
```

| From | To | API Call | WS Event Emitted |
|------|----|---------|-----------------|
| `requested` | `accepted` | `POST /rides/:id/accept` | `ride.accepted` → passenger |
| `requested` | `cancelled` | `POST /rides/:id/cancel` | `ride.cancelled` → both |
| `accepted` | `arrived` | `POST /rides/:id/arrive` | `ride.status_changed` → both |
| `accepted` | `cancelled` | `POST /rides/:id/cancel` | `ride.cancelled` → both |
| `arrived` | `in_progress` | `POST /rides/:id/start` | `ride.status_changed` → both |
| `arrived` | `cancelled` | `POST /rides/:id/cancel` | `ride.cancelled` → both |
| `in_progress` | `completed` | `POST /rides/:id/complete` | `ride.status_changed` → both |

> **Invariant:** `in_progress` → `cancelled` is **not permitted**. Returns `409`.

---

## 11. Non-Functional Requirements

| NFR | Requirement |
|-----|-------------|
| Cold start | < 3 seconds to interactive state on mid-range device |
| Session restore | Token validation + state rehydration < 2 seconds |
| Location update | Every 3–5 seconds while online |
| WS latency | Location update delivered to passenger within 500ms end-to-end |
| WS reconnect | Exponential backoff: 1s → 2s → 4s → 8s → max 30s |
| Token expiry | Access token: 60 min. Refresh token: 30 days. Silent refresh at ~80% TTL |
| Rate limits | Auth: 10 rpm/IP · Location updates: 30 rpm/driver |
| Offline | Apps must recover from network interruption without data loss or crash |

---

## 12. Development Workflow

### Running the Apps

```sh
# Passenger
cd mobile/passenger
flutter pub get
flutter run

# Driver
cd mobile/driver
flutter pub get
flutter run
```

### Testing

```sh
cd mobile/passenger   # or driver or shared
flutter test
flutter test --coverage
```

### Linting

```sh
flutter analyze   # must be clean before every PR
```

### Adding a Feature

1. **OpenAPI first** — update `openapi/swagger.yaml`, then `./scripts/generate-client.sh`
2. **Domain** — add entity and abstract interface in `domain/` (pure Dart only)
3. **Data** — implement repository in `data/` using the generated client
4. **Presentation** — create ViewModel (`ChangeNotifier`) + screen in `presentation/<feature>/`
5. **Wire** — inject dependencies in `app/` and `main.dart`
6. **Shared** — if the widget is used in both apps, add it to `sakai_shared/widgets/`

### Branching Convention

| Branch type | Pattern | Example |
|-------------|---------|---------|
| Mobile feature | `feature/mobile/<name>` | `feature/mobile/passenger-auth` |
| Bug fix | `fix/mobile/<name>` | `fix/mobile/ws-reconnect` |
| API contract | `feature/api-contract/<name>` | `feature/api-contract/ride-events` |

**PR checklist:**
- [ ] `flutter analyze` clean
- [ ] `flutter test` passing
- [ ] Linked to GitHub issue or requirement ID
- [ ] PRs touching `openapi/` reviewed by backend team

---

## 13. Definition of Done — Phase 3

> A passenger can register, request a ride, see a driver accept, track the driver in real-time on a map, and see the ride complete. A driver can register with vehicle info, go online, accept a ride offer, navigate through all state transitions, and complete the ride.

### Passenger App ✅ when:

- [ ] Register and login flow works end-to-end
- [ ] Cold start restores session and active ride correctly
- [ ] Pickup + destination can be set on a map
- [ ] `POST /rides` is called with idempotency key; app transitions to waiting state
- [ ] `ride.accepted` WS event triggers navigation to active ride screen
- [ ] Driver marker moves in real-time on `driver.location_updated` events
- [ ] Status banner updates correctly on `ride.status_changed` events
- [ ] Completion screen appears on `completed` status
- [ ] Cancellation works from all allowed states
- [ ] `ride.offer_expired` shows correct message to passenger

### Driver App ✅ when:

- [ ] Register with vehicle info works end-to-end
- [ ] Login and session restore works
- [ ] Online/offline toggle calls correct endpoints
- [ ] GPS streaming runs at 3–5s intervals while online
- [ ] `ride.requested` WS event shows offer screen with 30s timer
- [ ] Accept navigates to active ride screen correctly
- [ ] Decline dismisses offer and keeps driver online
- [ ] Arrive → Start → Complete transitions work and call correct endpoints
- [ ] Cancel works in `accepted` / `arrived` states
- [ ] Cold start restores active ride or pending offer

### Shared ✅ when:

- [ ] Generated API client covers all 18 endpoints
- [ ] Token storage + auth interceptor with silent refresh works
- [ ] WebSocket client connects, auto-reconnects, and exposes typed event stream
- [ ] All shared models serialize/deserialize correctly
- [ ] Theme and shared widgets render correctly in both apps
