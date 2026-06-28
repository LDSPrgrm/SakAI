import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ConfirmationModal } from './ConfirmationModal';

const baseProps = {
  open: true,
  title: 'Delete Role',
  onConfirm: vi.fn(),
  onCancel: vi.fn(),
};

describe('ConfirmationModal', () => {
  it('does not render when open=false', () => {
    render(<ConfirmationModal {...baseProps} open={false} />);
    expect(screen.queryByText('Delete Role')).toBeNull();
  });

  it('renders title when open=true', () => {
    render(<ConfirmationModal {...baseProps} />);
    expect(screen.getByText('Delete Role')).toBeInTheDocument();
  });

  it('renders description when provided', () => {
    render(<ConfirmationModal {...baseProps} description="This action cannot be undone." />);
    expect(screen.getByText('This action cannot be undone.')).toBeInTheDocument();
  });

  it('calls onConfirm when confirm button is clicked', () => {
    const onConfirm = vi.fn();
    render(<ConfirmationModal {...baseProps} onConfirm={onConfirm} />);
    fireEvent.click(screen.getByText('Confirm'));
    expect(onConfirm).toHaveBeenCalledOnce();
  });

  it('calls onCancel when cancel button is clicked', () => {
    const onCancel = vi.fn();
    render(<ConfirmationModal {...baseProps} onCancel={onCancel} />);
    fireEvent.click(screen.getByText('Cancel'));
    expect(onCancel).toHaveBeenCalledOnce();
  });

  it('calls onCancel when backdrop is clicked', () => {
    const onCancel = vi.fn();
    const { container } = render(<ConfirmationModal {...baseProps} onCancel={onCancel} />);
    const backdrop = container.querySelector('.absolute.inset-0');
    fireEvent.click(backdrop!);
    expect(onCancel).toHaveBeenCalledOnce();
  });

  it('shows custom confirm and cancel labels', () => {
    render(<ConfirmationModal {...baseProps} confirmLabel="Yes, delete" cancelLabel="Keep it" />);
    expect(screen.getByText('Yes, delete')).toBeInTheDocument();
    expect(screen.getByText('Keep it')).toBeInTheDocument();
  });

  it('shows "Processing…" and disables buttons while loading', () => {
    render(<ConfirmationModal {...baseProps} loading={true} />);
    expect(screen.getByText('Processing…')).toBeInTheDocument();
    expect(screen.getByText('Cancel')).toBeDisabled();
  });
});
