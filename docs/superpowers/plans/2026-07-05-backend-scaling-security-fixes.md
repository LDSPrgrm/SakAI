# Backend Scaling & Security Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remediate the 2026-07-05 backend audit — fix the PostGIS degrees-vs-meters bug, slim the GPS hot path, stop token leakage into logs, and close the remaining scaling/security gaps.

**Architecture:** Ten independent, individually-committable tasks against the Go backend (`backend/`). No new services; all changes are surgical edits to existing clean-architecture layers (repository/usecase/delivery). One new SQL migration (032).

**Tech Stack:** Go 1.x, Gin, pgx/v5, PostGIS, Redis (go-redis), Prometheus client_golang, gorilla/websocket.

## Global Constraints

- Working dir for all commands: `C:\Users\EDWARD\Documents\SakAI\backend`
- Verify with: `go build ./... ` then `go test ./...` — full suite must stay green after every task.
- All SQL stays parameterized (`$N`) — no string interpolation.
- Follow existing code style: table-driven tests, `domain.Err*` sentinel errors, comments explain constraints not mechanics.
- Commit after each task using conventional commits (user has `git-commit-helper` skill — use it before committing).
- Migration files live in `internal/infrastructure/database/migrations/`; next free number is **032**. Migrations run embedded at startup.
- Do NOT touch `.env` (gitignored, contains local secrets).

---

### Task 1: PostGIS geography cast — nearby radius in meters, not degrees

The `drivers.location` column is `GEOMETRY(Point,4326)`. `ST_DWithin(location, pt, 5000)` therefore measures 5000 **degrees** — matches every driver on Earth, and `ORDER BY ST_Distance` sorts them all. Cast to `::geography` so the unit is meters, and add a functional GiST index so the cast is index-assisted.

**Files:**
- Modify: `internal/repository/postgres/driver_repo.go` (queries at ~lines 91-109 and 135-159)
- Create: `internal/infrastructure/database/migrations/032_geography_driver_index.up.sql`
- Create: `internal/infrastructure/database/migrations/032_geography_driver_index.down.sql`

**Interfaces:** No Go signature changes — SQL-only edits. `radiusMeters float64` now genuinely means meters.

- [ ] **Step 1: Write the migration**

`032_geography_driver_index.up.sql`:
```sql
-- 032_geography_driver_index.up.sql
-- FindNearbyOnline* now cast location to geography so ST_DWithin/ST_Distance
-- operate in meters (geometry-4326 units are degrees — the old 5000 "meter"
-- radius matched every driver on the planet). This functional index lets the
-- planner prune the cast form; the old geometry index no longer matches any
-- query and is dropped.
CREATE INDEX IF NOT EXISTS idx_drivers_online_location_geog
    ON drivers USING GIST ((location::geography))
    WHERE status = 'online';

DROP INDEX IF EXISTS idx_drivers_online_location;
```

`032_geography_driver_index.down.sql`:
```sql
-- 032_geography_driver_index.down.sql
CREATE INDEX IF NOT EXISTS idx_drivers_online_location
    ON drivers USING GIST (location)
    WHERE status = 'online';

DROP INDEX IF EXISTS idx_drivers_online_location_geog;
```

(Check `003_create_drivers.up.sql:18-20` for the exact original index definition and mirror its `WHERE` clause verbatim in the down migration.)

- [ ] **Step 2: Cast the two nearby queries in `driver_repo.go`**

In `FindNearbyOnline` replace the `ST_DWithin` / `ORDER BY` portion:
```sql
  AND ST_DWithin(
        location::geography,
        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
        $3
      )
ORDER BY ST_Distance(location::geography, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography)
```

In `FindNearbyOnlineByType` likewise:
```sql
       ST_Distance(d.location::geography, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography) AS distance_m
...
  AND ST_DWithin(
        d.location::geography,
        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
        $3
      )
```
`ST_Y(location)`/`ST_X(location)` selects stay geometry (unchanged). `distance_m` is now real meters — no DTO change needed.

- [ ] **Step 3: Build + test**

Run: `go build ./... ; go test ./...`
Expected: PASS (repo layer has no live-Postgres unit tests; correctness is covered by E2E later).

- [ ] **Step 4: Commit**

`fix(driver): measure nearby radius in meters via geography cast`

---

### Task 2: GPS ping hot path — one conditional UPDATE instead of SELECT+UPDATE, drop hot-path logs

Every driver ping currently runs `GetByUserID` (SELECT) purely to check `status='online'`, then `UpdateLocation` (UPDATE), and logs driver status at INFO on every ping. Fold the status check into the UPDATE's WHERE clause; 0 rows affected ⇒ not online ⇒ `domain.ErrForbidden`.

**Files:**
- Modify: `internal/repository/postgres/driver_repo.go` (`UpdateLocation`, ~lines 76-85)
- Modify: `internal/usecase/driver_usecase.go` (`UpdateLocation`, lines 40-56)
- Test: existing usecase tests — find with `grep -l "UpdateLocation" internal/usecase/*_test.go` and update mocks.

**Interfaces:**
- Produces: `driverRepo.UpdateLocation(ctx, userID, loc)` now returns `domain.ErrForbidden` when the driver row is missing or not online (previously unconditional update).
- `driverUseCase.UpdateLocation` behavior unchanged from the handler's perspective (still returns `domain.ErrForbidden` for offline drivers) — handler needs no edit.

- [ ] **Step 1: Update or write the failing usecase test**

Locate the existing test for offline-driver rejection. Rewire it so the *mock repo's* `UpdateLocation` returns `domain.ErrForbidden` (instead of the mock `GetByUserID` returning an offline driver), and assert the usecase surfaces `domain.ErrForbidden` and does NOT call the incident repo. Add/keep a happy-path test: repo `UpdateLocation` returns nil ⇒ usecase returns nil and calls `incidentRepo.FindActiveByDriver` once.

- [ ] **Step 2: Run tests to verify current failure**

Run: `go test ./internal/usecase/ -run TestDriver -v`
Expected: FAIL (mock still asserts `GetByUserID` is called / new expectation unmet).

- [ ] **Step 3: Implement**

`driver_repo.go`:
```go
// UpdateLocation writes the driver's position only while they are online —
// the status predicate replaces a separate SELECT on the GPS hot path.
// Zero rows affected means offline (or no driver row): ErrForbidden.
func (r *driverRepo) UpdateLocation(ctx context.Context, userID uuid.UUID, loc domain.DriverLocation) error {
	const q = `
		UPDATE drivers
		SET location  = ST_SetSRID(ST_MakePoint($2, $3), 4326),
		    updated_at = NOW()
		WHERE user_id = $1
		  AND status  = 'online'`
	tag, err := r.db.Exec(ctx, q, userID, loc.Lng, loc.Lat)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrForbidden
	}
	return nil
}
```

`driver_usecase.go` — replace lines 40-56 with:
```go
func (uc *driverUseCase) UpdateLocation(ctx context.Context, driverID uuid.UUID, loc domain.DriverLocation) error {
	// Repo enforces the online-only rule in the UPDATE's WHERE clause so the
	// hot path costs one round-trip instead of SELECT+UPDATE.
	if err := uc.driverRepo.UpdateLocation(ctx, driverID, loc); err != nil {
		return err
	}
	uc.captureIncidentTrail(ctx, driverID, loc)
	return nil
}
```
Both `log.Printf` calls in the old body are deleted (they also logged driver status per ping — noise + prior privacy flag). If `log` becomes unused in the file, remove the import — `captureIncidentTrail` still uses it, so it likely stays.

- [ ] **Step 4: Run tests**

Run: `go test ./... `
Expected: PASS.

- [ ] **Step 5: Commit**

`perf(driver): fold online check into location UPDATE, drop per-ping logs`

---

### Task 3: Perf middleware — Prometheus histogram, sample the DB writes

`middleware/perf.go` spawns a goroutine + DB INSERT per request. Add a Prometheus histogram (always) and keep the DB table only as a 1-in-100 sample (admin dashboard may read `http_request_timings` — do not remove the table or `RecordHTTPTiming`).

**Files:**
- Modify: `internal/delivery/http/middleware/perf.go`
- Test: `internal/delivery/http/middleware/perf_test.go` (create if absent)

**Interfaces:**
- Consumes: existing `PerfSampler` interface (unchanged).
- Produces: Prometheus metric `sakai_http_request_duration_seconds{method,path,status}` on the default registry (scraped by the existing `/metrics` promhttp handler).

- [ ] **Step 1: Write the failing test**

```go
package middleware

import (
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	dto "github.com/prometheus/client_model/go"
)

func TestPerfRecordsHistogram(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(Perf(nil)) // nil sampler: histogram must still record
	r.GET("/ping", func(c *gin.Context) { c.Status(200) })

	req := httptest.NewRequest("GET", "/ping", nil)
	r.ServeHTTP(httptest.NewRecorder(), req)

	mfs, err := prometheus.DefaultGatherer.Gather()
	if err != nil {
		t.Fatal(err)
	}
	for _, mf := range mfs {
		if mf.GetName() == "sakai_http_request_duration_seconds" {
			for _, m := range mf.GetMetric() {
				if m.GetHistogram().GetSampleCount() >= 1 {
					return
				}
			}
		}
	}
	var _ *dto.MetricFamily // keep import if unused branches change
	t.Fatal("sakai_http_request_duration_seconds not recorded")
}
```
(Adjust imports to what compiles; the assertion is: after one request, the histogram family exists with ≥1 sample.)

- [ ] **Step 2: Run test — expect FAIL** (`metric not recorded`).

- [ ] **Step 3: Implement**

```go
var (
	httpDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "sakai_http_request_duration_seconds",
		Help:    "HTTP request latency by matched route template.",
		Buckets: prometheus.DefBuckets,
	}, []string{"method", "path", "status"})
	perfSampleCounter atomic.Uint64
)

// perfDBSampleEvery: 1-in-N requests also land in http_request_timings so the
// admin dashboard keeps data without a per-request INSERT write amplifier.
const perfDBSampleEvery = 100
```
In the handler body, after computing `path`, `method`, `status`, `elapsed`:
```go
httpDuration.WithLabelValues(method, path, strconv.Itoa(status)).Observe(elapsed / 1000)

if sampler != nil && perfSampleCounter.Add(1)%perfDBSampleEvery == 0 {
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		if err := sampler.RecordHTTPTiming(ctx, method, path, status, elapsed); err != nil {
			log.Printf("perf-middleware: record timing: %v", err)
		}
	}()
}
```
Keep the `sampler == nil` fast-path constructor but note the histogram must record even with nil sampler (restructure: nil sampler no longer short-circuits the whole middleware).
Imports to add: `strconv`, `sync/atomic`, `github.com/prometheus/client_golang/prometheus`, `github.com/prometheus/client_golang/prometheus/promauto`.

- [ ] **Step 4: Run** `go test ./internal/delivery/http/middleware/ -v` → PASS, then `go test ./...` → PASS.

- [ ] **Step 5: Commit** — `perf(http): prometheus latency histogram, sample DB timings 1-in-100`

---

### Task 4: DB pool sizing from environment

Pool is hardcoded `MaxConns: 20` in `cmd/api/main.go:55-61`; make it deploy-tunable.

**Files:**
- Modify: `configs/config.go` (struct + `Load()`)
- Modify: `cmd/api/main.go:55-61`
- Test: `configs/config_test.go` (extend existing pattern if present)

**Interfaces:**
- Produces: `cfg.DBMaxConns int`, `cfg.DBMinConns int` (defaults 20 / 2).

- [ ] **Step 1: Failing test** — in configs tests, set `t.Setenv("DB_MAX_CONNS", "50")`, call `Load()`, assert `cfg.DBMaxConns == 50`; unset ⇒ default 20.
- [ ] **Step 2: Run** `go test ./configs/ -v` → FAIL (field undefined).
- [ ] **Step 3: Implement** — add to `Config` struct:
```go
DBMaxConns int
DBMinConns int
```
and in `Load()` (there is an existing `getInt` helper — line 94 uses it):
```go
DBMaxConns: getInt("DB_MAX_CONNS", 20),
DBMinConns: getInt("DB_MIN_CONNS", 2),
```
`main.go`:
```go
pool, err := database.Connect(ctx, database.Config{
	DSN:             cfg.DatabaseURL,
	MaxConns:        int32(cfg.DBMaxConns),
	MinConns:        int32(cfg.DBMinConns),
	MaxConnLifetime: 30 * time.Minute,
	MaxConnIdleTime: 5 * time.Minute,
})
```
(Match `database.Config` field types — check `internal/infrastructure/database` for whether MaxConns is int32 or int and cast accordingly.)
Also add both vars to `.env.example` with a comment: size against Postgres max_connections ÷ instance count.
- [ ] **Step 4: Run** `go test ./... ; go build ./...` → PASS.
- [ ] **Step 5: Commit** — `feat(config): env-tunable DB pool sizing (DB_MAX_CONNS/DB_MIN_CONNS)`

---

### Task 5: Redact tokens from Gin access logs

`gin.Logger()` logs full request lines; WS upgrades carry `?token=<JWT>` so every connect writes a valid access token to logs.

**Files:**
- Modify: `internal/delivery/http/router/router.go:86`
- Create: `internal/delivery/http/middleware/log_redact.go`
- Test: `internal/delivery/http/middleware/log_redact_test.go`

**Interfaces:**
- Produces: `middleware.RedactQueryToken(path string) string` — pure function, and `middleware.AccessLogger() gin.HandlerFunc`.

- [ ] **Step 1: Failing test**

```go
package middleware

import "testing"

func TestRedactQueryToken(t *testing.T) {
	cases := []struct{ in, want string }{
		{"/api/ws?token=eyJhbGciOi.abc.def", "/api/ws?token=%5BREDACTED%5D"},
		{"/api/ws?foo=1&token=xyz&bar=2", "/api/ws?foo=1&token=%5BREDACTED%5D&bar=2"},
		{"/api/health", "/api/health"},
		{"/api/rides?page=2", "/api/rides?page=2"},
	}
	for _, c := range cases {
		if got := RedactQueryToken(c.in); got != c.want {
			t.Errorf("RedactQueryToken(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}
```

- [ ] **Step 2: Run** → FAIL (undefined).
- [ ] **Step 3: Implement**

```go
// Package-level so the formatter allocates nothing per request beyond the
// replacement itself.
var tokenParamRe = regexp.MustCompile(`(token=)[^&\s]+`)

// RedactQueryToken masks any token=... query parameter value. The WS upgrade
// authenticates via ?token=<JWT>; without this, every connect logs a live
// access token.
func RedactQueryToken(path string) string {
	return tokenParamRe.ReplaceAllString(path, "$1%5BREDACTED%5D")
}

// AccessLogger is gin.Logger with token-redacting path formatting.
func AccessLogger() gin.HandlerFunc {
	return gin.LoggerWithConfig(gin.LoggerConfig{
		Formatter: func(p gin.LogFormatterParams) string {
			return fmt.Sprintf("[GIN] %s | %3d | %13v | %15s | %-7s %s\n",
				p.TimeStamp.Format("2006/01/02 - 15:04:05"),
				p.StatusCode, p.Latency, p.ClientIP, p.Method,
				RedactQueryToken(p.Path))
		},
	})
}
```
Note: gin's `p.Path` includes the raw query when present. Router change: `r.Use(gin.Logger())` → `r.Use(middleware.AccessLogger())`.

- [ ] **Step 4: Run** `go test ./... ` → PASS. Manually eyeball: `go run ./cmd/api` locally (needs backend/.env) and hit `/api/health?token=secret` — log line must show `[REDACTED]`. Skip if env not running; unit test is the gate.
- [ ] **Step 5: Commit** — `fix(security): redact token query param from access logs`

---

### Task 6: Block deactivated accounts at Login and Refresh

Deactivation sets `role='deactivated'` (`admin_repo.go:54-58`) but `Login`/`Refresh` never check role, so a deactivated admin keeps minting tokens for the full refresh window.

**Files:**
- Modify: `internal/domain/user.go` (add role constant if absent — check existing `UserRole` consts first)
- Modify: `internal/usecase/auth_usecase.go` (`Login` line ~102, `Refresh` line ~114)
- Test: `internal/usecase/auth_usecase_test.go` (follow existing test style)

**Interfaces:**
- Produces: `domain.UserRoleDeactivated UserRole = "deactivated"` (only if no equivalent constant exists — grep `deactivated` in `internal/domain/` first and reuse).

- [ ] **Step 1: Failing tests** — two cases:
  - Login: mock `userRepo.GetByEmail` returns user with `Role: domain.UserRoleDeactivated` and a bcrypt hash matching the supplied password ⇒ expect `domain.ErrInvalidCredentials`, and `tokenRepo.Store` never called.
  - Refresh: mock `tokenRepo.GetUserID` ok, `userRepo.GetByID` returns deactivated user ⇒ expect `domain.ErrRefreshTokenInvalid`.
- [ ] **Step 2: Run** `go test ./internal/usecase/ -run TestAuth -v` → FAIL.
- [ ] **Step 3: Implement**

`user.go` (next to existing role consts):
```go
// UserRoleDeactivated marks a disabled account (set by DeactivateAdmin).
// Login and Refresh must reject it — deactivation would otherwise leave a
// working refresh token for its full 30-day window.
UserRoleDeactivated UserRole = "deactivated"
```
`Login` — after the bcrypt check, before `issueTokens`:
```go
if user.Role == domain.UserRoleDeactivated {
	return nil, domain.ErrInvalidCredentials
}
```
`Refresh` — after `GetByID`:
```go
if user.Role == domain.UserRoleDeactivated {
	return nil, domain.ErrRefreshTokenInvalid
}
```
Bonus hardening (same commit, only if a `DELETE ... WHERE user_id` method already exists on the token repo — grep `user_tokens` in `internal/repository/postgres/user_token_repo.go`): call it from `DeactivateAdmin`'s usecase so outstanding refresh tokens die immediately. If no such method exists, skip — the role check above already closes the hole at next refresh.
- [ ] **Step 4: Run** `go test ./...` → PASS.
- [ ] **Step 5: Commit** — `fix(auth): reject deactivated accounts at login and refresh`

---

### Task 7: Guard /metrics

`GET /metrics` (router.go:105) is open to any client.

**Files:**
- Modify: `configs/config.go` (add `MetricsToken string` ← `getEnv("METRICS_TOKEN", "")`)
- Modify: `internal/delivery/http/router/router.go` (Deps struct + mount)
- Modify: `cmd/api/main.go` (pass `MetricsToken: cfg.MetricsToken` into Deps)
- Test: router-level test alongside existing router tests (grep `router_test` for the harness pattern).

**Interfaces:**
- Produces: `router.Deps.MetricsToken string`. Behavior: token set ⇒ `/metrics` requires `Authorization: Bearer <token>`; token empty ⇒ `/metrics` not mounted at all (scrapers must be configured explicitly — fail closed).

- [ ] **Step 1: Failing tests** — three cases against a `router.New` instance:
  - `MetricsToken: ""` ⇒ GET /metrics → 404.
  - `MetricsToken: "s3cret"` + correct Bearer header ⇒ 200.
  - `MetricsToken: "s3cret"` + missing/wrong header ⇒ 401.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement** in router.go:
```go
if d.MetricsToken != "" {
	promH := gin.WrapH(promhttp.Handler())
	r.GET("/metrics", func(c *gin.Context) {
		if subtle.ConstantTimeCompare(
			[]byte(c.GetHeader("Authorization")),
			[]byte("Bearer "+d.MetricsToken)) != 1 {
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}
		promH(c)
	})
}
```
Add `METRICS_TOKEN` to `.env.example` with comment: required for Prometheus scraping; leave empty to disable the endpoint.
While in this file: drop `"version": d.AppVersion` from the public `/api/health` payload (audit LOW — version disclosure); update any test asserting it.
- [ ] **Step 4: Run** `go test ./...` → PASS.
- [ ] **Step 5: Commit** — `fix(security): bearer-gate /metrics, drop version from public health`

---

### Task 8: WebSocket write deadline

`writePump` (`internal/delivery/ws/hub.go:79-110`) writes with no deadline; a wedged client blocks the pump until the 64-slot buffer fills.

**Files:**
- Modify: `internal/delivery/ws/hub.go`

**Interfaces:** none — internal behavior only.

- [ ] **Step 1: Implement** (no meaningful unit test without a real slow socket — WS package tests are integration-style; keep this a reviewed two-line change):
```go
const writeWait = 10 * time.Second
```
In `writePump`, immediately before **each** of the three write sites (`WriteMessage(websocket.CloseMessage…)`, `WriteJSON(msg)`, ping `WriteMessage(websocket.PingMessage…)`):
```go
cl.conn.SetWriteDeadline(time.Now().Add(writeWait)) //nolint:errcheck
```
- [ ] **Step 2: Run** `go test ./internal/delivery/ws/ ; go test ./...` → PASS.
- [ ] **Step 3: Commit** — `fix(ws): bound writes with a 10s deadline so wedged clients can't stall the pump`

---

### Task 9: Single query for all-vehicle-type nearby lookup

`GetNearbyDriversAllTypes` (`driver_usecase.go:104-114`) runs the spatial query 3× sequentially. Replace with one query partitioned by vehicle type.

**Files:**
- Modify: `internal/domain/` driver repository interface (add method — find it via `grep -r "FindNearbyOnlineByType" internal/domain/`)
- Modify: `internal/repository/postgres/driver_repo.go` (new method)
- Modify: `internal/usecase/driver_usecase.go:104-114`
- Test: usecase test with mock returning mixed types; repo mocks in existing test files gain the new method.

**Interfaces:**
- Produces: `FindNearbyOnlineAllTypes(ctx context.Context, lat, lng, radiusM float64) ([]domain.NearbyDriver, error)` on `domain.DriverRepository`. `domain.NearbyDriver` must expose its vehicle type — check the struct; `FindNearbyOnlineByType` already scans `vehicle_type`, add a `VehicleType string` field if it is currently dropped.

- [ ] **Step 1: Failing usecase test** — mock repo returns one driver of each type from `FindNearbyOnlineAllTypes`; assert the usecase groups them into the `map[domain.RideType][]domain.NearbyDriver` with all three keys present (empty slice for missing types).
- [ ] **Step 2: Run** → FAIL (method undefined).
- [ ] **Step 3: Implement repo method** — same SELECT as `FindNearbyOnlineByType` (WITH the Task-1 geography casts) but: no `v.vehicle_type = $4` filter, and per-type LIMIT via window function:
```sql
SELECT * FROM (
    SELECT d.user_id, d.status,
           ST_Y(d.location) AS lat,
           ST_X(d.location) AS lng,
           v.make, v.model, v.plate, v.vehicle_type,
           COALESCE(AVG(rt.stars), 0) AS rating,
           ST_Distance(d.location::geography, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography) AS distance_m,
           ROW_NUMBER() OVER (
               PARTITION BY v.vehicle_type
               ORDER BY ST_Distance(d.location::geography, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography)
           ) AS rn
    FROM drivers d
    INNER JOIN vehicles v ON v.user_id = d.user_id
    LEFT JOIN ratings rt ON rt.ratee_id = d.user_id
    WHERE d.status = 'online'
      AND NOT EXISTS (
            SELECT 1 FROM rides
            WHERE driver_id = d.user_id
              AND status NOT IN ('completed', 'cancelled')
          )
      AND ST_DWithin(
            d.location::geography,
            ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
            $3
          )
    GROUP BY d.user_id, d.status, d.location, v.make, v.model, v.plate, v.vehicle_type
) ranked
WHERE rn <= 20
ORDER BY vehicle_type, distance_m
```
Scan rows exactly like `FindNearbyOnlineByType` (plus `rn` into a throwaway var, plus vehicle_type into the NearbyDriver).

Usecase:
```go
func (uc *driverUseCase) GetNearbyDriversAllTypes(ctx context.Context, lat, lng float64, radiusM float64) (map[domain.RideType][]domain.NearbyDriver, error) {
	all, err := uc.driverRepo.FindNearbyOnlineAllTypes(ctx, lat, lng, radiusM)
	if err != nil {
		return nil, err
	}
	result := map[domain.RideType][]domain.NearbyDriver{
		domain.RideTypeCar:        {},
		domain.RideTypeMotorcycle: {},
		domain.RideTypeTricycle:   {},
	}
	for _, d := range all {
		rt := domain.RideType(d.VehicleType)
		result[rt] = append(result[rt], d)
	}
	return result, nil
}
```
(Confirm the JSON shape of the all-types endpoint response is unchanged — empty slices vs previous behavior; existing handler/dto tests are the gate.)
- [ ] **Step 4: Run** `go test ./...` → PASS.
- [ ] **Step 5: Commit** — `perf(driver): single partitioned query for all-vehicle-type nearby lookup`

---

### Task 10: Drain background workers on shutdown

Workers (`main.go:206-210` + dispatcher at 160-161) are `go`-routines on `workerCtx`, but `workerCancel` only fires via `defer` as `main` unwinds and nothing awaits them.

**Files:**
- Modify: `cmd/api/main.go`

**Interfaces:** none.

- [ ] **Step 1: Implement**

Above the dispatcher launch:
```go
var workers sync.WaitGroup
runWorker := func(name string, run func(context.Context)) {
	workers.Add(1)
	go func() {
		defer workers.Done()
		run(workerCtx)
	}()
	_ = name // reserved for a shutdown log if needed
}
```
Replace each raw `go X.Run(workerCtx)` call:
```go
runWorker("ws-dispatcher", dispatcher.Run)
...
runWorker("ride-expiry", expiry.New(rideRepo, dispatcher).Run)
runWorker("health", health.New(systemRepo, pool, rdb, hub, 30*time.Second).Run)
runWorker("alerting", alerting.New(alertRepo, pool, 5*time.Minute).WithNotifier(notifier).Run)
runWorker("notifications", notifications.NewDispatcher(pool, 30*time.Second, 20).Run)
```
After `srv.Shutdown(shutCtx)`:
```go
// HTTP is drained; now stop workers and wait for them within the same window.
workerCancel()
done := make(chan struct{})
go func() { workers.Wait(); close(done) }()
select {
case <-done:
	log.Println("workers stopped")
case <-shutCtx.Done():
	log.Println("workers did not stop within shutdown window")
}
```
Add `"sync"` import.
- [ ] **Step 2: Verify** — `go build ./... ; go test ./...` → PASS. Then `go vet ./cmd/api/`.
- [ ] **Step 3: Commit** — `fix(lifecycle): wait for background workers during graceful shutdown`

---

## Deferred follow-ups (out of scope, tracked for a future plan)

- **Redis-backed rate limiter + per-account lockout** (audit H3) — matters at multi-pod; M effort, protocol for lockout UX needs a decision.
- **GPS pings to Redis GEO + throttling** (audit C2 phase 2) — Task 2 removes the read amplification; moving live location off Postgres entirely is a larger refactor touching nearby queries. `LOCATION_RATE_LIMIT_PER_MIN` config exists but is dead code — wire it when this lands.
- **Denormalized driver rating** (M1) and **sharded WS event channels** (M3) — schema/protocol churn, only needed at scale.
- **Replay cursor by stream ID** (M4) — requires client protocol change (clients send event_id today).
- **Upload magic-byte sniffing, jti denylist, rating-endpoint scoping** — security LOWs.
