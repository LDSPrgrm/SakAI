// Before/after fare change comparison modal — spec superadmin.md §4.4 Business Rules
import React from 'react';
import { X, ArrowRight } from 'lucide-react';
import { formatPHP } from '@/utils/formatCurrency';
import type { FareConfig } from '@/types/super-admin';

interface FareChangePreviewProps {
  open: boolean;
  before: Partial<FareConfig> | null;
  after:  Partial<FareConfig> | null;
  loading?: boolean;
  onConfirm: () => void;
  onCancel:  () => void;
}

const FIELDS: { key: keyof FareConfig; label: string }[] = [
  { key: 'base_fare',        label: 'Base Fare' },
  { key: 'per_km_rate',      label: 'Per-KM Rate' },
  { key: 'per_min_rate',     label: 'Per-Minute Rate' },
  { key: 'minimum_fare',     label: 'Minimum Fare' },
  { key: 'booking_fee',      label: 'Booking Fee' },
  { key: 'cancellation_fee', label: 'Cancellation Fee' },
];

export function FareChangePreview({ open, before, after, loading, onConfirm, onCancel }: FareChangePreviewProps) {
  if (!open) return null;

  const changed = FIELDS.filter(
    ({ key }) => before && after && before[key] !== after[key],
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/60" onClick={onCancel} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-lg p-6">
        <button onClick={onCancel} className="absolute top-4 right-4 text-text-muted hover:text-text-main">
          <X className="w-5 h-5" />
        </button>
        <h3 className="text-base font-semibold text-text-main mb-1">Confirm Fare Changes</h3>
        <p className="text-sm text-text-muted mb-5">
          These changes apply immediately to new bookings. In-progress rides keep the fare at booking time.
        </p>

        {changed.length === 0 ? (
          <p className="text-sm text-text-muted">No changes detected.</p>
        ) : (
          <div className="space-y-2 mb-5">
            {changed.map(({ key, label }) => (
              <div key={key} className="flex items-center gap-3 text-sm">
                <span className="w-36 text-text-muted">{label}</span>
                <span className="text-danger line-through">{formatPHP(Number(before?.[key] ?? 0))}</span>
                <ArrowRight className="w-4 h-4 text-text-muted flex-shrink-0" />
                <span className="text-success font-medium">{formatPHP(Number(after?.[key] ?? 0))}</span>
              </div>
            ))}
          </div>
        )}

        <div className="flex justify-end gap-3">
          <button onClick={onCancel} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">
            Cancel
          </button>
          <button
            onClick={onConfirm}
            disabled={loading || changed.length === 0}
            className="px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50"
          >
            {loading ? 'Saving…' : 'Apply Changes'}
          </button>
        </div>
      </div>
    </div>
  );
}
