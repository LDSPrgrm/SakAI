import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
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

// Provider key → exact tab-trigger button text. Used for unambiguous
// `getByRole('button', { name })` lookups; substring regex like /cash/i
// would match both "GCash" and "Cash".
const TAB_LABEL: Record<string, string> = {
  gcash: 'GCash',
  paymaya: 'PayMaya',
  card: 'Card (Stripe)',
  cash: 'Cash',
};

beforeEach(() => {
  vi.clearAllMocks();
});

describe('<GatewayProvidersSection /> cashless gating', () => {
  it('renders each provider as interactive when cashless is enabled', async () => {
    const user = userEvent.setup();
    mockCashless.mockReturnValue(true);
    render(<GatewayProvidersSection configs={configs} onSave={vi.fn()} />);
    expect(screen.queryByText(/Cashless payments are disabled/i)).not.toBeInTheDocument();

    // Walk every provider tab; nothing should be aria-disabled.
    for (const provider of ['gcash', 'paymaya', 'card', 'cash']) {
      await user.click(screen.getByRole('button', { name: TAB_LABEL[provider] }));
      expect(document.querySelector('[aria-disabled="true"]')).toBeNull();
    }
  });

  it('locks gcash / paymaya / card cards and leaves cash interactive when disabled', async () => {
    const user = userEvent.setup();
    mockCashless.mockReturnValue(false);
    render(<GatewayProvidersSection configs={configs} onSave={vi.fn()} />);

    expect(screen.getByText(/Cashless payments are disabled/i)).toBeInTheDocument();

    // Each cashless provider tab shows a locked editor: aria-disabled, "Locked" badge, disabled checkbox.
    for (const provider of ['gcash', 'paymaya', 'card']) {
      await user.click(screen.getByRole('button', { name: TAB_LABEL[provider] }));
      const lockedEditor = document.querySelector('[aria-disabled="true"]') as HTMLElement | null;
      expect(lockedEditor).not.toBeNull();
      expect(within(lockedEditor as HTMLElement).getByText('Locked')).toBeInTheDocument();
      expect(within(lockedEditor as HTMLElement).getByRole('checkbox')).toBeDisabled();
    }

    // Cash tab — no aria-disabled, checkbox not disabled.
    await user.click(screen.getByRole('button', { name: TAB_LABEL.cash }));
    expect(document.querySelector('[aria-disabled="true"]')).toBeNull();
    const cashCheckbox = screen.getByRole('checkbox', { name: 'Cash enabled' });
    expect(cashCheckbox).not.toBeDisabled();
  });
});

describe('<GatewayProvidersSection /> per-provider footer', () => {
  it('renders an UpdatedByFooter with the Save button in its actions slot per provider', async () => {
    const user = userEvent.setup();
    mockCashless.mockReturnValue(true);
    render(<GatewayProvidersSection configs={configs} onSave={vi.fn()} />);

    // Tabs render only the active panel — walk every provider tab and confirm
    // each one shows exactly one "Never updated" footer + one Save button.
    for (const provider of ['gcash', 'paymaya', 'card', 'cash']) {
      await user.click(screen.getByRole('button', { name: TAB_LABEL[provider] }));
      expect(screen.getAllByText('Never updated')).toHaveLength(1);
      expect(screen.getAllByRole('button', { name: 'Save' })).toHaveLength(1);
    }
  });

  it('shows the named author when updated_by is a non-UUID value', () => {
    mockCashless.mockReturnValue(true);
    const named: PaymentGatewayConfig[] = [
      { provider: 'gcash', is_active: true, config_fields: {}, updated_by: 'Maria Reyes' },
    ];
    render(<GatewayProvidersSection configs={named} onSave={vi.fn()} />);
    expect(screen.getByText('Maria Reyes')).toBeInTheDocument();
  });
});
