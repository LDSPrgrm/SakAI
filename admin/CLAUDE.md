# SakAI Admin Panel - Project Context

## Project Overview
SakAI is a modern, responsive admin web panel for a ride-hailing platform operating in the Philippines. It provides comprehensive tools for managing riders, drivers, rides, payments, surge pricing, safety compliance, and analytics.

## Tech Stack
- **Framework:** React 18 with TypeScript
- **Build Tool:** Vite
- **Styling:** Tailwind CSS v4
- **Icons:** `lucide-react`
- **Charts:** `recharts`
- **Utilities:** `clsx`, `tailwind-merge`, `date-fns`

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
- `/src/components/ui/` - Reusable, atomic UI components (Button, Card, Table, Tabs, Input, Badge).
- `/src/components/` - Layout components (Sidebar, Header).
- `/src/pages/` - Main views for the application:
  - `Dashboard.tsx` - Key metrics, charts, and live activity.
  - `UserManagement.tsx` - Rider and Driver data tables, KYC reviews.
  - `RideManagement.tsx` - Ride history, status tracking, and routing.
  - `Payments.tsx` - Revenue tracking, transactions, and driver payouts.
  - `FareSurge.tsx` - Base fare configuration and dynamic surge pricing controls.
  - `SafetyCompliance.tsx` - Incident logs, KYC queue, and LTFRB status.
  - `Reports.tsx` - Analytics charts and exportable data reports.
  - `Settings.tsx` - Admin roles, notification templates, and system config.
- `/src/lib/` - Utility functions (e.g., `cn` for Tailwind class merging, `formatPHP` for currency formatting).

## AI Assistant Guidelines
When contributing to this project, please adhere to the following rules:
1. **Styling:** Always use Tailwind CSS utility classes. Do not use inline styles or create new CSS files unless absolutely necessary. Rely on the CSS variables defined in `/src/index.css`.
2. **Components:** Reuse existing UI components from `/src/components/ui/` whenever possible.
3. **Icons:** Always use `lucide-react` for icons.
4. **Context:** Maintain the Philippine context (e.g., use PHP for currency, reference local locations like Metro Manila, Makati, BGC, and local payment methods).
5. **State Management:** Use standard React hooks (`useState`, `useEffect`, `useContext`).
6. **Code Style:** Write clean, functional React components with TypeScript interfaces for props.
