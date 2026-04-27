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
  mockUseAuth.mockReturnValue({
    user: { role: 'admin', name: 'Test' },
    isAuthenticated: true,
    isLoading: false,
    login: vi.fn(),
    logout: vi.fn(),
  } as unknown as AuthReturn);
});

function renderSidebar() {
  return render(
    <MemoryRouter initialEntries={['/admin/dashboard']}>
      <Sidebar isOpen={true} onClose={vi.fn()} />
    </MemoryRouter>,
  );
}

describe('<Sidebar /> grouping', () => {
  it('renders every section label when all permissions granted', () => {
    setPerms(() => true);
    renderSidebar();
    for (const label of ['Overview', 'Operations', 'Finance', 'Safety']) {
      expect(screen.getByText(label)).toBeInTheDocument();
    }
  });

  it('hides a section entirely when none of its items are permitted', () => {
    // Only Dashboard readable → Overview section alone should render.
    setPerms((key) => key === 'dashboard');
    renderSidebar();
    expect(screen.getByText('Overview')).toBeInTheDocument();
    expect(screen.queryByText('Finance')).not.toBeInTheDocument();
    expect(screen.queryByText('Safety')).not.toBeInTheDocument();
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.queryByText('Payments & Earnings')).not.toBeInTheDocument();
  });

  it('falls back to Dashboard when permission fetch fails for a non-superadmin', () => {
    setPerms(() => false, 'fetch failed');
    renderSidebar();
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByRole('alert')).toHaveTextContent(/permissions/i);
  });
});
