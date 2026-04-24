import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import { GatewayProvidersSection } from './GatewayProvidersSection';
import type { PaymentGatewayConfig } from '@/api/super-admin/payments';

vi.mock('@/hooks/useSystem', () => ({
  useIsCashlessEnabled: vi.fn(),
}));

import { useIsCashlessEnabled } from '@/hooks/useSystem';

const mockCashless = vi.mocked(useIsCashlessEnabled);

const configs: PaymentGatewayConfig[] = [
  { provider: 'gcash',   is_active: true,  config_fields: {} },
  { provider: 'paymaya', is_active: true,  config_fields: {} },
  { provider: 'card',    is_active: false, config_fields: {} },
  { provider: 'cash',    is_active: true,  config_fields: {} },
];

beforeEach(() => {
  vi.clearAllMocks();
});

describe('<GatewayProvidersSection /> cashless gating', () => {
  it('renders each provider as interactive when cashless is enabled', () => {
    mockCashless.mockReturnValue(true);
    render(<GatewayProvidersSection configs={configs} onSave={vi.fn()} />);
    expect(screen.queryByText(/Cashless payments are disabled/i)).not.toBeInTheDocument();
    // No card has aria-disabled.
    expect(document.querySelector('[aria-disabled="true"]')).toBeNull();
  });

  it('locks gcash / paymaya / card cards and leaves cash interactive when disabled', () => {
    mockCashless.mockReturnValue(false);
    render(<GatewayProvidersSection configs={configs} onSave={vi.fn()} />);

    expect(screen.getByText(/Cashless payments are disabled/i)).toBeInTheDocument();

    const locked = Array.from(document.querySelectorAll('[aria-disabled="true"]'));
    expect(locked).toHaveLength(3);

    // Each locked card shows a "Locked" badge and a disabled checkbox.
    for (const card of locked) {
      expect(within(card as HTMLElement).getByText('Locked')).toBeInTheDocument();
      const checkbox = within(card as HTMLElement).getByRole('checkbox');
      expect(checkbox).toBeDisabled();
    }

    // Cash card has no aria-disabled and its checkbox is still enabled.
    const cashHeading = screen.getByText('Cash');
    const cashCard = cashHeading.closest('[class*="bg-surface-hover"]') as HTMLElement | null;
    expect(cashCard).not.toBeNull();
    expect(cashCard?.getAttribute('aria-disabled')).not.toBe('true');
    const cashCheckbox = within(cashCard as HTMLElement).getByRole('checkbox');
    expect(cashCheckbox).not.toBeDisabled();
  });
});
