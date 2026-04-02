import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ShieldAlert, FileCheck, AlertTriangle } from 'lucide-react';

const initialIncidents = [
  { id: 'INC-001', date: '2026-04-01 16:30', rideId: 'RD-99284', reporter: 'Rider', type: 'Reported Incident', severity: 'Medium', status: 'Investigating' },
  { id: 'INC-002', date: '2026-04-01 10:15', rideId: 'RD-99102', reporter: 'Driver', type: 'SOS Triggered', severity: 'High', status: 'Open' },
  { id: 'INC-003', date: '2026-03-31 22:00', rideId: 'RD-98999', reporter: 'Rider', type: 'Lost Item', severity: 'Low', status: 'Resolved' },
];

const initialKycQueue = [
  { id: 'D-2002', name: 'Pedro Penduko', submitted: '2026-04-01', docs: ['License', 'OR/CR', 'NBI Clearance'] },
  { id: 'D-2005', name: 'Lito Lapid', submitted: '2026-03-31', docs: ['License', 'OR/CR'] },
];

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
          <Button
            variant={dialog.variant}
            size="sm"
            onClick={() => { dialog.onConfirm(); onClose(); }}
          >
            Confirm
          </Button>
        </div>
      </div>
    </div>
  );
}

export function SafetyCompliance() {
  const [kycQueue, setKycQueue] = useState(initialKycQueue);
  const [confirm, setConfirm] = useState<ConfirmDialog>({
    open: false, title: '', message: '', variant: 'danger', onConfirm: () => {},
  });

  const closeConfirm = () => setConfirm(prev => ({ ...prev, open: false }));

  const approveDriver = (id: string, name: string) => {
    setConfirm({
      open: true,
      title: 'Approve KYC',
      message: `Approve KYC for ${name}? They will be verified and can start accepting rides.`,
      variant: 'success',
      onConfirm: () => setKycQueue(prev => prev.filter(d => d.id !== id)),
    });
  };

  const rejectDriver = (id: string, name: string) => {
    setConfirm({
      open: true,
      title: 'Reject KYC',
      message: `Reject KYC for ${name}? They will be notified to resubmit their documents.`,
      variant: 'danger',
      onConfirm: () => setKycQueue(prev => prev.filter(d => d.id !== id)),
    });
  };

  return (
    <div className="space-y-6">
      <ConfirmModal dialog={confirm} onClose={closeConfirm} />

      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">Safety & Compliance</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <ShieldAlert className="w-5 h-5 text-danger" />
              Emergency & Incident Log
            </CardTitle>
            <Button variant="outline" size="sm">View All</Button>
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
                {initialIncidents.map((inc) => (
                  <TableRow key={inc.id}>
                    <TableCell>
                      <p className="font-medium text-text-main">{inc.id}</p>
                      <p className="text-xs text-text-muted">{inc.date}</p>
                    </TableCell>
                    <TableCell>
                      <p className="text-sm">{inc.type}</p>
                      <Badge
                        variant={inc.severity === 'High' ? 'danger' : inc.severity === 'Medium' ? 'warning' : 'default'}
                        className="mt-1"
                      >
                        {inc.severity}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <p className="text-sm font-medium text-primary">{inc.rideId}</p>
                      <p className="text-xs text-text-muted">By: {inc.reporter}</p>
                    </TableCell>
                    <TableCell>
                      <Badge variant={inc.status === 'Resolved' ? 'success' : inc.status === 'Open' ? 'danger' : 'warning'}>
                        {inc.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      <Button size="sm" variant="secondary">Review</Button>
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
              {kycQueue.length === 0 ? (
                <p className="text-sm text-text-muted text-center py-6">No pending KYC submissions.</p>
              ) : (
                <div className="space-y-4">
                  {kycQueue.map(driver => (
                    <div key={driver.id} className="p-4 bg-surface-hover rounded-lg border border-border">
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <p className="font-medium text-text-main">{driver.name}</p>
                          <p className="text-xs text-text-muted">ID: {driver.id} • Submitted: {driver.submitted}</p>
                        </div>
                      </div>
                      <div className="flex flex-wrap gap-1 mb-3">
                        {driver.docs.map(doc => (
                          <Badge key={doc} variant="default" className="text-[10px]">{doc}</Badge>
                        ))}
                      </div>
                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          variant="success"
                          className="w-full"
                          onClick={() => approveDriver(driver.id, driver.name)}
                        >
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="danger"
                          className="w-full"
                          onClick={() => rejectDriver(driver.id, driver.name)}
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
                <span className="text-sm text-text-muted">Accreditation Validity</span>
                <Badge variant="success">Valid until 2027</Badge>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-muted">Data Privacy Act (DPA)</span>
                <Badge variant="success">Compliant</Badge>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-muted">Pending Regulatory Reports</span>
                <Badge variant="warning">2 Due Soon</Badge>
              </div>
              <Button variant="outline" className="w-full mt-2">Generate LTFRB Report</Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
