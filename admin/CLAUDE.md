# SakAI Admin Panel - Project Context

## Project Overview
SakAI is a modern, responsive admin web panel for a ride-hailing platform operating in the Philippines. It provides comprehensive tools for managing riders, drivers, rides, payments, surge pricing, safety compliance, and analytics.

## Tech Stack
- **Framework:** React 19 + TypeScript, Vite 6
- **Routing:** `react-router-dom` v7
- **Server state:** `@tanstack/react-query`
- **Client state:** `zustand`
- **Forms/validation:** `react-hook-form` + `zod` (via `@hookform/resolvers`)
- **Tables:** `@tanstack/react-table`
- **Styling:** Tailwind CSS v4 (via `@tailwindcss/vite`)
- **Icons / charts / motion:** `lucide-react`, `recharts`, `motion`
- **Testing:** `vitest` + `@testing-library/react` + `jsdom` + `fast-check`
- **API types:** generated from `../openapi/swagger.yaml` via `openapi-typescript`

## Commands
```bash
npm run dev              # Vite dev server on http://localhost:3000
npm run build            # Production build
npm run preview          # Preview built bundle
npm run lint             # tsc --noEmit (type-check only)
npm test                 # Vitest, single run
npm run test:watch       # Vitest, watch mode
npm run generate:types   # Regenerate src/types/openapi.d.ts from ../openapi/swagger.yaml
```

## Design System & Branding
- **Theme:** Dark theme by default.
- **Backgrounds:** `--color-background` (#121212), `--color-surface` (#1E1E1E)
- **Primary Accent:** `--color-primary` (#1A73E8 - Blue)
- **Status Colors:** Success (Green), Warning (Yellow), Danger (Red)
- **Typography:** Inter (sans-serif)
- **Localization:**
  - Currency: Philippine Peso (PHP / ₱)
  - Payment Methods: GCash, PayMaya, Cash, Card
  - Compliance: LTFRB references
  - Vehicle Types: Motorcycle, Tricycle, Car (4-seater)

## Project Structure
- `/src/api/` - API client + React Query hooks (typed against generated OpenAPI types).
- `/src/components/ui/` - Reusable atomic UI primitives (Button, Card, Table, Tabs, Input, Badge, ...).
- `/src/components/layout/`, `shared/`, `forms/` - Composed layout, shared widgets, and form components.
- `/src/components/super-admin/{dashboard,tables,modals,forms,shared}/` - Superadmin feature components.
- `/src/components/Header.tsx`, `ErrorBoundary.tsx` - Top-level chrome.
- `/src/components/layout/AppSidebar.tsx` - Unified sidebar consumed by both `AdminShell` and `SuperAdminShell`. Nav config lives in `/src/nav/{admin,super-admin}.ts`. Brand color comes from `useRoleAccent()` — never hardcode `text-primary` / `bg-warning` for brand chrome.
- `/src/components/RequirePermission.tsx` - Route/element guard backed by `usePermissions`.
- `/src/pages/` - One file per admin section (Dashboard, UserManagement, RideManagement, Payments, FareSurge, SafetyCompliance, Reports, Settings, Login).
- `/src/pages/super-admin/` - Superadmin-only views (audit logs, role management, system config, payments, safety compliance).
- `/src/contexts/`, `/src/hooks/` - Cross-cutting React context + custom hooks.
- `/src/constants/`, `/src/utils/`, `/src/lib/` - Constants, helpers, and `cn` / `formatPHP`.
- `/src/types/openapi.d.ts` - **Generated**, do not hand-edit. Run `npm run generate:types`.
- `/src/mocks/`, `/src/test/` - Static fixtures and Vitest jsdom setup.
- `/src/api/super-admin/` - One file per resource; uses typed `adminRequest` helper from `_request.ts`.

## AI Assistant Guidelines
When contributing to this project, please adhere to the following rules:
1. **Styling:** Always use Tailwind CSS utility classes. Do not use inline styles or create new CSS files unless absolutely necessary. Rely on the CSS variables defined in `/src/index.css`.
2. **Components:** Reuse existing UI components from `/src/components/ui/` whenever possible.
3. **Icons:** Always use `lucide-react` for icons.
4. **Context:** Maintain the Philippine context (e.g., use PHP for currency, reference local locations like Metro Manila, Makati, BGC, and local payment methods).
5. **State Management:**
    - **Server state** (API data) → `@tanstack/react-query` hooks in `src/api/`. Do not fetch with raw `useEffect`.
    - **Client state** (UI, session) → `zustand` stores. Use `useState` only for local, ephemeral state.
    - **Forms** → `react-hook-form` + `zod` schemas via `@hookform/resolvers`.
6. **Code Style:** Write clean, functional React components with TypeScript interfaces for props.
7. **API types:** Do not hand-write request/response types that belong in OpenAPI. Update `../openapi/swagger.yaml` and run `npm run generate:types`.
8. **Testing:** Vitest + Testing Library live alongside code. Run `npm test` before declaring work done. Don't add Jest.
9. **Admin / SA page parity:** All admin/SA page pairs (Dashboard, Payments, SafetyCompliance, Reports) share the same skeleton: `<PageHeader> → KpiRow → MainGrid → role-extras → modals`. SA-deeper features (tabs, batch toolbars, gateway/commission editors, LTFRB section) render below the MainGrid as sub-components — never interleaved into the shared skeleton.
10. **Brand accent:** Use `useRoleAccent()` from `@/hooks/useRoleAccent` for any brand-colored surface (KPI tone, ActionQueueCard tone, sidebar logo, active-link). Status colors (success/warning/danger) stay literal. Never hardcode `'primary'` or `'sa-accent'` tones in page files.
11. **Confirmation modals:** Use `ConfirmationModal` from `@/components/shared/ConfirmationModal`. The legacy `ConfirmModal` adapter and the SA re-export have been removed.

## Gotchas
- Dev server runs on **port 3000** (see `package.json`) — some older docs (e.g. `TEST_ACCOUNTS.md`) reference `5173`; 3000 is correct.
- `src/types/openapi.d.ts` is generated; editing it by hand will be overwritten.
- Backend API base URL comes from `.env` (see `.env.example`); test credentials are in `TEST_ACCOUNTS.md` (local only).
- **Monorepo siblings:** backend lives at `../backend/`, OpenAPI contract at `../openapi/swagger.yaml`. `npm run generate:types` reads from there.
- **Dynamic RBAC:** gate UI with `usePermissions().can('key', 'read' | 'write')`. Do NOT compare against a static role string — backend roles are dynamic.
- **Test colocation:** Vitest specs live next to source as `*.test.ts(x)` (e.g. `src/utils/formatCurrency.test.ts`). No separate `__tests__/` dirs.
