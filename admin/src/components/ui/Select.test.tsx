import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Select } from './Select';

const OPTS = [
  { label: 'Apple', value: 'apple' },
  { label: 'Banana', value: 'banana' },
  { label: 'Cherry', value: 'cherry' },
];

describe('Select', () => {
  it('renders all options', () => {
    render(
      <Select value="apple" onValueChange={() => {}} options={OPTS} aria-label="fruit" />,
    );
    expect(screen.getByRole('option', { name: 'Apple' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Banana' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Cherry' })).toBeInTheDocument();
  });

  it('reflects the value prop', () => {
    render(
      <Select value="banana" onValueChange={() => {}} options={OPTS} aria-label="fruit" />,
    );
    expect((screen.getByRole('combobox') as HTMLSelectElement).value).toBe('banana');
  });

  it('calls onValueChange with the selected value', () => {
    const handle = vi.fn();
    render(
      <Select value="apple" onValueChange={handle} options={OPTS} aria-label="fruit" />,
    );
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'cherry' } });
    expect(handle).toHaveBeenCalledWith('cherry');
  });

  it('respects the disabled attribute', () => {
    render(
      <Select value="apple" onValueChange={() => {}} options={OPTS} disabled aria-label="fruit" />,
    );
    expect(screen.getByRole('combobox')).toBeDisabled();
  });

  it('exposes aria-label on the underlying select', () => {
    render(
      <Select value="apple" onValueChange={() => {}} options={OPTS} aria-label="fruit picker" />,
    );
    expect(screen.getByRole('combobox', { name: 'fruit picker' })).toBeInTheDocument();
  });

  it('renders a placeholder option when provided', () => {
    render(
      <Select
        value=""
        onValueChange={() => {}}
        options={OPTS}
        placeholder="Choose…"
        aria-label="fruit"
      />,
    );
    const placeholder = screen.getByText('Choose…');
    expect(placeholder.tagName).toBe('OPTION');
    expect(placeholder).toHaveAttribute('disabled');
    expect(placeholder).toHaveAttribute('hidden');
  });
});
