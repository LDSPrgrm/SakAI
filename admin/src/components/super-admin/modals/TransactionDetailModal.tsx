import React from 'react';
import { X, Receipt, User, Car, CreditCard } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { formatPHP } from '@/lib/utils';
import type { Transaction } from '@/types/super-admin';

export interface TransactionDetailModalProps {
  open: boolean;
  transaction: Transaction | null;
  onClose: () => void;
}

function methodLabel(m?: string | null): string {
  if (!m) return '—';
  if (m === 'gcash') return 'GCash';
  if (m === 'paymaya') return 'PayMaya';
  if (m === 'card') return 'Card';
  if (m === 'cash') return 'Cash';
  return m;
}

function statusVariant(s?: string): 'success' | 'warning' | 'danger' | 'default' {
  if (s === 'settled') return 'success';
  if (s === 'pending') return 'warning';
  if (s === 'failed' || s === 'refunded') return 'danger';
  return 'default';
}

export function TransactionDetailModal({ open, transaction, onClose }: TransactionDetailModalProps) {
  if (!open || !transaction) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-lg p-6 space-y-5 max-h-[90vh] overflow-y-auto">
        <button onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main" aria-label="Close">
          <X className="w-5 h-5" />
        </button>

        <header className="space-y-1">
          <div className="flex items-center gap-3">
            <Receipt className="w-5 h-5 text-primary" />
            <h3 className="text-lg font-semibold text-text-main">Transaction Detail</h3>
            <Badge variant={statusVariant(transaction.status)}>{transaction.status ?? 'unknown'}</Badge>
          </div>
          <p className="text-xs font-mono text-text-muted break-all">{transaction.id}</p>
          {transaction.ride_id && (
            <p className="text-xs font-mono text-text-muted break-all">Ride: {transaction.ride_id}</p>
          )}
        </header>

        <section className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
              <User className="w-3.5 h-3.5" /> Rider
            </p>
            <p className="text-text-main font-medium">{transaction.rider_name ?? '—'}</p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
              <Car className="w-3.5 h-3.5" /> Driver
            </p>
            <p className="text-text-main font-medium">{transaction.driver_name ?? '—'}</p>
          </div>
        </section>

        <section className="p-4 bg-surface-hover rounded-lg border border-border space-y-3 text-sm">
          <div className="flex justify-between">
            <span className="text-text-muted">Gross Amount</span>
            <span className="text-text-main font-medium">{formatPHP(transaction.amount)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-text-muted">Platform Commission</span>
            <span className="text-text-main">{formatPHP(transaction.commission)}</span>
          </div>
          <div className="flex justify-between border-t border-border pt-2">
            <span className="text-text-muted">Net to Driver</span>
            <span className="text-success font-semibold">
              {formatPHP((transaction.amount ?? 0) - (transaction.commission ?? 0))}
            </span>
          </div>
        </section>

        <section className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
              <CreditCard className="w-3.5 h-3.5" /> Method
            </p>
            <p className="text-text-main">{methodLabel(transaction.payment_method)}</p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted">Processed</p>
            <p className="text-text-main">
              {transaction.created_at ? new Date(transaction.created_at).toLocaleString('en-PH') : '—'}
            </p>
          </div>
        </section>

        <p className="text-xs text-text-muted">
          Gateway raw response + refund action require backend endpoints tracked for Phase 3.
        </p>

        <div className="flex justify-end">
          <Button variant="outline" onClick={onClose}>Close</Button>
        </div>
      </div>
    </div>
  );
}
