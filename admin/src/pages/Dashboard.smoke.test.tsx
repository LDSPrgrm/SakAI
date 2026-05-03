import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Dashboard } from './Dashboard';

function renderWithClient(ui: React.ReactElement) {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>{ui}</MemoryRouter>
    </QueryClientProvider>,
  );
}

vi.mock('@/hooks/usePermissions', () => ({
  usePermissions: () => ({
    can: () => true,
    role: null,
    permissions: [],
    loading: false,
    error: null,
    loadPermissions: vi.fn(),
    clear: vi.fn(),
  }),
}));

vi.mock('@/api/super-admin/metrics', () => ({
  metricsApi: {
    getDashboard: vi.fn().mockResolvedValue({
      total_riders: 1200, total_drivers: 340, rides_today: 88,
      revenue_today: 45000, avg_wait_minutes: 3.2, platform_uptime: 99.9,
      riders_trend: '+5%', drivers_trend: '+2%', rides_trend: '+10%',
      revenue_trend: '+8%', wait_trend: '-0.3',
    }),
    getDriverHeatmap: vi.fn().mockResolvedValue({
      positions: [{ id: 'd1' }, { id: 'd2' }],
      bounds: { north: 0, south: 0, east: 0, west: 0 },
      generated_at: new Date().toISOString(),
    }),
    getActivityFeed: vi.fn().mockResolvedValue([
      { id: 'a1', type: 'ride_completed', message: 'Ride completed', time: '1m', isAlert: false },
    ]),
  },
}));

vi.mock('@/api/super-admin/safety', () => ({
  safetyApi: {
    getKycQueue: vi.fn().mockResolvedValue([
      { id: 'k1', status: 'pending' },
      { id: 'k2', status: 'pending' },
    ]),
    getIncidents: vi.fn().mockResolvedValue([
      { id: 'i1', status: 'open' },
      { id: 'i2', status: 'resolved' },
    ]),
  },
}));

vi.mock('@/api/super-admin/payments', () => ({
  paymentsApi: {
    getPayouts: vi.fn().mockResolvedValue([
      { id: 'p1', status: 'pending' },
    ]),
    getGatewayConfigs: vi.fn().mockResolvedValue([
      { id: 'c1', provider: 'gcash', is_active: true, updated_at: new Date().toISOString() },
    ]),
  },
}));

vi.mock('@/api/super-admin/reports', () => ({
  reportsApi: {
    getChartData: vi.fn().mockResolvedValue([
      { label: 'GCash', value: 45 },
      { label: 'Cash', value: 30 },
    ]),
  },
}));

describe('Dashboard smoke test', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders loading state initially', () => {
    renderWithClient(<Dashboard />);
    expect(screen.getByText(/loading dashboard/i)).toBeTruthy();
  });

  it('renders KPI titles in skeleton order after data loads', async () => {
    renderWithClient(<Dashboard />);
    await waitFor(() =>
      expect(screen.getByText('Dashboard')).toBeTruthy(),
    );
    expect(screen.getByText('Revenue Today')).toBeTruthy();
    expect(screen.getByText('Rides Today')).toBeTruthy();
    expect(screen.getByText('Avg Wait')).toBeTruthy();
    expect(screen.getByText('Uptime')).toBeTruthy();
  });

  it('renders ops sections + action queue', async () => {
    renderWithClient(<Dashboard />);
    await waitFor(() =>
      expect(screen.getByText('Dashboard')).toBeTruthy(),
    );
    expect(screen.getByText('Total Riders')).toBeTruthy();
    expect(screen.getByText('Total Drivers')).toBeTruthy();
    expect(screen.getByText('Drivers Online')).toBeTruthy();
    expect(screen.getByText('KYC Pending')).toBeTruthy();
    expect(screen.getByText('Open Incidents')).toBeTruthy();
    expect(screen.getByText('Payouts Pending')).toBeTruthy();
  });

  it('renders activity feed and live hotspots', async () => {
    renderWithClient(<Dashboard />);
    await waitFor(() =>
      expect(screen.getByText('Dashboard')).toBeTruthy(),
    );
    expect(screen.getAllByText('Recent Activity').length).toBeGreaterThan(0);
    expect(screen.getByText('Live Hotspots')).toBeTruthy();
  });
});
