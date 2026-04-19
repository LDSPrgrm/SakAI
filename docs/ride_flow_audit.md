# SakAI Core Ride Flow Audit

**Date:** 2026-04-13
**Scope:** Passenger request → Driver completion → Payment → Rating

---

## 1. Implementation Completeness

### Passenger App — ~90%

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (email/password) | ✅ Working | Login, register, logout, session checks |
| Onboarding | ✅ Working | Welcome screen with flag persistence |
| Home + Maps | ✅ Working | Google Maps, location search, geocoding |
| Ride request | ✅ Working | Idempotent requests, ride type selection |
| Waiting for driver | ✅ Working | Cancel option, countdown timer |
| Active ride tracking | ✅ Working | Real-time WebSocket updates, driver location |
| Ride completion | ✅ Working | Summary screen with fare breakdown |
| Rating + tips | ✅ Working | 5-star rating, tip selection |
| Ride history | ✅ Working | Paginated, filterable, detail view |
| Cancelled ride screen | ✅ Working | Reason codes, refund/fee details |
| Receipt generation | ✅ Working | Shareable receipt |
| Payment methods UI | ✅ Working | CRUD for saved payment methods |
| WebSocket real-time | ✅ Working | Ride events, driver location updates |
| Settings + profile | ✅ Working | Basic settings, emergency contacts |

### Driver App — ~85%

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (email/password) | ✅ Working | Login, register with vehicle info |
| Home + Maps | ✅ Working | Google Maps, GPS streaming |
| Online/offline toggle | ✅ Working | Start/end shift, green/red markers |
| Ride offer screen | ✅ Working | Countdown timer, accept/decline with retry |
| Active ride management | ✅ Working | Navigate, arrive, start, complete steps |
| Rating passengers | ✅ Working | 5-star rating with feedback |
| Earnings display | ✅ Working | Session-level summary (in-memory only) |
| WebSocket integration | ✅ Working | Ride offers, status changes |

### Backend — ~95%

| Component | Status | Notes |
|-----------|--------|-------|
| Ride state machine | ✅ Working | Enforced transitions: requested→accepted→arrived→in_progress→completed |
| Driver matching | ✅ Working | Finds nearest online driver by ride type |
| Ride lifecycle endpoints | ✅ Working | Request, accept, decline, arrive, start, complete, cancel |
| WebSocket events | ✅ Working | All ride events published to passengers/drivers |
| Fare calculation | ✅ Working | Calculated on ride completion |
| Cancellation logic | ✅ Working | Role-based, with fees |
| Re-match on decline | ✅ Working | Auto-reassigns to next driver |
| Expiry worker | ✅ Working | Cancels stale offers, notifies via WS |
| Tests | ✅ Working | 16+ backend usecase test cases passing |

---

## 2. Known Incomplete Items (Non-Blocking)

| Issue | Impact | Location |
|-------|--------|----------|
| OAuth/Google login not implemented | Medium | Both apps show "coming soon" |
| Phone verification not implemented | Medium | TODO in login notifiers |
| Profile editing is placeholder | Medium | Returns current profile unchanged |
| Earnings are session-only | Medium | In-memory, lost on app restart |
| Document upload is local-file stub | Medium | No S3/GCS integration |
| Driver enrichment missing on completion | Low | Ride completion shows "Driver" instead of name |
| Currency hardcoded to USD | Low | Payment/tip usecases |
| Help Center has no backend | Low | Placeholder UI |
| Terms/Privacy URLs are placeholders | Low | Hardcoded placeholder text |
| No ride history for drivers | Missing feature | Only session earnings shown |

---

## 3. Definitive Blockers: Ride Request → Completion

### 🔴 CRITICAL BLOCKERS

#### B1: Payment Processing is Entirely Stubbed

| Aspect | Detail |
|--------|--------|
| **What breaks** | After ride completes, `POST /payments/process` returns fake transaction IDs. No real money is charged. |
| **Mobile** | `AddPaymentMethodViewModel` generates tokens like `tok_stub_XXXX`. No Stripe SDK integration. |
| **Backend** | `stripeClientStub.Charge()` in `main.go` returns fake IDs. `payment_repo.go` — all payment/payout operations are hardcoded stubs. |
| **API contract** | Spec defines full Stripe payment flow with card tokenization, payment intents, and receipt generation. None of it exists. |
| **User impact** | Rides complete for "free". No payment history, no actual charges. |
| **Fidelity to spec** | ❌ **0%** — endpoint exists but does nothing real |

#### B2: OpenAPI → Dart Client Deserialization Mismatch

| Aspect | Detail |
|--------|--------|
| **What breaks** | `POST /rides` returns 201 with a valid body, but the generated `RideResponse` deserializer throws. The passenger repo has a manual JSON fallback (`_entityFromMap`) that papers over this, but it means **the contract and implementation are out of sync**. |
| **Where** | `ride_repository_impl.dart` — catches 2xx DioExceptions and parses raw JSON because `response.data` is null when the generated client fails. |
| **Root cause** | The OpenAPI spec's `RideResponse` schema likely includes a `passenger` field that the backend doesn't always populate in 201 responses (or vice versa). |
| **User impact** | Ride may be created successfully but the app could show "request failed" to the passenger. The ride proceeds but UX is broken. |
| **Fidelity to spec** | ⚠️ **~80%** — ride IS created, but response shape doesn't match spec |

---

### 🟡 FUNCTIONAL GAPS (flow works but is fragile)

#### B3: No Active Ride Auto-Resume for Drivers

| Aspect | Detail |
|--------|--------|
| **What breaks** | If a driver app restarts mid-ride, `splash_screen.dart` explicitly skips active ride recovery: `case SplashState.activeRide: break; // Driver doesn't auto-resume` |
| **Passenger side** | ✅ Passenger app DOES recover active rides on splash |
| **Driver side** | ❌ Driver must manually poll or re-navigate to the ride |
| **Workaround** | `driver_home_notifier.dart` polls `GET /driver/incoming-ride` after WS reconnect, but this only finds `requested` rides, not `accepted`/`arrived`/`in_progress` ones. |
| **Fidelity to spec** | ⚠️ Spec doesn't mandate auto-resume, but it's a UX gap |

#### B4: Earnings Are Session-Only (In-Memory)

| Aspect | Detail |
|--------|--------|
| **What breaks** | `EarningsNotifier` is an in-memory accumulator. All earnings data is lost when the driver app restarts. |
| **Backend** | No endpoint for driver earnings history. |
| **User impact** | Drivers can't see their historical earnings. |
| **Fidelity to spec** | ⚠️ Spec doesn't define this endpoint — it's a missing feature |

---

### ✅ RESOLVED (previously flagged but no longer blockers)

| Issue | Status | Evidence |
|-------|--------|----------|
| **C1: Expiry worker WS notification** | ✅ **FIXED** | `expiry/worker.go` correctly calls `PublishToUser` with `EventRideOfferExpired`. The `RedisDispatcher` properly routes to the local hub. |
| **C2: `FindNearbyOnline` excludes busy drivers** | ✅ **FIXED** | SQL query includes `NOT EXISTS (SELECT 1 FROM rides WHERE driver_id = d.user_id AND status NOT IN ('completed', 'cancelled'))`. |
| **L3: `GET /rides/:id` participant auth** | ✅ **FIXED** | `ride_handler.go` passes `userID` to usecase; usecase checks `ride.PassengerID != userID && *ride.DriverID != userID`. |
| **H4: No request body size limit** | ✅ **FIXED** | `router.go` applies `middleware.MaxBodySize(1 << 20)` globally. |
| **L2: Cancel per-role validation** | ✅ **FIXED** | `ride_usecase.go:Cancel()` validates role and checks `ride.PassengerID` / `ride.DriverID` match. |
| **L1: Re-dispatch after decline** | ✅ **FIXED** | `ride_usecase.go:Decline()` performs re-match and assigns new driver. Handler publishes `ride.declined` + new `ride.requested`. |

---

## 4. Step-by-Step Flow Completeness

| Step | Action | Passenger | Driver | Backend | WS Events | Fidelity to Contract |
|------|--------|-----------|--------|---------|-----------|----------------------|
| 1 | Passenger requests ride | ⚠️ Fragile response parsing | — | ✅ Creates ride, assigns driver | — | ~80% |
| 2 | Driver receives offer (WS) | — | ✅ Receives + displays | ✅ Publishes `ride.requested` | ✅ | 100% |
| 3 | Driver accepts ride | ✅ Receives `ride.accepted` | ✅ Calls accept endpoint | ✅ `requested → accepted` | ✅ | 100% |
| 4 | Driver arrives at pickup | ✅ Receives `ride.status_changed` | ✅ Calls arrive endpoint | ✅ `accepted → arrived` | ✅ | 100% |
| 5 | Driver starts ride | ✅ Receives `ride.status_changed` | ✅ Calls start endpoint | ✅ `arrived → in_progress` | ✅ | 100% |
| 6 | Driver completes ride | ✅ Receives `ride.status_changed` | ✅ Calls complete endpoint | ✅ `in_progress → completed`, driver→online | ✅ | 100% |
| 7 | **Passenger pays** | 🔴 **Stubbed** | — | 🔴 **Stubbed** | — | **0%** |
| 8 | Passenger rates driver | ✅ Submits rating | — | ✅ Stores rating | — | 100% |
| 9 | Driver rates passenger | — | ✅ Submits rating | ✅ Stores rating | — | 100% |

---

## 5. API Contract Fidelity Summary

| Area | Fidelity | Notes |
|------|----------|-------|
| Auth endpoints | 90% | OAuth + phone auth missing |
| Ride request | 80% | Response deserialization mismatch |
| Ride lifecycle (accept/arrive/start/complete) | 100% | Full contract compliance |
| Ride cancellation | 100% | Role validation, reason codes, fees |
| WebSocket events | 100% | All spec events published |
| Driver management | 95% | Status, location, incoming ride |
| Payment processing | 0% | Endpoint exists, entirely stubbed |
| Payment methods | 30% | CRUD endpoints work, gateway integration stubbed |
| Rating system | 100% | Full contract compliance |
| Ride history | 100% | Pagination, filtering |
| Receipt | 100% | Fare breakdown included |

---

## 6. Recommended Priority

1. **B1 — Integrate Stripe** (mobile SDK + backend Go client). Without this, no revenue is collected.
2. **B2 — Fix OpenAPI → Dart pipeline.** Regenerate client after aligning `RideResponse` schema with actual backend output.
3. **B3 — Add driver active ride auto-resume.** Small change to splash logic to call `GET /rides/active` for drivers.
4. **B4 — Persist driver earnings.** Add DB table + endpoint for earnings history.
