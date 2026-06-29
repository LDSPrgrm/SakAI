import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SafetyCompliance } from './SafetyCompliance';

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

vi.mock('@/api/super-admin/safety', () => ({
  safetyApi: {
    getIncidents: vi.fn().mockResolvedValue([
      { id: 'i1', status: 'open', type: 'reported_incident' },
      { id: 'i2', status: 'investigating', type: 'sos_triggered' },
      { id: 'i3', status: 'resolved', type: 'sos_triggered' },
    ]),
    getKycQueue: vi.fn().mockResolvedValue([
      { id: 'k1', status: 'pending', driver_id: 'd1', driver_name: 'A', docs: [] },
      { id: 'k2', status: 'approved', driver_id: 'd2', driver_name: 'B', docs: [] },
    ]),
    resolveIncident: vi.fn(),
    updateKyc: vi.fn(),
    getLtfrbCompliance: vi.fn().mockResolvedValue({
      accreditation_status: 'active',
      driver_compliance_rate: 92.5,
      violation_count: 1,
    }),
  },
}));

vi.mock('@/api/super-admin/reports', () => ({
  reportsApi: {
    exportCsv: vi.fn().mockResolvedValue({ url: 'https://example.test/r.csv', data: '' }),
  },
}));

describe('SafetyCompliance smoke test', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders 4-tile KPI row matching SA parity', async () => {
    renderWithClient(<SafetyCompliance />);
    await waitFor(() =>
      expect(screen.getByText('Safety & Compliance')).toBeTruthy(),
    );
    expect(screen.getByText('Open Incidents')).toBeTruthy();
    expect(screen.getByText('SOS Active')).toBeTruthy();
    expect(screen.getByText('Pending KYC')).toBeTruthy();
    expect(screen.getByText('Driver Compliance')).toBeTruthy();
  });

  it('renders main grid sections', async () => {
    renderWithClient(<SafetyCompliance />);
    await waitFor(() =>
      expect(screen.getByText('Safety & Compliance')).toBeTruthy(),
    );
    expect(screen.getByText('Emergency & Incident Log')).toBeTruthy();
    expect(screen.getByText('Driver KYC Queue')).toBeTruthy();
    expect(screen.getByText('LTFRB Compliance Status')).toBeTruthy();
  });
});
