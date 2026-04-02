# SakAI — Development vibe and skill bridge

This repo is a **ride-hailing platform monorepo**: Go + Gin backend (Clean Architecture), Flutter passenger/driver apps, **OpenAPI** as the contract, **PostgreSQL + PostGIS**, **Redis**, and **WebSockets** for live tracking. Docs and phase gates live in `overview.md` and `docs/`.

The **agentic skill library** checked in here: `./~/.agent/skills.json` (paths like `skills/<id>` → `./~/.agent/skills/<id>/SKILL.md`). If you keep another copy under `$HOME/.agents`, point Cursor at the same content so the mappings in `.cursorrules` stay valid.

---

## Andru.ia skills (use for Spanish-first strategy and quality bar)

| Skill | Role | When to use on SakAI |
|-------|------|----------------------|
| **00-andruia-consultant** | Solution architect, evolution vs greenfield | Kickoff, quarterly planning, Spanish milestone docs, restructuring proposals |
| **10-andruia-skill-smith** | Skill engineer, **Estándar de Diamante** | Creating or upgrading Cursor/agent skills, registries, structured expert prompts |
| **20-andruia-niche-intelligence** | Domain strategist | Mobility/compliance, driver–rider trust, map/geo UX, marketplace dynamics—after niche is named |

---

## Community skills — highest signal for this codebase

| Skill ID | Why it maps to SakAI |
|----------|----------------------|
| **golang-pro** | Core backend language |
| **backend-architect** | Service layers, boundaries, scalability |
| **go-concurrency-patterns** | WS hubs, Redis fan-out, parallel work |
| **backend-security-coder** | Phase 2 security items, authZ on handlers |
| **postgresql**, **postgres-best-practices**, **database-migration** | Migrations, PostGIS, indexes |
| **openapi-spec-generation**, **api-documentation**, **api-design-principles** | `openapi/swagger.yaml`, client sync |
| **flutter-expert** | Passenger/driver apps |
| **docker-expert** | `docker-compose`, local infra |
| **ai-engineer** | Backend/feature design, service thinking |
| **full-stack-orchestration-full-stack-feature** | Cross-cutting features (API + mobile + DB) |
| **software-architecture** | Clean Architecture alignment across stacks |
| **writing-plans** | Scoped implementation plans |
| **verification-before-completion** | Pre-merge discipline |
| **debugging-strategies** | Deep dives on failing flows |
| **3d-web-experience** | Only if you add Three.js / R3F (e.g. map or marketing 3D)—not core stack today |
| **react-best-practices**, **typescript-pro** | Future `admin/` dashboard |

---

## Shortcut prompts (copy-paste)

Use these at the start of a chat so the agent loads the right mindset; then rely on `.cursorrules` **Skill Mapping** for path-based detail.

**Architecture / planning (ES)**

- `@skills/00-andruia-consultant` Diagnostica SakAI como proyecto en evolución. Salida en español: breve diagnóstico, riesgos y siguiente hilo de trabajo alineado con `overview.md`.

**Domain (mobility)**

- `@skills/20-andruia-niche-intelligence` Nicho: ride-hailing B2C/B2B. Genera un dossier de dominio en español: regulaciones típicas, riesgos de producto, patrones UX para conductor y pasajero, y checklist de cumplimiento datos/ubicación.

**Backend Go**

- `@skills/golang-pro` @backend Trabaja en archivos abiertos siguiendo Clean Architecture del repo; no rompas puertos del dominio.
- `@skills/backend-security-coder` @backend Audita el archivo activo: authZ, validación, límites de request, fugas de datos.

**API contract**

- `@skills/openapi-spec-generation` @openapi Cambios coherentes con `swagger.yaml`; indica impacto en clientes Dart.

**SQL / PostGIS**

- `@skills/postgresql` @migrations Migración segura, compatible con PostGIS y convenciones existentes.

**Flutter**

- `@skills/flutter-expert` @mobile Domain/data/presentation limpios; sin lógica de negocio pesada en widgets.

**Infra**

- `@skills/docker-expert` Revisa `docker-compose.yml` y variables alineadas con `backend/.env.example`.

**Skills / Diamond standard**

- `@skills/10-andruia-skill-smith` Diseña una skill nueva para X; cumple Estándar de Diamante y español.

**Full stack slice**

- `@skills/writing-plans` Luego `@skills/full-stack-orchestration-full-stack-feature` Plan corto + implementación: feature que toque OpenAPI, Go y Flutter.

---

## One-line vibe

**Serious transport backend, contract-first APIs, mobile-first UX, realtime by default—documented and phased like a product company shipping, not a demo.**
