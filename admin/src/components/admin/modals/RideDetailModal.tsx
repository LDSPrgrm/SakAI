import React from 'react';
import { X, MapPin, User, Car } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { formatPHP } from '@/lib/utils';
import type { AdminRideItem, RideStatus } from '@/types/super-admin';

export interface RideDetailModalProps {
  open: boolean;
  ride: AdminRideItem | null;
  onClose: () => void;
}

function statusVariant(s: RideStatus): 'success' | 'warning' | 'info' | 'danger' | 'default' {
  if (s === 'completed') return 'success';
  if (s === 'cancelled') return 'danger';
  if (s === 'requested') return 'warning';
  if (s === 'accepted' || s === 'arrived' || s === 'in_progress') return 'info';
  return 'default';
}

function methodLabel(m: string | null): string {
  if (!m) return '—';
  if (m === 'gcash') return 'GCash';
  if (m === 'paymaya') return 'PayMaya';
  if (m === 'card') return 'Card';
  if (m === 'cash') return 'Cash';
  return m;
}

export function RideDetailModal({ open, ride, onClose }: RideDetailModalProps) {
  if (!open || !ride) return null;
  const vehicle = ride.driver?.vehicle;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-xl p-6 space-y-5 max-h-[90vh] overflow-y-auto">
        <button onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main" aria-label="Close">
          <X className="w-5 h-5" />
        </button>

        <header className="space-y-1">
          <div className="flex items-center gap-3">
            <h3 className="text-lg font-semibold text-text-main">Ride {ride.id?.slice(0, 8)}</h3>
            <Badge variant={statusVariant(ride.status as RideStatus)}>
              {(ride.status ?? '').replace('_', ' ')}
            </Badge>
          </div>
          <p className="text-xs text-text-muted font-mono">{ride.id}</p>
        </header>

        <section className="grid grid-cols-2 gap-4 text-sm">
          <div className="space-y-1">
            <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
              <User className="w-3.5 h-3.5" /> Rider
            </p>
            <p className="text-text-main font-medium">{ride.passenger?.name ?? ride.passenger_name ?? '—'}</p>
            {ride.passenger?.email && <p className="text-xs text-text-muted">{ride.passenger.email}</p>}
          </div>
          <div className="space-y-1">
            <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
              <Car className="w-3.5 h-3.5" /> Driver
            </p>
            <p className="text-text-main font-medium">{ride.driver?.name ?? ride.driver_name ?? '—'}</p>
            {vehicle && (
              <p className="text-xs text-text-muted">
                {vehicle.make} {vehicle.model} · {vehicle.plate}
              </p>
            )}
          </div>
        </section>

        <section className="space-y-2">
          <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
            <MapPin className="w-3.5 h-3.5" /> Route
          </p>
          <div className="p-3 bg-surface-hover rounded-lg border border-border text-sm space-y-1">
            <p><span className="text-success">A:</span> {ride.origin_address ?? '—'}</p>
            <p><span className="text-danger">B:</span> {ride.destination_address ?? '—'}</p>
          </div>
        </section>

        <section className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted">Total Fare</p>
            <p className="text-text-main font-medium">
              {ride.total_fare != null ? formatPHP(ride.total_fare) : '—'}
            </p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted">Payment</p>
            <p className="text-text-main">{methodLabel(ride.payment_method)}</p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted">Created</p>
            <p className="text-text-main">{ride.created_at ? new Date(ride.created_at).toLocaleString('en-PH') : '—'}</p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-wide text-text-muted">Updated</p>
            <p className="text-text-main">{ride.updated_at ? new Date(ride.updated_at).toLocaleString('en-PH') : '—'}</p>
          </div>
        </section>

        <p className="text-xs text-text-muted">
          Lifecycle timeline + rating + tip require /admin/rides/{'{id}'} enrichment; tracked in Phase 3.
        </p>

        <div className="flex justify-end">
          <Button variant="outline" onClick={onClose}>Close</Button>
        </div>
      </div>
    </div>
  );
}
