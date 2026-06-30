import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Checkbox } from './Checkbox';

describe('Checkbox', () => {
  it('renders as a checkbox input and reflects checked state', () => {
    render(<Checkbox checked={true} onCheckedChange={() => {}} aria-label="select" />);
    const cb = screen.getByRole('checkbox', { name: 'select' }) as HTMLInputElement;
    expect(cb.checked).toBe(true);
  });

  it('reflects unchecked state', () => {
    render(<Checkbox checked={false} onCheckedChange={() => {}} aria-label="select" />);
    const cb = screen.getByRole('checkbox') as HTMLInputElement;
    expect(cb.checked).toBe(false);
  });

  it('calls onCheckedChange with the new value on toggle', () => {
    const handle = vi.fn();
    render(<Checkbox checked={false} onCheckedChange={handle} aria-label="select" />);
    fireEvent.click(screen.getByRole('checkbox'));
    expect(handle).toHaveBeenCalledWith(true);
  });

  it('forwards the disabled attribute (browsers suppress the click natively)', () => {
    const handle = vi.fn();
    render(<Checkbox checked={false} onCheckedChange={handle} disabled aria-label="select" />);
    expect(screen.getByRole('checkbox')).toBeDisabled();
  });

  it('exposes indeterminate state on the underlying input', () => {
    render(<Checkbox checked={false} indeterminate onCheckedChange={() => {}} aria-label="select" />);
    const cb = screen.getByRole('checkbox') as HTMLInputElement;
    expect(cb.indeterminate).toBe(true);
  });

  it('clears indeterminate when the prop becomes false', () => {
    const { rerender } = render(
      <Checkbox checked={false} indeterminate onCheckedChange={() => {}} aria-label="select" />,
    );
    rerender(
      <Checkbox checked={false} indeterminate={false} onCheckedChange={() => {}} aria-label="select" />,
    );
    const cb = screen.getByRole('checkbox') as HTMLInputElement;
    expect(cb.indeterminate).toBe(false);
  });

  it('forwards id and aria-labelledby', () => {
    render(
      <Checkbox
        id="cb-1"
        aria-labelledby="lbl"
        checked={false}
        onCheckedChange={() => {}}
      />,
    );
    const cb = screen.getByRole('checkbox') as HTMLInputElement;
    expect(cb.id).toBe('cb-1');
    expect(cb.getAttribute('aria-labelledby')).toBe('lbl');
  });
});
