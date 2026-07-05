# SakAI Security Remediation — Operator Runbook

Actions the code fixes (branch `security/audit-remediation`, audit `docs/SECURITY_AUDIT_2026-06-13.md`)
**cannot** perform. Do these in a maintenance window. Treat every value that was ever
committed to `.env` as compromised and rotate it.

## 1. Rotate JWT_SECRET (mandatory — C1 / H5)
- Generate a strong secret (>= 32 chars): `openssl rand -base64 48`.
- Set `JWT_SECRET` via the secret manager / real environment — **never** a committed file.
- **Breaking:** rotation invalidates all live access tokens → every user and admin must
  log in again. Schedule accordingly.
- The app now **fails to boot** in any non-development environment if `JWT_SECRET` is weak:
  shorter than 32 chars, or one of the known defaults (`change-me-in-production`,
  `change-me-in-production-use-a-long-random-string`). An **unset `APP_ENV` is treated as
  non-development** (fail closed) — set a strong secret before deploy.

## 2. Rotate the database password (mandatory — H5)
- Replace the leaked `postgres:postgres` credentials with a strong password.
- Update `DATABASE_URL`; require TLS with `?sslmode=require` (or `verify-full`).
- The default DSN is now `sslmode=require`. **Production must supply an explicit TLS DSN.**
  **Local dev without TLS must set `DATABASE_URL` explicitly with `?sslmode=disable`** —
  the insecure default was the bug, so it is no longer the default.

## 3. Rotate the Google Maps key (mandatory — H5)
- Revoke the key that was committed in the root `.env`
  (`AIzaSyAfzFWwxAOov-4DKulSFO-tCTOfYwdAq6w`).
- Issue a new key and restrict it by HTTP referrer / IP / API.

## 4. Source secrets from a manager (mandatory — H5)
- `.env`, `backend/.env`, and `mobile/.env` are now untracked and gitignored. Never commit
  env files again. Use the platform secret manager or real environment variables for
  `JWT_SECRET`, `DATABASE_URL`, `STRIPE_SECRET_KEY`, the Maps key, etc.
- De-tracking does **not** invalidate already-leaked values — rotation (sections 1–3) is what
  does. If the repo is or ever was shared, purge the secrets from git history
  (e.g. `git filter-repo`) and treat all previously committed secrets as compromised.

## 5. Trusted proxy CIDRs (H4)
- The app calls `SetTrustedProxies(nil)` (`configureTrustedProxies` in
  `internal/delivery/http/router/router.go`), so `ClientIP()` resolves to the real
  `RemoteAddr` and ignores client-supplied `X-Forwarded-For`. This is correct **only when the
  service is NOT behind a proxy / load balancer.**
- If you deploy behind a known proxy/LB, edit `configureTrustedProxies` to list that proxy's
  CIDRs — otherwise every client collapses to the LB's IP and the per-IP rate limiter
  (`/auth/*`, including the newly limited `/auth/refresh` and `/auth/logout`) becomes a single
  shared bucket.

## 6. Allowed origins (L1 / L2)
- Set `ALLOWED_ORIGINS` (comma-separated) to the real app and admin-panel origins, e.g.
  `ALLOWED_ORIGINS=https://app.sakai.ph,https://admin.sakai.ph`.
- CORS (`middleware.CORS`) and the WebSocket `CheckOrigin` now **reject any browser origin not
  in this list**, and only an allowlisted origin is echoed back with
  `Access-Control-Allow-Credentials: true`. **Fail-closed default:** if `ALLOWED_ORIGINS` is
  unset, no browser cross-origin request or cross-site WS handshake is permitted. Non-browser
  / same-origin clients (no `Origin` header) are still allowed and remain gated by JWT auth.

## 7. SOS live-location opt-in (SOS)
- Migration `031_create_sos_safety_prefs` adds the `sos_safety_prefs` table; run migrations on
  deploy. The opt-in column defaults to **FALSE (fail closed)** — until a user explicitly opts
  in, the incident-location endpoint (`AppendIncidentLocation`) returns 403 and records no
  pings, even for a valid ride participant.
- The opt-in is enforced **server-side** now (not just in the apps). A write path
  (`SetLiveLocationOptIn`) exists in the repo for a future preferences endpoint; wire a
  consent UI before advertising the live-location feature.

## 8. CI / build toolchain (M5)
- Build and deploy on **Go >= 1.26.4** (`backend/go.mod` requires `go 1.26.4`). 1.26.4 — not
  1.26.3 — is required: GO-2026-5039 and GO-2026-5037 are only fixed in 1.26.4.
- `.github/workflows/ci-backend.yml` already runs `govulncheck ./...` as a required `vuln` job
  that the `build` job depends on (`needs: [test, vuln]`), and `setup-go` reads the version
  from `go.mod`. On the bumped toolchain govulncheck reports **0 reachable** stdlib
  vulnerabilities (down from 11 on 1.26.1). Keep the gate; do not relax `go-version-file`.

## 9. Accepted residual risk
- **RBAC cache lag (L5-adjacent):** permission/role changes propagate within ~30s (in-process
  RBAC cache TTL). A revoked permission can still authorize for up to 30s. Accepted. To make
  revocation instant, invalidate the cache entry on role change.
- **KYC file reads:** admin-tier reads of `/files/*` now require the `kyc_verification:read`
  permission (M1); drivers remain limited to their own document prefix. The same ~30s cache lag
  applies to a freshly revoked `kyc_verification` grant.

## 10. 2026-07-05 scaling & security follow-up (branch `fix/backend-scaling-security`, PR #73)

Deploy-time requirements introduced by the July 2026 audit remediation
(plan: `docs/superpowers/plans/2026-07-05-backend-scaling-security-fixes.md`):

- **`METRICS_TOKEN` (fail-closed):** `/metrics` is no longer public. Unset ⇒ the endpoint is
  **not mounted** (scrapers get 404, not 401). Set a strong token via the secret manager
  **before** pointing Prometheus at the service, and configure the scrape job with
  `Authorization: Bearer <token>`.
- **DB pool sizing:** `DB_MAX_CONNS` (default 20) / `DB_MIN_CONNS` (default 2) are now
  env-tunable. Size `DB_MAX_CONNS` against Postgres `max_connections` ÷ instance count.
- **Migration 032** runs embedded at startup: swaps the drivers spatial index to a functional
  `(location::geography)` GiST index (non-`CONCURRENTLY` — acceptable at current table size;
  revisit if the drivers table grows past ~100k rows before this deploys).
- **Deactivated accounts:** login/refresh now reject `role='deactivated'`. Existing **access**
  tokens still work until expiry (60 min default) — the accepted revocation window. For
  instant revocation a `jti` denylist is a deferred follow-up.
- **Log hygiene:** access logs redact `token=` query values (WS upgrade JWTs). Keep any log
  aggregation retention/scrubbing policies in place for logs captured **before** this deploy —
  they contain valid-at-the-time tokens.
- **Version disclosure:** `/api/health` no longer returns `version`. Update any monitoring
  that parsed it (scrape an internal/authenticated source instead).
- **Deferred (tracked in the plan doc):** Redis-backed rate limiter + per-account lockout,
  GPS location writes to Redis GEO (phase 2), driver-rating denormalization, WS event-channel
  sharding, replay stream-ID cursor, upload magic-byte sniffing.
