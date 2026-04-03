# RidePH Super Admin Panel — Implementation Specification

> **Purpose:** This file is the single source of truth for building the RidePH Super Admin Panel. Claude Code should reference this document when implementing any super admin feature.

---

## 1. Project Context

RidePH is a ride-hailing platform for the Philippine market connecting passengers with drivers of motorcycles, tricycles, and other local vehicle types.

The Super Admin Panel is a **separate route group** within the React admin application (`/super-admin/*`). It provides platform-level configuration and oversight that sits above the regular Admin Panel (which handles day-to-day operations like ride monitoring and user support).

### Tech Stack

- **Frontend:** React 18+ with TypeScript
- **Styling:** Tailwind CSS (dark theme)
- **State Management:** React Query (TanStack Query) for server state, Zustand for client state
- **Tables:** TanStack Table (React Table v8)
- **Charts:** Recharts
- **Forms:** React Hook Form + Zod validation
- **Maps:** Google Maps API or Mapbox GL JS
- **Routing:** React Router v6+ with protected route wrappers
- **API:** REST endpoints to Go backend, authenticated via JWT
- **Database:** PostgreSQL (backend), Redis (caching)

### Dark Theme Palette

```
Background (base):      #121212
Background (surface):   #1E1E1E
Background (elevated):  #2A2A2A
Primary (RidePH blue):  #1A73E8
Text (primary):         #FFFFFF
Text (secondary):       #B0B0B0
Success:                #4CAF50
Warning:                #FF9800
Error:                  #F44336
Border:                 #3A3A3A
```

### Philippine-Specific Rules

- All currency: PHP (₱) with 2 decimal places and thousands separator (e.g., ₱12,345.67)
- Dates/times: PHT (Asia/Manila, UTC+8)
- Address fields: support barangay-level granularity
- Payment methods: Cash, GCash, PayMaya, Credit/Debit Card — all treated as first-class options
- Regulatory body: LTFRB (Land Transportation Franchising and Regulatory Board)
- SMS OTP: support local provider option alongside Twilio

---

## 2. Directory Structure

```
src/
├── pages/
│   └── super-admin/
│       ├── DashboardPage.tsx
│       ├── AdminManagementPage.tsx
│       ├── RoleManagementPage.tsx
│       ├── FareConfigPage.tsx
│       ├── PaymentsPage.tsx
│       ├── SafetyCompliancePage.tsx
│       ├── ReportsPage.tsx
│       ├── SystemConfigPage.tsx
│       ├── SystemHealthPage.tsx
│       └── AuditLogPage.tsx
├── components/
│   └── super-admin/
│       ├── layout/
│       │   ├── SuperAdminShell.tsx       # Sidebar + header wrapper
│       │   ├── Sidebar.tsx
│       │   └── TopHeader.tsx
│       ├── dashboard/
│       │   ├── KPICard.tsx
│       │   ├── RidesChart.tsx
│       │   ├── RevenueChart.tsx
│       │   ├── DriverHeatmap.tsx
│       │   ├── VehicleTypeDonut.tsx
│       │   └── ActivityFeed.tsx
│       ├── tables/
│       │   ├── DataTable.tsx            # Reusable TanStack Table wrapper
│       │   ├── TransactionTable.tsx
│       │   ├── AdminTable.tsx
│       │   ├── IncidentTable.tsx
│       │   └── KYCQueue.tsx
│       ├── modals/
│       │   ├── ConfirmationModal.tsx     # Reusable for all destructive actions
│       │   ├── CreateAdminModal.tsx
│       │   ├── CreateRoleModal.tsx
│       │   ├── FareChangePreview.tsx
│       │   └── PayoutApprovalModal.tsx
│       ├── forms/
│       │   ├── FareConfigForm.tsx
│       │   ├── SurgeConfigForm.tsx
│       │   ├── CommissionForm.tsx
│       │   ├── NotificationTemplateForm.tsx
│       │   └── IntegrationConfigForm.tsx
│       │   └── RolePermissionForm.tsx    # Permission toggle grid for role creation/editing
│       └── shared/
│           ├── StatusBadge.tsx
│           ├── CurrencyDisplay.tsx       # Formats PHP values
│           ├── DateDisplay.tsx           # Formats to PHT
│           ├── RoleBadge.tsx
│           ├── ServiceHealthIndicator.tsx
│           └── DateRangePicker.tsx
├── hooks/
│   ├── usePermissions.ts                # Dynamic permission checks from role's permission set
│   ├── useAuth.ts                       # JWT auth context
│   ├── useRoles.ts                      # CRUD for roles and permissions
│   ├── useAuditLog.ts                   # Log admin actions
│   ├── useFareConfig.ts
│   ├── useMetrics.ts
│   └── useRealTimeUpdates.ts            # WebSocket or polling
├── api/
│   └── super-admin/
│       ├── auth.ts
│       ├── metrics.ts
│       ├── admins.ts
│       ├── roles.ts
│       ├── fares.ts
│       ├── payments.ts
│       ├── safety.ts
│       ├── reports.ts
│       ├── system.ts
│       └── audit.ts
├── types/
│   └── super-admin/
│       ├── admin.ts
│       ├── role.ts
│       ├── fare.ts
│       ├── payment.ts
│       ├── incident.ts
│       ├── audit.ts
│       ├── system.ts
│       └── enums.ts
├── utils/
│   ├── formatCurrency.ts               # PHP formatting
│   ├── formatDate.ts                   # PHT timezone
│   ├── maskApiKey.ts                   # Show last 4 chars only
│   └── permissions.ts                  # Permission key constants
└── constants/
    ├── roles.ts
    ├── permissions.ts
    ├── routes.ts
    └── featureFlags.ts
```

---

## 3. Role-Based Access Control (Dynamic RBAC)

The Super Admin Panel uses **dynamic RBAC** — roles and their permissions are stored in the database, not hardcoded. Super Admins can create custom roles and toggle individual permissions per feature through the UI, without code changes or redeployment.

### 3.1 Built-in Roles (Defaults)

These roles are seeded on first deployment. They can be modified (except `super_admin`) but not deleted.

| Role | Default Permissions | Editable | Deletable |
|------|-------------------|:--------:|:---------:|
| `super_admin` | All permissions (read + write) | ✗ | ✗ |
| `operations` | Users, rides, KYC, safety, reports, notifications | ✓ | ✓ |
| `finance` | Payments, reports, commission (propose only) | ✓ | ✓ |
| `support` | Read-only: users, rides, incidents | ✓ | ✓ |

The `super_admin` role is a system-level constant — it always has full access and cannot be modified or deleted. This is enforced at the backend, not just the frontend.

### 3.2 Permission Keys

Permissions are defined as feature + access level pairs. Each permission has a `read` and `write` scope.

| Permission Key | Read | Write | Description |
|---------------|------|-------|-------------|
| `dashboard` | View KPIs and charts | N/A (read-only) | Dashboard and system overview |
| `admin_management` | View admin list | Create, edit, suspend, deactivate admins | Admin account management |
| `role_management` | View roles and permissions | Create, edit, delete roles | Role and permission configuration |
| `fare_config` | View fare settings | Edit base fares, surge settings | Fare and surge pricing |
| `payments` | View transactions, summaries | Edit gateway config, commission rates | Payment and financial config |
| `payouts` | View payout queue | Approve/reject driver payouts | Driver payout management |
| `user_management` | View rider/driver profiles | Edit, suspend, deactivate users | Rider and driver accounts |
| `kyc_verification` | View KYC queue | Approve, reject, flag submissions | Driver document verification |
| `safety_incidents` | View incident log | Update status, assign, resolve | Emergency and safety management |
| `reports` | View reports and charts | Export reports (CSV/PDF) | Reports and analytics |
| `system_config` | View integration settings | Edit API keys, feature flags, templates | System-level configuration |
| `system_health` | View service status | Trigger health checks, toggle maintenance | Infrastructure monitoring |
| `audit_log` | View audit entries | Export audit log | Audit trail access |
| `ltfrb_compliance` | View compliance status | Edit compliance records | LTFRB regulatory tracking |

### 3.3 How Dynamic Roles Work

1. Super Admin creates a role via the Role Management page (e.g., "City Manager")
2. Toggles permissions using a grid of on/off switches per feature, with separate read/write columns
3. Role is saved to the database with its permission set
4. When assigning an admin, the role dropdown includes the custom role
5. On login, the JWT includes the `role_id` — the backend looks up that role's permissions from the database
6. Frontend fetches permissions via `GET /api/admin/roles/:id/permissions` on auth, caches in Zustand, and uses `usePermissions()` hook to gate UI elements
7. Backend middleware checks permissions on every API request — the frontend is only a convenience layer

### 3.4 Default Permission Sets for Built-in Roles

These are the default permission assignments for the seeded roles. Super Admin can modify the non-super_admin roles at any time.

| Permission Key | super_admin | operations (default) | finance (default) | support (default) |
|---------------|:-----------:|:-------------------:|:-----------------:|:----------------:|
| `dashboard` | R | R | R | R |
| `admin_management` | R+W | — | — | — |
| `role_management` | R+W | — | — | — |
| `fare_config` | R+W | — | R | — |
| `payments` | R+W | — | R | — |
| `payouts` | R+W | — | R+W | — |
| `user_management` | R+W | R+W | — | R |
| `kyc_verification` | R+W | R+W | — | — |
| `safety_incidents` | R+W | R+W | — | R |
| `reports` | R+W | R+W | R+W | — |
| `system_config` | R+W | — | — | — |
| `system_health` | R+W | R | — | — |
| `audit_log` | R+W | — | — | — |
| `ltfrb_compliance` | R+W | R | — | — |

R = read, W = write, R+W = both, — = no access

### 3.5 Implementation

```typescript
// hooks/usePermissions.ts
// On auth, fetches role's permissions from API and caches in Zustand
// Returns: { can(key: string, scope: 'read' | 'write'): boolean, permissions: Permission[], role: Role }

// Usage in components:
const { can } = usePermissions();
if (!can('fare_config', 'write')) return <AccessDenied />;

// Sidebar dynamically shows/hides nav items based on permissions:
{can('payments', 'read') && <SidebarItem to="/super-admin/payments" />}

// JWT includes: { sub: adminId, role_id: "uuid", exp: ... }
// Backend middleware: decode JWT → look up role_id → load permissions → check against endpoint
```

### 3.6 Business Rules

- `super_admin` role is immutable — always has all permissions, cannot be edited or deleted
- Cannot delete a role that is currently assigned to any active admin (must reassign first)
- Cannot deactivate the last remaining `super_admin` account
- Cannot modify own role (prevents accidental self-demotion)
- Only `super_admin` can access Role Management by default
- All role changes (create, edit, delete, assign) logged in audit trail
- Suspended admins have JWT tokens invalidated server-side immediately
- When a role's permissions are modified, affected admins see changes on next API request (frontend refreshes on 401)

---

## 4. Pages

### 4.1 Dashboard (`/super-admin/dashboard`)

**Permissions:** All roles (content varies by role)

#### KPI Cards Row

| Card | Endpoint | Notes |
|------|----------|-------|
| Total Active Riders | `GET /api/admin/metrics/riders` | Monthly active, trend vs previous month |
| Total Active Drivers | `GET /api/admin/metrics/drivers` | Verified + online in past 30 days |
| Rides Today | `GET /api/admin/metrics/rides?period=today` | Live count, auto-refresh every 60s |
| Revenue Today (₱) | `GET /api/admin/metrics/revenue?period=today` | Gross bookings in PHP |
| Avg Wait Time | `GET /api/admin/metrics/wait-time` | Target: < 5 minutes |
| Platform Uptime | `GET /api/admin/system/health` | Target: 99.99% |

Each card: current value, trend arrow (up/down), percentage change vs previous period.

#### Charts

- **Rides Over Time:** Line chart, 30-day default (toggleable: 7d/90d). Previous period overlay for comparison.
- **Revenue by Week:** Stacked bar chart (last 12 weeks), stacked by payment method (Cash/GCash/PayMaya/Card). All values in ₱.
- **Driver Supply Heatmap:** Map widget with real-time driver density. Color gradient: red (low) → green (high).
- **Vehicle Type Distribution:** Donut chart — motorcycle, tricycle, other.

#### Activity Feed

Real-time event stream, most recent first. Filterable by type:
- New driver sign-ups (pending KYC)
- SOS / emergency button activations
- Payment failures or gateway errors
- Rides exceeding fare estimate by >10% outside surge (AC1 violation)
- API latency alerts (>500ms threshold)

---

### 4.2 Admin User Management (`/super-admin/admins`)

**Permissions:** `admin_management` (read to view, write to create/edit/suspend)

#### Table Columns

| Column | Type |
|--------|------|
| Name | String |
| Email | String |
| Role | String (dynamic — from roles table, displayed as badge) |
| Status | Enum: active / suspended / deactivated |
| Last Login | Datetime (PHT) |
| Created By | String (admin name) |
| Date Created | Datetime |

#### Actions

- **Create Admin:** Modal → name, email, role (dropdown populated from `GET /api/admin/roles`), temporary password. Sends invitation email. Must change password on first login.
- **Edit Admin:** Modify role or status. Role dropdown shows all active roles. Role changes show confirmation modal listing permissions gained/lost.
- **Suspend Admin:** Immediate access revocation. Server-side JWT invalidation.
- **Deactivate Admin:** Permanent. Account kept for audit trail, cannot be reactivated.
- **View Activity:** Opens audit log filtered to this admin's actions.

---

### 4.3 Role Management (`/super-admin/roles`)

**Permissions:** `role_management` (super_admin only by default)

This is the core of the dynamic RBAC system. Super Admins create, edit, and delete roles with custom permission sets.

#### Role List

| Column | Type |
|--------|------|
| Role Name | String |
| Description | String |
| Type | Badge: System (built-in) / Custom |
| Active Admins | Number (count of admins assigned) |
| Permissions Count | Number (e.g., "8 of 14") |
| Created By | String (admin name) |
| Date Created | Datetime |

#### Create/Edit Role

Modal or full-page form with:

1. **Role Name:** Text input (e.g., "City Manager", "Auditor", "Marketing Lead")
2. **Description:** Text input explaining the role's purpose
3. **Permission Grid:** Toggle table with all permission keys as rows, Read / Write as columns

```
┌────────────────────┬──────┬───────┐
│ Permission         │ Read │ Write │
├────────────────────┼──────┼───────┤
│ Dashboard          │ [ON] │ [--]  │  ← no write scope
│ Admin management   │ [  ] │ [  ]  │
│ Role management    │ [  ] │ [  ]  │
│ Fare config        │ [ON] │ [  ]  │
│ Payments           │ [  ] │ [  ]  │
│ Payouts            │ [ON] │ [ON]  │
│ User management    │ [ON] │ [ON]  │
│ KYC verification   │ [ON] │ [ON]  │
│ Safety / incidents │ [ON] │ [ON]  │
│ Reports            │ [ON] │ [  ]  │
│ System config      │ [  ] │ [  ]  │
│ System health      │ [ON] │ [  ]  │
│ Audit log          │ [  ] │ [  ]  │
│ LTFRB compliance   │ [ON] │ [  ]  │
└────────────────────┴──────┴───────┘
```

- Toggling "Write" automatically enables "Read" for that permission
- "Select All Read" / "Select All Write" / "Clear All" bulk actions at the top
- Preview section below the grid showing which sidebar items this role will see

#### Actions

- **Create Role:** Permission grid form. Requires name + at least one permission.
- **Edit Role:** Grid pre-filled with current permissions. Warning: "X admin(s) will be affected."
- **Duplicate Role:** Creates copy with "Copy of [name]" — useful for variants.
- **Delete Role:** Only if no active admins assigned. Must reassign first.
- **View Admins:** Filtered list of admins assigned to this role.

#### Business Rules

- `super_admin` displayed but not editable (greyed out, "System role — cannot be modified")
- Role names must be unique (case-insensitive)
- Cannot delete a role with active admins — must reassign first
- All role changes logged with full before/after permission diff

---

### 4.4 Fare Configuration (`/super-admin/fares`)

**Permissions:** super_admin (full), finance (view only)
**Traces to:** FR-02 (Fare Calculation), AC1 (fare within 10% of estimate)

#### Base Fare Settings

Editable table, one row per vehicle type. All values in ₱.

| Parameter | Motorcycle | Tricycle | Other |
|-----------|:----------:|:--------:|:-----:|
| Base Fare (₱) | configurable | configurable | configurable |
| Per-KM Rate (₱/km) | configurable | configurable | configurable |
| Per-Minute Rate (₱/min) | configurable | configurable | configurable |
| Minimum Fare (₱) | configurable | configurable | configurable |
| Booking Fee (₱) | configurable | configurable | configurable |
| Cancellation Fee (₱) | configurable | configurable | configurable |

#### Surge Pricing Controls

- **Global Toggle:** On/Off. When off, no surge multipliers applied platform-wide.
- **Multiplier Range:** Min 1.0x, max configurable (recommended cap: 3.0x).
- **Trigger Thresholds:** Demand-to-supply ratio that activates each surge level.
- **Surge Zones:** Map interface to draw geographic polygons for independent surge zones.
- **Surge Schedule:** Option to disable surge during specific hours (holidays, emergencies).

#### Fare Estimate Simulator

Input: pickup coordinates, drop-off coordinates, vehicle type.
Output: fare breakdown — base fare + distance charge + time charge + booking fee + surge.
Purpose: validate config changes produce expected results before going live.

#### Business Rules

- All fare changes require confirmation modal with before/after comparison
- Changes logged to audit trail with exact values changed
- AC1 enforcement: show violation counter for rides where final fare exceeded estimate by >10% outside surge
- Fare changes apply immediately to NEW bookings; in-progress rides use fare at time of booking

---

### 4.5 Payments & Financial Controls (`/super-admin/payments`)

**Permissions:** super_admin (full), finance (reports + payout approval)
**Traces to:** FR-03 (Payment Processing)

#### Payment Gateway Configuration (super_admin only)

| Provider | Config Fields |
|----------|--------------|
| GCash | API Key, Secret, Merchant ID, Webhook URL |
| PayMaya | API Key, Secret, Merchant ID, Webhook URL |
| Stripe / Local Card Processor | Publishable Key, Secret Key, Webhook Secret |
| Cash | No API config (logic in fare settings) |

Rules:
- API keys masked in UI (show last 4 characters only)
- Credential changes require password re-confirmation
- Each provider shows health indicator: last successful transaction, error rate
- Failover toggle: if primary e-wallet fails, auto-suggest alternative to rider

#### Commission Settings

- **Platform Commission Rate:** % deducted per ride. Configurable per vehicle type.
- **Minimum Commission:** Floor amount in ₱.
- **Promotional Overrides:** Temporary adjustments for driver acquisition (e.g., 0% for first month).
- Finance admin can propose changes; super_admin must approve.

#### Summary Cards

| Card | Description |
|------|-------------|
| Total Revenue (₱) | Gross bookings for selected period |
| Total Driver Payouts (₱) | Amount paid/owed to drivers |
| Platform Commission (₱) | Revenue minus payouts |
| Pending Settlements (₱) | Payouts awaiting processing |
| Failed Transactions | Count of failures in period |

#### Transaction History Table

| Column | Type | Filterable |
|--------|------|:----------:|
| Transaction ID | String | search |
| Ride ID | String (link) | search |
| Rider Name | String | search |
| Driver Name | String | search |
| Amount (₱) | Decimal | range |
| Payment Method | Enum | dropdown |
| Status | Enum: Settled/Pending/Failed/Refunded | dropdown |
| Commission (₱) | Decimal | no |
| Date | Datetime | date range |

#### Driver Payout Management

- **Payout Queue:** Table of pending payouts — driver name, amount, period, payout method.
- **Batch Approval:** Multi-select + bulk approve. Requires finance or super_admin role.
- **Payout Schedule:** Configure frequency — daily, weekly, bi-weekly.
- **Export:** CSV or PDF. Satisfies requirement: "Admins must be able to export weekly financial reports detailing commission and driver payouts."

---

### 4.6 Safety & Compliance (`/super-admin/safety`)

**Permissions:** super_admin (full), operations (incident management), support (read only)
**Traces to:** FR-10 (In-App SOS), BR3 (Safety)

#### Emergency Incident Log

| Column | Type |
|--------|------|
| Incident ID | Auto-generated |
| Date/Time | Datetime (PHT) |
| Ride ID | String (link) |
| Triggered By | Enum: Rider / Driver |
| Rider Name | String |
| Driver Name | String |
| Type | Enum: SOS Triggered / Reported Incident / Safety Complaint |
| Status | Enum: Open / Investigating / Resolved / Escalated |
| Assigned To | String (admin name) |
| Resolution Notes | Text |

Expanded view per incident: ride route on map, rider/driver profiles, event timeline (SOS pressed → SMS sent → 911 called), communication log.

#### Driver Verification Queue (KYC)

Documents to review per submission:
- Driver's license
- Vehicle registration
- Commercial insurance policy (required before activation)
- Profile photo
- NBI clearance

Actions: Approve (activates driver) | Reject (with reason, driver notified, can resubmit) | Flag for Review (escalate to super_admin)

Batch processing supported. Document viewer with zoom, rotate, side-by-side comparison.

#### LTFRB Compliance Dashboard

- Accreditation status and expiry dates
- Driver compliance rates (valid license, insurance, vehicle inspection)
- Required report generation for LTFRB submissions
- LGU (Local Government Unit) partnership tracking by city/municipality
- Compliance violation alerts with remediation deadlines

---

### 4.7 Reports & Analytics (`/super-admin/reports`)

**Permissions:** super_admin (all), operations (operational), finance (financial)

#### Report Types

| Report | Contents | Export |
|--------|----------|--------|
| Weekly Financial Summary | Revenue, payouts, commissions, payment method breakdown | CSV, PDF |
| Driver Performance | Ratings, acceptance rate, completion rate, earnings per driver | CSV, PDF |
| Rider Retention | MAU, churn rate, retention rate (target: 75%) | CSV, PDF |
| Ride Volume by Area | Rides per city/barangay, heatmap data | CSV, PDF |
| Vehicle Type Analysis | Rides per type, revenue per type, demand trends | CSV, PDF |
| Safety Incident Report | Count by type, resolution times, escalation rate | CSV, PDF |
| KYC Processing Report | Submissions, approval/rejection rates, avg review time | CSV, PDF |

#### Analytics Charts

- **Rides by Vehicle Type:** Donut/pie chart
- **Peak Hours Heatmap:** 7-day × 24-hour grid showing ride volume intensity
- **Average Rating Trends:** Line chart (rider + driver ratings over time)
- **Payment Method Distribution:** Stacked bar (Cash/GCash/PayMaya/Card over time)
- **Wait Time Trends:** Line chart with 5-minute target threshold line
- **KPI Progress Gauges:** Year-one targets — 100K riders, 5K drivers, 75% retention

#### Date Controls

- Global date range picker: presets (today, 7d, 30d, 90d, custom)
- All charts/tables respond to selected range
- Compare toggle: overlay previous period for trends

---

### 4.8 System Configuration (`/super-admin/system`)

**Permissions:** super_admin only

#### Integration Settings

| Integration | Config Fields | Health Check |
|-------------|--------------|--------------|
| Google Maps / Mapbox | API key, usage limits, billing alert threshold | Last geocode, daily quota |
| SMS OTP (Twilio / local) | Account SID, Auth Token, sender number | Last OTP, delivery rate |
| Firebase Cloud Messaging | Server key, project ID | Last push, delivery rate |
| Background Check Service | API key, webhook URL | Pending checks, avg turnaround |
| Cloud Storage (S3 / equiv) | Bucket name, access key, region | Storage used, last upload |

Rules: API keys masked. Changes require password re-confirmation. Health check runs on page load + manual trigger.

#### Notification Templates

| Event | Channel | Template Variables |
|-------|---------|-------------------|
| Ride Accepted | Push + SMS | `{driver_name}`, `{vehicle_type}`, `{eta}` |
| Driver ETA Update | Push | `{eta}`, `{driver_name}` |
| Ride Started | Push | `{driver_name}`, `{pickup_address}` |
| Ride Completed | Push + SMS | `{fare}`, `{payment_method}`, `{driver_name}` |
| Payment Failed | Push + SMS | `{amount}`, `{payment_method}`, `{retry_url}` |
| SOS Alert | SMS (emergency contact) | `{rider_name}`, `{location_url}`, `{ride_id}` |
| KYC Approved | Push + SMS | `{driver_name}` |
| KYC Rejected | Push + SMS | `{driver_name}`, `{rejection_reason}` |

#### Feature Flags

| Flag | Description |
|------|-------------|
| `surge_pricing` | Enable/disable surge globally |
| `vehicle_type_*` | Enable/disable specific vehicle types |
| `payment_method_*` | Enable/disable per payment method |
| `maintenance_mode` | Disable ride booking with custom message |
| `driver_onboarding` | Open/close new driver registrations |

#### Data Retention Settings

- Trip history: minimum 3 years (regulatory requirement)
- PII anonymization schedule for analytics
- Driver document retention after deactivation
- Audit log retention: indefinite

---

### 4.9 System Health Monitoring (`/super-admin/health`)

**Permissions:** super_admin (full), operations (limited view)

#### Service Status Board

| Service | Metrics | Alert Threshold |
|---------|---------|----------------|
| API Gateway | Response time, request rate, error rate | Latency > 500ms |
| Dispatch Service | Match rate, match time, queue depth | Match time > 60s (AC2) |
| Payment Service | Transaction success rate, processing time | Success rate < 99% |
| WebSocket (Tracking) | Active connections, message latency | Latency > 3s (FR-05) |
| PostgreSQL | Connection pool, query latency, replication lag | Query time > 200ms |
| Redis | Hit rate, memory usage, connections | Hit rate < 80% |
| NATS (JetStream) | Message throughput, consumer lag | Consumer lag > 1000 msgs |

#### Infrastructure Metrics

- CPU/Memory/Disk per service with historical charts
- Database: active connections, slow query log, table sizes
- API Latency: P50, P95, P99 per endpoint (target: <500ms)
- WebSocket connections: current count, update frequency indicator (target: every 3s)

#### Alerting

- Configurable alert rules: threshold, duration, notification channel (email, SMS, Slack webhook)
- Alert history log with timestamps and resolution status
- Maintenance mode toggle: banner in rider/driver apps, pauses dispatch

---

### 4.10 Audit Log (`/super-admin/audit`)

**Permissions:** super_admin only

#### Log Entry Schema

| Field | Type | Description |
|-------|------|-------------|
| timestamp | Datetime (PHT) | When action occurred |
| actor | String | Admin name + email |
| ip_address | String | Source IP |
| action | Enum | CREATE / UPDATE / DELETE / APPROVE / REJECT / LOGIN / LOGOUT |
| resource_type | String | e.g., `fare_config`, `admin_user`, `driver_payout` |
| resource_id | String | ID of affected resource |
| before | JSON | State before change (null for CREATE) |
| after | JSON | State after change (null for DELETE) |
| reason | String (optional) | Admin-provided reason |

#### Features

- Searchable by: actor, action type, resource type, date range
- Diff view: side-by-side before/after for UPDATE actions
- Export to CSV
- Append-only: no admin can modify or delete entries
- Retention: indefinite

---

## 5. API Endpoints

All prefixed with `/api/admin`. JWT authentication required. Standard response envelope:

```json
{ "success": true, "data": {}, "error": null, "meta": { "page": 1, "total": 100 } }
```

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Admin login → JWT |
| POST | `/auth/logout` | Invalidate JWT |
| POST | `/auth/refresh` | Refresh token |
| PUT | `/auth/password` | Change password |

### Metrics

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/metrics/riders` | Active rider count + trends |
| GET | `/metrics/drivers` | Active driver count + trends |
| GET | `/metrics/rides?period=` | Ride counts |
| GET | `/metrics/revenue?period=` | Revenue data |
| GET | `/metrics/wait-time` | Wait time stats |
| GET | `/system/health` | Service health |

### Admin Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admins` | List all admins |
| POST | `/admins` | Create admin |
| PUT | `/admins/:id` | Update admin |
| DELETE | `/admins/:id` | Deactivate admin |
| GET | `/admins/:id/activity` | Admin's audit entries |

### Roles

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/roles` | List all roles |
| POST | `/roles` | Create role |
| GET | `/roles/:id` | Get role with permissions |
| PUT | `/roles/:id` | Update role name/description/permissions |
| DELETE | `/roles/:id` | Delete role (fails if admins assigned) |
| GET | `/roles/:id/permissions` | Get permission set for a role |
| GET | `/roles/:id/admins` | List admins assigned to this role |

### Fares

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/fares` | Current config |
| PUT | `/fares` | Update config |
| GET | `/fares/surge` | Surge settings |
| PUT | `/fares/surge` | Update surge |
| POST | `/fares/simulate` | Fare simulator |

### Payments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/payments/transactions` | Transaction list (paginated) |
| GET | `/payments/summary` | Financial summary |
| GET | `/payments/payouts` | Pending payouts |
| POST | `/payments/payouts/approve` | Batch approve |
| GET | `/payments/config` | Gateway config |
| PUT | `/payments/config/:provider` | Update provider |
| GET | `/payments/commission` | Commission settings |
| PUT | `/payments/commission` | Update commission |

### Safety

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/safety/incidents` | Incident list |
| PUT | `/safety/incidents/:id` | Update incident |
| GET | `/safety/kyc` | KYC queue |
| PUT | `/safety/kyc/:id` | Approve/reject |
| POST | `/safety/kyc/batch` | Batch actions |
| GET | `/safety/compliance` | LTFRB data |

### Reports

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/reports/:type` | Generate report |
| GET | `/reports/:type/export` | Export CSV/PDF |
| GET | `/analytics/charts/:chart` | Chart data |

### System

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/system/integrations` | List integrations |
| PUT | `/system/integrations/:service` | Update config |
| POST | `/system/integrations/:service/test` | Test health |
| GET | `/system/notifications/templates` | List templates |
| PUT | `/system/notifications/templates/:event` | Update template |
| GET | `/system/features` | Feature flags |
| PUT | `/system/features/:flag` | Toggle flag |

### Audit

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/audit` | Log entries (paginated) |
| GET | `/audit/export` | Export CSV |

---

## 6. Data Models

### AdminUser

```typescript
interface AdminUser {
  id: string;                  // UUID
  name: string;
  email: string;               // unique, login credential
  role_id: string;             // UUID — references Role.id
  role_name: string;           // denormalized for display
  status: 'active' | 'suspended' | 'deactivated';
  created_by: string;          // UUID of creating admin
  created_at: string;          // ISO timestamp UTC
  last_login_at: string | null;
}
```

### Role

```typescript
interface Role {
  id: string;                  // UUID
  name: string;                // e.g., "City Manager", "Operations"
  description: string;
  is_system: boolean;          // true for built-in roles (super_admin, operations, finance, support)
  permissions: RolePermission[];
  admin_count: number;         // number of active admins with this role
  created_by: string;          // AdminUser UUID
  created_at: string;
  updated_at: string;
}

interface RolePermission {
  permission_key: string;      // e.g., "fare_config", "payments", "audit_log"
  read: boolean;
  write: boolean;
}
```

### FareConfig

```typescript
interface FareConfig {
  id: string;
  vehicle_type: 'motorcycle' | 'tricycle' | 'other';
  base_fare: number;           // PHP
  per_km_rate: number;
  per_min_rate: number;
  minimum_fare: number;
  booking_fee: number;
  cancellation_fee: number;
  updated_by: string;          // AdminUser UUID
  updated_at: string;
}
```

### SurgeConfig

```typescript
interface SurgeConfig {
  id: string;
  enabled: boolean;
  max_multiplier: number;      // e.g., 3.0
  trigger_ratio: number;       // demand/supply ratio
  zones: GeoJSON;              // polygons for surge zones
  blackout_hours: {            // hours when surge disabled
    day: number;               // 0=Sunday
    start: string;             // "HH:mm"
    end: string;
  }[];
}
```

### AuditLogEntry

```typescript
interface AuditLogEntry {
  id: string;
  timestamp: string;           // ISO UTC
  actor_id: string;            // AdminUser UUID
  actor_name: string;
  ip_address: string;
  action: 'create' | 'update' | 'delete' | 'approve' | 'reject' | 'login' | 'logout';
  resource_type: string;       // e.g., 'fare_config', 'admin_user'
  resource_id: string;
  before_state: Record<string, any> | null;
  after_state: Record<string, any> | null;
  reason: string | null;
}
```

### Incident

```typescript
interface Incident {
  id: string;
  ride_id: string;
  triggered_by: 'rider' | 'driver';
  rider_id: string;
  driver_id: string;
  type: 'sos_triggered' | 'reported_incident' | 'safety_complaint';
  status: 'open' | 'investigating' | 'resolved' | 'escalated';
  assigned_to: string | null;  // AdminUser UUID
  resolution_notes: string | null;
  created_at: string;
  resolved_at: string | null;
}
```

### Transaction

```typescript
interface Transaction {
  id: string;
  ride_id: string;
  rider_name: string;
  driver_name: string;
  amount: number;              // PHP
  payment_method: 'cash' | 'gcash' | 'paymaya' | 'card';
  status: 'settled' | 'pending' | 'failed' | 'refunded';
  commission: number;          // PHP
  created_at: string;
}
```

---

## 7. Implementation Patterns

### Route Guards

```typescript
// Routes no longer check for specific role names — they check permissions
// SuperAdminShell loads permissions on mount via usePermissions()

// Page-level guard:
const { can } = usePermissions();
if (!can('fare_config', 'read')) return <AccessDenied />;

// Sidebar dynamically renders based on permissions:
const sidebarItems = allItems.filter(item => can(item.permissionKey, 'read'));

// Role Management page specifically checks:
if (!can('role_management', 'write')) return <AccessDenied />;
```

### Confirmation Modals

Every destructive or high-impact action must trigger a confirmation modal:
- Deactivate/suspend admin
- Create, edit, or delete roles
- Change fare configuration
- Toggle maintenance mode
- Approve/reject KYC
- Batch approve payouts
- Toggle feature flags
- Update payment gateway credentials

Modal shows: action description, affected resource, consequences, and requires explicit "Confirm" click.

### Audit Logging

```typescript
// useAuditLog hook wraps mutations to automatically log:
const { mutate } = useAuditedMutation({
  mutationFn: updateFareConfig,
  resourceType: 'fare_config',
  getBeforeState: () => currentConfig,
});
```

### Real-Time Updates

- Dashboard KPIs: polling every 60 seconds
- Activity feed: WebSocket subscription or 30s polling
- System health: polling every 30 seconds
- Incident log: WebSocket for new incidents

### Error Boundaries

Each page wrapped in error boundary to prevent cascading failures:

```typescript
<ErrorBoundary fallback={<PageError />}>
  <DashboardPage />
</ErrorBoundary>
```

---

## 8. Requirements Traceability

| Requirement | Super Admin Coverage |
|-------------|---------------------|
| FR-01 (Authentication) | Dynamic RBAC, JWT auth, role management, permission-based access control |
| FR-02 (Fare Calculation) | Fare config page, surge controls, simulator |
| FR-03 (Payment) | Gateway config, commission settings, payout management |
| FR-04 (Dispatch) | Dashboard metrics (match rate/time), dispatch health |
| FR-05 (Real-Time Tracking) | System health (WebSocket metrics, 3s update target) |
| FR-10 (SOS Button) | Safety incident log, emergency event tracking |
| AC1 (Fare ≤ 10% of estimate) | Fare violation counter, config constraints |
| AC2 (60s match time) | Dispatch service alert at >60s |
| AC3 (Smooth tracking) | WebSocket latency monitoring |
| NFR (500ms API) | API latency P50/P95/P99 per endpoint |
| NFR (99.99% uptime) | Service status board, alerting |
| NFR (encryption) | Gateway config, HTTPS enforcement |
| NFR (scalability) | Infrastructure metrics, resource monitoring |
| Data Retention (3yr) | Data retention settings page |
| BR3 (Safety) | Full safety/compliance section |