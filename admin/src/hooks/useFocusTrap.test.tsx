import React, { useRef } from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, fireEvent, act } from '@testing-library/react';
import { useFocusTrap } from './useFocusTrap';

function Trapped({ open }: { open: boolean }) {
  const ref = useRef<HTMLDivElement>(null);
  useFocusTrap(ref, open);
  return (
    <div ref={ref} data-testid="trap" tabIndex={-1}>
      <button data-testid="first">first</button>
      <button data-testid="middle">middle</button>
      <button data-testid="last">last</button>
    </div>
  );
}

describe('useFocusTrap', () => {
  it('cycles Tab from last focusable to first', () => {
    const { getByTestId } = render(<Trapped open />);
    const first = getByTestId('first');
    const last = getByTestId('last');
    act(() => last.focus());
    expect(document.activeElement).toBe(last);
    fireEvent.keyDown(getByTestId('trap'), { key: 'Tab' });
    expect(document.activeElement).toBe(first);
  });

  it('cycles Shift+Tab from first focusable to last', () => {
    const { getByTestId } = render(<Trapped open />);
    const first = getByTestId('first');
    const last = getByTestId('last');
    act(() => first.focus());
    fireEvent.keyDown(getByTestId('trap'), { key: 'Tab', shiftKey: true });
    expect(document.activeElement).toBe(last);
  });

  it('does not intercept Tab when open is false', () => {
    const { getByTestId } = render(<Trapped open={false} />);
    const last = getByTestId('last');
    act(() => last.focus());
    // Capture preventDefault — the hook calls it on cycling Tabs, so its
    // absence proves the listener didn't run.
    const event = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true, cancelable: true });
    const preventSpy = vi.spyOn(event, 'preventDefault');
    getByTestId('trap').dispatchEvent(event);
    expect(preventSpy).not.toHaveBeenCalled();
  });

  it('ignores non-Tab keys', () => {
    const { getByTestId } = render(<Trapped open />);
    const middle = getByTestId('middle');
    act(() => middle.focus());
    fireEvent.keyDown(getByTestId('trap'), { key: 'Enter' });
    expect(document.activeElement).toBe(middle);
  });
});
