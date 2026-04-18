import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { StatusBadge } from './StatusBadge';

describe('StatusBadge', () => {
  it('renders the status as capitalised text', () => {
    render(<StatusBadge status="active" />);
    expect(screen.getByText('active')).toBeInTheDocument();
  });

  it('replaces underscores with spaces in the label', () => {
    render(<StatusBadge status="investigating" />);
    expect(screen.getByText('investigating')).toBeInTheDocument();
  });

  it('uses a custom label when provided', () => {
    render(<StatusBadge status="active" label="Online" />);
    expect(screen.getByText('Online')).toBeInTheDocument();
    expect(screen.queryByText('active')).toBeNull();
  });

  it('applies success variant classes for "active"', () => {
    const { container } = render(<StatusBadge status="active" />);
    const badge = container.firstChild as HTMLElement;
    expect(badge.className).toContain('text-success');
  });

  it('applies danger variant classes for "suspended"', () => {
    const { container } = render(<StatusBadge status="suspended" />);
    const badge = container.firstChild as HTMLElement;
    expect(badge.className).toContain('text-danger');
  });

  it('applies warning variant classes for "pending"', () => {
    const { container } = render(<StatusBadge status="pending" />);
    const badge = container.firstChild as HTMLElement;
    expect(badge.className).toContain('text-warning');
  });

  it('applies default classes for an unknown status', () => {
    const { container } = render(<StatusBadge status="unknown_status" />);
    const badge = container.firstChild as HTMLElement;
    expect(badge.className).toContain('text-text-muted');
  });
});
