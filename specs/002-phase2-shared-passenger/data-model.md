# Data Model: Phase 2 Fixes + Shared Module + Passenger App

**Date**: 2026-04-11
**Feature**: `specs/002-phase2-shared-passenger`

## Backend Entities (Phase 2 Fixes — No Schema Changes)

These fixes modify behavior only — no database schema or API contract changes.

### H2: WebSocket Connection

**File**: `backend/internal/delivery/ws/handler.go`

| Property | Value |
|---|---|
| Read Limit | 4096 bytes per message |
| Read Deadline | `2 × WSPingInterval` (default 60s) |
| Pong Handler | Resets read deadline on each pong |
| Effect | Dead connections closed within 60s; rogue clients capped at 4KB frames |

### H3: Embedded Migrations

**File**: `backend/internal/infrastructure/database/migrate.go`

| Property | Value |
|---|---|
| Source | `//go:embed migrations/*.sql` → `embed.FS` |
| Driver | `iofs.New(migrationFS, "migrations")` passed to golang-migrate |
| Effect | Binary runs migrations from any working directory |

### H5: Transactional Token Rotation

**File**: `backend/internal/usecase/auth_usecase.go`

| Property | Value |
|---|---|
| Transaction scope | `Delete(old token)` + `Store(new token)` |
| Effect | Crash between operations does not orphan user session |

---

## Mobile Domain Models (Shared Module)

### User

| Field | Type | Validation |
|---|---|---|
| `id` | `String` (UUID) | Non-null |
| `name` | `String` | 2–100 chars |
| `email` | `String` | Valid email format |
| `role` | `UserRole` enum | `passenger`, `driver`, `admin`, `superadmin` |

**Source**: Generated from OpenAPI `UserResponse` schema in `sakai_api_client`.

### Ride

| Field | Type | Validation |
|---|---|---|
| `id` | `String` (UUID) | Non-null |
| `passengerId` | `String` (UUID) | Non-null |
| `driverId` | `String?` (UUID) | Null when no driver assigned |
| `pickupLat` | `double` | -90 to 90 |
| `pickupLng` | `double` | -180 to 180 |
| `destLat` | `double` | -90 to 90 |
| `destLng` | `double` | -180 to 180 |
| `status` | `RideStatus` enum | `requested`, `accepted`, `arrived`, `in_progress`, `completed`, `cancelled` |
| `notes` | `String?` | Max 500 chars |
| `createdAt` | `DateTime` | Non-null |
| `updatedAt` | `DateTime` | Non-null |

**Source**: Generated from OpenAPI `RideResponse` schema. Shared model wraps the generated type with convenience accessors.

### Driver

| Field | Type | Validation |
|---|---|---|
| `userId` | `String` (UUID) | Non-null |
| `name` | `String` | Non-null |
| `status` | `DriverStatus` enum | `online`, `offline` |
| `vehicle` | `Vehicle` | Non-null when assigned |

### Vehicle

| Field | Type | Validation |
|---|---|---|
| `make` | `String` | Non-null |
| `model` | `String` | Non-null |
| `year` | `int` | ≥ 1990 |
| `color` | `String` | Non-null |
| `plateNumber` | `String` | Non-null |

### LatLng

| Field | Type | Validation |
|---|---|---|
| `lat` | `double` | -90 to 90 |
| `lng` | `double` | -180 to 180 |
| `heading` | `double?` | 0–360 (optional compass bearing) |

### ErrorResponse

| Field | Type | Validation |
|---|---|---|
| `code` | `ErrorCode` enum | Non-null — this is the branching key |
| `message` | `String` | Human-readable (not stable API) |
| `field` | `String?` | Which field failed validation |

---

## WebSocket Events

| Event Name | Payload Type | Description |
|---|---|---|
| `ride.accepted` | `RideResponse` | Driver accepted the ride; payload includes driver + vehicle info |
| `ride.declined` | `{ ride_id: String }` | Driver declined |
| `ride.offer_expired` | `{ ride_id: String, reason: String }` | Offer timed out without driver response |
| `ride.arrived` | `{ ride_id: String }` | Driver arrived at pickup |
| `ride.status_changed` | `{ ride_id: String, status: RideStatus }` | Ride state transition |
| `ride.cancelled` | `{ ride_id: String, cancelled_by: CancelledBy }` | Ride cancelled by passenger, driver, or system |
| `driver.location_updated` | `{ ride_id: String, lat: double, lng: double, heading: double? }` | Driver GPS update |

**Envelope**: All events arrive as `{ "event": "<name>", "payload": { ... } }`.

---

## Token Pair

| Token | Storage | Lifetime |
|---|---|---|
| Access Token | `flutter_secure_storage` | 60 minutes |
| Refresh Token | `flutter_secure_storage` | 30 days (rotated on each use) |

---

## State Transitions (Ride)

```
requested → accepted → arrived → in_progress → completed
    ↓           ↓          ↓
  cancelled   cancelled  cancelled
```

Transitions are enforced by the backend `CanTransitionTo` guard. The mobile app only reflects the current state — it does not enforce transitions.

---

## Validation Rules (from Requirements)

| Rule | Source | Enforcement |
|---|---|---|
| Name 2–100 chars | FR-010 | Registration form validator |
| Email format | FR-010 | Registration form validator |
| Password ≥ 8 chars | FR-010 | Registration form validator |
| Role = "passenger" | FR-010 | Hardcoded in registration call |
| LatLng bounds | FR-013 | Map picker + form validator |
| Notes max 500 chars | FR-014 | Optional notes field validator |
| Idempotency-Key UUID | FR-014 | Generated client-side, cached |
| Cancel hidden in `in_progress` | FR-018 | UI visibility based on ride status |
| Loading state during API calls | FR-020 | ViewModel busy flag disables submit |
