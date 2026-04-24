import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SADashboard } from '../SADashboard';

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
  },
}));

vi.mock('@/api/super-admin/system', () => ({
  systemApi: {
    getSystemServices: vi.fn().mockResolvedValue([
      { name: 'api', status: 'ok' },
      { name: 'websocket', status: 'ok' },
    ]),
    getInfraMetrics: vi.fn().mockResolvedValue({ api_p95_ms: 180 }),
  },
}));

vi.mock('@/api/super-admin/safety', () => ({
  safetyApi: {
    getKycQueue: vi.fn().mockResolvedValue([
      { id: 'k1', status: 'pending' },
      { id: 'k2', status: 'pending' },
      { id: 'k3', status: 'approved' },
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
      { id: 'p2', status: 'done' },
    ]),
  },
}));

describe('SADashboard smoke test', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders loading state initially', () => {
    renderWithClient(<SADashboard />);
    expect(screen.getByText(/loading dispatch console/i)).toBeTruthy();
  });

  it('renders KPI cards after data loads', async () => {
    renderWithClient(<SADashboard />);
    await waitFor(() =>
      expect(screen.getByText('Dispatch Console')).toBeTruthy(),
    );
    expect(screen.getByText('Revenue Today')).toBeTruthy();
    expect(screen.getByText('Rides Today')).toBeTruthy();
    expect(screen.getByText('Avg Wait')).toBeTruthy();
    expect(screen.getByText('Uptime')).toBeTruthy();
  });

  it('renders live ops + action queue', async () => {
    renderWithClient(<SADashboard />);
    await waitFor(() =>
      expect(screen.getByText('Dispatch Console')).toBeTruthy(),
    );
    expect(screen.getByText('Drivers Online')).toBeTruthy();
    expect(screen.getByText('API P95 Latency')).toBeTruthy();
    expect(screen.getByText('KYC Pending')).toBeTruthy();
    expect(screen.getByText('Open Incidents')).toBeTruthy();
    expect(screen.getByText('Payouts Pending')).toBeTruthy();
  });

  it('does not render removed dashboard widgets', async () => {
    renderWithClient(<SADashboard />);
    await waitFor(() =>
      expect(screen.getByText('Dispatch Console')).toBeTruthy(),
    );
    expect(screen.queryByText('Super Admin · Operations')).toBeNull();
    expect(screen.queryByText('Riders')).toBeNull();
    expect(screen.queryByText('Drivers')).toBeNull();
    expect(screen.queryByText(/recent activity/i)).toBeNull();
  });
});
