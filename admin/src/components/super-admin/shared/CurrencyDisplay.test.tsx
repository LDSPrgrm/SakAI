import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { CurrencyDisplay } from './CurrencyDisplay';

describe('CurrencyDisplay', () => {
  it('renders a formatted PHP amount', () => {
    render(<CurrencyDisplay amount={1234.56} />);
    expect(screen.getByText('₱1,234.56')).toBeInTheDocument();
  });

  it('renders zero correctly', () => {
    render(<CurrencyDisplay amount={0} />);
    expect(screen.getByText('₱0.00')).toBeInTheDocument();
  });

  it('prepends + sign for positive amounts when showSign=true', () => {
    render(<CurrencyDisplay amount={500} showSign />);
    expect(screen.getByText('+₱500.00')).toBeInTheDocument();
  });

  it('prepends - sign for negative amounts', () => {
    render(<CurrencyDisplay amount={-250} showSign />);
    expect(screen.getByText('-₱250.00')).toBeInTheDocument();
  });

  it('applies danger class for negative amount with showSign', () => {
    const { container } = render(<CurrencyDisplay amount={-100} showSign />);
    expect(container.firstChild).toHaveClass('text-danger');
  });

  it('applies success class for positive amount with showSign', () => {
    const { container } = render(<CurrencyDisplay amount={100} showSign />);
    expect(container.firstChild).toHaveClass('text-success');
  });

  it('does not apply color classes without showSign', () => {
    const { container } = render(<CurrencyDisplay amount={100} />);
    expect(container.firstChild).not.toHaveClass('text-success');
    expect(container.firstChild).not.toHaveClass('text-danger');
  });
});
