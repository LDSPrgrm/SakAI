// Canonical confirmation dialog used for all destructive/high-impact actions.
// Spec: superadmin.md §2 modals/ConfirmationModal.tsx
import React from 'react';
import { AlertTriangle, CheckCircle, X } from 'lucide-react';
import { cn } from '@/lib/utils';

export type ConfirmationVariant = 'danger' | 'warning' | 'info' | 'success';

export interface ConfirmationModalProps {
  open: boolean;
  title: string;
  description?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: ConfirmationVariant;
  loading?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

const VARIANT_STYLES: Record<ConfirmationVariant, { icon: string; confirm: string; ring: string }> = {
  danger:  { icon: 'text-danger',  confirm: 'bg-danger hover:bg-danger/90 text-white',   ring: 'bg-danger/10' },
  warning: { icon: 'text-warning', confirm: 'bg-warning hover:bg-warning/90 text-white', ring: 'bg-warning/10' },
  info:    { icon: 'text-primary', confirm: 'bg-primary hover:bg-primary/90 text-white', ring: 'bg-primary/10' },
  success: { icon: 'text-success', confirm: 'bg-success hover:bg-success/90 text-white', ring: 'bg-success/10' },
};

export function ConfirmationModal({
  open,
  title,
  description,
  confirmLabel = 'Confirm',
  cancelLabel  = 'Cancel',
  variant      = 'danger',
  loading,
  onConfirm,
  onCancel,
}: ConfirmationModalProps) {
  if (!open) return null;

  const styles = VARIANT_STYLES[variant];
  const Icon   = variant === 'success' ? CheckCircle : AlertTriangle;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onCancel} />

      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-md p-6 flex flex-col gap-5">
        <button
          onClick={onCancel}
          aria-label="Close"
          className="absolute top-4 right-4 text-text-muted hover:text-text-main transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        <div className="flex items-start gap-4">
          <div className={cn('w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0', styles.ring)}>
            <Icon className={cn('w-5 h-5', styles.icon)} />
          </div>
          <div>
            <h3 className="text-base font-semibold text-text-main">{title}</h3>
            {description && (
              <p className="text-sm text-text-muted mt-1 leading-relaxed">{description}</p>
            )}
          </div>
        </div>

        <div className="flex justify-end gap-3">
          <button
            onClick={onCancel}
            disabled={loading}
            className="px-4 py-2 text-sm font-medium rounded-lg border border-border text-text-muted hover:text-text-main hover:border-primary/50 transition-colors disabled:opacity-50"
          >
            {cancelLabel}
          </button>
          <button
            onClick={onConfirm}
            disabled={loading}
            className={cn('px-4 py-2 text-sm font-medium rounded-lg transition-colors disabled:opacity-50', styles.confirm)}
          >
            {loading ? 'Processing…' : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
