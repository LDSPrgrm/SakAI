import React from 'react';
import { FileText } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { formatDate } from '@/utils/formatDate';

export interface LtfrbData {
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

function isReportDueSoon(dueDateStr: string): boolean {
  const due = new Date(dueDateStr);
  const now = new Date();
  const diffDays = (due.getTime() - now.getTime()) / (1000 * 60 * 60 * 24);
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

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-1">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">Accreditation Status</p>
          <div className="flex items-center gap-2 mt-1">
            <StatusBadge status={data.accreditation_status} />
            <span className="text-sm text-text-muted">
              Expires {formatDate(data.accreditation_expiry)}
            </span>
          </div>
        </div>

        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-1">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">Violations</p>
          <div className="flex items-center gap-4 mt-1">
            <span className="text-lg font-bold text-danger">
              {data.violations_open}
              <span className="text-xs font-normal text-text-muted ml-1">open</span>
            </span>
            <span className="text-lg font-bold text-success">
              {data.violations_resolved}
              <span className="text-xs font-normal text-text-muted ml-1">resolved</span>
            </span>
          </div>
        </div>

        <div className="p-4 bg-surface-hover rounded-lg border border-border">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide mb-3">Compliance Rates</p>
          <div className="space-y-3">
            <ComplianceBar label="Driver Compliance" rate={data.driver_compliance_rate} />
            <ComplianceBar label="Insurance Compliance" rate={data.insurance_compliance_rate} />
            <ComplianceBar label="Vehicle Inspection" rate={data.inspection_compliance_rate} />
          </div>
        </div>

        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-3">
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">Report Schedule</p>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-text-muted">Last Submitted</span>
              <span className="text-text-main">{formatDate(data.last_report_submitted)}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-text-muted">Next Due</span>
              <span className={isReportDueSoon(data.next_report_due) ? 'text-warning font-medium' : 'text-text-main'}>
                {formatDate(data.next_report_due)}
                {isReportDueSoon(data.next_report_due) && (
                  <span className="ml-1.5 text-xs">(Due soon)</span>
                )}
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
