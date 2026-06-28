import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AppSidebar } from './AppSidebar';
import { RoleAccentProvider } from '@/contexts/RoleAccentContext';
import { adminNavSections } from '@/nav/admin';
import { superAdminNavSections } from '@/nav/super-admin';

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

function setPerms(canFn: PermsReturn['can'], error: PermsReturn['error'] = null) {
  mockUsePermissions.mockReturnValue({
    can: canFn,
    role: null,
    permissions: [],
    loading: false,
    error,
    loadPermissions: vi.fn(),
    clear: vi.fn(),
  } as PermsReturn);
}

beforeEach(() => {
  vi.clearAllMocks();
});

function renderAdmin(initialPath = '/admin/dashboard') {
  mockUseAuth.mockReturnValue({
    user: { role: 'admin', name: 'Test' },
    isAuthenticated: true,
    isLoading: false,
    login: vi.fn(),
    logout: vi.fn(),
  } as unknown as AuthReturn);
  return render(
    <MemoryRouter initialEntries={[initialPath]}>
      <RoleAccentProvider role="admin">
        <AppSidebar
          isOpen
          onClose={vi.fn()}
          sections={adminNavSections}
          brandLabel="SakAI"
          fallbackOnPermsError
        />
      </RoleAccentProvider>
    </MemoryRouter>,
  );
}

function renderSuperAdmin(initialPath = '/super-admin/dashboard') {
  mockUseAuth.mockReturnValue({
    user: { role: 'superadmin', name: 'Super' },
    isAuthenticated: true,
    isLoading: false,
    login: vi.fn(),
    logout: vi.fn(),
  } as unknown as AuthReturn);
  return render(
    <MemoryRouter initialEntries={[initialPath]}>
      <RoleAccentProvider role="super-admin">
        <AppSidebar
          isOpen
          onClose={vi.fn()}
          sections={superAdminNavSections}
          brandLabel="SakAI Super"
        />
      </RoleAccentProvider>
    </MemoryRouter>,
  );
}

describe('<AppSidebar /> admin nav config', () => {
  it('renders every section label when all permissions granted', () => {
    setPerms(() => true);
    renderAdmin();
    for (const label of ['Overview', 'Operations', 'Finance', 'Safety']) {
      expect(screen.getByText(label)).toBeInTheDocument();
    }
  });

  it('hides a section entirely when none of its items are permitted', () => {
    setPerms((key) => key === 'dashboard');
    renderAdmin();
    expect(screen.getByText('Overview')).toBeInTheDocument();
    expect(screen.queryByText('Finance')).not.toBeInTheDocument();
    expect(screen.queryByText('Safety')).not.toBeInTheDocument();
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.queryByText('Payments & Earnings')).not.toBeInTheDocument();
  });

  it('falls back to Dashboard when permission fetch fails for a non-superadmin', () => {
    setPerms(() => false, 'fetch failed');
    renderAdmin();
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByRole('alert')).toHaveTextContent(/permissions/i);
  });
});

describe('<AppSidebar /> super-admin nav config', () => {
  it('renders all five section labels for a superadmin', () => {
    setPerms(() => true);
    renderSuperAdmin();
    for (const label of ['Overview', 'Access', 'Operations', 'Insights', 'System']) {
      expect(screen.getByText(label)).toBeInTheDocument();
    }
    expect(screen.getByText('SA Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Audit Log')).toBeInTheDocument();
  });

  it('drops the Access section when admin_management + role_management are denied', () => {
    setPerms((key) => key !== 'admin_management' && key !== 'role_management');
    renderSuperAdmin();
    expect(screen.queryByText('Access')).not.toBeInTheDocument();
    expect(screen.queryByText('Admin Management')).not.toBeInTheDocument();
    expect(screen.getByText('Insights')).toBeInTheDocument();
  });
});
