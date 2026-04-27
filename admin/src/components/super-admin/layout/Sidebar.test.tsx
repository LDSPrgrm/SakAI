import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Sidebar } from './Sidebar';

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

function setPerms(canFn: PermsReturn['can']) {
  mockUsePermissions.mockReturnValue({
    can: canFn,
    role: null,
    permissions: [],
    loading: false,
    error: null,
    loadPermissions: vi.fn(),
    clear: vi.fn(),
  } as PermsReturn);
}

beforeEach(() => {
  vi.clearAllMocks();
  mockUseAuth.mockReturnValue({
    user: { role: 'superadmin', name: 'Super' },
    isAuthenticated: true,
    isLoading: false,
    login: vi.fn(),
    logout: vi.fn(),
  } as unknown as AuthReturn);
});

function renderSidebar() {
  return render(
    <MemoryRouter initialEntries={['/super-admin/dashboard']}>
      <Sidebar isOpen={true} onClose={vi.fn()} />
    </MemoryRouter>,
  );
}

describe('<Super-Admin Sidebar /> grouping', () => {
  it('renders all five section labels for a superadmin', () => {
    setPerms(() => true);
    renderSidebar();
    for (const label of ['Overview', 'Access', 'Operations', 'Insights', 'System']) {
      expect(screen.getByText(label)).toBeInTheDocument();
    }
    expect(screen.getByText('SA Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Audit Log')).toBeInTheDocument();
  });

  it('drops the Access section when admin_management + role_management are denied', () => {
    setPerms((key) => key !== 'admin_management' && key !== 'role_management');
    renderSidebar();
    expect(screen.queryByText('Access')).not.toBeInTheDocument();
    expect(screen.queryByText('Admin Management')).not.toBeInTheDocument();
    // Other sections still render.
    expect(screen.getByText('Insights')).toBeInTheDocument();
  });
});
