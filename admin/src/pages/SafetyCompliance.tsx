import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ShieldAlert, FileCheck, AlertTriangle } from 'lucide-react';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { KycDocPreview } from '@/components/super-admin/kyc/KycDocPreview';
import { usePermissions } from '@/hooks/usePermissions';
import {
  useIncidents, useKycQueue, useLtfrbCompliance,
  useResolveIncident, useUpdateKyc,
} from '@/hooks/useSafety';
import { useExportReport } from '@/hooks/useReports';
import type { Incident, KycEntry } from '@/types/super-admin';

function incidentTypeLabel(type: string): string {
  switch (type) {
    case 'sos_triggered': return 'SOS Triggered';
    case 'reported_incident': return 'Reported Incident';
    case 'safety_complaint': return 'Safety Complaint';
    default: return type;
  }
}

function severityVariant(severity: string | undefined): 'danger' | 'warning' | 'default' {
  switch (severity) {
    case 'high': return 'danger';
    case 'medium': return 'warning';
    default: return 'default';
  }
}

function incidentStatusVariant(status: string): 'success' | 'danger' | 'warning' | 'default' {
  switch (status) {
    case 'resolved': return 'success';
    case 'open': return 'danger';
    case 'escalated': return 'danger';
    case 'investigating': return 'warning';
    default: return 'default';
  }
}

function accreditationVariant(status: string): 'success' | 'warning' | 'danger' {
  switch (status) {
    case 'active': return 'success';
    case 'expiring': return 'warning';
    case 'expired': return 'danger';
    default: return 'success';
  }
}

interface ConfirmDialog {
  open: boolean;
  title: string;
  message: string;
  variant: 'danger' | 'success';
  onConfirm: () => void;
}

function ConfirmModal({ dialog, onClose }: { dialog: ConfirmDialog; onClose: () => void }) {
  if (!dialog.open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" role="dialog" aria-modal="true">
      <div className="bg-surface border border-border rounded-xl p-6 w-full max-w-sm shadow-xl space-y-4">
        <div className="flex items-center gap-3">
          <AlertTriangle className="w-5 h-5 text-warning flex-shrink-0" />
          <h2 className="text-base font-semibold text-text-main">{dialog.title}</h2>
        </div>
        <p className="text-sm text-text-muted">{dialog.message}</p>
        <div className="flex gap-3 justify-end">
          <Button variant="outline" size="sm" onClick={onClose}>Cancel</Button>
          <Button variant={dialog.variant} size="sm" onClick={() => { dialog.onConfirm(); onClose(); }}>
            Confirm
          </Button>
        </div>
      </div>
    </div>
  );
}

export function SafetyCompliance() {
  const { can } = usePermissions();
  const canWrite = can('safety_incidents', 'write');
  const writeDisabledTitle = canWrite ? undefined : 'You do not have write access';
  const incidentsQuery = useIncidents();
  const kycQuery = useKycQueue();
  const complianceQuery = useLtfrbCompliance();
  const resolveIncident = useResolveIncident();
  const updateKyc = useUpdateKyc();
  const exportReport = useExportReport();

  const incidents = (incidentsQuery.data ?? []) as Incident[];
  const kycQueue = (kycQuery.data ?? []) as KycEntry[];
  const compliance = complianceQuery.data as
    | import('@/types/openapi').components['schemas']['ComplianceData']
    | undefined;
  const loading = incidentsQuery.isPending || kycQuery.isPending || complianceQuery.isPending;

  const [confirm, setConfirm] = useState<ConfirmDialog>({
    open: false, title: '', message: '', variant: 'danger', onConfirm: () => {},
  });
  const closeConfirm = () => setConfirm(prev => ({ ...prev, open: false }));

  const [banner, setBanner] = useState<{ visible: boolean; message: string }>({
    visible: false,
    message: '',
  });
  const flashBanner = (message: string) => {
    setBanner({ visible: true, message });
    setTimeout(() => setBanner(s => ({ ...s, visible: false })), 3000);
  };

  const runUpdateKyc = async (id: string, status: 'approved' | 'rejected') => {
    try {
      await updateKyc.mutateAsync({ id, status });
      flashBanner(status === 'approved' ? 'KYC approved' : 'KYC rejected');
    } catch {
      flashBanner('Failed to update KYC');
    }
  };

  const approveDriver = (id: string, name: string) => {
    setConfirm({
      open: true,
      title: 'Approve KYC',
      message: `Approve KYC for ${name}? They will be verified and can start accepting rides.`,
      variant: 'success',
      onConfirm: () => runUpdateKyc(id, 'approved'),
    });
  };

  const rejectDriver = (id: string, name: string) => {
    setConfirm({
      open: true,
      title: 'Reject KYC',
      message: `Reject KYC for ${name}? They will be notified to resubmit their documents.`,
      variant: 'danger',
      onConfirm: () => runUpdateKyc(id, 'rejected'),
    });
  };

  const handleResolveIncident = (id: string) => {
    resolveIncident.mutate({ id, notes: 'Resolved via admin panel' });
  };

  const handleGenerateLtfrb = async () => {
    const res = await exportReport.mutateAsync({ type: 'ltfrb' }).catch(() => null);
    if (res?.url) window.open(res.url, '_blank');
  };

  return (
    <div className="space-y-6">
      <ConfirmModal dialog={confirm} onClose={closeConfirm} />

      <div className="flex flex-wrap justify-between items-center gap-3">
        <h1 className="text-2xl font-bold text-text-main">Safety & Compliance</h1>
        <SaveBanner visible={banner.visible} message={banner.message} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <ShieldAlert className="w-5 h-5 text-danger" />
              Emergency & Incident Log
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Incident ID</TableHead>
                  <TableHead>Type & Severity</TableHead>
                  <TableHead>Ride & Reporter</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={5} className="text-center py-10 text-text-muted">Loading...</TableCell>
                  </TableRow>
                ) : incidents.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} className="text-center py-10 text-text-muted">No incidents found.</TableCell>
                  </TableRow>
                ) : incidents.map((inc) => (
                  <TableRow key={inc.id}>
                    <TableCell>
                      <p className="font-medium text-text-main">{inc.id}</p>
                      <p className="text-xs text-text-muted">
                        {inc.created_at ? new Date(inc.created_at).toLocaleString('en-PH', { dateStyle: 'short', timeStyle: 'short' }) : '—'}
                      </p>
                    </TableCell>
                    <TableCell>
                      <p className="text-sm">{incidentTypeLabel(inc.type)}</p>
                      {inc.severity && (
                        <Badge variant={severityVariant(inc.severity)} className="mt-1">
                          {inc.severity.charAt(0).toUpperCase() + inc.severity.slice(1)}
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <p className="text-sm font-medium text-primary">{inc.ride_id}</p>
                      <p className="text-xs text-text-muted">By: {inc.triggered_by}</p>
                      {(inc.rider_name || inc.driver_name) && (
                        <p className="text-xs text-text-muted">
                          {inc.rider_name ?? inc.driver_name}
                        </p>
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge variant={incidentStatusVariant(inc.status)}>
                        {inc.status.charAt(0).toUpperCase() + inc.status.slice(1)}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      {inc.status !== 'resolved' ? (
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => handleResolveIncident(inc.id)}
                          disabled={!canWrite}
                          title={writeDisabledTitle}
                        >
                          Resolve
                        </Button>
                      ) : (
                        <Button size="sm" variant="ghost" disabled>Resolved</Button>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <FileCheck className="w-5 h-5 text-primary" />
                Driver KYC Queue
              </CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <p className="text-sm text-text-muted text-center py-6">Loading...</p>
              ) : kycQueue.length === 0 ? (
                <p className="text-sm text-text-muted text-center py-6">No pending KYC submissions.</p>
              ) : (
                <div className="space-y-4">
                  {kycQueue.map(driver => (
                    <div key={driver.id} className="p-4 bg-surface-hover rounded-lg border border-border">
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <p className="font-medium text-text-main">{driver.driver_name}</p>
                          <p className="text-xs text-text-muted">
                            ID: {driver.driver_id} • Submitted: {driver.submitted_at ? new Date(driver.submitted_at).toLocaleDateString('en-PH') : '—'}
                          </p>
                        </div>
                      </div>
                      <div className="mb-3">
                        <KycDocPreview docs={driver.docs ?? []} />
                      </div>
                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          variant="success"
                          className="w-full"
                          disabled={updateKyc.isPending || !canWrite}
                          title={writeDisabledTitle}
                          onClick={() => approveDriver(driver.id, driver.driver_name)}
                        >
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="danger"
                          className="w-full"
                          disabled={updateKyc.isPending || !canWrite}
                          title={writeDisabledTitle}
                          onClick={() => rejectDriver(driver.id, driver.driver_name)}
                        >
                          Reject
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <AlertTriangle className="w-5 h-5 text-warning" />
                LTFRB Compliance Status
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-muted">Accreditation Status</span>
                <Badge variant={compliance ? accreditationVariant(compliance.accreditation_status) : 'default'}>
                  {compliance ? compliance.accreditation_status.charAt(0).toUpperCase() + compliance.accreditation_status.slice(1) : '—'}
                </Badge>
              </div>
              {compliance?.accreditation_expiry && (
                <div className="flex justify-between items-center">
                  <span className="text-sm text-text-muted">Expiry Date</span>
                  <span className="text-sm text-text-main">
                    {new Date(compliance.accreditation_expiry).toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })}
                  </span>
                </div>
              )}
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-muted">Driver Compliance Rate</span>
                <span className="text-sm font-medium text-text-main">
                  {compliance != null ? `${compliance.driver_compliance_rate.toFixed(1)}%` : '—'}
                </span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-muted">Violations (Current Period)</span>
                <Badge variant={compliance && compliance.violation_count > 0 ? 'warning' : 'success'}>
                  {compliance != null ? compliance.violation_count : '—'}
                </Badge>
              </div>
              <Button
                variant="outline"
                className="w-full mt-2"
                onClick={handleGenerateLtfrb}
                disabled={!canWrite}
                title={writeDisabledTitle}
              >
                Generate LTFRB Report
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
