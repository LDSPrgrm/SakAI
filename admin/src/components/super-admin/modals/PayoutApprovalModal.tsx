// Batch payout approval modal — spec superadmin.md §4.5 Driver Payout Management
import React from 'react';
import { X, CheckCircle } from 'lucide-react';
import { formatPHP } from '@/utils/formatCurrency';
import type { DriverPayout } from '@/lib/admin-api';

interface PayoutApprovalModalProps {
  open: boolean;
  selected: DriverPayout[];
  loading?: boolean;
  onConfirm: () => void;
  onCancel:  () => void;
}

export function PayoutApprovalModal({ open, selected, loading, onConfirm, onCancel }: PayoutApprovalModalProps) {
  if (!open) return null;

  const totalAmount  = selected.reduce((s, p) => s + p.total_amount, 0);
  const totalDrivers = selected.reduce((s, p) => s + p.driver_count, 0);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/60" onClick={onCancel} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-md p-6">
        <button onClick={onCancel} className="absolute top-4 right-4 text-text-muted hover:text-text-main">
          <X className="w-5 h-5" />
        </button>

        <div className="flex items-start gap-4 mb-5">
          <div className="w-10 h-10 rounded-full bg-success/10 flex items-center justify-center flex-shrink-0">
            <CheckCircle className="w-5 h-5 text-success" />
          </div>
          <div>
            <h3 className="text-base font-semibold text-text-main">Approve Payouts</h3>
            <p className="text-sm text-text-muted mt-1">
              You are about to approve <strong className="text-text-main">{selected.length}</strong> payout batch{selected.length !== 1 ? 'es' : ''} for{' '}
              <strong className="text-text-main">{totalDrivers} driver{totalDrivers !== 1 ? 's' : ''}</strong> totalling{' '}
              <strong className="text-success">{formatPHP(totalAmount)}</strong>.
            </p>
          </div>
        </div>

        {selected.length > 0 && (
          <ul className="text-xs text-text-muted space-y-1 mb-5 max-h-40 overflow-y-auto">
            {selected.map((p) => (
              <li key={p.id} className="flex items-center justify-between">
                <span>{p.batch} — {p.driver_count} drivers</span>
                <span className="text-success font-medium">{formatPHP(p.total_amount)}</span>
              </li>
            ))}
          </ul>
        )}

        <div className="flex justify-end gap-3">
          <button onClick={onCancel} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">
            Cancel
          </button>
          <button
            onClick={onConfirm}
            disabled={loading || selected.length === 0}
            className="px-4 py-2 text-sm rounded-lg bg-success hover:bg-success/90 text-white font-medium transition-colors disabled:opacity-50"
          >
            {loading ? 'Processing…' : 'Approve All'}
          </button>
        </div>
      </div>
    </div>
  );
}
