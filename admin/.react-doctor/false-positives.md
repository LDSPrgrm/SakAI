# React Doctor — known false positives

Diagnostics matching the patterns below are suppressed during triage. Each entry
records *why* it is a false positive so a future reviewer can re-verify.

## `deslop/unused-file` — super-admin tree

- `deslop/unused-file` — `src/pages/super-admin/**` — reached via `React.lazy(() => import(...))` in `src/App.tsx`; the dead-code detector cannot trace dynamic imports across the `lazy()` boundary.
- `deslop/unused-file` — `src/components/super-admin/**` — imported transitively by the lazy-loaded SA pages above (tables, modals, forms, dashboard widgets, shared); unreachable to a static tracer that stops at the dynamic-import boundary.
- `deslop/unused-file` — `src/api/super-admin/**` — the data layer consumed by the SA hooks/pages behind the same `lazy()` boundary.
- `deslop/unused-file` — `src/types/super-admin/**` — type-only modules consumed by the above; `verbatimModuleSyntax`/type-only imports are invisible to the runtime-import graph the detector walks.

Verification: `src/App.tsx` lazy-loads every `SA*` page (`lazy(() => import('@/pages/super-admin/...').then(m => ({ default: m.X })))`) and mounts them under the `/super-admin` route tree.

## `react-doctor/aria-role` — `RoleAccentProvider role=`

- `react-doctor/aria-role` — `src/components/layout/AdminShell.tsx` — `role="admin"` here is a **prop on the custom `<RoleAccentProvider>`** (`role: AdminRole`), not a DOM ARIA attribute. The rule cannot distinguish a custom component prop from a real `aria` role.
- `react-doctor/aria-role` — `src/components/super-admin/layout/SuperAdminShell.tsx` — same: `role="super-admin"` is the `RoleAccentProvider` prop.
- `react-doctor/aria-role` — `src/components/layout/AppSidebar.test.tsx` — same: `<RoleAccentProvider role="admin" | "super-admin">` in test render helpers.

Verification: `src/contexts/RoleAccentContext.tsx` defines `RoleAccentProvider({ role }: { role: AdminRole })` where `AdminRole = 'admin' | 'super-admin'`.
