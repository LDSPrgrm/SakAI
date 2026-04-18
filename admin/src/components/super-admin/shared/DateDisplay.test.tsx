import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { DateDisplay } from './DateDisplay';
import { formatDate, formatDateTime } from '@/utils/formatDate';

// 2026-04-18 08:00 UTC = 2026-04-18 16:00 PHT
const ISO = '2026-04-18T08:00:00.000Z';

describe('DateDisplay', () => {
  it('renders an em dash when iso is null', () => {
    render(<DateDisplay iso={null} />);
    expect(screen.getByText('—')).toBeInTheDocument();
  });

  it('renders an em dash when iso is undefined', () => {
    render(<DateDisplay iso={undefined} />);
    expect(screen.getByText('—')).toBeInTheDocument();
  });

  it('renders full datetime by default', () => {
    render(<DateDisplay iso={ISO} />);
    expect(screen.getByText(formatDateTime(ISO))).toBeInTheDocument();
  });

  it('renders date only when format="date"', () => {
    render(<DateDisplay iso={ISO} format="date" />);
    expect(screen.getByText(formatDate(ISO))).toBeInTheDocument();
  });

  it('sets title attribute to the full datetime for all formats', () => {
    const { container } = render(<DateDisplay iso={ISO} format="date" />);
    const span = container.querySelector('span');
    expect(span?.title).toBe(formatDateTime(ISO));
  });
});
