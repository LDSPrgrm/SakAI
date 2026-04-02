import React, { useEffect, useState } from 'react';
import { Search, Eye, FileText } from 'lucide-react';
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
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { StatusBadge } from '@/components/shared/StatusBadge';
import {
  adminApi,
  Incident,
  IncidentStatus,
  IncidentType,
  KycEntry,
} from '@/lib/admin-api';

// ── Types ──────────────────────────────────────────────────────────────────────

interface LtfrbData {
  accreditation_status: string;
  accreditation_expiry: string;
  driver_compliance_rate: number;
  insurance_compliance_rate: number;
  inspection_compliance_rate: number;
  violations_open: number;
  violations_resolved: number;
  last_report_submitted: string;
  next_report_due: string;
}

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

function complianceBarColor(rate: number): string {
  if (rate >= 90) return 'bg-success';
  if (rate >= 75) return 'bg-warning';
  return 'bg-danger';
}

function ComplianceBar({ label, rate }: { label: string; rate: number }) {
  return (
    <div className="space-y-1">
      <div className="flex justify-between text-sm">
        <span className="text-text-muted">{label}</span>
        <span className="font-medium text-text-main">{rate}%</span>
      </div>
      <div className="h-2 w-full rounded-full bg-surface-hover">
        <div
          className={`h-2 rounded-full transition-all ${complianceBarColor(rate)}`}
          style={{ width: `${rate}%` }}
        />
      </div>
    </div>
  );
}

const STATUS_FILTER_OPTIONS: { label: string; value: string }[] = [
  { label: 'All', value: '' },
  { label: 'Open', value: 'open' },
  { label: 'Investigating', value: 'investigating' },
  { label: 'Resolved', value: 'resolved' },
  { label: 'Escalated', value: 'escalated' },
];

// ── Component ─────────────────────────────────────────────────────────────────

export function SASafetyCompliance() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [kycQueue, setKycQueue] = useState<KycEntry[]>([]);
  const [ltfrbData, setLtfrbData] = useState<LtfrbData | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [kycConfirm, setKycConfirm] = useState<KycConfirmState>({
    open: false,
    entryId: '',
    driverName: '',
    action: 'approve',
  });

  // ── Load data ──────────────────────────────────────────────────────────────

  useEffect(() => {
    async function load() {
      const [inc, kyc, ltfrb] = await Promise.all([
        adminApi.safety.getIncidents(),
        adminApi.safety.getKycQueue(),
        adminApi.safety.getLtfrbCompliance(),
      ]);
      setIncidents(inc);
      setKycQueue(kyc);
      setLtfrbData(ltfrb as LtfrbData);
    }
    void load();
  }, []);

  // ── Derived counts ─────────────────────────────────────────────────────────

  const filteredIncidents = incidents.filter((inc) => {
    const q = search.toLowerCase();
    const matchesSearch =
      inc.id.toLowerCase().includes(q) ||
      inc.ride_id.toLowerCase().includes(q) ||
      inc.rider_name.toLowerCase().includes(q) ||
      inc.driver_name.toLowerCase().includes(q);
    const matchesStatus = statusFilter === '' || inc.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const pendingKycCount = kycQueue.filter((k) => k.status === 'pending').length;

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
    const updated = await adminApi.safety.updateKyc(kycConfirm.entryId, status);
    setKycQueue((prev) =>
      prev.map((k) => (k.id === updated.id ? updated : k))
    );
  }

  // ── LTFRB helpers ─────────────────────────────────────────────────────────

  function isReportDueSoon(dueDateStr: string): boolean {
    const due = new Date(dueDateStr);
    const now = new Date();
    const diffDays = (due.getTime() - now.getTime()) / (1000 * 60 * 60 * 24);
    return diffDays <= 30;
  }

  function fmtDate(dateStr: string): string {
    return new Date(dateStr).toLocaleDateString('en-PH', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  }

  function handleGenerateReport() {
    // Placeholder — connect to real export API when backend ships
    alert('Generating LTFRB report…');
  }

  // ── Render ─────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6 p-6">
      <h1 className="text-2xl font-bold text-text-main">Safety & Compliance</h1>

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
                  <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="h-10 rounded-lg border border-border bg-background px-3 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    {STATUS_FILTER_OPTIONS.map((opt) => (
                      <option key={opt.value} value={opt.value}>
                        {opt.label}
                      </option>
                    ))}
                  </select>
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
                    {filteredIncidents.length === 0 ? (
                      <TableRow>
                        <TableCell
                          colSpan={9}
                          className="text-center text-text-muted py-10"
                        >
                          No incidents found.
                        </TableCell>
                      </TableRow>
                    ) : (
                      filteredIncidents.map((inc) => (
                        <TableRow key={inc.id}>
                          <TableCell className="text-sm font-medium text-text-main">
                            {inc.id}
                          </TableCell>
                          <TableCell className="text-sm text-text-muted whitespace-nowrap">
                            {fmtDate(inc.created_at)}
                          </TableCell>
                          <TableCell className="text-sm text-text-muted">
                            {inc.ride_id}
                          </TableCell>
                          <TableCell>
                            <Badge variant="default">
                              {inc.triggered_by === 'rider' ? 'Rider' : 'Driver'}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <span className="text-sm text-text-main">
                              {inc.rider_name}
                            </span>
                            <br />
                            <span className="text-xs text-text-muted">
                              {inc.driver_name}
                            </span>
                          </TableCell>
                          <TableCell>{incidentTypeBadge(inc.type)}</TableCell>
                          <TableCell>
                            <StatusBadge status={inc.status} />
                          </TableCell>
                          <TableCell className="text-sm">
                            {inc.assigned_to ? (
                              <span className="text-text-main">{inc.assigned_to}</span>
                            ) : (
                              <span className="text-text-muted italic">Unassigned</span>
                            )}
                          </TableCell>
                          <TableCell>
                            <Button variant="ghost" size="icon" title="View incident">
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
            {kycQueue.length === 0 ? (
              <Card>
                <CardContent className="py-10 text-center text-text-muted">
                  No KYC entries in queue.
                </CardContent>
              </Card>
            ) : (
              kycQueue.map((entry) => (
                <div
                  key={entry.id}
                  className="bg-surface-hover rounded-lg border border-border p-4 space-y-3"
                >
                  {/* Header row */}
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className="font-medium text-text-main">{entry.driver_name}</p>
                      <p className="text-xs text-text-muted mt-0.5">
                        Submitted {fmtDate(entry.submitted_at)}
                      </p>
                    </div>
                    <StatusBadge status={entry.status} />
                  </div>

                  {/* Documents */}
                  <div className="flex flex-wrap gap-1.5">
                    {entry.docs.map((doc) => (
                      <Badge key={doc} variant="default">
                        {doc}
                      </Badge>
                    ))}
                  </div>

                  {/* Actions — only show when pending */}
                  {entry.status === 'pending' && (
                    <div className="flex gap-2">
                      <Button
                        variant="success"
                        size="sm"
                        onClick={() => openKycConfirm(entry, 'approve')}
                      >
                        Approve
                      </Button>
                      <Button
                        variant="danger"
                        size="sm"
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
          {!ltfrbData ? (
            <Card>
              <CardContent className="py-10 text-center text-text-muted">
                Loading compliance data...
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">

                {/* Accreditation Status */}
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-1">
                  <p className="text-xs text-text-muted font-medium uppercase tracking-wide">
                    Accreditation Status
                  </p>
                  <div className="flex items-center gap-2 mt-1">
                    <StatusBadge status={ltfrbData.accreditation_status} />
                    <span className="text-sm text-text-muted">
                      Expires {fmtDate(ltfrbData.accreditation_expiry)}
                    </span>
                  </div>
                </div>

                {/* Open Violations */}
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-1">
                  <p className="text-xs text-text-muted font-medium uppercase tracking-wide">
                    Violations
                  </p>
                  <div className="flex items-center gap-4 mt-1">
                    <span className="text-lg font-bold text-danger">
                      {ltfrbData.violations_open}
                      <span className="text-xs font-normal text-text-muted ml-1">open</span>
                    </span>
                    <span className="text-lg font-bold text-success">
                      {ltfrbData.violations_resolved}
                      <span className="text-xs font-normal text-text-muted ml-1">resolved</span>
                    </span>
                  </div>
                </div>

                {/* Driver Compliance Rate */}
                <div className="p-4 bg-surface-hover rounded-lg border border-border">
                  <p className="text-xs text-text-muted font-medium uppercase tracking-wide mb-3">
                    Compliance Rates
                  </p>
                  <div className="space-y-3">
                    <ComplianceBar
                      label="Driver Compliance"
                      rate={ltfrbData.driver_compliance_rate}
                    />
                    <ComplianceBar
                      label="Insurance Compliance"
                      rate={ltfrbData.insurance_compliance_rate}
                    />
                    <ComplianceBar
                      label="Vehicle Inspection"
                      rate={ltfrbData.inspection_compliance_rate}
                    />
                  </div>
                </div>

                {/* Report Dates */}
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-3">
                  <p className="text-xs text-text-muted font-medium uppercase tracking-wide">
                    Report Schedule
                  </p>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-text-muted">Last Submitted</span>
                      <span className="text-text-main">
                        {fmtDate(ltfrbData.last_report_submitted)}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-text-muted">Next Due</span>
                      <span
                        className={
                          isReportDueSoon(ltfrbData.next_report_due)
                            ? 'text-warning font-medium'
                            : 'text-text-main'
                        }
                      >
                        {fmtDate(ltfrbData.next_report_due)}
                        {isReportDueSoon(ltfrbData.next_report_due) && (
                          <span className="ml-1.5 text-xs">(Due soon)</span>
                        )}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Generate Report button */}
              <div className="flex justify-end">
                <Button variant="primary" onClick={handleGenerateReport}>
                  <FileText className="w-4 h-4 mr-2" />
                  Generate LTFRB Report
                </Button>
              </div>
            </div>
          )}
        </TabsContent>
      </Tabs>

      {/* KYC Confirm Modal */}
      <ConfirmModal
        open={kycConfirm.open}
        title={kycConfirm.action === 'approve' ? 'Approve KYC' : 'Reject KYC'}
        message={
          kycConfirm.action === 'approve'
            ? `Approve the KYC documents submitted by ${kycConfirm.driverName}?`
            : `Reject the KYC documents submitted by ${kycConfirm.driverName}? The driver will be notified.`
        }
        variant={kycConfirm.action === 'approve' ? 'success' : 'danger'}
        confirmLabel={kycConfirm.action === 'approve' ? 'Approve' : 'Reject'}
        onConfirm={handleKycConfirm}
        onClose={() => setKycConfirm((s) => ({ ...s, open: false }))}
      />
    </div>
  );
}
