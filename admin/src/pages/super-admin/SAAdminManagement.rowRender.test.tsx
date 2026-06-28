import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MemoryRouter } from 'react-router-dom';

vi.mock('@/hooks/useAuth', () => ({
  useAuth: () => ({ user: { id: 'current-user' } }),
}));

// Fixtures mirror backend quirk: POST /admin/users with a custom role sends role_id,
// but the returned `role` enum is the lossy `roleNameToEnum()` result — unknown
// role names default to "admin". Only role_id is reliable for display.
const adminsData = [
  {
    id: 'u-custom',
    name: 'Maria Santos',
    email: 'maria@sakai.ph',
    role: 'admin',            // backend lossy default for user-created custom admin
    role_id: 'r-operations',  // truth: points at "operations" role
    status: 'active',
    created_at: '2026-04-01T00:00:00Z',
    last_login_at: null,
  },
  {
    id: 'u-marketing',
    name: 'Liza Reyes',
    email: 'liza@sakai.ph',
    role: 'admin',          // backend lossy default
    role_id: 'r-marketing',  // custom (non-system) role
    status: 'active',
    created_at: '2026-04-01T00:00:00Z',
    last_login_at: null,
  },
  {
    id: 'u-super',
    name: 'Ana Reyes',
    email: 'ana@sakai.ph',
    role: 'superadmin',
    role_id: 'r-super',
    status: 'active',
    created_at: '2026-04-01T00:00:00Z',
    last_login_at: null,
  },
];

const roleDefs = [
  { id: 'r-admin',      name: 'admin',      description: '', permissions: [] },
  { id: 'r-super',      name: 'superadmin', description: '', permissions: [] },
  { id: 'r-operations', name: 'operations', description: '', permissions: [] },
  { id: 'r-finance',    name: 'finance',    description: '', permissions: [] },
  { id: 'r-marketing',  name: 'marketing',  description: '', permissions: [] },
];

vi.mock('@/hooks/useAdmins', () => ({
  useAdmins: () => ({ data: adminsData, isPending: false }),
}));

vi.mock('@/hooks/useRoles', () => ({
  useRoles: () => ({ data: roleDefs, isPending: false }),
}));

// Import after mocks so the component picks them up.
import { SAAdminManagement } from './SAAdminManagement';

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <SAAdminManagement />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe('SAAdminManagement role column', () => {
  it('renders the correct role label for a user-created admin whose backend `role` is the lossy default', () => {
    renderPage();
    // Proves the bug is fixed: displayRole resolves role_id -> "operations".
    expect(screen.getByText('Operations')).toBeTruthy();
  });

  it('renders a custom (non-system) role name via role_id lookup', () => {
    renderPage();
    // roleLabel() titlecases unknown names: "marketing" -> "Marketing".
    expect(screen.getByText('Marketing')).toBeTruthy();
  });

  it('renders "Super Admin" for a superadmin row', () => {
    renderPage();
    expect(screen.getByText('Super Admin')).toBeTruthy();
  });
});
