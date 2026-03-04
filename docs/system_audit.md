# SakAI Backend — System Audit Report

> **Audited:** 2026-02-19 | **Scope:** Go backend (no frontend yet) | **Session:** Post-fix audit (v2)

This report reflects the state of the codebase **after** two rounds of hardening. Fixed issues are marked ✅. Open issues remain numbered and prioritised.

---

## ✅ Issues Resolved Since Last Audit

| #   | Issue                                                   | Fix Applied                                                                  |
| --- | ------------------------------------------------------- | ---------------------------------------------------------------------------- |
| 1   | Race condition on `RequestRide`                         | DB unique partial index on `passenger_id WHERE active`                       |
| 2   | `Decline` didn't clear `driver_id`                      | `ClearDriver` repo method + `Decline` use-case fix                           |
| 3   | Driver location sent to driver, not passenger           | `UpdateLocation` now sends to `ride.PassengerID`                             |
| 4   | `getVehicle` never called                               | Called in `GetByID` / `GetByEmail` for driver-role users                     |
| 5   | Rides hung forever — no offer expiry                    | Background `expiry.Worker` with 30 s timeout, 15 s tick                      |
| 6   | `Complete` silently swallowed driver status reset error | Replaced `_ =` with `log.Printf`                                             |
| 7   | No LatLng validation                                    | `binding:"min=-90,max=90"` / `binding:"min=-180,max=180"` on `LatLng`        |
| 8   | No rate limiting on `/auth/register` + `/auth/login`    | Token-bucket middleware, 10 rpm / IP                                         |
| 9   | `FindNearbyOnline` returned unbounded slice             | `LIMIT 1` — only closest driver needed                                       |
| 10  | `Register` not transactional — orphaned users possible  | `CreateWithTokens` wraps user + vehicle + token in one TX                    |
| 11  | JWT weak default could start in production              | `configs.Load()` panics if `JWT_SECRET == default && APP_ENV != development` |
| 12  | `password` vs `password_hash` column mismatch           | Migration renamed to `password_hash`                                         |

---

## 🔥 Critical Issues

### C1. Expiry Worker Cancels Rides Without Notifying Passenger

**File:** [`expiry/worker.go:65`](file:///e:/Projects/SakAI/backend/internal/infrastructure/expiry/worker.go#L65)

`CancelExpiredOffers` issues a raw `UPDATE` in the DB. No WebSocket event is emitted to the passenger. The passenger's client will never learn the offer expired until they call `GET /rides/active` manually. On mobile, where the app stays alive in the foreground, this is a silent freeze.

**Fix:** After `CancelExpiredOffers`, query for the cancelled ride IDs, emit `EventRideOfferExpired` to each affected `passenger_id` via the Hub. This requires the hub to be injected into the worker.

---

### C2. `FindNearbyOnline` Does Not Exclude Drivers Already on a Ride

**File:** [`driver_repo.go`](file:///e:/Projects/SakAI/backend/internal/repository/postgres/driver_repo.go)

`FindNearbyOnline` queries `WHERE status = 'online'` but does **not** exclude drivers who have an active, non-terminal ride. A driver who accepted a ride still appears as `online` (status is `accepted`, not `online`), so this case is partially guarded — but it relies on the status update being atomic. A race between `Accept` and `FindNearbyOnline` could still deliver a second offer to a driver before their status updates.

**Fix:** Add `AND NOT EXISTS (SELECT 1 FROM rides WHERE driver_id = d.user_id AND status NOT IN ('completed','cancelled'))` to the query.

---

## ⚠️ High-Risk Issues

### H1. `SendToDriver` Alias Is Dead Code and a Trap

**File:** [`hub.go:137-139`](file:///e:/Projects/SakAI/backend/internal/delivery/ws/hub.go#L137-L139)

```go
func (h *Hub) SendToDriver(driverID uuid.UUID, event EventType, payload any) {
    h.SendToUser(driverID, event, payload)
}
```

`SendToDriver` is never called after fixing the broadcast bug. It remains as a public method that _looks_ intentful. Any future developer calling `SendToDriver` thinking it routes through different logic will reintroduce the original bug.

**Fix:** Delete the method. Any send to a driver is just `SendToUser`.

---

### H2. No `SetReadDeadline` / `ReadLimit` on WebSocket Connections

**File:** [`ws/handler.go`](file:///e:/Projects/SakAI/backend/internal/delivery/ws/handler.go)

The `writePump` sends pings every `WSPingInterval`, but nowhere is a **read deadline** set on the connection. If a client stops sending pong frames or data, the server holds the goroutine and the open connection indefinitely — a resource leak.

There is also no `conn.SetReadLimit(...)` — a rogue client can stream arbitrarily large frames and exhaust server memory.

**Fix:**

```go
conn.SetReadLimit(4096) // no message from client exceeds this
conn.SetReadDeadline(time.Now().Add(2 * pingInterval)) // reset on each pong
conn.SetPongHandler(func(string) error {
    conn.SetReadDeadline(time.Now().Add(2 * pingInterval))
    return nil
})
```

---

### H3. Migrations Path Is Fragile — Breaks Outside `backend/cmd/api/`

**File:** [`config.go`](file:///e:/Projects/SakAI/backend/configs/config.go), [`main.go`](file:///e:/Projects/SakAI/backend/cmd/api/main.go)

`MIGRATIONS_DIR` defaults to `../migrations`. This is resolves correctly only if the binary's CWD is `backend/cmd/api/`. In Docker (`WORKDIR /app/`), CI, or `go test`, the path resolves incorrectly and migrations silently fail to run.

**Fix:** Embed migration files with `//go:embed`:

```go
//go:embed migrations/*.sql
var migrationFS embed.FS
```

Then pass `iofs.New(migrationFS, "migrations")` to `golang-migrate` instead of a file path.

---

### H4. No Request Body Size Limit

**File:** [`router/router.go`](file:///e:/Projects/SakAI/backend/internal/delivery/http/router/router.go)

Gin's default allows arbitrarily large request bodies. A malicious client can POST a multi-MB `notes` field or registration payload and exhaust server memory — a cheap DoS vector.

**Fix:** Add global middleware:

```go
r.Use(func(c *gin.Context) {
    c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, 1<<20) // 1 MiB
    c.Next()
})
```

---

### H5. `Refresh` Token Rotation Has a TOCTOU Window

**File:** [`auth_usecase.go:108-115`](file:///e:/Projects/SakAI/backend/internal/usecase/auth_usecase.go#L108-L115)

`Refresh` does: `Delete(old token)` → `GetByID(user)` → `Store(new token)`. If the server crashes between `Delete` and `Store`, the user loses their session permanently — they cannot refresh (token deleted) and cannot log in without their password.

**Fix:** Wrap the full token rotation in `database.Transact`.

---

## 🧩 Logic & State Problems

### L1. `Decline` Has No Re-Matching Logic

After a driver declines, the ride status returns to `requested` but no new driver is notified. The passenger is silently stranded until they poll `GET /rides/active`. There is no automatic re-dispatch.

**Mitigation:** Emit `EventRideDeclined` to the passenger (current code does this via `BroadcastToRide`). The passenger client should call `RequestRide` again with the same idempotency key. Document this expectation in the API contract.

**Long-term:** Add server-side re-dispatch: after `Decline`, immediately run `FindNearbyOnline` again excluding the declining driver and send a new offer.

---

### L2. `Cancel` Is Accessible to Both Passenger and Driver — No Permission Differentiation

**File:** [`ride_handler.go:112-127`](file:///e:/Projects/SakAI/backend/internal/delivery/http/ride_handler.go#L112-L127)

`Cancel` reads `role` from the context but doesn't actually restrict which states each role can cancel in. A driver could theoretically cancel an `accepted` ride via `POST /rides/:id/cancel` — which succeeds if `Cancel` doesn't enforce per-role state validity.

**Fix:** In `RideUseCase.Cancel`, validate that the requesting role is permitted to cancel in the current state (e.g., driver cannot cancel an `in_progress` ride).

---

### L3. `GetByID` Does Not Verify the Caller Is a Participant

**File:** [`ride_handler.go:67-80`](file:///e:/Projects/SakAI/backend/internal/delivery/http/ride_handler.go#L67-L80)

`GET /rides/:rideId` accepts any authenticated user ID. A passenger can fetch another passenger's ride details (including their origin, destination, address, and driver info) by guessing/knowing a ride UUID.

**Fix:** In `RideUseCase.GetByID`, verify `userID == ride.PassengerID || userID == ride.DriverID`. Return `ErrForbidden` otherwise.

---

## 🌐 Real-Time / WebSocket Risks

### W1. WebSocket Required for Correctness — No HTTP Fallback or Event Replay

If a passenger's WebSocket drops, they will miss `ride.accepted`, `ride.arrived`, `driver.location_updated`, etc. The only recovery path is `GET /rides/active`, which must be manually invoked by the client. There is no event history endpoint.

**Mitigation (short-term):** Document that clients must call `GET /rides/active` on reconnect.

**Fix (long-term):** Add a `ride_events` table. On every significant state change, write an event row. Add `GET /rides/:id/events?since=<seq>` for replay.

---

### W2. One WebSocket per User — Silent Eviction of Previous Connection

**File:** [`hub.go:101-104`](file:///e:/Projects/SakAI/backend/internal/delivery/ws/hub.go#L101-L104)

When a user reconnects, the old connection is closed without sending a `CloseMessage` notification or a user-readable error. The first tab gets a silent dead socket. Rapid reconnect loops (mobile backgrounding) can cause the new connection to be immediately displaced by the _next_ reconnect.

**Fix:** Send a `CloseMessage` with reason code `1000` (normal closure) before evicting. Add backoff on the client side.

---

### W3. Slow Consumer Eviction Drops Critical Ride Events

**File:** [`hub.go:130-133`](file:///e:/Projects/SakAI/backend/internal/delivery/ws/hub.go#L130-L133)

A full send buffer (64 messages) causes immediate eviction — all in-channel events are lost. A critical event like `ride.accepted` can be permanently dropped with no retry.

**Fix:** Persist ride-state events to DB and provide a replay mechanism (see W1 long-term fix).

---

### W4. In-Memory Hub — Not Multi-Instance Safe

**File:** [`hub.go:82-86`](file:///e:/Projects/SakAI/backend/internal/delivery/ws/hub.go#L82-L86)

The Hub is a single in-memory map. Running more than one API instance (horizontal scaling, rolling deploys) means `SendToUser` silently no-ops if the user is connected to a different instance.

**Fix:** Replace with Redis Pub/Sub or NATS. Each server subscribes to a per-user channel and forwards locally.

---

## 🗄 Data Integrity Risks

### D1. `Refresh` Token Rotation Not Transactional (see H5)

### D2. No DB-Level `ON DELETE CASCADE` on `refresh_tokens`

If a user row is deleted without going through the application layer, their refresh tokens become orphaned rows with a non-existent `user_id` FK (assuming FK exists). Confirm FK constraints are in place on the `refresh_tokens.user_id` column in the appropriate migration.

### D3. `schema_migrations` Advisory Lock — Two-Instance Race

`golang-migrate` uses a Postgres advisory lock. With the `pgx/v5` driver, verify that the advisory lock is correctly acquired — some driver versions have known issues with advisory lock semantics. A double-migration can corrupt data.

---

## 🔐 Security Concerns

### S1. WebSocket `CheckOrigin` Allows All Origins

**File:** [`ws/handler.go`](file:///e:/Projects/SakAI/backend/internal/delivery/ws/handler.go)

```go
CheckOrigin: func(r *http.Request) bool { return true }
```

Allows WebSocket upgrades from any domain — a CSRF vector for web clients.

**Fix:** Read `ALLOWED_ORIGINS` from config and enforce in `CheckOrigin`.

---

### S2. Refresh Token in JSON Response Body

Refresh tokens in the response body are accessible to JavaScript — an XSS attack can steal them. For web clients, prefer `HttpOnly` + `Secure` cookies. Mobile clients are not affected.

---

### S3. No Helmet / Security Headers Middleware

No `X-Frame-Options`, `X-Content-Type-Options`, `Strict-Transport-Security`, or `Content-Security-Policy` headers are set. A future admin or web client will be vulnerable to clickjacking and MIME sniffing.

**Fix:** Add a security-headers middleware (one `gin.Use(...)` with a few header writes).

---

## 📈 Scalability Risks

### SC1. No PostGIS Index on Driver Location

**File:** [`003_create_drivers.sql`](file:///e:/Projects/SakAI/migrations/003_create_drivers.sql)

The `GEOGRAPHY` column used by `ST_DWithin` requires a **GIST index** for efficient radius queries. Without `CREATE INDEX ON drivers USING GIST(location)`, radius queries do a sequential scan. With thousands of online drivers this is a full-table sequential scan on every ride request.

**Fix:**

```sql
CREATE INDEX ON drivers USING GIST(location);
```

---

### SC2. No Pagination on Future List Endpoints

No list endpoints exist yet, but the pattern isn't established. When trip history, driver lists, or ride listings are added, they need cursor-based or offset pagination from day one.

---

## 🎨 UX / System Feedback Gaps

| Gap                                                                            | Impact                                               | Recommendation                                                               |
| ------------------------------------------------------------------------------ | ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| Expired offers not sent to passenger via WS                                    | Passenger UI freezes silently after 30s              | Emit `ride.offer_expired` when worker cancels (see C1)                       |
| `Decline` emits `ride.declined` to driver, not passenger via generic broadcast | Passenger learns driver declined, but no re-dispatch | Document or implement auto re-dispatch                                       |
| No structured error codes for `notes` max-length violation                     | Client sees raw validation error string              | Standardize to `{"code":"VALIDATION_ERROR","field":"notes","message":"..."}` |

---

## ✅ Strengths

| Area                            | Observation                                                                            |
| ------------------------------- | -------------------------------------------------------------------------------------- |
| **State machine**               | `CanTransitionTo` guard is clean and centralized                                       |
| **Idempotency**                 | Idempotency key on ride requests mitigates double-taps                                 |
| **Auth flow**                   | Token rotation on refresh is correctly implemented                                     |
| **WebSocket hub**               | `sync.Once` on channel close prevents double-close panics                              |
| **Error mapping**               | Sentinel errors in domain layer cleanly separate business logic from HTTP status codes |
| **Concurrency safety**          | Hub uses `sync.RWMutex` correctly                                                      |
| **Graceful shutdown**           | `main.go` uses `signal.Notify` + `srv.Shutdown` correctly                              |
| **Rate limiting**               | IP-based token-bucket on auth endpoints with background cleanup                        |
| **Atomic registration**         | `CreateWithTokens` wraps user + vehicle + token in one DB transaction                  |
| **Offer expiry**                | Background worker cleans up stale offers; non-fatal, logs on error                     |
| **JWT security**                | Startup panic guard prevents production use of weak default secret                     |
| **Background worker lifecycle** | Worker context is tied to graceful shutdown via `workerCancel`                         |

---

## 🛠 Fix Recommendations — Priority Order

| #   | Issue                                                 | Severity    | Effort                               |
| --- | ----------------------------------------------------- | ----------- | ------------------------------------ |
| C1  | Expiry worker doesn't notify passenger via WS         | 🔥 Critical | S — inject Hub into worker           |
| C2  | `FindNearbyOnline` matches drivers already on a ride  | 🔥 Critical | S — add subquery to SQL              |
| H1  | `SendToDriver` dead alias — trap for future devs      | ⚠️ High     | XS — delete the method               |
| H2  | No `SetReadDeadline` or `ReadLimit` on WS connections | ⚠️ High     | S — add to `ws/handler.go`           |
| H3  | Migrations path fragile outside CWD                   | ⚠️ High     | M — use `embed.FS`                   |
| H4  | No request body size limit                            | ⚠️ High     | XS — `MaxBytesReader` in middleware  |
| H5  | `Refresh` token rotation not transactional            | ⚠️ High     | M — wrap in `database.Transact`      |
| L1  | No re-dispatch after driver decline                   | 🧩 Logic    | M — auto re-dispatch from use case   |
| L2  | `Cancel` lacks per-role state validation              | 🧩 Logic    | S — add state+role guard in use case |
| L3  | `GetByID` doesn't verify caller is participant        | 🔐 Security | XS — add participant check           |
| S1  | `CheckOrigin: true` allow all WS origins              | 🔐 Security | S — config-driven allow-list         |
| S3  | No security headers                                   | 🔐 Security | XS — add middleware                  |
| W1  | No WS event replay on reconnect                       | 🌐 WS       | L — `ride_events` table + replay API |
| W4  | In-memory hub — not multi-instance safe               | 📈 Scale    | L — Redis/NATS pub-sub               |
| SC1 | No GIST index on driver location                      | 📈 Scale    | XS — one SQL line                    |
| D2  | `refresh_tokens` FK cascade not verified              | 🗄 Data     | XS — confirm migration               |
