import React from 'react';
import { X, FileCheck } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import type { DriverUser } from '@/types/super-admin';

export interface DriverDetailModalProps {
  open: boolean;
  driver: DriverUser | null;
  onClose: () => void;
  onReviewDocuments?: (driver: DriverUser) => void;
}

function statusVariant(status?: string): 'success' | 'warning' | 'danger' | 'default' {
  if (status === 'active') return 'success';
  if (status === 'suspended') return 'danger';
  return 'default';
}

export function DriverDetailModal({ open, driver, onClose, onReviewDocuments }: DriverDetailModalProps) {
  if (!open || !driver) return null;
  const status = driver.status ?? 'active';
  const vehicle = driver.vehicle;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-lg p-6 space-y-5">
        <button type="button" onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main" aria-label="Close">
          <X className="w-5 h-5" />
        </button>
        <header className="space-y-1">
          <h3 className="text-lg font-semibold text-text-main">{driver.name}</h3>
          <p className="text-xs text-text-muted font-mono">{driver.id}</p>
        </header>

        <dl className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Email</dt>
            <dd className="text-text-main break-all">{driver.email}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Phone</dt>
            <dd className="text-text-main">{driver.phone ?? '—'}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Status</dt>
            <dd><Badge variant={statusVariant(status)}>{status}</Badge></dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-text-muted">Joined</dt>
            <dd className="text-text-main">
              {driver.created_at ? new Date(driver.created_at).toLocaleDateString('en-PH') : '—'}
            </dd>
          </div>
          <div className="col-span-2">
            <dt className="text-xs uppercase tracking-wide text-text-muted">Vehicle</dt>
            <dd className="text-text-main">
              {vehicle ? `${vehicle.make} ${vehicle.model} · ${vehicle.color} · ${vehicle.plate}` : '—'}
            </dd>
          </div>
        </dl>

        <p className="text-xs text-text-muted">
          Earnings summary + recent rides require per-driver endpoints wired in Phase 3.
        </p>

        <div className="flex justify-between items-center">
          {onReviewDocuments ? (
            <Button variant="outline" onClick={() => onReviewDocuments(driver)} className="gap-2">
              <FileCheck className="w-4 h-4" /> Review Documents
            </Button>
          ) : <span />}
          <Button variant="outline" onClick={onClose}>Close</Button>
        </div>
      </div>
    </div>
  );
}
