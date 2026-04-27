import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Switch } from './Switch';

describe('Switch', () => {
  it('renders with role="switch" and reflects checked state', () => {
    render(<Switch checked={true} onCheckedChange={() => {}} aria-label="toggle" />);
    const sw = screen.getByRole('switch', { name: 'toggle' });
    expect(sw).toHaveAttribute('aria-checked', 'true');
  });

  it('reflects unchecked state', () => {
    render(<Switch checked={false} onCheckedChange={() => {}} aria-label="toggle" />);
    expect(screen.getByRole('switch')).toHaveAttribute('aria-checked', 'false');
  });

  it('calls onCheckedChange with the inverted value when clicked', () => {
    const handle = vi.fn();
    render(<Switch checked={false} onCheckedChange={handle} aria-label="toggle" />);
    fireEvent.click(screen.getByRole('switch'));
    expect(handle).toHaveBeenCalledWith(true);
  });

  it('does not fire when disabled', () => {
    const handle = vi.fn();
    render(
      <Switch checked={false} onCheckedChange={handle} disabled aria-label="toggle" />,
    );
    fireEvent.click(screen.getByRole('switch'));
    expect(handle).not.toHaveBeenCalled();
  });

  it('applies the on-state background when checked', () => {
    render(<Switch checked={true} onCheckedChange={() => {}} aria-label="toggle" />);
    expect(screen.getByRole('switch').className).toContain('bg-primary');
  });
});
