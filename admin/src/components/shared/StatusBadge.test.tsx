import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { StatusBadge } from './StatusBadge';

describe('shared StatusBadge', () => {
  it('title-cases the raw status when no label is provided', () => {
    render(<StatusBadge status="active" />);
    expect(screen.getByText('Active')).toBeInTheDocument();
  });

  it('title-cases multi-word statuses with underscores', () => {
    render(<StatusBadge status="in_progress" />);
    expect(screen.getByText('In Progress')).toBeInTheDocument();
  });

  it('uses an explicit label verbatim when provided', () => {
    render(<StatusBadge status="active" label="Online now" />);
    expect(screen.getByText('Online now')).toBeInTheDocument();
    expect(screen.queryByText('Active')).toBeNull();
  });

  it('falls through to default variant for unknown statuses', () => {
    render(<StatusBadge status="zzz_unknown" />);
    expect(screen.getByText('Zzz Unknown')).toBeInTheDocument();
  });
});
