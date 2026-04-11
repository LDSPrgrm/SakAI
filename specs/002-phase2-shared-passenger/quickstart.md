# Quickstart: Phase 2 Fixes + Shared Module + Passenger App

**Date**: 2026-04-11
**Feature**: `specs/002-phase2-shared-passenger`

## What This Feature Delivers

1. **3 backend security fixes** (WebSocket hardening, embedded migrations, transactional token rotation)
2. **Shared Flutter module** (token storage, auth interceptor, WebSocket client, domain models)
3. **Passenger app** (auth → home → ride request → waiting → active ride → complete → cancel)

## Prerequisites

- Go 1.21+ with backend running on `http://localhost:8080`
- Flutter 3.x with iOS simulator or Android emulator running
- Google Maps API key (for `google_maps_flutter` + Places Autocomplete)
- `flutter_secure_storage` dependency added to `mobile/shared/pubspec.yaml`

## Execution Order

### Step 1: Backend Fixes (15 minutes)

1. Add read limit/deadline to `backend/internal/delivery/ws/handler.go`
2. Embed migrations in `backend/internal/infrastructure/database/migrate.go`
3. Wrap token rotation in `backend/internal/usecase/auth_usecase.go`
4. Run `cd backend && go test -race ./...` — all pass

### Step 2: Shared Module (build foundation)

1. Add dependencies to `mobile/shared/pubspec.yaml`:
   - `flutter_secure_storage: ^9.0.0`
   - `web_socket_channel: ^2.4.0`
2. Create `lib/models/` — User, Ride, Driver, Vehicle, LatLng, ErrorResponse
3. Create `lib/auth/` — `TokenStorage` + `AuthInterceptor`
4. Create `lib/ws/` — `WsClient` + `WsEvent` types
5. Update `lib/sakai_shared.dart` to export new modules
6. Run `cd mobile/shared && flutter pub get && flutter analyze`

### Step 3: Passenger App — Auth Screens

1. Create `lib/features/auth/` — repository, view model, login/register views
2. Wire `AuthRepository` to `SakaiApiSupport.createClient` + `TokenStorage`
3. Add session restoration in app startup (`main.dart`)
4. Run `cd mobile/passenger && flutter pub get && flutter run`

### Step 4: Passenger App — Home + Ride Request

1. Create `lib/features/home/` — map view with Google Maps, location picker
2. Create `lib/features/waiting/` — "Finding driver…" screen with WS listener
3. Wire ride request to `POST /rides` with idempotency key
4. Test: request ride → see waiting screen

### Step 5: Passenger App — Active Ride + Complete + Cancel

1. Create `lib/features/active_ride/` — driver tracking, status display
2. Create `lib/features/ride_complete/` — trip summary
3. Add cancel dialog for permitted states
4. Test full flow: request → accept (via WS mock) → track → complete

### Step 6: Integration Test

1. Start backend: `cd backend && go run cmd/api/main.go`
2. Launch passenger app in simulator
3. Register → login → request ride → (use Swagger UI or second client to simulate driver acceptance) → track → complete
4. Verify: no crashes, WS events update UI, session survives app restart

## Verification Checklist

- [ ] `go test -race ./...` passes with all 3 backend fixes
- [ ] `flutter analyze` clean for `mobile/shared` and `mobile/passenger`
- [ ] Token storage uses `flutter_secure_storage` (not `shared_preferences`)
- [ ] Auth interceptor retries on 401 with refresh token
- [ ] WS client reconnects with exponential backoff
- [ ] All passenger screens use `ListenableBuilder` (no `setState` for reactive state)
- [ ] No repository calls in View files
- [ ] No `BuildContext` in ViewModel files
- [ ] Idempotency key is cached and reused on retry
- [ ] Google Maps API key configured via Flutter flavors or env var
