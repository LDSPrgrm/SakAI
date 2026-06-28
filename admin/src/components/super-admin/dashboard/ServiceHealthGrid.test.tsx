import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { ServiceHealthGrid } from './ServiceHealthGrid';
import type { SystemService } from '@/api/super-admin/system';

const services: SystemService[] = [
  { name: 'api',       status: 'ok',       latency_ms: 120, uptime_pct: 99.98 },
  { name: 'websocket', status: 'degraded', latency_ms: 640, uptime_pct: 97.40 },
  { name: 'payments',  status: 'down',     latency_ms: 0,   uptime_pct: 80.00 },
];

describe('ServiceHealthGrid', () => {
  it('renders each service name', () => {
    render(<ServiceHealthGrid services={services} />);
    expect(screen.getByText('api')).toBeTruthy();
    expect(screen.getByText('websocket')).toBeTruthy();
    expect(screen.getByText('payments')).toBeTruthy();
  });

  it('shows status labels for each service', () => {
    render(<ServiceHealthGrid services={services} />);
    expect(screen.getByText('Operational')).toBeTruthy();
    expect(screen.getByText('Degraded')).toBeTruthy();
    expect(screen.getByText('Down')).toBeTruthy();
  });

  it('renders skeleton tiles when loading', () => {
    const { container } = render(<ServiceHealthGrid services={[]} isLoading />);
    expect(container.querySelectorAll('[data-testid="service-skeleton"]').length).toBeGreaterThan(3);
  });

  it('renders empty state when services array is empty', () => {
    render(<ServiceHealthGrid services={[]} />);
    expect(screen.getByText(/no services reporting/i)).toBeTruthy();
  });
});
