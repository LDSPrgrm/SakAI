import React, { useMemo, useState } from 'react';
import {
  Search, Eye, Download, ShieldCheck, FileCheck2,
  AlertCircle, Siren, Users, Activity,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Checkbox } from '@/components/ui/Checkbox';
import { Select } from '@/components/ui/Select';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { EntityId } from '@/components/ui/EntityId';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { PageHeader } from '@/components/shared/PageHeader';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { SummaryCard } from '@/components/shared/SummaryCard';
import { KycDocPreview } from '@/components/super-admin/kyc/KycDocPreview';
import {
  useIncidents, useKycQueue, useLtfrbCompliance,
  useUpdateKyc, useBatchKyc,
} from '@/hooks/useSafety';
import { useExportReport } from '@/hooks/useReports';
import { formatDate } from '@/utils/formatDate';
import { csvRow } from '@/utils/csv';
import { LtfrbReportsSection, type LtfrbData } from '@/components/super-admin/safety/LtfrbReportsSection';
import { IncidentDetailModal } from '@/components/super-admin/modals/IncidentDetailModal';
import type { Incident, IncidentType, KycEntry } from '@/types/super-admin';

// ── Types ──────────────────────────────────────────────────────────────────────

type KycAction = 'approve' | 'reject';

interface KycConfirmState {
  open: boolean;
  entryId: string;
  driverName: string;
  action: KycAction;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function incidentTypeBadge(type: IncidentType) {
  if (type === 'sos_triggered') return <Badge variant="danger">SOS Triggered</Badge>;
  if (type === 'reported_incident') return <Badge variant="warning">Reported Incident</Badge>;
  return <Badge variant="default">Safety Complaint</Badge>;
}

const STATUS_FILTER_OPTIONS: { label: string; value: string }[] = [
  { label: 'All', value: '' },
  { label: 'Open', value: 'open' },
  { label: 'Investigating', value: 'investigating' },
  { label: 'Resolved', value: 'resolved' },
  { label: 'Escalated', value: 'escalated' },
];

const INCIDENT_CSV_HEADER = csvRow([
  'Incident ID', 'Created At', 'Ride ID', 'Triggered By',
  'Rider', 'Driver', 'Type', 'Status', 'Assigned To', 'Resolution Notes',
]);

// ── Component ─────────────────────────────────────────────────────────────────

export function SASafetyCompliance() {
  const incidentsQuery = useIncidents();
  const kycQuery = useKycQueue();
  const ltfrbQuery = useLtfrbCompliance();
  const updateKyc = useUpdateKyc();
  const batchKyc = useBatchKyc();
  const exportReport = useExportReport();

  const incidents = (incidentsQuery.data ?? []) as Incident[];
  const kycQueue = (kycQuery.data ?? []) as KycEntry[];
  const ltfrbData = (ltfrbQuery.data ?? null) as LtfrbData | null;

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [kycConfirm, setKycConfirm] = useState<KycConfirmState>({
    open: false,
    entryId: '',
    driverName: '',
    action: 'approve',
  });
  const [selectedIncidentId, setSelectedIncidentId] = useState<string | null>(null);
  const [selectedKycIds, setSelectedKycIds] = useState<Set<string>>(new Set());
  const batchKycLoading = batchKyc.isPending;
  const [banner, setBanner] = useState<{ visible: boolean; message: string }>({
    visible: false,
    message: '',
  });

  function flashBanner(message: string) {
    setBanner({ visible: true, message });
    setTimeout(() => setBanner((s) => ({ ...s, visible: false })), 3000);
  }

  // ── Derived counts ─────────────────────────────────────────────────────────

  const filteredIncidents = useMemo(
    () =>
      incidents.filter((inc) => {
        const q = search.toLowerCase();
        const matchesSearch =
          (inc.id ?? '').toLowerCase().includes(q) ||
          (inc.ride_id ?? '').toLowerCase().includes(q) ||
          (inc.rider_name ?? '').toLowerCase().includes(q) ||
          (inc.driver_name ?? '').toLowerCase().includes(q);
        const matchesStatus = statusFilter === '' || inc.status === statusFilter;
        return matchesSearch && matchesStatus;
      }),
    [incidents, search, statusFilter],
  );

  const pendingKycCount = kycQueue.filter((k) => k.status === 'pending').length;
  const openIncidentCount = incidents.filter(
    (i) => i.status === 'open' || i.status === 'investigating' || i.status === 'escalated',
  ).length;
  const sosActiveCount = incidents.filter(
    (i) => i.type === 'sos_triggered' && i.status !== 'resolved',
  ).length;
  const complianceRate = ltfrbData?.driver_compliance_rate ?? null;

  const incidentsLoading = incidentsQuery.isLoading;
  const kycLoading = kycQuery.isLoading;

  // ── KYC actions ───────────────────────────────────────────────────────────

  function openKycConfirm(entry: KycEntry, action: KycAction) {
    setKycConfirm({
      open: true,
      entryId: entry.id,
      driverName: entry.driver_name,
      action,
    });
  }

  async function handleKycConfirm() {
    const status = kycConfirm.action === 'approve' ? 'approved' : 'rejected';
    try {
      await updateKyc.mutateAsync({ id: kycConfirm.entryId, status });
      flashBanner(kycConfirm.action === 'approve' ? 'KYC approved' : 'KYC rejected');
    } catch {
      flashBanner('Failed to update KYC');
    }
  }

  async function handleBatchKyc(action: KycAction) {
    const ids = [...selectedKycIds];
    const status = action === 'approve' ? 'approved' : 'rejected';
    try {
      await batchKyc.mutateAsync({ ids, status });
      setSelectedKycIds(new Set());
      flashBanner(action === 'approve' ? `Approved ${ids.length} KYC entries` : `Rejected ${ids.length} KYC entries`);
    } catch {
      flashBanner('Batch KYC update failed');
    }
  }

  // ── LTFRB helpers ─────────────────────────────────────────────────────────

  async function handleGenerateReport() {
    const res = await exportReport.mutateAsync({ type: 'ltfrb' }).catch(() => null);
    if (res?.url) window.open(res.url, '_blank');
  }

  // ── Incident CSV export ───────────────────────────────────────────────────

  function downloadIncidentsCsv() {
    const rows = filteredIncidents.map((inc) =>
      csvRow([
        inc.id, inc.created_at, inc.ride_id, inc.triggered_by,
        inc.rider_name, inc.driver_name, inc.type, inc.status,
        inc.assigned_to, inc.resolution_notes,
      ]),
    );
    const blob = new Blob([[INCIDENT_CSV_HEADER, ...rows].join('\n')], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `incidents-${Date.now()}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }

  // ── Render ─────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6 p-6">
      <PageHeader
        title="Safety & Compliance"
        actions={<SaveBanner visible={banner.visible} message={banner.message} />}
      />

      {/* KPI cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <SummaryCard
          title="Open Incidents"
          value={incidentsLoading ? '—' : openIncidentCount.toLocaleString('en-PH')}
          icon={<AlertCircle className="w-5 h-5 text-warning" />}
        />
        <SummaryCard
          title="SOS Active"
          value={incidentsLoading ? '—' : sosActiveCount.toLocaleString('en-PH')}
          icon={<Siren className="w-5 h-5 text-danger" />}
        />
        <SummaryCard
          title="Pending KYC"
          value={kycLoading ? '—' : pendingKycCount.toLocaleString('en-PH')}
          icon={<Users className="w-5 h-5 text-primary" />}
        />
        <SummaryCard
          title="Driver Compliance"
          value={
            ltfrbQuery.isLoading || complianceRate == null
              ? '—'
              : `${complianceRate.toFixed(1)}%`
          }
          icon={<Activity className="w-5 h-5 text-success" />}
        />
      </div>

      <Tabs defaultValue="incidents">
        <TabsList className="mb-4">
          <TabsTrigger value="incidents">
            Incidents
            {incidents.length > 0 && (
              <span className="ml-1.5 inline-flex items-center justify-center w-5 h-5 rounded-full bg-danger/20 text-danger text-xs font-semibold">
                {incidents.length}
              </span>
            )}
          </TabsTrigger>
          <TabsTrigger value="kyc">
            KYC Queue
            {pendingKycCount > 0 && (
              <span className="ml-1.5 inline-flex items-center justify-center w-5 h-5 rounded-full bg-warning/20 text-warning text-xs font-semibold">
                {pendingKycCount}
              </span>
            )}
          </TabsTrigger>
          <TabsTrigger value="ltfrb">LTFRB Compliance</TabsTrigger>
        </TabsList>

        {/* ── Tab 1: Incidents ─────────────────────────────────────────────── */}
        <TabsContent value="incidents">
          <Card>
            <CardHeader>
              <div className="flex flex-col sm:flex-row sm:items-center gap-3">
                <CardTitle className="flex-1">Incident Log</CardTitle>
                <div className="flex items-center gap-2 flex-wrap">
                  <Input
                    placeholder="Search incidents..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    icon={<Search className="w-4 h-4" />}
                    className="w-52"
                  />
                  <Select
                    value={statusFilter}
                    onValueChange={setStatusFilter}
                    options={STATUS_FILTER_OPTIONS}
                    aria-label="Filter incidents by status"
                    className="w-40"
                  />
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={downloadIncidentsCsv}
                    disabled={incidentsLoading || filteredIncidents.length === 0}
                  >
                    <Download className="w-4 h-4 mr-1.5" />
                    Export CSV
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent className="p-0">
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Incident ID</TableHead>
                      <TableHead>Date</TableHead>
                      <TableHead>Ride ID</TableHead>
                      <TableHead>Triggered By</TableHead>
                      <TableHead>Parties</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Assigned To</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {incidentsLoading ? (
                      Array.from({ length: 5 }).map((_, i) => (
                        <TableRow key={`inc-skel-${i}`}>
                          {Array.from({ length: 9 }).map((__, j) => (
                            <TableCell key={j}>
                              <div className="h-4 bg-surface-hover rounded animate-pulse" />
                            </TableCell>
                          ))}
                        </TableRow>
                      ))
                    ) : filteredIncidents.length === 0 ? (
                      <TableRow>
                        <TableCell
                          colSpan={9}
                          className="text-center text-text-muted py-10"
                        >
                          <div className="flex flex-col items-center gap-2">
                            <ShieldCheck className="w-8 h-8 text-text-muted/60" />
                            <span>No incidents found.</span>
                          </div>
                        </TableCell>
                      </TableRow>
                    ) : (
                      filteredIncidents.map((inc) => (
                        <TableRow
                          key={inc.id}
                          className="cursor-pointer hover:bg-surface-hover/80"
                          onClick={() => inc.id && setSelectedIncidentId(inc.id)}
                        >
                          <TableCell className="text-sm font-medium text-text-main">
                            <EntityId displayId={(inc as any).display_id} uuid={inc.id} fallbackPrefix="INC" />
                          </TableCell>
                          <TableCell className="text-sm text-text-muted whitespace-nowrap">
                            {inc.created_at ? formatDate(inc.created_at) : '—'}
                          </TableCell>
                          <TableCell className="text-sm text-text-muted">
                            <EntityId displayId={(inc as any).ride_display_id} uuid={inc.ride_id} fallbackPrefix="RIDE" />
                          </TableCell>
                          <TableCell>
                            <Badge variant="default">
                              {inc.triggered_by === 'rider' ? 'Rider' : inc.triggered_by === 'driver' ? 'Driver' : 'Unknown'}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <span className="text-sm text-text-main">
                              {inc.rider_name ?? '—'}
                            </span>
                            <br />
                            <span className="text-xs text-text-muted">
                              {inc.driver_name ?? '—'}
                            </span>
                          </TableCell>
                          <TableCell>{inc.type ? incidentTypeBadge(inc.type) : '—'}</TableCell>
                          <TableCell>
                            <StatusBadge status={inc.status} />
                          </TableCell>
                          <TableCell className="text-sm">
                            {inc.assigned_to ? (
                              <span className="text-text-main">{inc.assigned_to_name || inc.assigned_to}</span>
                            ) : (
                              <span className="text-text-muted italic">Unassigned</span>
                            )}
                          </TableCell>
                          <TableCell>
                            <Button
                              variant="ghost"
                              size="icon"
                              title="View incident"
                              onClick={(e) => {
                                e.stopPropagation();
                                if (inc.id) setSelectedIncidentId(inc.id);
                              }}
                            >
                              <Eye className="w-4 h-4" />
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* ── Tab 2: KYC Queue ─────────────────────────────────────────────── */}
        <TabsContent value="kyc">
          <div className="space-y-3">
            {/* Bulk action toolbar */}
            {selectedKycIds.size > 0 && (
              <div className="flex items-center gap-2 p-3 bg-surface-hover rounded-lg border border-border">
                <span className="text-sm text-text-muted flex-1">
                  {selectedKycIds.size} selected
                </span>
                <Button
                  variant="success"
                  size="sm"
                  onClick={() => handleBatchKyc('approve')}
                  disabled={batchKycLoading}
                >
                  {batchKycLoading ? 'Processing…' : `Approve Selected (${selectedKycIds.size})`}
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  onClick={() => handleBatchKyc('reject')}
                  disabled={batchKycLoading}
                >
                  {batchKycLoading ? 'Processing…' : `Reject Selected (${selectedKycIds.size})`}
                </Button>
              </div>
            )}

            {kycLoading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <div
                  key={`kyc-skel-${i}`}
                  className="bg-surface-hover rounded-lg border border-border p-4 space-y-3"
                >
                  <div className="h-4 w-1/3 bg-background rounded animate-pulse" />
                  <div className="h-20 w-full bg-background rounded animate-pulse" />
                </div>
              ))
            ) : kycQueue.length === 0 ? (
              <Card>
                <CardContent className="py-10 text-center text-text-muted">
                  <div className="flex flex-col items-center gap-2">
                    <FileCheck2 className="w-8 h-8 text-text-muted/60" />
                    <span>No KYC entries in queue.</span>
                  </div>
                </CardContent>
              </Card>
            ) : (
              kycQueue.map((entry) => (
                <div
                  key={entry.id}
                  className="bg-surface-hover rounded-lg border border-border p-4 space-y-3 focus-within:ring-2 focus-within:ring-primary/30 transition-shadow"
                >
                  {/* Header row */}
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2 min-w-0">
                      {entry.status === 'pending' && (
                        <Checkbox
                          className="flex-shrink-0"
                          checked={selectedKycIds.has(entry.id)}
                          onCheckedChange={(checked) => {
                            setSelectedKycIds((prev) => {
                              const next = new Set(prev);
                              if (checked) next.add(entry.id);
                              else next.delete(entry.id);
                              return next;
                            });
                          }}
                          aria-label={`Select KYC entry for ${entry.driver_name ?? 'driver'}`}
                        />
                      )}
                      <div>
                        <p className="font-medium text-text-main">{entry.driver_name ?? 'Unknown Driver'}</p>
                        <p className="text-xs text-text-muted mt-0.5">
                          Submitted {entry.submitted_at ? formatDate(entry.submitted_at) : '—'}
                        </p>
                      </div>
                    </div>
                    <StatusBadge status={entry.status} />
                  </div>

                  {/* Documents */}
                  <KycDocPreview docs={entry.docs ?? []} />

                  {/* Actions — only show when pending */}
                  {entry.status === 'pending' && (
                    <div className="flex gap-2">
                      <Button
                        variant="success"
                        size="sm"
                        disabled={updateKyc.isPending}
                        onClick={() => openKycConfirm(entry, 'approve')}
                      >
                        Approve
                      </Button>
                      <Button
                        variant="danger"
                        size="sm"
                        disabled={updateKyc.isPending}
                        onClick={() => openKycConfirm(entry, 'reject')}
                      >
                        Reject
                      </Button>
                    </div>
                  )}
                </div>
              ))
            )}
          </div>
        </TabsContent>

        {/* ── Tab 3: LTFRB Compliance ──────────────────────────────────────── */}
        <TabsContent value="ltfrb">
          <LtfrbReportsSection data={ltfrbData} onGenerateReport={handleGenerateReport} />
        </TabsContent>
      </Tabs>

      {/* Incident detail modal */}
      <IncidentDetailModal
        open={!!selectedIncidentId}
        incidentId={selectedIncidentId}
        onClose={() => setSelectedIncidentId(null)}
      />

      {/* KYC Confirm Modal */}
      <ConfirmationModal
        open={kycConfirm.open}
        title={kycConfirm.action === 'approve' ? 'Approve KYC' : 'Reject KYC'}
        description={
          kycConfirm.action === 'approve'
            ? `Approve the KYC documents submitted by ${kycConfirm.driverName}?`
            : `Reject the KYC documents submitted by ${kycConfirm.driverName}? The driver will be notified.`
        }
        variant={kycConfirm.action === 'approve' ? 'success' : 'danger'}
        confirmLabel={kycConfirm.action === 'approve' ? 'Approve' : 'Reject'}
        onConfirm={() => {
          handleKycConfirm();
          setKycConfirm((s) => ({ ...s, open: false }));
        }}
        onCancel={() => setKycConfirm((s) => ({ ...s, open: false }))}
      />
    </div>
  );
}
