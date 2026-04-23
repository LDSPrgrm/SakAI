import React from 'react';
import { FileText } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { formatDate } from '@/utils/formatDate';
import type { components } from '@/types/openapi';

export type LtfrbData = components['schemas']['ComplianceData'];

export interface LtfrbReportsSectionProps {
  data: LtfrbData | null | undefined;
  onGenerateReport: () => void | Promise<void>;
}

function complianceBarColor(rate: number): string {
  if (rate >= 90) return 'bg-success';
  if (rate >= 75) return 'bg-warning';
  return 'bg-danger';
}

function ComplianceBar({ label, rate }: { label: string; rate: number }) {
  const pct = Math.max(0, Math.min(100, rate ?? 0));
  return (
    <div className="space-y-1">
      <div className="flex justify-between text-sm">
        <span className="text-text-muted">{label}</span>
        <span className="font-medium text-text-main">{pct.toFixed(1)}%</span>
      </div>
      <div className="h-2 w-full rounded-full bg-surface-hover">
        <div
          className={`h-2 rounded-full transition-all ${complianceBarColor(pct)}`}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}

function isExpiringSoon(dateStr?: string | null): boolean {
  if (!dateStr) return false;
  const due = new Date(dateStr);
  const diffDays = (due.getTime() - Date.now()) / (1000 * 60 * 60 * 24);
  return diffDays <= 30;
}

export function LtfrbReportsSection({ data, onGenerateReport }: LtfrbReportsSectionProps) {
  if (!data) {
    return (
      <Card>
        <CardContent className="py-10 text-center text-text-muted">
          Loading compliance data...
        </CardContent>
      </Card>
    );
  }

  const violationsOpen = data.violations_open ?? data.violation_count ?? 0;
  const violationsResolved = data.violations_resolved ?? 0;
  const rate = data.driver_compliance_rate ?? 0;
  const expiry = data.accreditation_expiry;
  const lastAudit = data.last_audit_at;

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-1">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">Accreditation Status</p>
          <div className="flex items-center gap-2 mt-1">
            <StatusBadge status={data.accreditation_status ?? 'pending'} />
            {expiry && (
              <span className={isExpiringSoon(expiry) ? 'text-warning text-sm font-medium' : 'text-sm text-text-muted'}>
                Expires {formatDate(expiry)}
                {isExpiringSoon(expiry) && <span className="ml-1.5 text-xs">(Expiring soon)</span>}
              </span>
            )}
          </div>
        </div>

        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-1">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">Violations</p>
          <div className="flex items-center gap-4 mt-1">
            <span className="text-lg font-bold text-danger">
              {violationsOpen}
              <span className="text-xs font-normal text-text-muted ml-1">open</span>
            </span>
            <span className="text-lg font-bold text-success">
              {violationsResolved}
              <span className="text-xs font-normal text-text-muted ml-1">resolved</span>
            </span>
          </div>
        </div>

        <div className="p-4 bg-surface-hover rounded-lg border border-border">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide mb-3">Compliance Rates</p>
          <div className="space-y-3">
            <ComplianceBar label="Driver Compliance" rate={rate} />
          </div>
        </div>

        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-3">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">Audit Schedule</p>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-text-muted">Last Audit</span>
              <span className="text-text-main">{lastAudit ? formatDate(lastAudit) : '—'}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-text-muted">Accreditation Expires</span>
              <span className={isExpiringSoon(expiry) ? 'text-warning font-medium' : 'text-text-main'}>
                {expiry ? formatDate(expiry) : '—'}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="flex justify-end">
        <Button variant="primary" onClick={onGenerateReport}>
          <FileText className="w-4 h-4 mr-2" />
          Generate LTFRB Report
        </Button>
      </div>
    </div>
  );
}
