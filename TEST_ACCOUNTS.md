# SakAI — Test Admin Accounts

> **LOCAL / DEVELOPMENT ONLY** — Never use these credentials in staging or production.

---

## Accounts

| Name        | Email                  | Password  | Role       |
|-------------|------------------------|-----------|------------|
| Super Admin | superadmin@sakai.com   | admin123  | superadmin |
| Operations  | operations@sakai.com   | admin123  | operations |
| Finance     | finance@sakai.com      | admin123  | finance    |
| Support     | support@sakai.com      | admin123  | support    |

**TEST a@sakai.com @MoXqEWDs3

---

## Reset & Reseed (single command)

Run from the `backend/` directory:

```bash
go run ./cmd/seed-admin -reset
```

This deletes all existing admin accounts and their audit log entries, resets system roles and permissions, then seeds all 4 accounts above — in a single transaction. Safe to re-run.

---

## Permissions by Role

| Permission         | super_admin | operations | finance | support |
|--------------------|:-----------:|:----------:|:-------:|:-------:|
| dashboard          | R           | R          | R       | R       |
| admin_management   | R/W         |            |         |         |
| role_management    | R/W         |            |         |         |
| fare_config        | R/W         |            | R/W     |         |
| payments           | R/W         |            | R/W     |         |
| payouts            | R/W         |            | R/W     |         |
| user_management    | R/W         | R/W        |         | R       |
| kyc_verification   | R/W         | R/W        |         |         |
| safety_incidents   | R/W         | R/W        |         | R       |
| reports            | R/W         | R          | R/W     | R       |
| system_config      | R/W         |            |         |         |
| system_health      | R           |            |         |         |
| audit_log          | R           |            |         |         |
| ltfrb_compliance   | R/W         | R/W        |         |         |

---

## How to Log In

**UI:** `http://localhost:5173`

**API:** `POST http://192.168.100.43/api/auth/login`
```json
{ "email": "superadmin@sakai.com", "password": "admin123" }
```
