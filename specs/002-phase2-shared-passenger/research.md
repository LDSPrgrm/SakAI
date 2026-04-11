# Research: Phase 2 Fixes + Shared Module + Passenger App

**Date**: 2026-04-11
**Feature**: `specs/002-phase2-shared-passenger`

## Research Task 1: Map Provider Selection

### Decision: Google Maps for Flutter (`google_maps_flutter`)

**Rationale**:
- **User familiarity**: Google Maps is the default map most users recognize — critical for a ride-hailing app where users set pickup/destination pins.
- **Place Autocomplete**: Google Places API has the best address autocomplete experience, reducing user friction when typing destinations.
- **Flutter ecosystem maturity**: `google_maps_flutter` is the most widely used map plugin for Flutter with active maintenance by the Flutter team.
- **Pricing**: Google Maps provides $200/month free credit. For an MVP with limited users, this covers all usage. Mapbox is cheaper at scale but adds no MVP advantage.
- **Migration path**: Switching to Mapbox later is a view-layer change only — the ViewModel and repository interfaces remain the same.

**Alternatives considered**:
| Alternative | Pros | Cons | Why Rejected |
|---|---|---|---|
| **Mapbox** | Cheaper at scale, custom styling | Less familiar UI, requires account setup, different plugin API | Not needed for MVP; can switch later |
| **OpenStreetMap + flutter_map** | Free, no API key | Lower-quality geocoding, no built-in place autocomplete | UX quality too low for ride-hailing |

---

## Research Task 2: WebSocket Reconnection Best Practices (Flutter)

### Decision: Exponential backoff with jitter, state resync on reconnect

**Rationale**:
- Standard pattern: 1s, 2s, 4s, 8s, max 30s with ±25% jitter to prevent thundering herd.
- On reconnect, call `GET /rides/active` to get current ride state before processing new events.
- The backend's `GET /rides/active` endpoint already exists and is designed for this exact scenario.
- Use a `StreamController<WsEvent>` to expose events as a broadcast stream that ViewModels can subscribe to.

**Alternatives considered**:
| Alternative | Why Rejected |
|---|---|
| Fixed-interval reconnect (every 5s) | No backoff under sustained outage; wastes server resources |
| WebSocket ping/pong from client | Backend already sends pings; client-side pongs are sufficient |

---

## Research Task 3: Token Storage Security (Flutter)

### Decision: `flutter_secure_storage` for both access and refresh tokens

**Rationale**:
- Uses iOS Keychain and Android Keystore — hardware-backed where available.
- Standard in the Flutter ecosystem for JWT storage.
- Already referenced in `docs/requirements.md` (REQ-3.1.2) as the required approach.

---

## Research Task 4: Backend Fix Implementation Details

### H2: WebSocket Read Deadlines

**File**: `backend/internal/delivery/ws/handler.go`

The current `readPump` goroutine reads and discards inbound frames but has no read deadline or limit. Fix:

```go
conn.SetReadLimit(4096)
conn.SetReadDeadline(time.Now().Add(2 * pingInterval))
conn.SetPongHandler(func(string) error {
    conn.SetReadDeadline(time.Now().Add(2 * pingInterval))
    return nil
})
```

The `pingInterval` is configured in `configs/config.go` as `WSPingInterval` (default 30s), so the deadline is 60s.

### H3: Embedded Migrations

**File**: `backend/internal/infrastructure/database/migrate.go`

Current code uses filesystem path resolution (`../migrations`). Fix:

```go
//go:embed migrations/*.sql
var migrationFS embed.FS

// Pass to golang-migrate:
source := iofs.New(migrationFS, "migrations")
```

Migration files already live at `backend/internal/infrastructure/database/migrations/` (or the path needs a symlink from `migrations/`).

### H5: Transactional Token Rotation

**File**: `backend/internal/usecase/auth_usecase.go`

Current `Refresh` method does `Delete(old)` → `GetByID(user)` → `Store(new)` as separate operations. Fix:

Wrap in `database.Transact(ctx, func(tx) error { ... })` so Delete + Store are atomic.

---

## Research Task 5: Existing `sakai_shared` Package State

### Finding

The `mobile/shared/` package exists with:
- `pubspec.yaml` — package name `sakai_shared`
- `lib/sakai_shared.dart` — public exports
- `lib/api/sakai_api_support.dart` — `SakaiApiEndpoints`, `SakaiApiSupport.createClient`
- `lib/api_client/` — generated Dart API client (from OpenAPI spec)

What's **missing** (to be added by this feature):
- `lib/models/` — shared domain models
- `lib/auth/` — token storage + interceptor
- `lib/ws/` — WebSocket client

---

## Alternatives Considered (Feature-Level)

| Alternative | Why Rejected |
|---|---|
| Separate specs for Phase 2 fixes vs mobile | They form a strict dependency chain — Phase 2 fixes must land before mobile works. Combining them into one spec reduces coordination overhead. |
| Build passenger app without shared module | The driver app will need the same auth/WS/models. Building shared first avoids duplication. |
| Use Provider instead of ChangeNotifier | The project constitution and existing architecture specify ChangeNotifier (`ListenableBuilder`) as the standard. |
