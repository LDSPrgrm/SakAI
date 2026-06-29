import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { PaymentSplitCard } from './PaymentSplitCard';
import type { UseQueryResult } from '@tanstack/react-query';

function makeQuery(partial: Partial<UseQueryResult<unknown[]>>): UseQueryResult<unknown[]> {
  return {
    data: undefined,
    error: null,
    isLoading: false,
    isFetching: false,
    isError: false,
    isSuccess: true,
    refetch: () => Promise.resolve(null as never),
    ...partial,
  } as unknown as UseQueryResult<unknown[]>;
}

describe('PaymentSplitCard', () => {
  it('renders header label', () => {
    render(<PaymentSplitCard query={makeQuery({ data: [] })} />);
    expect(screen.getByText(/payment split/i)).toBeTruthy();
  });

  it('renders skeleton when loading', () => {
    const { container } = render(<PaymentSplitCard query={makeQuery({ isLoading: true, isSuccess: false })} />);
    expect(container.querySelector('[data-testid="payment-split-skeleton"]')).toBeTruthy();
  });

  it('renders empty state when no data', () => {
    render(<PaymentSplitCard query={makeQuery({ data: [] })} />);
    expect(screen.getByText(/no payment data/i)).toBeTruthy();
  });

  it('does not render empty state when data present', () => {
    const data = [
      { label: 'GCash', value: 50 },
      { label: 'Cash',  value: 30 },
    ];
    render(<PaymentSplitCard query={makeQuery({ data })} />);
    expect(screen.queryByText(/no payment data/i)).toBeNull();
  });
});
