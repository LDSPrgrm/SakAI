# Implementation Plan: Phase 2 Fixes + Shared Module + Passenger App

**Branch**: `dev` | **Date**: 2026-04-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-phase2-shared-passenger/spec.md`

## Summary

This feature delivers three layers in dependency order:

1. **Phase 2 Backend Fixes (P0)** — 3 remaining audit items: WebSocket read deadlines/limits (H2), embedded migrations via `go:embed` (H3), transactional refresh token rotation (H5). These are small, targeted changes to `ws/handler.go`, `database/migrate.go`, and `auth_usecase.go`.

2. **Shared Module (P1)** — Foundation for all mobile apps: token storage + auth interceptor (`flutter_secure_storage`), WebSocket client with reconnection + state resync, shared domain models (User, Ride, Driver, Vehicle, LatLng, ErrorResponse), and integration with the existing `sakai_api_client` + `SakaiApiSupport`.

3. **Passenger App (P1)** — Registration/login with session restoration, home screen with map + location, ride request flow with idempotency key, "Waiting for driver" state with WebSocket event handling, active ride tracking screen, ride completion summary, and ride cancellation.

## Technical Context

**Language/Version**: Go 1.21+ (backend fixes), Dart 3.10+ / Flutter 3.x (mobile)
**Primary Dependencies**:
- Backend: `gorilla/websocket` (read limits/deadlines), `embed.FS` + `iofs` (migrations), `database.Transact` (token rotation)
- Mobile: `flutter_secure_storage` (tokens), generated `sakai_api_client` (HTTP), `package:sakai_shared` (shared exports), map provider (NEEDS CLARIFICATION — Google Maps vs Mapbox)
**Storage**: `flutter_secure_storage` for tokens; PostgreSQL/Redis untouched by this feature
**Testing**: `go test -race ./...` (backend), `flutter test` (shared module + passenger app)
**Target Platform**: iOS simulator + Android emulator (Flutter); Go backend unchanged deployment model
**Project Type**: Backend hardening + cross-platform mobile app (MVVM)
**Performance Goals**: Session restoration < 3s (SC-003), ride request < 10s (SC-002), WS reconnect < 5s (SC-004), zero crashes (SC-007)
**Constraints**: Must not modify existing backend business logic or endpoints. Only 3 backend files change. Mobile must use feature-first MVVM per constitution. All HTTP goes through shared module, never from views.
**Scale/Scope**: 6 user stories, 20 functional requirements, ~49 tasks estimated (3 backend + 15 shared + 31 passenger screens/flows)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Constitution Principle | Applicability | Compliance |
|---|---|---|
| I. Contract-First API | Mobile must use `sakai_api_client` generated from `openapi/swagger.yaml`. No invented endpoints. | ✅ All mobile HTTP calls use the generated client. OpenAPI spec is authoritative for request/response shapes. |
| II. Clean Architecture Layers | Mobile: feature-first MVVM (`features/<feature>/{models,repositories,view_models,views}`). Backend: strict `delivery → usecase → domain ← repository`. | ✅ Passenger app uses feature-first MVVM. Backend fixes touch existing files without violating layer boundaries (ws/handler.go is delivery, migrate.go is infrastructure, auth_usecase.go is usecase). |
| III. Test-First | Backend use-case changes require unit tests. Flutter tests for shared module and passenger flows. | ✅ Backend: add tests for transactional refresh (H5) and WS hardening (H2). Mobile: unit tests for token interceptor, WS reconnection, model serialization. |
| IV. Generated Code Integrity | Must not hand-edit `mobile/shared/lib/api_client/`. Use codegen pipeline. | ✅ All Dart client usage goes through `package:sakai_shared` exports. Any spec changes → `./scripts/generate-client.sh`. |
| V. Error Contract Stability | Mobile must branch on `ErrorCode`, not message strings. | ✅ FR-020 requires user-friendly error mapping; shared module maps `ErrorResponse.code` to display strings. |
| Additional Constraints | Token storage via secure storage (no plaintext). Idempotency-Key on `POST /rides`. WS envelope format `{ event, payload }`. | ✅ FR-004 uses `flutter_secure_storage`. FR-014 uses client-generated UUID idempotency key. FR-008 parses WS envelope. |
| Mobile MVVM Rules | 1:1 View/ViewModel, no logic in views, no HTTP in widgets, navigation in views, constructor injection. | ✅ All passenger screens follow this. Shared module provides repositories, not view code. |

**Result**: All applicable gates pass. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/002-phase2-shared-passenger/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

This feature modifies backend files and adds mobile app structure:

```text
E:\Projects\SakAI/
├── backend/
│   └── internal/
│       ├── delivery/ws/handler.go              # H2: Add SetReadLimit, SetReadDeadline, PongHandler
│       └── infrastructure/database/
│           └── migrate.go                      # H3: Embed migrations via go:embed
│       └── usecase/
│           └── auth_usecase.go                 # H5: Wrap token rotation in Transact
├── mobile/
│   └── shared/
│       └── lib/
│           ├── sakai_shared.dart               # Public exports (already exists)
│           ├── api/sakai_api_support.dart      # API client factory (already exists)
│           ├── models/                         # NEW: Shared domain models
│           │   ├── user.dart
│           │   ├── ride.dart
│           │   ├── driver.dart
│           │   ├── vehicle.dart
│           │   └── error_response.dart
│           ├── auth/                           # NEW: Token storage + interceptor
│           └── ws/                             # NEW: WebSocket client
│               ├── ws_client.dart
│               └── ws_events.dart
│   └── passenger/
│       └── lib/
│           ├── app/
│           │   └── app.dart                    # Root widget + routing
│           └── features/
│               ├── auth/
│               │   ├── repositories/auth_repository.dart
│               │   ├── view_models/auth_view_model.dart
│               │   └── views/
│               │       ├── login_view.dart
│               │       └── register_view.dart
│               ├── home/
│               │   ├── repositories/location_repository.dart
│               │   ├── view_models/home_view_model.dart
│               │   └── views/home_view.dart
│               ├── waiting/
│               │   ├── view_models/waiting_view_model.dart
│               │   └── views/waiting_view.dart
│               ├── active_ride/
│               │   ├── view_models/active_ride_view_model.dart
│               │   └── views/active_ride_view.dart
│               ├── ride_complete/
│               │   ├── view_models/ride_complete_view_model.dart
│               │   └── views/ride_complete_view.dart
│               └── cancellation/
│                   └── views/cancel_dialog.dart
└── (no other files modified)
```

**Structure Decision**: Option 3 (Mobile + API). The backend is already built — only 3 files change. The mobile layer follows the project's feature-first MVVM convention with `features/<feature>/{models,repositories,view_models,views}`. The shared module provides cross-cutting concerns (auth, WS, models) that both current and future driver apps consume.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations. The architecture follows the established patterns:
- Backend fixes are surgical changes to existing files (no new layers).
- Mobile uses the established `features/<feature>/` MVVM layout.
- Shared module provides the infrastructure layer that the constitution requires.
