# SakAI Project Roadmap

## 🚀 Phase 1: Foundation (Completed)

- [x] Project Scaffolding (Go + Gin + Postgres)
- [x] Database Schema & Migrations
- [x] Domain Models (User, Ride, Driver, Location)
- [x] Basic Auth (JWT, Refresh Tokens)
- [x] Core Ride Flow (Request, Accept, Decline, Complete)
- [x] WebSocket Hub & Event Broadcasting

## 🛡️ Phase 2: Hardening & Security (Current Focus)

**Goal:** Address system audit findings and ensure production readiness.

### ✅ Completed

- [x] **Race Condition Fix:** DB-level constraints for `RequestRide`
- [x] **Data Integrity:** `Decline` properly un-assigns drivers
- [x] **Privacy:** Driver location updates sent only to passenger
- [x] **Vehicle Data:** Fixed missing vehicle info in driver responses
- [x] **Self-Healing:** Background worker for ride offer expiry
- [x] **Validation:** LatLng bounds checks
- [x] **Security:** Auth rate limiting (10 rpm/IP)
- [x] **Performance:** `FindNearbyOnline` limited to 1 result
- [x] **Consistency:** Transactional `Register` flow
- [x] **Observability:** Logging for critical async failures

### 🚧 To Do (Immediate Priority)

- [ ] **Critical:** Notify passenger via WebSocket when offer expires
- [ ] **Critical:** Fix `FindNearbyOnline` race (exclude drivers with active rides)
- [ ] **Security:** Add WebSocket read deadlines & limits
- [ ] **Security:** Restrict `GET /rides/:id` to participants only
- [ ] **Scale:** Add GIST index for geospatial queries
- [ ] **Ops:** Embed migrations into binary

## 🔌 Phase 3: Real-Time Resilience

- [ ] **Scale:** Redis Pub/Sub for multi-instance WebSocket support
- [ ] **Reliability:** Message replay/history for reconnected clients
- [ ] **Security:** Config-driven WebSocket allowed origins

## 📱 Phase 4: Client Interaction

- [ ] Build Flutter Passenger App
- [ ] Build Flutter Driver App
- [ ] Admin Dashboard
