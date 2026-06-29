import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { EntityId } from './EntityId';

describe('<EntityId />', () => {
  beforeEach(() => {
    Object.defineProperty(window.navigator, 'clipboard', {
      value: { writeText: vi.fn().mockResolvedValue(undefined) },
      configurable: true,
    });
  });

  it('renders displayId when provided', () => {
    render(<EntityId displayId="INC-0042" uuid="20000007-0000-0000-0000-000000000005" />);
    expect(screen.getByTestId('entity-id')).toHaveTextContent('INC-0042');
  });

  it('falls back to prefix + uuid slice when displayId missing', () => {
    render(<EntityId uuid="abcdef12-0000-0000-0000-000000000000" fallbackPrefix="INC" />);
    expect(screen.getByTestId('entity-id')).toHaveTextContent('INC-ABCD');
  });

  it('uses default REF prefix when fallbackPrefix not provided', () => {
    render(<EntityId uuid="12345678-aaaa-bbbb-cccc-dddddddddddd" />);
    expect(screen.getByTestId('entity-id')).toHaveTextContent('REF-1234');
  });

  it('exposes full UUID via title attribute for hover tooltip', () => {
    const uuid = '20000007-0000-0000-0000-000000000005';
    render(<EntityId displayId="INC-0042" uuid={uuid} />);
    expect(screen.getByTestId('entity-id')).toHaveAttribute('title', uuid);
  });

  it('copies UUID to clipboard on click and flashes "Copied!"', async () => {
    vi.useFakeTimers();
    const uuid = '20000007-0000-0000-0000-000000000005';
    render(<EntityId displayId="INC-0042" uuid={uuid} />);

    await act(async () => {
      fireEvent.click(screen.getByTestId('entity-id'));
    });

    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(uuid);
    expect(screen.getByTestId('entity-id')).toHaveTextContent('Copied!');

    act(() => {
      vi.advanceTimersByTime(1500);
    });
    expect(screen.getByTestId('entity-id')).toHaveTextContent('INC-0042');
    vi.useRealTimers();
  });

  it('renders em-dash placeholder when both uuid and displayId absent', () => {
    render(<EntityId />);
    expect(screen.getByTestId('entity-id')).toHaveTextContent('—');
  });
});
