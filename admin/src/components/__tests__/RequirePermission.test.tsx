import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { RequirePermission } from '../RequirePermission';

vi.mock('@/contexts/AuthContext', () => ({
  useAuth: vi.fn(),
}));

vi.mock('@/hooks/usePermissions', () => ({
  usePermissions: vi.fn(),
}));

import { useAuth } from '@/contexts/AuthContext';
import { usePermissions } from '@/hooks/usePermissions';

const mockUseAuth = vi.mocked(useAuth);
const mockUsePermissions = vi.mocked(usePermissions);

type AuthReturn = ReturnType<typeof useAuth>;
type PermsReturn = ReturnType<typeof usePermissions>;

function setAuth(partial: Partial<AuthReturn>) {
  mockUseAuth.mockReturnValue({
    user: null,
    isAuthenticated: false,
    isLoading: false,
    login: vi.fn(),
    logout: vi.fn(),
    ...partial,
  } as AuthReturn);
}

function setPerms(partial: Partial<PermsReturn>) {
  mockUsePermissions.mockReturnValue({
    can: () => false,
    role: null,
    permissions: [],
    loading: false,
    error: null,
    loadPermissions: vi.fn(),
    clear: vi.fn(),
    ...partial,
  } as PermsReturn);
}

function renderAt(initialPath: string) {
  return render(
    <MemoryRouter initialEntries={[initialPath]}>
      <Routes>
        <Route
          path="/admin/payments"
          element={
            <RequirePermission permission="payments">
              <div>payments page</div>
            </RequirePermission>
          }
        />
        <Route path="/admin/dashboard" element={<div>admin dashboard</div>} />
        <Route path="/super-admin/dashboard" element={<div>super dashboard</div>} />
        <Route path="/login" element={<div>login page</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

beforeEach(() => {
  vi.clearAllMocks();
});

describe('<RequirePermission />', () => {
  it('shows loader while auth is loading', () => {
    setAuth({ isLoading: true });
    setPerms({});
    const { container } = renderAt('/admin/payments');
    expect(container.querySelector('.animate-spin')).not.toBeNull();
  });

  it('shows loader while permissions are loading', () => {
    setAuth({ isAuthenticated: true, user: { role: 'admin' } as AuthReturn['user'] });
    setPerms({ loading: true });
    const { container } = renderAt('/admin/payments');
    expect(container.querySelector('.animate-spin')).not.toBeNull();
  });

  it('redirects unauthenticated users to /login', () => {
    setAuth({ isAuthenticated: false });
    setPerms({});
    renderAt('/admin/payments');
    expect(screen.getByText('login page')).toBeInTheDocument();
  });

  it('renders children when user has the permission', () => {
    setAuth({ isAuthenticated: true, user: { role: 'finance' } as AuthReturn['user'] });
    setPerms({ can: (key, scope) => key === 'payments' && scope === 'read' });
    renderAt('/admin/payments');
    expect(screen.getByText('payments page')).toBeInTheDocument();
  });

  it('redirects admin users without permission to /admin/dashboard', () => {
    setAuth({ isAuthenticated: true, user: { role: 'support' } as AuthReturn['user'] });
    setPerms({ can: () => false });
    renderAt('/admin/payments');
    expect(screen.getByText('admin dashboard')).toBeInTheDocument();
  });

  it('redirects superadmin users without permission to /super-admin/dashboard', () => {
    setAuth({ isAuthenticated: true, user: { role: 'superadmin' } as AuthReturn['user'] });
    // In practice can() short-circuits true for superadmin; this test isolates redirect
    // behaviour by forcing can() to return false.
    setPerms({ can: () => false });
    renderAt('/admin/payments');
    expect(screen.getByText('super dashboard')).toBeInTheDocument();
  });
});
