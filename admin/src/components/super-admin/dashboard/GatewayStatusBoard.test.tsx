import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { GatewayStatusBoard } from './GatewayStatusBoard';
import type { PaymentGatewayConfig } from '@/api/super-admin/payments';

describe('GatewayStatusBoard', () => {
  it('renders all four providers in fixed order with correct status labels', () => {
    const configs: PaymentGatewayConfig[] = [
      { id: 'c1', provider: 'gcash', is_active: true,  updated_at: new Date().toISOString() },
      { id: 'c2', provider: 'cash',  is_active: false, updated_at: new Date().toISOString() },
    ];

    render(<GatewayStatusBoard configs={configs} />);

    expect(screen.getByText('GCash')).toBeTruthy();
    expect(screen.getByText('PayMaya')).toBeTruthy();
    expect(screen.getByText('Card')).toBeTruthy();
    expect(screen.getByText('Cash')).toBeTruthy();

    expect(screen.getByText('Connected')).toBeTruthy();
    expect(screen.getAllByText('Not configured').length).toBe(2);
    expect(screen.getByText('Disabled')).toBeTruthy();
  });

  it('renders skeletons when loading', () => {
    const { container } = render(<GatewayStatusBoard configs={[]} isLoading />);
    expect(container.querySelectorAll('[data-testid="gateway-skeleton"]').length).toBe(4);
  });
});
