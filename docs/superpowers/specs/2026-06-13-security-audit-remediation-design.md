# SakAI Backend — Security Audit Remediation (Spec / Design)

**Date:** 2026-06-13
**Source audit:** `docs/SECURITY_AUDIT_2026-06-13.md` (14 findings: 1 Critical · 5 High · 5 Medium · 5 Low) + SOS opt-in manual-review item.
**Goal:** Close all 14 findings + the SOS opt-in via code fixes, verified by regression tests where testable; document operator-only actions in a runbook.
**Branch:** `security/audit-remediation` (one branch, one commit per finding).

---

## Scope

**In scope (code):** C1, H1–H5, M1–M5, L1–L5, SOS live-location opt-in enforcement.
**In scope (docs):** `docs/SECURITY_REMEDIATION_RUNBOOK.md` for operator-only actions (secret rotation, secret manager, trusted-proxy CIDRs, CI gate, toolchain build version).

**Out of scope:**
- Flutter apps / admin frontend internals (audit excluded them; only vulnerable dep versions were flagged).
- The actual rotation of live secret *values* (`JWT_SECRET`, DB password, Google Maps key) — operator action, not code. Runbook documents the procedure; code cannot perform it.
- New product features. No behavior change beyond closing findings.

---

## Decisions (locked during brainstorming)

1. **Structure:** phased by audit priority (fastest risk burn-down), mapped onto plan phases.
2. **Verification:** regression test per finding where the finding is behavioral (TDD red→green); per-finding manual checklist (command + expected output) for log-deletion / config / gitignore / dependency items.
3. **JWT guard hardening (C1/H5):** the guard must reject a *class* of weak secrets, not one literal. Reject when `APP_ENV != "development"` AND the secret is any of: the sentinel `change-me-in-production`, the committed near-miss `change-me-in-production-use-a-long-random-string`, or any value shorter than 32 chars.
4. **SOS:** persist the opt-in (one DB migration) and reject pings with 403 when the actor's opt-in is false. This is the only schema change in the plan.

### Why guard hardening is not optional
The audit's C1 minimal fix (default `APP_ENV` to empty so an unset env never silences the panic) does **not** close H5. The committed `backend/.env` sets `JWT_SECRET=change-me-in-production-use-a-long-random-string`, which is **not** equal to the sentinel `change-me-in-production` the guard compares against (`config.go:88`). That weak, VCS-published secret therefore passes the equality guard even in production. A denylist + minimum-length predicate closes the bypass; the equality check alone cannot.

---

## Phasing

One branch. Each phase ends green on `go test ./...` (run from `backend/`) before the next begins. Commit per finding.

| Phase | Findings | Verification |
|---|---|---|
| **1 — Auth / secrets** | C1, H5, guard hardening | TDD `validateJWTSecret`; checklist: `.gitignore`, `git rm --cached`, rotation (runbook) |
| **2 — Privilege escalation** | H2, H3 | TDD: CreateAdmin rejects superadmin; ResetPassword rejects superadmin target |
| **3 — Token exposure / brute-force** | H1, H4 | Checklist: `[DEBUG-AUTH]` lines deleted. TDD: spoofed `X-Forwarded-For` → same rate bucket |
| **4 — Medium** | M1, M2, M3, M4, SOS | TDD: M1 perm-gate, M2 short-circuit+ownership, SOS opt-in 403. Checklist: M3, M4 |
| **5 — Low** | L1, L2, L3, L4, L5 | TDD: L3 CSV formula-escape. Checklist: L1, L2, L4, L5 |
| **6 — Deps + runbook** | M5, runbook | `govulncheck ./...` clean on go ≥ 1.26.3; CI gate added; runbook written |

---

## Per-finding remediation

Each entry: location → fix → verification.

### Phase 1 — Auth / secrets

**C1 — JWT secret silent default** · `backend/configs/config.go:73,88`
Replace the inline equality guard with `validateJWTSecret(secret, appEnv)`. Fail closed: when `appEnv != "development"`, panic if secret ∈ denylist `{change-me-in-production, change-me-in-production-use-a-long-random-string}` or `len(secret) < 32`. Default `APP_ENV` fallback stays `"development"` only for the *getter*; the guard treats unset/empty `APP_ENV` as non-development (fail closed).
*Verify (TDD):* table test on `validateJWTSecret` — dev+weak ⇒ no panic; prod+sentinel ⇒ panic; prod+committed-long ⇒ panic; prod+`len<32` ⇒ panic; prod+strong(≥32, not denied) ⇒ no panic; empty `APP_ENV`+weak ⇒ panic.

**H5 — secrets committed to git** · `backend/.env:7,16`; root `.env`; `mobile/.env`; `.gitignore`
Add `.env` and `**/.env` to `.gitignore`; `git rm --cached .env backend/.env mobile/.env`. Rotation of values is runbook (Phase 6).
*Verify (checklist):* `git ls-files | grep -E '(^|/)\.env$'` returns nothing; `git check-ignore backend/.env` confirms ignored.

### Phase 2 — Privilege escalation

**H2 — CreateAdmin can mint superadmin** · `backend/internal/usecase/admin_usecase.go:72-86,57-70`
After role resolution, reject `role == domain.RoleSuperadmin` (covers both the enum-validation path `:82-83` and the `roleNameToEnum` `role_id` path).
*Verify (TDD):* CreateAdmin with `role="superadmin"` ⇒ error; with `role_id` naming `super_admin` ⇒ error; with `role="operations"` ⇒ success.

**H3 — ResetPassword on superadmin target** · `backend/internal/usecase/admin_usecase.go:258-277`
After `GetByID` (`:266`), reject when `target.Role == domain.RoleSuperadmin`.
*Verify (TDD):* actor with `admin_management:write` resetting a superadmin target ⇒ error; resetting a normal admin ⇒ success.

### Phase 3 — Token exposure / brute-force

**H1 — bearer/WS token logged** · `backend/internal/delivery/http/middleware/auth.go:21-24,44`
Delete the `[DEBUG-AUTH]` Authorization/query-token lines and the `[auth] userID=… role=…` line. If a presence signal is genuinely needed, log only `len(tokenStr)`.
*Verify (checklist):* `grep -rn 'DEBUG-AUTH' backend/` returns nothing; auth still works (`go test ./internal/delivery/http/...`).

**H4 — rate-limit XFF bypass** · `backend/internal/delivery/http/middleware/rate_limit.go:98`; `router.go:70-71`
Pin trusted proxies in `router.New`. Default to `r.SetTrustedProxies(nil)` (ClientIP == RemoteAddr; ignores `X-Forwarded-For`). Real prod proxy CIDRs documented in runbook.
*Verify (TDD):* two requests with differing `X-Forwarded-For` but same `RemoteAddr` share one bucket → the 11th within the window is throttled.

### Phase 4 — Medium

**M1 — KYC docs readable by any admin role** · `backend/internal/delivery/http/files_handler.go:86-98`; `router.go:357-360`
Gate the non-driver/passenger path with `requirePerm("kyc_verification","read")` — either on the route or inside `canReadKey`'s default branch. Keep the driver-owns-prefix allow path.
*Verify (TDD):* admin role lacking `kyc_verification:read` fetching `documents/<driverID>/…` ⇒ 403; role with the perm ⇒ 200; driver fetching own prefix ⇒ 200.

**M2 — Stripe charge before idempotency/ownership check** · `backend/internal/usecase/payment_processing_usecase.go:43,56-103`
Before `ChargePaymentMethod` (`:72`): short-circuit if `paymentRepo.GetByRideID` already has a record; verify `ride.PassengerID == passengerID` (return `domain.ErrForbidden` otherwise).
*Verify (TDD):* second `ChargeRide` on an already-paid ride ⇒ no charge call, returns nil; mismatched passenger ⇒ forbidden, no charge.

**M3 — precise geolocation logged at INFO** · `driver_handler.go:53`; `driver_repo.go:112,129,132`; `driver_usecase.go:42`; `ride_usecase.go:48`
Drop the coordinate/UUID logs, or guard behind an explicit debug flag; if kept for ops, truncate to ~2 decimals and omit the user ID.
*Verify (checklist):* `grep -rn` the listed lines show no raw lat/lng+UUID at INFO; `go test ./...` green.

**M4 — access token in URL query** · `backend/internal/delivery/http/middleware/auth.go:56-62`
Restrict the `?token=` fallback to the `/ws` upgrade path; require the `Authorization` header for REST routes. At minimum strip the `token` query value from access logs.
*Verify (TDD):* REST route with only `?token=` ⇒ 401; `/ws` upgrade with `?token=` ⇒ accepted.

**SOS — live-location opt-in not enforced** · `backend/internal/delivery/http/ride_handler.go:544-552,586-596`
Migration: persist `live_location_opt_in` (on `sos_safety_prefs`, or the ride-participant/incident-participant record). In `AppendIncidentLocation`, reject with 403 when the acting participant's opt-in is false.
*Verify (TDD):* participant with opt-in false posting an incident location ⇒ 403; opt-in true ⇒ recorded.

### Phase 5 — Low

**L1 — permissive CORS** · `backend/internal/delivery/http/middleware/security.go:33-34`
Replace `Origin` reflection with an explicit allowlist of app/admin origins; set `Allow-Credentials: true` only for allowlisted origins.
*Verify (checklist):* disallowed Origin ⇒ no `Access-Control-Allow-Origin` echo; allowlisted ⇒ echoed.

**L2 — WS CheckOrigin always true** · `backend/internal/delivery/ws/handler.go:25`
Restrict `CheckOrigin` to known app/admin origins (share the L1 allowlist).
*Verify (checklist):* cross-site Origin ⇒ upgrade rejected; allowlisted ⇒ accepted.

**L3 — CSV/formula injection in exports** · `backend/internal/repository/postgres/report_repo.go:107-110`; `backend/internal/usecase/admin_usecase.go:538-543`
Prefix any cell starting with `= + - @` with a single quote; use `encoding/csv` `csv.Writer` for quoting (replace manual string building in the audit export).
*Verify (TDD):* a `Reason`/`ActorName` field of `=cmd()` is emitted as `'=cmd()`; fields with commas/newlines stay one column.

**L4 — default DSN sslmode=disable** · `backend/configs/config.go:70`
Change the fallback to `sslmode=require`; document that production must supply an explicit TLS DSN (runbook).
*Verify (checklist):* default `DatabaseURL` contains `sslmode=require`.

**L5 — unthrottled refresh; permission-cache lag** · `router.go:125-126`; `middleware/permission.go:16`
Add `middleware.RateLimit` to `/auth/refresh`. Document the 30 s RBAC propagation delay; optionally invalidate the cache entry on role change.
*Verify (checklist):* `/auth/refresh` route registers the rate-limit middleware; note added on cache lag.

### Phase 6 — Dependencies + runbook

**M5 — reachable Go stdlib vulns** · `backend/go.mod:3`
Bump the `go` directive and build/deploy on **go ≥ 1.26.3**. Add `govulncheck ./...` as a CI gate.
*Verify (checklist):* `govulncheck ./...` reports 0 reachable; CI step present.

---

## Ops runbook — `docs/SECURITY_REMEDIATION_RUNBOOK.md`

Operator-only actions code cannot perform. Sections:
1. **Rotate `JWT_SECRET`** — generate ≥32-char random secret; set via secret manager/env. **Breaking:** invalidates all live access tokens → forces re-login. Schedule a maintenance window or accept forced logout.
2. **Rotate DB password** — replace `postgres:postgres`; update `DATABASE_URL`; require TLS (`sslmode=require`/`verify-full`).
3. **Rotate Google Maps key** — revoke `AIzaSyAfzFWwxAOov-4DKulSFO-tCTOfYwdAq6w` (root `.env`); restrict the new key by referrer/IP.
4. **Secret manager** — source production secrets from a manager / real env vars, never `.env` in VCS.
5. **Trusted proxy CIDRs** — if deployed behind a real proxy/LB, set `SetTrustedProxies([...real CIDRs...])` instead of `nil` so `ClientIP()` resolves correctly (interacts with H4).
6. **CI** — `govulncheck ./...` gate; build image on go ≥ 1.26.3.

---

## Testing strategy

- TDD red→green per behavioral finding, reusing the existing table-driven `_test.go` patterns (`admin_usecase_test.go`, `payment_processing_usecase_test.go`, `middleware/permission_test.go`, etc.).
- `validateJWTSecret` extracted as a pure function for isolated unit testing.
- Each phase: `go test ./...` from `backend/` must be green before advancing.
- Non-behavioral findings (log deletion, gitignore, config defaults, dep bump) get a manual checklist entry (exact command + expected output), executed and recorded in the plan.

---

## Risks / breaking changes

1. **JWT rotation logs out all users** — intended; sequence in a maintenance window (runbook §1).
2. **Min-length guard panics weak non-dev deploys** — intended fail-closed; runbook warns operators to set a ≥32-char secret first.
3. **`SetTrustedProxies(nil)` breaks real-client-IP behind a proxy** — runbook §5 gives the correct prod CIDR config.
4. **SOS migration** — the one schema change; must be reversible (down migration).
5. **L1/L2 origin allowlist** — must enumerate every legitimate app/admin origin or risk blocking real clients; allowlist sourced from config, not hardcoded where avoidable.

---

## Definition of done

- All 14 findings + SOS closed in code or documented as operator action in the runbook.
- `go test ./...` green from `backend/`.
- `govulncheck ./...` reports 0 reachable on go ≥ 1.26.3.
- No `.env` tracked in git; `.gitignore` covers `**/.env`.
- `grep -rn 'DEBUG-AUTH' backend/` empty.
- Runbook committed; CI `govulncheck` gate present.
