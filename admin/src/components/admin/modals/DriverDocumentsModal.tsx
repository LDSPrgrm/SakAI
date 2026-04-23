import React, { useMemo, useState } from 'react';
import { X, Check, XCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useKycQueue, useUpdateKyc } from '@/hooks/useSafety';
import type { DriverUser } from '@/types/super-admin';
import type { KycEntry } from '@/api/super-admin/safety';

export interface DriverDocumentsModalProps {
  open: boolean;
  driver: DriverUser | null;
  onClose: () => void;
}

function statusVariant(s?: string): 'success' | 'warning' | 'danger' | 'default' {
  if (s === 'approved') return 'success';
  if (s === 'rejected') return 'danger';
  if (s === 'pending') return 'warning';
  return 'default';
}

export function DriverDocumentsModal({ open, driver, onClose }: DriverDocumentsModalProps) {
  const kycQuery = useKycQueue();
  const updateKyc = useUpdateKyc();
  const [busyId, setBusyId] = useState<string | null>(null);

  const entries: KycEntry[] = useMemo(() => {
    const all = (kycQuery.data ?? []) as KycEntry[];
    if (!driver) return [];
    return all.filter((e) => e.driver_id === driver.id);
  }, [kycQuery.data, driver]);

  if (!open || !driver) return null;

  const act = async (id: string, status: 'approved' | 'rejected') => {
    setBusyId(id);
    try {
      await updateKyc.mutateAsync({ id, status });
    } finally {
      setBusyId(null);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-xl p-6 space-y-4">
        <button onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main" aria-label="Close">
          <X className="w-5 h-5" />
        </button>
        <header>
          <h3 className="text-lg font-semibold text-text-main">Review Documents</h3>
          <p className="text-xs text-text-muted mt-0.5">{driver.name} · {driver.id}</p>
        </header>

        {kycQuery.isPending ? (
          <p className="text-sm text-text-muted text-center py-6">Loading submissions…</p>
        ) : entries.length === 0 ? (
          <p className="text-sm text-text-muted text-center py-6">
            No KYC submissions for this driver.
          </p>
        ) : (
          <ul className="space-y-3">
            {entries.map((entry) => (
              <li key={entry.id} className="p-3 bg-surface-hover rounded-lg border border-border space-y-2">
                <div className="flex items-center justify-between gap-3">
                  <div className="space-y-1">
                    <p className="text-sm font-medium text-text-main">Submission · {entry.id?.slice(0, 8)}</p>
                    <p className="text-xs text-text-muted">
                      Submitted {entry.submitted_at ? new Date(entry.submitted_at).toLocaleDateString('en-PH') : '—'}
                    </p>
                  </div>
                  <Badge variant={statusVariant(entry.status)}>{entry.status ?? 'pending'}</Badge>
                </div>
                {entry.docs && entry.docs.length > 0 && (
                  <ul className="flex flex-wrap gap-1 text-xs text-text-muted">
                    {entry.docs.map((d, i) => (
                      <li
                        key={`${d.type ?? 'doc'}-${i}`}
                        className="px-2 py-0.5 rounded bg-surface border border-border"
                      >
                        {d.label ?? d.type ?? 'doc'}
                      </li>
                    ))}
                  </ul>
                )}
                {entry.status === 'pending' && (
                  <div className="flex justify-end gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-danger"
                      disabled={busyId === entry.id}
                      onClick={() => entry.id && act(entry.id, 'rejected')}
                    >
                      <XCircle className="w-4 h-4 mr-1" /> Reject
                    </Button>
                    <Button
                      variant="primary"
                      size="sm"
                      disabled={busyId === entry.id}
                      onClick={() => entry.id && act(entry.id, 'approved')}
                    >
                      <Check className="w-4 h-4 mr-1" /> Approve
                    </Button>
                  </div>
                )}
              </li>
            ))}
          </ul>
        )}

        <div className="flex justify-end">
          <Button variant="outline" onClick={onClose}>Close</Button>
        </div>
      </div>
    </div>
  );
}
