import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SADashboard } from '../SADashboard';

function renderWithClient(ui: React.ReactElement) {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>{ui}</QueryClientProvider>,
  );
}

// Prevent recharts from throwing in jsdom (SVG not fully supported)
vi.mock('recharts', () => {
  const Noop = ({ children }: { children?: React.ReactNode }) =>
    React.createElement(React.Fragment, null, children ?? null);
  return {
    ResponsiveContainer: Noop, LineChart: Noop, Line: Noop,
    AreaChart: Noop, Area: Noop,
    BarChart: Noop, Bar: Noop, PieChart: Noop, Pie: Noop, Cell: Noop,
    XAxis: Noop, YAxis: Noop, CartesianGrid: Noop, Tooltip: Noop, Legend: Noop,
  };
});

vi.mock('@/api/super-admin/metrics', () => ({
  metricsApi: {
    getDashboard: vi.fn().mockResolvedValue({
      total_riders: 1200, total_drivers: 340, rides_today: 88,
      revenue_today: 45000, avg_wait_minutes: 3.2, platform_uptime: 99.9,
      riders_trend: '+5%', drivers_trend: '+2%', rides_trend: '+10%',
      revenue_trend: '+8%', wait_trend: '-0.3',
    }),
    getRidesChart:          vi.fn().mockResolvedValue([{ name: 'Mon', rides: 40 }]),
    getRevenueChart:        vi.fn().mockResolvedValue([{ name: 'Mon', revenue: 5000 }]),
    getVehicleDistribution: vi.fn().mockResolvedValue([{ name: 'Car', value: 60 }]),
    getActivityFeed:        vi.fn().mockResolvedValue([]),
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
    expect(screen.getByText('Riders')).toBeTruthy();
    expect(screen.getByText('Drivers')).toBeTruthy();
    expect(screen.getByText('Rides Today')).toBeTruthy();
  });
});
