import React, { useMemo, useState } from 'react';
import { X, ShieldAlert, User, Car, Clock, UserCog } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { StatusBadge } from '@/components/shared/StatusBadge';
import {
  useIncident, useAssignIncident, useResolveIncident, useAssigneeCandidates,
} from '@/hooks/useSafety';
import { formatDate } from '@/utils/formatDate';

export interface IncidentDetailModalProps {
  open: boolean;
  incidentId: string | null;
  onClose: () => void;
}

const ASSIGNABLE_ROLES = new Set(['superadmin', 'operations', 'support', 'admin']);

export function IncidentDetailModal({ open, incidentId, onClose }: IncidentDetailModalProps) {
  const incidentQuery = useIncident(open ? incidentId : null);
  const candidatesQuery = useAssigneeCandidates();
  const assignMut = useAssignIncident();
  const resolveMut = useResolveIncident();

  const [resolutionNotes, setResolutionNotes] = useState('');

  const detail = incidentQuery.data ?? null;
  const incident = detail?.incident ?? null;
  const history = detail?.status_history ?? [];

  const assignees = useMemo(() => {
    const rows = candidatesQuery.data ?? [];
    return rows.filter((a) => !a.role || ASSIGNABLE_ROLES.has(a.role));
  }, [candidatesQuery.data]);

  if (!open) return null;

  async function handleAssign(e: React.ChangeEvent<HTMLSelectElement>) {
    if (!incident) return;
    const value = e.target.value || null;
    await assignMut.mutateAsync({ id: incident.id!, assigneeId: value }).catch(() => undefined);
  }

  async function handleResolve() {
    if (!incident || resolveMut.isPending) return;
    const notes = resolutionNotes.trim();
    if (!notes) return;
    await resolveMut.mutateAsync({ id: incident.id!, notes }).catch(() => undefined);
    setResolutionNotes('');
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-2xl p-6 space-y-5 max-h-[90vh] overflow-y-auto">
        <button onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-main" aria-label="Close">
          <X className="w-5 h-5" />
        </button>

        <header className="space-y-1">
          <div className="flex items-center gap-3">
            <ShieldAlert className="w-5 h-5 text-danger" />
            <h3 className="text-lg font-semibold text-text-main">Incident Detail</h3>
            {incident && <StatusBadge status={incident.status ?? ''} />}
          </div>
          {incident && <p className="text-xs font-mono text-text-muted break-all">{incident.id}</p>}
        </header>

        {incidentQuery.isLoading && (
          <p className="text-sm text-text-muted">Loading…</p>
        )}
        {incidentQuery.isError && (
          <p className="text-sm text-danger">Failed to load incident.</p>
        )}

        {incident && (
          <>
            <section className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-xs uppercase tracking-wide text-text-muted">Type</p>
                <Badge variant={incident.type === 'sos_triggered' ? 'danger' : 'warning'}>
                  {incident.type ?? '—'}
                </Badge>
              </div>
              <div>
                <p className="text-xs uppercase tracking-wide text-text-muted">Triggered By</p>
                <p className="text-text-main capitalize">{incident.triggered_by ?? '—'}</p>
              </div>
              <div>
                <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
                  <User className="w-3.5 h-3.5" /> Rider
                </p>
                <p className="text-text-main font-mono text-xs break-all">{incident.rider_id ?? '—'}</p>
              </div>
              <div>
                <p className="text-xs uppercase tracking-wide text-text-muted flex items-center gap-1.5">
                  <Car className="w-3.5 h-3.5" /> Driver
                </p>
                <p className="text-text-main font-mono text-xs break-all">{incident.driver_id ?? '—'}</p>
              </div>
              <div className="col-span-2">
                <p className="text-xs uppercase tracking-wide text-text-muted">Ride</p>
                <p className="text-text-main font-mono text-xs break-all">{incident.ride_id ?? '—'}</p>
              </div>
            </section>

            <section>
              <p className="text-xs uppercase tracking-wide text-text-muted mb-1.5 flex items-center gap-1.5">
                <UserCog className="w-3.5 h-3.5" /> Assigned To
              </p>
              <select
                value={incident.assigned_to ?? ''}
                onChange={handleAssign}
                disabled={assignMut.isPending}
                className="w-full h-10 rounded-lg border border-border bg-background px-3 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="">Unassigned</option>
                {assignees.map((a) => (
                  <option key={a.id} value={a.id}>
                    {a.name || a.id}
                    {a.role ? ` (${a.role})` : ''}
                  </option>
                ))}
              </select>
            </section>

            <section>
              <p className="text-xs uppercase tracking-wide text-text-muted mb-1.5 flex items-center gap-1.5">
                <Clock className="w-3.5 h-3.5" /> Timeline
              </p>
              <ol className="relative border-l border-border ml-2 space-y-3">
                {history.length === 0 && (
                  <li className="text-sm text-text-muted pl-4">No events recorded.</li>
                )}
                {history.map((ev) => (
                  <li key={ev.id} className="pl-4">
                    <span className="absolute -left-1.5 w-3 h-3 rounded-full bg-primary border-2 border-surface" />
                    <div className="flex flex-wrap items-baseline gap-2">
                      <p className="text-sm text-text-main">
                        {ev.from_status ? (
                          <>
                            {ev.from_status} <span className="text-text-muted">→</span>{' '}
                            <span className="font-medium">{ev.to_status}</span>
                          </>
                        ) : (
                          <span className="font-medium">{ev.to_status}</span>
                        )}
                      </p>
                      <span className="text-xs text-text-muted">{formatDate(ev.occurred_at)}</span>
                    </div>
                    {ev.actor_name && (
                      <p className="text-xs text-text-muted">by {ev.actor_name}</p>
                    )}
                    {ev.note && <p className="text-xs text-text-main mt-0.5">{ev.note}</p>}
                  </li>
                ))}
              </ol>
            </section>

            {incident.status !== 'resolved' && (
              <section className="space-y-2">
                <label className="text-xs uppercase tracking-wide text-text-muted">Resolution Notes</label>
                <textarea
                  value={resolutionNotes}
                  onChange={(e) => setResolutionNotes(e.target.value)}
                  rows={3}
                  placeholder="Summary of how the incident was handled…"
                  className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
                />
                <div className="flex justify-end gap-2">
                  <Button variant="outline" onClick={onClose}>Close</Button>
                  <Button
                    variant="success"
                    disabled={resolveMut.isPending || resolutionNotes.trim().length === 0}
                    onClick={handleResolve}
                  >
                    {resolveMut.isPending ? 'Resolving…' : 'Mark Resolved'}
                  </Button>
                </div>
              </section>
            )}

            {incident.status === 'resolved' && (
              <div className="flex justify-between items-center">
                {incident.resolution_notes && (
                  <p className="text-xs text-text-muted italic flex-1 pr-4">
                    {incident.resolution_notes}
                  </p>
                )}
                <Button variant="outline" onClick={onClose}>Close</Button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
