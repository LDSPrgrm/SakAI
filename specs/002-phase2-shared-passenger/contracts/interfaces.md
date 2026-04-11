# Interface Contracts: Phase 2 Fixes + Shared Module + Passenger App

**Date**: 2026-04-11
**Feature**: `specs/002-phase2-shared-passenger`

## Contract 1: Backend WebSocket Hardening (H2)

**File**: `backend/internal/delivery/ws/handler.go`

The WebSocket upgrader MUST configure the connection as follows before calling `hub.Register`:

```
conn.SetReadLimit(4096)
conn.SetReadDeadline(time.Now().Add(2 * pingInterval))
conn.SetPongHandler(func(string) error {
    conn.SetReadDeadline(time.Now().Add(2 * pingInterval))
    return nil
})
```

**Verification**:
- `go test -race ./...` passes
- A WebSocket client that sends > 4096 bytes is disconnected with an error
- A WebSocket client that stops responding is disconnected within `2 × pingInterval` (60s default)

---

## Contract 2: Embedded Migrations (H3)

**File**: `backend/internal/infrastructure/database/migrate.go`

The migration source MUST use `embed.FS` rather than filesystem paths:

```go
//go:embed migrations/*.sql
var migrationFS embed.FS

source := iofs.New(migrationFS, "migrations")
```

**Verification**:
- Backend starts and runs migrations from the repo root, `backend/`, and `backend/cmd/api/` working directories — all succeed
- Binary built with `go build` and run from a temporary directory executes migrations

---

## Contract 3: Transactional Token Rotation (H5)

**File**: `backend/internal/usecase/auth_usecase.go`

The `Refresh` method MUST wrap `Delete(old)` + `Store(new)` in a single database transaction:

```go
err := database.Transact(ctx, func(tx) error {
    if err := uc.tokenRepo.DeleteWithTx(tx, oldToken); err != nil { return err }
    // ... generate new token ...
    return uc.tokenRepo.StoreWithTx(tx, newToken)
})
```

**Verification**:
- Unit test: simulate failure after `Delete` — transaction rolls back, old token remains valid
- Unit test: normal flow — old token deleted, new token stored, both in one commit

---

## Contract 4: Shared Module API Client Interface

**Package**: `mobile/shared/lib/`

### TokenStorage (abstract)

```dart
abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String access, required String refresh});
  Future<void> clearTokens();
}
```

**Implementation**: `SecureTokenStorage` using `flutter_secure_storage`.

### AuthInterceptor (behavior contract)

- Intercepts all outgoing requests from `SakaiApiClient`.
- If `Authorization` header not already set, attaches `Bearer <access_token>`.
- On `401` response: calls `POST /auth/refresh` with stored refresh token.
  - On success: retries original request with new access token.
  - On failure: calls `onSessionExpired()` callback and throws.

### WsClient (behavior contract)

```dart
abstract class WsClient {
  Stream<WsEvent> get events;
  Future<void> connect({required String baseUrl, String? accessToken});
  Future<void> disconnect();
  // Called by the shared module internally — not exposed to apps.
  // On disconnect: exponential backoff (1s, 2s, 4s, max 30s) with jitter.
  // On reconnect: calls GET /rides/active to resync state.
}
```

---

## Contract 5: Passenger App Screen Contracts

Each screen follows the MVVM contract:

| Component | Contract |
|---|---|
| **View** | `ListenableBuilder(listenable: viewModel, builder: ...)`. No repository calls. No `BuildContext` in ViewModel. |
| **ViewModel** | `ChangeNotifier`. Exposes state via getters. Methods return `Future<void>`. Constructor-injects repositories. |
| **Repository** | Uses `SakaiApiClient` (from `sakai_shared`) for HTTP calls. Maps generated types to domain models. |

### Navigation Contract

- Root `app.dart` defines named routes: `/login`, `/register`, `/home`, `/waiting`, `/active-ride`, `/complete`.
- Navigation decisions happen in the View layer (action handlers or `_onVmChanged` listener).
- ViewModels never hold `BuildContext` or call `Navigator` directly.

---

## Contract 6: REST Endpoints Used (Existing — No Changes)

All endpoints are defined in `openapi/swagger.yaml` and already implemented in the backend. This feature consumes them without modification:

| Endpoint | Used By | Purpose |
|---|---|---|
| `POST /auth/register` | AuthRepository | Create passenger account |
| `POST /auth/login` | AuthRepository | Authenticate passenger |
| `POST /auth/refresh` | AuthInterceptor | Silent token refresh |
| `POST /auth/logout` | AuthRepository | Sign out |
| `GET /users/me` | AuthRepository, SessionManager | Profile hydration + token validation |
| `POST /rides` | RideRepository | Request ride (with Idempotency-Key) |
| `GET /rides/active` | RideRepository, WsClient | Check for active ride + WS resync |
| `GET /rides/:id` | RideRepository | Fetch ride details |
| `POST /rides/:id/cancel` | RideRepository | Cancel ride |
| WebSocket `/ws?token=...` | WsClient | Real-time event stream |
