import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { UpdatedByFooter } from './UpdatedByFooter';

describe('UpdatedByFooter', () => {
  it('renders the provided name', () => {
    render(<UpdatedByFooter name="Jane Smith" />);
    expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    expect(screen.getByText(/Last updated by/)).toBeInTheDocument();
  });

  it('renders "Never updated" when name is missing', () => {
    render(<UpdatedByFooter />);
    expect(screen.getByText('Never updated')).toBeInTheDocument();
  });

  it('renders "Never updated" when name is empty/whitespace', () => {
    render(<UpdatedByFooter name="   " />);
    expect(screen.getByText('Never updated')).toBeInTheDocument();
  });

  it('hides raw UUID values rather than leaking them', () => {
    const uuid = '550e8400-e29b-41d4-a716-446655440000';
    render(<UpdatedByFooter name={uuid} />);
    expect(screen.getByText('Never updated')).toBeInTheDocument();
    expect(screen.queryByText(uuid)).toBeNull();
  });

  it('renders the actions slot', () => {
    render(
      <UpdatedByFooter name="Jane" actions={<button>Save</button>} />,
    );
    expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
  });
});
