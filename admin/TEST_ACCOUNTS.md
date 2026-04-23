# SakAI — Test Admin Accounts

> **LOCAL / DEVELOPMENT ONLY** — Never use these credentials in staging or production.

---

## Accounts

| Name       | Email                  | Password  | Role       |
|------------|------------------------|-----------|------------|
| SuperAdmin | superadmin@sakai.com   | admin123  | superadmin |

---

## Creating the Superadmin Account

Run from the `backend/` directory:

```bash
go run ./cmd/seed-admin \
  -role superadmin \
  -name "SuperAdmin" \
  -email "superadmin@sakai.com" \
  -password "admin123"
```

The tool supports `-role admin` or `-role superadmin`. For `operations`, `finance`, and `support` roles, create accounts through the admin panel after logging in as superadmin (`Settings → Role Management → Add Admin`).

---

## How to Log In

**UI:** `http://localhost:3000`

**API:** `POST http://192.168.100.43/api/auth/login`
```json
{ "email": "superadmin@sakai.com", "password": "admin123" }
```
