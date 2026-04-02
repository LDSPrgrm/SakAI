import React, { useEffect, useState } from 'react';
import { Download, Eye, Search, X } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/Card';
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
import { adminApi, AuditLogEntry } from '@/lib/admin-api';

// ── Helpers ───────────────────────────────────────────────────────────────────

type ActionType = AuditLogEntry['action'];

const ACTION_VARIANTS: Record<ActionType, 'info' | 'default' | 'danger' | 'success'> = {
  create: 'info',
  update: 'default',
  delete: 'danger',
  approve: 'success',
  reject: 'danger',
  login: 'default',
  logout: 'default',
};

const ACTION_OPTIONS: { value: string; label: string }[] = [
  { value: '', label: 'All Actions' },
  { value: 'create', label: 'Create' },
  { value: 'update', label: 'Update' },
  { value: 'delete', label: 'Delete' },
  { value: 'approve', label: 'Approve' },
  { value: 'reject', label: 'Reject' },
  { value: 'login', label: 'Login' },
  { value: 'logout', label: 'Logout' },
];

function formatTimestamp(iso: string | null | undefined): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('en-PH', {
    dateStyle: 'medium',
    timeStyle: 'short',
  });
}

function humanizeResourceType(type: string | null | undefined): string {
  if (!type) return '—';
  return type
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

function truncate(str: string | null | undefined, max = 24): string {
  if (!str) return '—';
  if (str.length <= max) return str;
  return str.slice(0, max) + '…';
}

function hasDiff(log: AuditLogEntry): boolean {
  return log.before_state !== null || log.after_state !== null;
}

// ── Diff View Modal ───────────────────────────────────────────────────────────

interface DiffModalProps {
  log: AuditLogEntry;
  onClose: () => void;
}

function DiffModal({ log, onClose }: DiffModalProps) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
      role="dialog"
      aria-modal="true"
      aria-label="Audit entry diff view"
    >
      <div className="bg-surface border border-border rounded-xl p-6 w-full max-w-2xl shadow-xl space-y-4 max-h-[90vh] overflow-y-auto">
        {/* Title */}
        <div className="flex items-start justify-between gap-3">
          <h2 className="text-base font-semibold text-text-main">
            Audit Entry —{' '}
            <span className="capitalize">{log.action}</span>{' '}
            {humanizeResourceType(log.resource_type)}
          </h2>
          <button
            onClick={onClose}
            className="text-text-muted hover:text-text-main transition-colors flex-shrink-0"
            aria-label="Close"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Meta */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm">
          <div>
            <span className="text-text-muted">Admin: </span>
            <span className="text-text-main">{log.actor_name}</span>
          </div>
          <div>
            <span className="text-text-muted">Timestamp: </span>
            <span className="text-text-main">{formatTimestamp(log.timestamp)}</span>
          </div>
          <div>
            <span className="text-text-muted">IP Address: </span>
            <span className="text-text-main font-mono text-xs">{log.ip_address}</span>
          </div>
          <div>
            <span className="text-text-muted">Resource ID: </span>
            <span className="text-text-main font-mono text-xs">{log.resource_id}</span>
          </div>
          {log.reason && (
            <div className="sm:col-span-2">
              <span className="text-text-muted">Reason: </span>
              <span className="text-text-main">{log.reason}</span>
            </div>
          )}
        </div>

        {/* Diff view */}
        {hasDiff(log) && (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <p className="text-sm font-medium text-danger mb-2">Before</p>
              <pre className="bg-background rounded-lg p-3 text-xs overflow-auto max-h-48 text-text-muted whitespace-pre-wrap break-all">
                {log.before_state !== null
                  ? JSON.stringify(log.before_state, null, 2)
                  : 'null'}
              </pre>
            </div>
            <div>
              <p className="text-sm font-medium text-success mb-2">After</p>
              <pre className="bg-background rounded-lg p-3 text-xs overflow-auto max-h-48 text-text-muted whitespace-pre-wrap break-all">
                {log.after_state !== null
                  ? JSON.stringify(log.after_state, null, 2)
                  : 'null'}
              </pre>
            </div>
          </div>
        )}

        <div className="flex justify-end pt-2">
          <Button variant="outline" size="sm" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>
    </div>
  );
}

// ── Main component ────────────────────────────────────────────────────────────

export function SAAuditLog() {
  const [logs, setLogs] = useState<AuditLogEntry[]>([]);
  const [search, setSearch] = useState('');
  const [actionFilter, setActionFilter] = useState('');
  const [selectedLog, setSelectedLog] = useState<AuditLogEntry | null>(null);

  useEffect(() => {
    adminApi.audit.getLogs().then(setLogs);
  }, []);

  const handleExportCsv = async () => {
    const csvContent = await adminApi.audit.exportCsv();
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `sakai-audit-log-${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  const filteredLogs = (logs || []).filter((log) => {
    const matchesSearch =
      !search ||
      (log.actor_name ?? '').toLowerCase().includes(search.toLowerCase()) ||
      (log.resource_type ?? '').toLowerCase().includes(search.toLowerCase());
    const matchesAction = !actionFilter || log.action === actionFilter;
    return matchesSearch && matchesAction;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">Audit Log</h1>
        <Button variant="outline" onClick={handleExportCsv}>
          <Download className="w-4 h-4 mr-2" />
          Export CSV
        </Button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="flex-1 min-w-48">
          <Input
            placeholder="Search by admin or resource type…"
            icon={<Search className="w-4 h-4" />}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select
          value={actionFilter}
          onChange={(e) => setActionFilter(e.target.value)}
          aria-label="Filter by action"
          className="bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
        >
          {ACTION_OPTIONS.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      </div>

      {/* Table */}
      <Card>
        <CardContent className="pt-6 px-0 overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Timestamp</TableHead>
                <TableHead>Admin</TableHead>
                <TableHead>Action</TableHead>
                <TableHead>Resource Type</TableHead>
                <TableHead>Resource ID</TableHead>
                <TableHead>Reason</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredLogs.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={7}
                    className="text-center text-text-muted py-10"
                  >
                    No audit log entries found.
                  </TableCell>
                </TableRow>
              ) : (
                filteredLogs.map((log) => (
                  <TableRow key={log.id}>
                    {/* Timestamp */}
                    <TableCell className="whitespace-nowrap text-sm text-text-muted">
                      {formatTimestamp(log.timestamp)}
                    </TableCell>

                    {/* Admin */}
                    <TableCell>
                      <p className="text-sm text-text-main font-medium">
                        {log.actor_name}
                      </p>
                      <p className="text-xs text-text-muted font-mono">
                        {log.ip_address}
                      </p>
                    </TableCell>

                    {/* Action */}
                    <TableCell>
                      <Badge variant={ACTION_VARIANTS[log.action]}>
                        {log.action}
                      </Badge>
                    </TableCell>

                    {/* Resource Type */}
                    <TableCell className="text-sm text-text-main capitalize whitespace-nowrap">
                      {humanizeResourceType(log.resource_type)}
                    </TableCell>

                    {/* Resource ID */}
                    <TableCell>
                      <span className="text-xs font-mono text-text-muted">
                        {truncate(log.resource_id, 20)}
                      </span>
                    </TableCell>

                    {/* Reason */}
                    <TableCell className="text-sm text-text-muted max-w-[160px]">
                      {log.reason ? truncate(log.reason, 32) : '—'}
                    </TableCell>

                    {/* Actions */}
                    <TableCell className="text-right">
                      {hasDiff(log) ? (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setSelectedLog(log)}
                          title="View diff"
                        >
                          <Eye className="w-4 h-4 mr-1" />
                          View Diff
                        </Button>
                      ) : null}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Diff modal */}
      {selectedLog && (
        <DiffModal log={selectedLog} onClose={() => setSelectedLog(null)} />
      )}
    </div>
  );
}
