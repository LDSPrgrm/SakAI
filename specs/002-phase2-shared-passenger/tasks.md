---

description: "Task list for Phase 2 fixes, shared module, and passenger app"
---

# Tasks: Phase 2 Fixes + Shared Module + Passenger App

**Input**: Design documents from `/specs/002-phase2-shared-passenger/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Unit tests required for backend changes (H2, H5) and shared module (auth interceptor, WS client). Flutter widget tests for passenger ViewModels per project convention.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each layer.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Backend**: `backend/internal/` (delivery, infrastructure, usecase)
- **Mobile shared**: `mobile/shared/lib/` (models, auth, ws, exports)
- **Mobile passenger**: `mobile/passenger/lib/` (app, features/)

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Ensure dependencies are in place for both backend fixes and mobile development.

- [x] T001 [P] Add `flutter_secure_storage: ^9.0.0` and `web_socket_channel: ^2.4.0` to `mobile/shared/pubspec.yaml` dependencies
- [x] T002 [P] Add `google_maps_flutter: ^2.9.0` and `geolocator: ^13.0.0` to `mobile/passenger/pubspec.yaml` dependencies
- [x] T003 Run `cd mobile/shared && flutter pub get` to resolve shared module dependencies
- [x] T004 Run `cd mobile/passenger && flutter pub get` to resolve passenger app dependencies
- [x] T005 [P] Add Google Maps API key configuration to `mobile/passenger/` (Android `AndroidManifest.xml`, iOS `AppDelegate.swift` or `Info.plist`)

**Checkpoint**: All dependencies resolved — backend fixes and mobile development can proceed.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Phase 2 backend security fixes and shared module foundation. These MUST complete before any passenger app feature work begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete. The shared module provides the auth interceptor, WebSocket client, and domain models that every passenger screen depends on.

### Backend Fixes (US1 — P0)

- [x] T006 [US1] Add `conn.SetReadLimit(4096)`, `conn.SetReadDeadline(time.Now().Add(2 * pingInterval))`, and `conn.SetPongHandler(...)` to `backend/internal/delivery/ws/handler.go` before calling `hub.Register`
- [x] T007 [US1] Add unit test for WebSocket read deadline: verify connection is closed after `2 × pingInterval` of inactivity in `backend/internal/delivery/ws/handler_test.go`
- [x] T008 [US1] Replace filesystem-path migration loading with `//go:embed migrations/*.sql` + `iofs.New(migrationFS, "migrations")` in `backend/internal/infrastructure/database/migrate.go`
- [x] T009 [US1] Copy or symlink migration SQL files from `migrations/` to `backend/internal/infrastructure/database/migrations/` so `go:embed` can find them
- [x] T010 [US1] Wrap `Delete(old token)` + `Store(new token)` in `database.Transact` in `Refresh` method of `backend/internal/usecase/auth_usecase.go`
- [x] T011 [US1] Add unit test for transactional token rotation: simulate failure after Delete, verify old token still valid in `backend/internal/usecase/auth_usecase_test.go`
- [x] T012 [US1] Run `cd backend && go test -race ./...` — verify all tests pass with all 3 fixes

**Checkpoint — Backend**: All 3 Phase 2 fixes implemented and tested. `go test -race ./...` passes.

### Shared Module Foundation (US2 — P1)

- [ ] T013 [P] [US2] Create `mobile/shared/lib/models/user.dart` — User model wrapping generated `UserResponse` from `sakai_api_client` with convenience accessors (id, name, email, role)
- [ ] T014 [P] [US2] Create `mobile/shared/lib/models/ride.dart` — Ride model wrapping generated `RideResponse` with typed `RideStatus` enum, convenience getters for pickup/dest LatLng, driver info
- [ ] T015 [P] [US2] Create `mobile/shared/lib/models/driver.dart` — Driver model with name, status (`online`/`offline`), and nested `Vehicle` model
- [ ] T016 [P] [US2] Create `mobile/shared/lib/models/vehicle.dart` — Vehicle model with make, model, year, color, plateNumber
- [ ] T017 [P] [US2] Create `mobile/shared/lib/models/error_response.dart` — ErrorResponse model with `ErrorCode` enum branching key and display message mapping
- [ ] T018 [US2] Create `mobile/shared/lib/auth/token_storage.dart` — `TokenStorage` abstract class with `getAccessToken`, `getRefreshToken`, `saveTokens`, `clearTokens` methods; implement `SecureTokenStorage` using `FlutterSecureStorage`
- [ ] T019 [US2] Create `mobile/shared/lib/auth/auth_interceptor.dart` — Dio interceptor that auto-attaches `Bearer <access_token>`; on 401, calls `POST /auth/refresh`; on refresh failure, calls `onSessionExpired` callback
- [ ] T020 [US2] Create `mobile/shared/lib/ws/ws_events.dart` — Typed WS event classes: `RideAcceptedEvent`, `RideDeclinedEvent`, `RideOfferExpiredEvent`, `RideArrivedEvent`, `RideStatusChangedEvent`, `RideCancelledEvent`, `DriverLocationUpdatedEvent`; all parse from `{ event, payload }` envelope
- [ ] T021 [US2] Create `mobile/shared/lib/ws/ws_client.dart` — `WsClient` class: connects to `ws://<host>/ws?token=<access_token>`, exposes `Stream<WsEvent> events`, reconnects with exponential backoff (1s, 2s, 4s, max 30s with ±25% jitter), calls `GET /rides/active` on reconnect to resync state
- [ ] T022 [US2] Update `mobile/shared/lib/sakai_shared.dart` to export new models, auth, and ws modules
- [ ] T023 [US2] Run `cd mobile/shared && flutter analyze` — verify no lint errors

**Checkpoint — Shared Module**: All shared components built and exported. `flutter analyze` clean. Passenger app can now import from `package:sakai_shared/sakai_shared.dart`.

---

## Phase 3: User Story 1 — Backend Security Hardening (Priority: P0) ✅

> Completed in Phase 2 foundational (T006–T012).

**Goal**: 3 remaining Phase 2 audit items fixed — WebSocket hardening (H2), embedded migrations (H3), transactional token rotation (H5).

**Independent Test**: `go test -race ./...` passes. Manual verification: WS connections enforce read limits/deadlines; migrations run from any working directory; crash between token Delete/Store does not orphan session.

---

## Phase 4: User Story 2 — Shared Module Foundation (Priority: P1)

> Completed in Phase 2 foundational (T013–T023).

**Goal**: Token storage, auth interceptor, WS client, shared domain models — all consumable by passenger app.

**Independent Test**: Import `package:sakai_shared/sakai_shared.dart`, register user via API client, store tokens securely, attach to requests, connect WS, parse event — all without passenger app code.

---

## Phase 5: User Story 3 — Passenger Registration & Login (Priority: P1) 🎯 MVP Start

**Goal**: A new user creates a passenger account, signs in, and has automatic session restoration on app restart. This is the entry point for the entire passenger experience.

**Independent Test**: A fresh app instance displays login screen. User registers with name/email/password → auto-logged in → sees home screen. On app restart, session restored without re-login.

### Implementation for User Story 3

- [ ] T024 [P] [US3] Create `mobile/passenger/lib/app/app.dart` — root widget with named routes (`/login`, `/register`, `/home`), theme from `sakai_shared`, session restoration logic in `main()` entry point
- [ ] T025 [P] [US3] Create `mobile/passenger/lib/features/auth/repositories/auth_repository.dart` — wraps `SakaiApiClient` for register/login/logout/refresh; uses `TokenStorage` for token persistence; calls `GET /users/me` for profile hydration
- [ ] T026 [US3] Create `mobile/passenger/lib/features/auth/view_models/auth_view_model.dart` — `ChangeNotifier` with `login(email, password)`, `register(name, email, password)`, `logout()` methods; exposes `isLoading`, `errorMessage` getters; constructor-injects `AuthRepository`
- [ ] T027 [US3] Create `mobile/passenger/lib/features/auth/views/login_view.dart` — email/password form with validation, submit button, loading indicator; `ListenableBuilder(listenable: viewModel, ...)'; navigation to `/register` and `/home`
- [ ] T028 [US3] Create `mobile/passenger/lib/features/auth/views/register_view.dart` — name/email/password form with validation (name 2–100 chars, email format, password ≥8), hardcoded `role: "passenger"`, loading state; navigation to `/home` on success
- [ ] T029 [US3] Implement session restoration in `main.dart` — check for stored access token → validate via `GET /users/me` → if expired, silent refresh → if refresh fails, navigate to `/login`; if valid, navigate to `/home`
- [ ] T030 [US3] Add form validation helpers for email format, password length, name length in `mobile/passenger/lib/features/auth/utils/validation.dart`

**Checkpoint**: User can register, login, and session survives app restart. `flutter analyze` clean.

---

## Phase 6: User Story 4 — Passenger Ride Request Flow (Priority: P1) 🎯 MVP

**Goal**: A logged-in passenger sets pickup/destination, requests a ride with idempotency key, and enters "Waiting for driver" state. This is the core MVP action.

**Independent Test**: Passenger opens home screen → map displays at GPS location → sets pickup/destination → taps "Request Ride" → sees "Finding driver…" screen. No errors.

### Implementation for User Story 4

- [ ] T031 [P] [US4] Create `mobile/passenger/lib/features/home/repositories/location_repository.dart` — wraps `geolocator` for GPS position, provides `Stream<Position> positionStream` and `Future<Position> getCurrentPosition()`
- [ ] T032 [P] [US4] Create `mobile/passenger/lib/features/home/repositories/ride_repository.dart` — wraps `SakaiApiClient` for `POST /rides` with generated `Idempotency-Key` UUID; caches key for retries; maps response to `Ride` model
- [ ] T033 [US4] Create `mobile/passenger/lib/features/home/view_models/home_view_model.dart` — `ChangeNotifier` with `pickupLocation`, `destination`, `requestRide()`, `isLoading` getters/methods; constructor-injects `LocationRepository` and `RideRepository`; generates and caches `Idempotency-Key`
- [ ] T034 [US4] Create `mobile/passenger/lib/features/home/views/home_view.dart` — Google Maps centered on GPS, pickup pin (defaults to current location), destination search input (Google Places Autocomplete), "Request Ride" button; `ListenableBuilder` for reactive state
- [ ] T035 [US4] Create `mobile/passenger/lib/features/waiting/view_models/waiting_view_model.dart` — `ChangeNotifier` that subscribes to `WsClient.events`, listens for `ride.accepted`, `ride.offer_expired`, `ride.declined`; exposes `waitingState` enum (`waiting`, `accepted`, `expired`, `declined`)
- [ ] T036 [US4] Create `mobile/passenger/lib/features/waiting/views/waiting_view.dart` — "Finding driver…" loading screen; on `ride.accepted` → navigate to `/active-ride`; on `ride.offer_expired` → show retry dialog; on `ride.declined` → show "finding another" message
- [ ] T037 [US4] Wire WebSocket connection lifecycle — connect WS after successful login (in `AuthRepository` or app init), disconnect on logout

**Checkpoint**: Passenger can request a ride and see the "Waiting for driver" screen. Idempotency key prevents duplicate rides on network retry.

---

## Phase 7: User Story 5 — Waiting for Driver & Active Ride (Priority: P2)

**Goal**: Passenger sees real-time driver location, status transitions, and trip summary on completion. Completes the end-to-end passenger flow.

**Independent Test**: Passenger requests ride → receives `ride.accepted` WS event → sees driver info + live location on map → watches status changes → sees completion summary.

### Implementation for User Story 5

- [ ] T038 [P] [US5] Create `mobile/passenger/lib/features/active_ride/repositories/ride_status_repository.dart` — wraps `SakaiApiClient` for `GET /rides/:id` and `GET /rides/active`; maps response to `Ride` model
- [ ] T039 [US5] Create `mobile/passenger/lib/features/active_ride/view_models/active_ride_view_model.dart` — `ChangeNotifier` that subscribes to `WsClient.events` for `driver.location_updated`, `ride.status_changed`, `ride.arrived`, `ride.completed`; exposes `currentRide`, `driverLocation`, `statusText`, `driverInfo` getters; constructor-injects `RideStatusRepository` and `WsClient`
- [ ] T040 [US5] Create `mobile/passenger/lib/features/active_ride/views/active_ride_view.dart` — map with driver live location marker, status text ("Driver on the way" / "Driver has arrived" / "Ride in progress"), driver info card (name, vehicle make/model/color/plate), pickup/destination addresses; `ListenableBuilder` for reactive updates
- [ ] T041 [P] [US5] Create `mobile/passenger/lib/features/ride_complete/view_models/ride_complete_view_model.dart` — `ChangeNotifier` with ride summary data (origin, destination, duration calculated from timestamps); `done()` method navigates to `/home`
- [ ] T042 [US5] Create `mobile/passenger/lib/features/ride_complete/views/ride_complete_view.dart` — trip summary screen with origin address, destination address, ride duration; "Done" button navigates to `/home`
- [ ] T043 [US5] Wire WS event-to-navigation: in `active_ride_view.dart`, listen for `ride.status_changed` with `completed` → navigate to `/complete`

**Checkpoint**: Full end-to-end flow works: request → accept (WS) → track → complete. All status transitions reflected in UI.

---

## Phase 8: User Story 6 — Passenger Ride Cancellation (Priority: P3)

**Goal**: Passenger cancels ride during permitted states and returns to home screen.

**Independent Test**: Passenger with active ride in `requested`/`accepted` state taps "Cancel" → confirms → returned to home with "Ride cancelled" message.

### Implementation for User Story 6

- [ ] T044 [P] [US6] Create `mobile/passenger/lib/features/cancellation/repositories/cancel_repository.dart` — wraps `SakaiApiClient` for `POST /rides/:id/cancel`
- [ ] T045 [US6] Create `mobile/passenger/lib/features/cancellation/views/cancel_dialog.dart` — confirmation dialog with "Cancel Ride" and "Keep Riding" options; on confirm, calls `CancelRepository.cancel(rideId)`; handles `409` response (cannot cancel `in_progress`)
- [ ] T046 [US6] Wire cancel button visibility in `active_ride_view.dart` — show in `requested`, `accepted`, `arrived` states; hide in `in_progress`, `completed`, `cancelled`
- [ ] T047 [US6] Handle driver-initiated cancellation — listen for `ride.cancelled` WS event in `active_ride_view_model.dart`, show notification, navigate to `/home`

**Checkpoint**: Passenger can cancel rides in permitted states. Driver-initiated cancels are handled via WS event.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, error handling consistency, and quality checks across all layers.

- [ ] T048 [P] Add loading states and disabled submit buttons during all API calls across all passenger screens (FR-020)
- [ ] T049 [P] Add user-friendly error message mapping: map `ErrorResponse.code` (enum) to display strings in `mobile/shared/lib/models/error_response.dart`
- [ ] T050 [P] Add network error handling with retry UI for all passenger screens (backend unreachable, timeout)
- [ ] T051 [P] Handle GPS permission denied state in home view — allow manual map-pin placement as fallback
- [ ] T052 [P] Handle WebSocket disconnect while on "Waiting for driver" screen — resync via `GET /rides/active` on reconnect
- [ ] T053 [P] Handle background/foreground transitions — WS reconnection survives these
- [ ] T054 Run `cd mobile/passenger && flutter analyze` — verify zero lint errors across entire passenger app
- [ ] T055 Run `cd mobile/passenger && flutter test` — run all unit/widget tests
- [ ] T056 Integration test: full passenger flow (register → login → request → accept via WS mock → track → complete) on simulator/emulator — verify zero crashes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately. Installs Flutter/Go dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1. BLOCKS all user stories. Contains:
  - Backend fixes (US1 — T006–T012): Must pass `go test -race ./...`
  - Shared module (US2 — T013–T023): Must pass `flutter analyze`
- **Phase 3 (US1)**: Completed within Phase 2.
- **Phase 4 (US2)**: Completed within Phase 2.
- **Phase 5 (US3 — Auth)**: Depends on Phase 2 (needs `TokenStorage`, `AuthInterceptor`, `SakaiApiClient`). Independent of US4, US5, US6.
- **Phase 6 (US4 — Ride Request)**: Depends on Phase 2 (needs `WsClient`, `Ride` model) and US3 (needs auth to be logged in). Independent of US5, US6.
- **Phase 7 (US5 — Active Ride)**: Depends on Phase 2 (needs `WsClient`, `Ride` model) and US4 (needs ride to be in active state). Independent of US6.
- **Phase 8 (US6 — Cancellation)**: Depends on Phase 2 (needs `WsClient`) and US5 (needs active ride screen to add cancel button to).
- **Phase 9 (Polish)**: Depends on Phases 5–8 completion.

### User Story Dependencies

```
Phase 2 (Foundational)
    ├── US3 (Auth) — can start after Phase 2
    │       └── US4 (Ride Request) — needs auth (user must be logged in)
    │               └── US5 (Active Ride) — needs a ride to track
    │                       └── US6 (Cancellation) — needs active ride to cancel
    └── US2 (Shared Module) — completed in Phase 2, feeds all stories
```

### Within Each User Story

- Models before repositories (repositories depend on model types)
- Repositories before ViewModels (ViewModels constructor-inject repositories)
- ViewModels before Views (Views listen to ViewModels)
- Core implementation before wiring (navigation, WS event binding)

### Parallel Opportunities

- **Phase 1**: T001, T002, T005 run in parallel (different pubspec/config files)
- **Phase 2 Backend**: T006, T008, T010 run in parallel (different backend files)
- **Phase 2 Shared Models**: T013–T017 run in parallel (different model files)
- **Phase 2 Shared Auth/WS**: T018, T020 run in parallel (different modules)
- **US3**: T024, T025 run in parallel (app.dart and auth repository are independent)
- **US4**: T031, T032 run in parallel (location and ride repositories are independent)
- **US5**: T038, T041 run in parallel (ride status repository and ride complete VM are independent)
- **Phase 9**: T048–T053 all run in parallel (different concerns, different files)

---

## Parallel Example: Phase 2 Foundational

```bash
# Backend fixes (3 different files — run in parallel):
Task: T006 - WebSocket read limit/deadline in backend/internal/delivery/ws/handler.go
Task: T008 - Embed migrations in backend/internal/infrastructure/database/migrate.go
Task: T010 - Transactional token rotation in backend/internal/usecase/auth_usecase.go

# Shared models (5 different files — run in parallel):
Task: T013 - User model in mobile/shared/lib/models/user.dart
Task: T014 - Ride model in mobile/shared/lib/models/ride.dart
Task: T015 - Driver model in mobile/shared/lib/models/driver.dart
Task: T016 - Vehicle model in mobile/shared/lib/models/vehicle.dart
Task: T017 - ErrorResponse model in mobile/shared/lib/models/error_response.dart
```

## Parallel Example: User Story 3 (Auth)

```bash
# App structure + auth repository (different files — run in parallel):
Task: T024 - Root app widget + routing in mobile/passenger/lib/app/app.dart
Task: T025 - Auth repository in mobile/passenger/lib/features/auth/repositories/auth_repository.dart

# Then sequential:
Task: T026 - Auth ViewModel (depends on T025)
Task: T027 - Login view (depends on T026)
Task: T028 - Register view (depends on T026)
Task: T029 - Session restoration in main.dart (depends on T025)
```

---

## Implementation Strategy

### MVP First (Phases 1–2 + US3 + US4)

1. Complete Phase 1: Setup — install dependencies
2. Complete Phase 2: Foundational — backend fixes + shared module
3. Complete Phase 5: User Story 3 — auth screens with session restoration
4. Complete Phase 6: User Story 4 — home screen + ride request + waiting state
5. **STOP and VALIDATE**: Register → login → request ride → see "Waiting for driver"
6. This delivers the core MVP: a passenger can authenticate and request a ride.

### Incremental Delivery

1. Setup + Foundational → Backend hardened, shared module ready
2. Add Auth (US3) → Test registration/login → Session survives restart
3. Add Ride Request (US4) → Test request flow → "Waiting for driver" works
4. Add Active Ride (US5) → Test driver tracking → Complete flow works end-to-end
5. Add Cancellation (US6) → Test cancel in permitted states
6. Polish (Phase 9) → Error handling, edge cases, integration test

### Parallel Team Strategy

With multiple developers after Phase 2 completes:

1. Team completes Phase 2 (backend fixes + shared module) together
2. Once shared module is ready:
   - Developer A: US3 (Auth) → US4 (Ride Request)
   - Developer B: US5 (Active Ride) — can start once US4's ride request is wired
   - Developer C: US6 (Cancellation) — can start once US5's active ride screen exists
3. Phase 9 — any available developer runs polish pass

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, hand-editing generated API client, adding business logic to backend (only 3 fixes allowed), putting HTTP calls in views, holding BuildContext in ViewModels
- Total tasks: 56
- Task count per user story: US1 = 7 (in Phase 2), US2 = 11 (in Phase 2), US3 = 7, US4 = 7, US5 = 6, US6 = 4
- Setup = 5 tasks, Foundational = 18 tasks, Polish = 9 tasks
