// Thin back-compat adapter; delegates to ConfirmationModal.
// New code should import ConfirmationModal directly.
import React from 'react';
import { ConfirmationModal, ConfirmationVariant } from '@/components/shared/ConfirmationModal';

export interface ConfirmModalProps {
  open: boolean;
  title: string;
  message: string;
  variant?: 'danger' | 'success';
  confirmLabel?: string;
  onConfirm: () => void;
  onClose: () => void;
}

export function ConfirmModal({
  open,
  title,
  message,
  variant = 'danger',
  confirmLabel,
  onConfirm,
  onClose,
}: ConfirmModalProps) {
  const mappedVariant: ConfirmationVariant = variant;
  return (
    <ConfirmationModal
      open={open}
      title={title}
      description={message}
      variant={mappedVariant}
      confirmLabel={confirmLabel}
      onConfirm={() => { onConfirm(); onClose(); }}
      onCancel={onClose}
    />
  );
}
