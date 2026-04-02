import React from 'react';
import { AlertTriangle, CheckCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';

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
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4" role="dialog" aria-modal="true">
      <div className="bg-surface border border-border rounded-xl p-6 w-full max-w-sm shadow-xl space-y-4">
        <div className="flex items-center gap-3">
          {variant === 'danger'
            ? <AlertTriangle className="w-5 h-5 text-warning flex-shrink-0" />
            : <CheckCircle className="w-5 h-5 text-success flex-shrink-0" />}
          <h2 className="text-base font-semibold text-text-main">{title}</h2>
        </div>
        <p className="text-sm text-text-muted">{message}</p>
        <div className="flex gap-3 justify-end">
          <Button variant="outline" size="sm" onClick={onClose}>Cancel</Button>
          <Button variant={variant} size="sm" onClick={() => { onConfirm(); onClose(); }}>
            {confirmLabel ?? 'Confirm'}
          </Button>
        </div>
      </div>
    </div>
  );
}
