import React from 'react';
import { X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import type { PassengerUser } from '@/types/super-admin';

export interface RiderDetailModalProps {
  open: boolean;
  rider: PassengerUser | null;
  onClose: () => void;
}

function statusVariant(status?: string): 'success' | 'warning' | 'danger' | 'default' {
  if (status === 'active') return 'success';
  if (status === 'suspended') return 'danger';
  return 'default';
}

export function RiderDetailModal({ open, rider, onClose }: RiderDetailModalProps) {
  if (!open || !rider) return null;
  const status = rider.status ?? 'active';
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-lg p-6 space-y-5">
        <button onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main" aria-label="Close">
          <X className="w-5 h-5" />
        </button>
        <header className="space-y-1">
          <h3 className="text-lg font-semibold text-text-main">{rider.name}</h3>
          <p className="text-xs text-text-muted font-mono">{rider.id}</p>
        </header>

        <dl className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Email</dt>
            <dd className="text-text-main break-all">{rider.email}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Phone</dt>
            <dd className="text-text-main">{rider.phone ?? '—'}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Status</dt>
            <dd><Badge variant={statusVariant(status)}>{status}</Badge></dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Joined</dt>
            <dd className="text-text-main">
              {rider.created_at ? new Date(rider.created_at).toLocaleDateString('en-PH') : '—'}
            </dd>
          </div>
        </dl>

        <p className="text-xs text-text-muted">
          Ride history and rating summary require per-user endpoints not yet wired. Tracked in Phase 3.
        </p>

        <div className="flex justify-end">
          <Button variant="outline" onClick={onClose}>Close</Button>
        </div>
      </div>
    </div>
  );
}
