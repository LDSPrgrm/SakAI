import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('@tanstack/react-query', () => ({
  useQuery: vi.fn(),
  useMutation: vi.fn(),
  useQueryClient: vi.fn(),
}));

import { useQuery } from '@tanstack/react-query';
import { useIsCashlessEnabled, compressCashlessFlags } from './useSystem';

const mockUseQuery = vi.mocked(useQuery);

function mockFlags(data: unknown) {
  mockUseQuery.mockReturnValue({ data } as ReturnType<typeof useQuery>);
}

beforeEach(() => {
  vi.clearAllMocks();
});

describe('useIsCashlessEnabled', () => {
  it('defaults to true when flags have not loaded', () => {
    mockFlags(undefined);
    expect(useIsCashlessEnabled()).toBe(true);
  });

  it('defaults to true when cashless_payments flag is absent from the list', () => {
    mockFlags([{ key: 'surge_pricing', enabled: false }]);
    expect(useIsCashlessEnabled()).toBe(true);
  });

  it('returns true when the flag is explicitly enabled', () => {
    mockFlags([{ key: 'cashless_payments', label: 'Cashless Payments', enabled: true }]);
    expect(useIsCashlessEnabled()).toBe(true);
  });

  it('returns false when the flag is explicitly disabled', () => {
    mockFlags([{ key: 'cashless_payments', label: 'Cashless Payments', enabled: false }]);
    expect(useIsCashlessEnabled()).toBe(false);
  });
});

describe('compressCashlessFlags', () => {
  it('collapses payment_gcash/paymaya/card rows into a single synthetic row', () => {
    const out = compressCashlessFlags([
      { key: 'surge_pricing',   label: 'Surge', enabled: true },
      { key: 'payment_gcash',   label: 'GCash', enabled: true },
      { key: 'payment_paymaya', label: 'PayMaya', enabled: true },
      { key: 'payment_card',    label: 'Card', enabled: true },
    ]);
    expect(out.map((f) => f.key)).toEqual(['surge_pricing', 'cashless_payments']);
    expect(out.find((f) => f.key === 'cashless_payments')?.enabled).toBe(true);
  });

  it('marks synthetic cashless flag disabled when any underlying method is disabled', () => {
    const out = compressCashlessFlags([
      { key: 'payment_gcash',   label: 'GCash', enabled: true },
      { key: 'payment_paymaya', label: 'PayMaya', enabled: false },
      { key: 'payment_card',    label: 'Card', enabled: true },
    ]);
    expect(out.find((f) => f.key === 'cashless_payments')?.enabled).toBe(false);
  });

  it('omits synthetic row entirely if backend seeds no cashless methods', () => {
    const out = compressCashlessFlags([
      { key: 'surge_pricing', label: 'Surge', enabled: true },
    ]);
    expect(out.map((f) => f.key)).toEqual(['surge_pricing']);
  });
});
