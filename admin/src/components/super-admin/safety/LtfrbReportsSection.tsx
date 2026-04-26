import React from 'react';
import { FileText, ShieldCheck, AlertTriangle, BarChart3, CalendarClock } from 'lucide-react';
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

function ComplianceBar({ label, rate, hasData }: { label: string; rate: number; hasData: boolean }) {
  const pct = Math.max(0, Math.min(100, rate ?? 0));
  return (
    <div className="space-y-1.5">
      <div className="flex justify-between text-sm">
        <span className="text-text-muted">{label}</span>
        <span className="font-medium text-text-main">
          {hasData ? `${pct.toFixed(1)}%` : '—'}
        </span>
      </div>
      <div className="h-2 w-full rounded-full bg-background overflow-hidden">
        <div
          className={`h-2 rounded-full transition-all ${hasData ? complianceBarColor(pct) : 'bg-surface-hover'}`}
          style={{ width: hasData ? `${pct}%` : '100%' }}
        />
      </div>
    </div>
  );
}

// Backend returns Go zero time (year 1) when a record is absent. Treat any
// pre-2000 timestamp as "no data" rather than rendering "Dec 31, 1".
function isValidDate(dateStr?: string | null): boolean {
  if (!dateStr) return false;
  const d = new Date(dateStr);
  return !Number.isNaN(d.getTime()) && d.getFullYear() >= 2000;
}

function isExpiringSoon(dateStr?: string | null): boolean {
  if (!isValidDate(dateStr)) return false;
  const diffDays = (new Date(dateStr!).getTime() - Date.now()) / (1000 * 60 * 60 * 24);
  return diffDays <= 30 && diffDays >= 0;
}

function SectionCard({
  icon, title, action, children,
}: {
  icon: React.ReactNode;
  title: string;
  action?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="p-5 bg-surface-hover rounded-lg border border-border space-y-3 h-full">
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <span className="p-1.5 bg-background rounded-md">{icon}</span>
          <p className="text-xs text-text-muted font-medium uppercase tracking-wide">{title}</p>
        </div>
        {action}
      </div>
      {children}
    </div>
  );
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
  const hasComplianceRate = data.driver_compliance_rate != null;
  const expiry = data.accreditation_expiry;
  const lastAudit = data.last_audit_at;
  const expiryValid = isValidDate(expiry);
  const lastAuditValid = isValidDate(lastAudit);
  const expiringSoon = isExpiringSoon(expiry);

  return (
    <div className="space-y-5">
      {/* Action bar */}
      <div className="flex items-center justify-between gap-3">
        <p className="text-sm text-text-muted">
          Regulatory metrics for the current LTFRB reporting period.
        </p>
        <Button variant="primary" size="sm" onClick={onGenerateReport}>
          <FileText className="w-4 h-4 mr-2" />
          Generate LTFRB Report
        </Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <SectionCard icon={<ShieldCheck className="w-4 h-4 text-primary" />} title="Accreditation Status">
          <div className="flex flex-wrap items-center gap-2">
            <StatusBadge status={data.accreditation_status ?? 'pending'} />
            {expiryValid ? (
              <span className={expiringSoon ? 'text-warning text-sm font-medium' : 'text-sm text-text-muted'}>
                Expires {formatDate(expiry!)}
                {expiringSoon && <span className="ml-1.5 text-xs">(Expiring soon)</span>}
              </span>
            ) : (
              <span className="text-sm text-text-muted">No expiry on file</span>
            )}
          </div>
        </SectionCard>

        <SectionCard icon={<AlertTriangle className="w-4 h-4 text-danger" />} title="Violations">
          <div className="flex items-baseline gap-6">
            <div>
              <span className="text-2xl font-bold text-danger">{violationsOpen}</span>
              <span className="text-xs font-normal text-text-muted ml-1.5">open</span>
            </div>
            <div>
              <span className="text-2xl font-bold text-success">{violationsResolved}</span>
              <span className="text-xs font-normal text-text-muted ml-1.5">resolved</span>
            </div>
          </div>
        </SectionCard>

        <SectionCard icon={<BarChart3 className="w-4 h-4 text-success" />} title="Compliance Rates">
          <ComplianceBar label="Driver Compliance" rate={rate} hasData={hasComplianceRate} />
          {!hasComplianceRate && (
            <p className="text-xs text-text-muted">No measurements recorded yet.</p>
          )}
        </SectionCard>

        <SectionCard icon={<CalendarClock className="w-4 h-4 text-warning" />} title="Audit Schedule">
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-text-muted">Last Audit</span>
              <span className="text-text-main">
                {lastAuditValid ? formatDate(lastAudit!) : '—'}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-text-muted">Accreditation Expires</span>
              <span className={expiringSoon ? 'text-warning font-medium' : 'text-text-main'}>
                {expiryValid ? formatDate(expiry!) : '—'}
              </span>
            </div>
          </div>
        </SectionCard>
      </div>
    </div>
  );
}
