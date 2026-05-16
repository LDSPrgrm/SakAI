import React, { useMemo, useState } from 'react';
import { Building2, MapPin, Plus, Trash2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import { SaveBanner } from '@/components/shared/SaveBanner';
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/Table';
import { SurgeZoneEditor } from '@/components/super-admin/fares/SurgeZoneEditor';
import {
  useLguPartnerships, useServiceAreas,
  useCreateLgu, useUpdateLgu, useDeleteLgu,
  useCreateServiceArea, useUpdateServiceArea, useDeleteServiceArea,
} from '@/hooks/useLgu';
import type { LGUPartnership, ServiceArea } from '@/api/super-admin/lgu';
import type { SurgeZone } from '@/lib/maps';
import { formatDate } from '@/utils/formatDate';

type Tab = 'partnerships' | 'areas';

const STATUS_VARIANT: Record<LGUPartnership['status'], 'success' | 'warning' | 'danger' | 'default'> = {
  active: 'success',
  pending: 'warning',
  expired: 'default',
  terminated: 'danger',
};

const EMPTY_BOUNDARY: SurgeZone = { name: '', multiplier: 1, polygon: [] };

export function SALguPartnerships() {
  const [tab, setTab] = useState<Tab>('partnerships');
  const [banner, setBanner] = useState(false);

  const lguQuery = useLguPartnerships();
  const areasQuery = useServiceAreas();
  const partnerships = lguQuery.data ?? [];
  const areas = areasQuery.data ?? [];

  const createLgu = useCreateLgu();
  const updateLgu = useUpdateLgu();
  const deleteLgu = useDeleteLgu();

  const createArea = useCreateServiceArea();
  const updateArea = useUpdateServiceArea();
  const deleteArea = useDeleteServiceArea();

  const [editingLgu, setEditingLgu] = useState<LGUPartnership | null>(null);
  const [editingArea, setEditingArea] = useState<ServiceArea | null>(null);
  const [deleteLguId, setDeleteLguId] = useState<string | null>(null);
  const [deleteAreaId, setDeleteAreaId] = useState<string | null>(null);

  function flashBanner() {
    setBanner(true);
    setTimeout(() => setBanner(false), 3000);
  }

  const areaNameById = useMemo(() => {
    const map = new Map<string, string>();
    for (const a of areas) map.set(a.id, a.name);
    return map;
  }, [areas]);

  return (
    <div className="space-y-6 p-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">LGU Partnerships &amp; Service Areas</h1>
        <SaveBanner visible={banner} message="Saved" />
      </div>

      <div className="flex items-center gap-2 border-b border-border">
        <button
          className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors ${
            tab === 'partnerships' ? 'border-primary text-text-main' : 'border-transparent text-text-muted'
          }`}
          onClick={() => setTab('partnerships')}
        >
          <Building2 className="inline w-4 h-4 mr-1.5" />
          Partnerships ({partnerships.length})
        </button>
        <button
          className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors ${
            tab === 'areas' ? 'border-primary text-text-main' : 'border-transparent text-text-muted'
          }`}
          onClick={() => setTab('areas')}
        >
          <MapPin className="inline w-4 h-4 mr-1.5" />
          Service Areas ({areas.length})
        </button>
      </div>

      {tab === 'partnerships' && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Partnership Directory</CardTitle>
              <Button size="sm" onClick={() => setEditingLgu({ id: '', lgu_name: '', status: 'pending' } as LGUPartnership)}>
                <Plus className="w-4 h-4 mr-1" /> New Partnership
              </Button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>LGU</TableHead>
                  <TableHead>Area</TableHead>
                  <TableHead>Contact</TableHead>
                  <TableHead>Agreement</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {partnerships.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="py-10 text-center text-text-muted">
                      No partnerships yet.
                    </TableCell>
                  </TableRow>
                ) : (
                  partnerships.map((p) => (
                    <TableRow
                      key={p.id}
                      className="cursor-pointer hover:bg-surface-hover/80"
                      onClick={() => setEditingLgu(p)}
                    >
                      <TableCell className="font-medium text-text-main">{p.lgu_name}</TableCell>
                      <TableCell className="text-sm text-text-muted">
                        {p.service_area_id ? areaNameById.get(p.service_area_id) ?? '—' : '—'}
                      </TableCell>
                      <TableCell className="text-sm">
                        {p.contact_name || '—'}
                        {p.contact_email && <div className="text-xs text-text-muted">{p.contact_email}</div>}
                      </TableCell>
                      <TableCell className="text-sm text-text-muted whitespace-nowrap">
                        {p.agreement_start ? formatDate(p.agreement_start) : '—'}
                        {p.agreement_end && <> → {formatDate(p.agreement_end)}</>}
                      </TableCell>
                      <TableCell>
                        <Badge variant={STATUS_VARIANT[p.status]} className="capitalize">{p.status}</Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={(e) => {
                            e.stopPropagation();
                            setDeleteLguId(p.id);
                          }}
                        >
                          <Trash2 className="w-4 h-4 text-danger" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {tab === 'areas' && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Service Areas</CardTitle>
              <Button
                size="sm"
                onClick={() =>
                  setEditingArea({ id: '', name: '', boundary: { ...EMPTY_BOUNDARY }, active: true } as ServiceArea)
                }
              >
                <Plus className="w-4 h-4 mr-1" /> New Area
              </Button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>LGU Code</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {areas.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="py-10 text-center text-text-muted">
                      No service areas.
                    </TableCell>
                  </TableRow>
                ) : (
                  areas.map((a) => (
                    <TableRow
                      key={a.id}
                      className="cursor-pointer hover:bg-surface-hover/80"
                      onClick={() => setEditingArea(a)}
                    >
                      <TableCell className="font-medium text-text-main">{a.name}</TableCell>
                      <TableCell className="text-sm text-text-muted">{a.lgu_code || '—'}</TableCell>
                      <TableCell>
                        <Badge variant={a.active ? 'success' : 'default'}>
                          {a.active ? 'Active' : 'Inactive'}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={(e) => {
                            e.stopPropagation();
                            setDeleteAreaId(a.id);
                          }}
                        >
                          <Trash2 className="w-4 h-4 text-danger" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {/* LGU edit modal */}
      {editingLgu && (
        <LguModal
          value={editingLgu}
          areas={areas}
          saving={createLgu.isPending || updateLgu.isPending}
          onClose={() => setEditingLgu(null)}
          onSave={async (data) => {
            if (editingLgu.id) {
              await updateLgu.mutateAsync({ id: editingLgu.id, data });
            } else {
              await createLgu.mutateAsync(data);
            }
            setEditingLgu(null);
            flashBanner();
          }}
        />
      )}

      {/* Service area edit modal */}
      {editingArea && (
        <AreaModal
          value={editingArea}
          saving={createArea.isPending || updateArea.isPending}
          onClose={() => setEditingArea(null)}
          onSave={async (data) => {
            if (editingArea.id) {
              await updateArea.mutateAsync({ id: editingArea.id, data });
            } else {
              await createArea.mutateAsync(data);
            }
            setEditingArea(null);
            flashBanner();
          }}
        />
      )}

      <ConfirmationModal
        open={!!deleteLguId}
        title="Delete Partnership"
        description="This removes the partnership record. Historical audit rows remain."
        variant="danger"
        confirmLabel="Delete"
        onConfirm={async () => {
          if (deleteLguId) {
            await deleteLgu.mutateAsync(deleteLguId);
            flashBanner();
          }
          setDeleteLguId(null);
        }}
        onCancel={() => setDeleteLguId(null)}
      />
      <ConfirmationModal
        open={!!deleteAreaId}
        title="Delete Service Area"
        description="Partnerships linked to this area will have their reference cleared."
        variant="danger"
        confirmLabel="Delete"
        onConfirm={async () => {
          if (deleteAreaId) {
            await deleteArea.mutateAsync(deleteAreaId);
            flashBanner();
          }
          setDeleteAreaId(null);
        }}
        onCancel={() => setDeleteAreaId(null)}
      />
    </div>
  );
}

// ─── LGU modal ──────────────────────────────────────────────────────────────

interface LguModalProps {
  value: LGUPartnership;
  areas: ServiceArea[];
  saving: boolean;
  onClose: () => void;
  onSave: (data: Omit<LGUPartnership, 'id' | 'created_at' | 'updated_at'>) => void;
}

function LguModal({ value, areas, saving, onClose, onSave }: LguModalProps) {
  const [form, setForm] = useState<LGUPartnership>(value);

  function update<K extends keyof LGUPartnership>(key: K, v: LGUPartnership[K]) {
    setForm((f) => ({ ...f, [key]: v }));
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-lg p-6 space-y-4 max-h-[90vh] overflow-y-auto">
        <h3 className="text-lg font-semibold text-text-main">
          {value.id ? 'Edit Partnership' : 'New Partnership'}
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
          <div className="sm:col-span-2">
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">LGU name</label>
            <Input value={form.lgu_name} onChange={(e) => update('lgu_name', e.target.value)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Status</label>
            <select
              value={form.status}
              onChange={(e) => update('status', e.target.value as LGUPartnership['status'])}
              className="w-full h-10 rounded-lg border border-border bg-background px-3 text-sm"
            >
              <option value="pending">pending</option>
              <option value="active">active</option>
              <option value="expired">expired</option>
              <option value="terminated">terminated</option>
            </select>
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Service area</label>
            <select
              value={form.service_area_id ?? ''}
              onChange={(e) => update('service_area_id', e.target.value || null)}
              className="w-full h-10 rounded-lg border border-border bg-background px-3 text-sm"
            >
              <option value="">— Unlinked —</option>
              {areas.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Contact name</label>
            <Input value={form.contact_name ?? ''} onChange={(e) => update('contact_name', e.target.value)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Contact email</label>
            <Input type="email" value={form.contact_email ?? ''} onChange={(e) => update('contact_email', e.target.value)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Contact phone</label>
            <Input value={form.contact_phone ?? ''} onChange={(e) => update('contact_phone', e.target.value)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Agreement start</label>
            <Input type="date" value={form.agreement_start ?? ''} onChange={(e) => update('agreement_start', e.target.value || null)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Agreement end</label>
            <Input type="date" value={form.agreement_end ?? ''} onChange={(e) => update('agreement_end', e.target.value || null)} />
          </div>
          <div className="sm:col-span-2">
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Notes</label>
            <textarea
              value={form.notes ?? ''}
              onChange={(e) => update('notes', e.target.value)}
              rows={3}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
            />
          </div>
        </div>
        <div className="flex justify-end gap-2 pt-2">
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button
            disabled={saving || form.lgu_name.trim() === ''}
            onClick={() =>
              onSave({
                service_area_id: form.service_area_id ?? null,
                lgu_name: form.lgu_name,
                contact_name: form.contact_name,
                contact_email: form.contact_email,
                contact_phone: form.contact_phone,
                agreement_start: form.agreement_start ?? null,
                agreement_end: form.agreement_end ?? null,
                status: form.status,
                notes: form.notes,
              })
            }
          >
            {saving ? 'Saving…' : 'Save'}
          </Button>
        </div>
      </div>
    </div>
  );
}

// ─── Service area modal ────────────────────────────────────────────────────

interface AreaModalProps {
  value: ServiceArea;
  saving: boolean;
  onClose: () => void;
  onSave: (data: { name: string; lgu_code?: string; boundary: SurgeZone; active?: boolean }) => void;
}

function AreaModal({ value, saving, onClose, onSave }: AreaModalProps) {
  const [name, setName] = useState(value.name);
  const [lguCode, setLguCode] = useState(value.lgu_code ?? '');
  const [active, setActive] = useState(value.active);
  const [zones, setZones] = useState<SurgeZone[]>([{ ...value.boundary, name: value.boundary.name || name || 'boundary' }]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-4xl p-6 space-y-4 max-h-[90vh] overflow-y-auto">
        <h3 className="text-lg font-semibold text-text-main">
          {value.id ? 'Edit Service Area' : 'New Service Area'}
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-sm">
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Name</label>
            <Input value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">LGU code</label>
            <Input value={lguCode} onChange={(e) => setLguCode(e.target.value)} />
          </div>
          <label className="flex items-end gap-2 pb-1 text-sm">
            <input
              type="checkbox"
              checked={active}
              onChange={(e) => setActive(e.target.checked)}
              className="w-4 h-4 accent-primary"
            />
            <span>Active (listed on public /service-area)</span>
          </label>
        </div>

        <SurgeZoneEditor
          value={zones}
          onChange={(next) => setZones(next.length ? [next[0]] : [{ ...EMPTY_BOUNDARY, name: 'boundary' }])}
        />

        <div className="flex justify-end gap-2 pt-2">
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button
            disabled={saving || name.trim() === '' || (zones[0]?.polygon.length ?? 0) < 3}
            onClick={() =>
              onSave({
                name,
                lgu_code: lguCode || undefined,
                active,
                boundary: zones[0] ?? { ...EMPTY_BOUNDARY, name },
              })
            }
          >
            {saving ? 'Saving…' : 'Save'}
          </Button>
        </div>
      </div>
    </div>
  );
}
