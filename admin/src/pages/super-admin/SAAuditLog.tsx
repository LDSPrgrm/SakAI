import { useEffect, useRef, useState } from 'react';
import {
  Check,
  Download,
  Eye,
  FileSearch,
  LogIn,
  LogOut,
  Pencil,
  Plus,
  Search,
  SearchX,
  Trash2,
  X,
  Zap,
  type LucideIcon,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { EntityId } from '@/components/ui/EntityId';
import { prefixFor } from '@/utils/resourceTypeToPrefix';
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
import { Select } from '@/components/ui/Select';
import { useAuditLog, useExportAuditLog } from '@/hooks/useAuditLog';
import { useAdmins } from '@/hooks/useAdmins';
import { useFocusTrap } from '@/hooks/useFocusTrap';
import { computeChangedKeys } from '@/utils/objectDiff';
import { cn } from '@/lib/utils';
import type { AuditLogEntry } from '@/types/super-admin';

// ── Helpers ───────────────────────────────────────────────────────────────────

type ActionType = AuditLogEntry['action'];

const ACTION_VARIANTS: Record<string, 'info' | 'default' | 'danger' | 'success' | 'warning'> = {
  create: 'info',
  update: 'default',
  update_surge: 'warning',
  delete: 'danger',
  approve: 'success',
  reject: 'danger',
  login: 'default',
  logout: 'default',
};

const ACTION_ICONS: Record<string, LucideIcon> = {
  create: Plus,
  update: Pencil,
  update_surge: Zap,
  delete: Trash2,
  approve: Check,
  reject: X,
  login: LogIn,
  logout: LogOut,
};

const QUICK_FILTERS: { value: string; label: string }[] = [
  { value: '', label: 'All' },
  { value: 'update', label: 'Update' },
  { value: 'update_surge', label: 'Update Surge' },
  { value: 'approve', label: 'Approve' },
  { value: 'reject', label: 'Reject' },
];

function actionVariant(action: ActionType | string | null | undefined) {
  if (!action) return 'default' as const;
  return ACTION_VARIANTS[String(action).toLowerCase()] ?? 'default';
}

function actionIcon(action: ActionType | string | null | undefined): LucideIcon | null {
  if (!action) return null;
  return ACTION_ICONS[String(action).toLowerCase()] ?? null;
}

function humanizeAction(action: ActionType | string | null | undefined): string {
  if (!action) return '—';
  return String(action)
    .toLowerCase()
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

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

function hasDiff(log: AuditLogEntry): boolean {
  return log.before_state !== null || log.after_state !== null;
}

function asRecord(value: unknown): Record<string, unknown> | null {
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
        return parsed as Record<string, unknown>;
      }
    } catch {
      // not JSON — fall through to null
    }
    return null;
  }
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return null;
}

// ── Diff View Modal ───────────────────────────────────────────────────────────

interface DiffModalProps {
  open: boolean;
  log: AuditLogEntry | null;
  onClose: () => void;
}

interface DiffSideProps {
  state: Record<string, unknown> | null;
  changedKeys: Set<string>;
  tone: 'before' | 'after';
}

function DiffSide({ state, changedKeys, tone }: DiffSideProps) {
  if (state === null) {
    const message = tone === 'before' ? 'No prior state' : 'No resulting state';
    return (
      <div className="bg-background rounded-lg p-3 text-xs text-text-muted italic">
        {message}
      </div>
    );
  }

  const allKeys = Array.from(
    new Set([...Object.keys(state), ...Array.from(changedKeys)]),
  );
  const sortedKeys = allKeys.sort((a, b) => {
    const aChanged = changedKeys.has(a);
    const bChanged = changedKeys.has(b);
    if (aChanged !== bChanged) return aChanged ? -1 : 1;
    return a.localeCompare(b);
  });

  const borderClass = tone === 'before' ? 'border-danger/60' : 'border-success/60';

  return (
    <div className="bg-background rounded-lg p-2 max-h-64 overflow-auto space-y-1">
      {sortedKeys.length === 0 && (
        <p className="text-xs text-text-muted px-2 py-1">{`{}`}</p>
      )}
      {sortedKeys.map((key) => {
        const changed = changedKeys.has(key);
        const value = state[key];
        const present = key in state;
        return (
          <div
            key={key}
            className={cn(
              'border-l-2 pl-2 pr-1 py-1 rounded-r',
              changed ? borderClass : 'border-transparent',
              changed ? 'bg-surface-hover/40' : '',
            )}
          >
            <p className="text-[11px] font-mono text-text-muted">{key}</p>
            <pre className="text-xs whitespace-pre-wrap break-all text-text-main">
              {present ? JSON.stringify(value, null, 2) : '—'}
            </pre>
          </div>
        );
      })}
    </div>
  );
}

function DiffModal({ open, log, onClose }: DiffModalProps) {
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    function onKey(event: KeyboardEvent) {
      if (event.key === 'Escape') onClose();
    }
    document.addEventListener('keydown', onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [open, onClose]);

  useEffect(() => {
    if (open) panelRef.current?.focus();
  }, [open]);

  useFocusTrap(panelRef, open);

  if (!open || !log) return null;

  const before = asRecord(log.before_state);
  const after = asRecord(log.after_state);
  const changedKeys = computeChangedKeys(before, after);
  const showDiff = hasDiff(log);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-label="Audit entry diff view"
    >
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div
        ref={panelRef}
        tabIndex={-1}
        className="relative bg-surface border border-border rounded-xl shadow-xl w-full max-w-2xl p-6 space-y-4 max-h-[90vh] overflow-y-auto focus:outline-none"
      >
        {/* Title */}
        <div className="flex items-start justify-between gap-3">
          <h2 className="text-base font-semibold text-text-main">
            Audit Entry —{' '}
            <span className="capitalize">{log.action}</span>{' '}
            {humanizeResourceType(log.resource_type)}
          </h2>
          <button
            onClick={onClose}
            className="text-text-muted hover:text-text-main rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-surface transition-colors flex-shrink-0"
            aria-label="Close"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Meta */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm">
          <div>
            <span className="text-text-muted">Admin: </span>
            <span className="text-text-main">{log.actor_name || <span className="italic text-text-muted">System</span>}</span>
            {log.actor_id && (
              <span className="ml-2 inline-flex">
                <EntityId displayId={log.actor_display_id} uuid={log.actor_id} fallbackPrefix="USR" />
              </span>
            )}
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
            <EntityId uuid={log.resource_id} fallbackPrefix={prefixFor(log.resource_type)} />
          </div>
          {log.reason && (
            <div className="sm:col-span-2">
              <span className="text-text-muted">Reason: </span>
              <span className="text-text-main">{log.reason}</span>
            </div>
          )}
        </div>

        {/* Diff view */}
        {showDiff && (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <p className="text-sm font-medium text-danger mb-2">Before</p>
              <DiffSide state={before} changedKeys={changedKeys} tone="before" />
            </div>
            <div>
              <p className="text-sm font-medium text-success mb-2">After</p>
              <DiffSide state={after} changedKeys={changedKeys} tone="after" />
            </div>
          </div>
        )}

        <div className="flex justify-end pt-3 mt-3 border-t border-border">
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
  const logsQuery = useAuditLog();
  const adminsQuery = useAdmins();
  const exportMutation = useExportAuditLog();
  const [search, setSearch] = useState('');
  const [actionFilter, setActionFilter] = useState('');
  const [selectedLog, setSelectedLog] = useState<AuditLogEntry | null>(null);

  const logs = (logsQuery.data ?? []) as unknown as AuditLogEntry[];
  const isLoading = logsQuery.isLoading;
  const roleByActorId = new Map(
    (adminsQuery.data ?? [])
      .filter((a) => a.id && a.role_name)
      .map((a) => [a.id!, a.role_name!] as const),
  );
  const handleExportCsv = () => exportMutation.mutate();

  const filteredLogs = logs.filter((log) => {
    const matchesSearch =
      !search ||
      (log.actor_name ?? '').toLowerCase().includes(search.toLowerCase()) ||
      (log.resource_type ?? '').toLowerCase().includes(search.toLowerCase());
    const matchesAction = !actionFilter || String(log.action).toLowerCase() === actionFilter;
    return matchesSearch && matchesAction;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">Audit Log</h1>
        <Button
          variant="outline"
          onClick={handleExportCsv}
          disabled={exportMutation.isPending || logs.length === 0}
        >
          <Download className="w-4 h-4 mr-2" />
          Export CSV
        </Button>
      </div>

      {/* Table */}
      <Card>
        <CardHeader>
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
            <div className="flex items-center gap-3">
              <CardTitle>Activity</CardTitle>
              {!isLoading && (
                <Badge variant="default">
                  {filteredLogs.length.toLocaleString('en-PH')}{' '}
                  {filteredLogs.length === 1 ? 'entry' : 'entries'}
                </Badge>
              )}
            </div>
            <div className="flex flex-col sm:flex-row sm:items-center gap-2">
              <Input
                placeholder="Search by admin or resource type…"
                icon={<Search className="w-4 h-4" />}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full sm:w-64"
              />
              <Select
                value={actionFilter}
                onValueChange={setActionFilter}
                options={ACTION_OPTIONS}
                aria-label="Filter by action"
                className="w-full sm:w-44"
              />
            </div>
          </div>
          <div className="mt-4 flex flex-wrap items-center gap-2 overflow-x-auto">
            {QUICK_FILTERS.map((opt) => {
              const Icon = opt.value ? actionIcon(opt.value) : null;
              const active = actionFilter === opt.value;
              return (
                <button
                  key={opt.value || 'all'}
                  type="button"
                  onClick={() => setActionFilter(opt.value)}
                  className={cn(
                    'inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60',
                    active
                      ? 'bg-primary text-white border-primary'
                      : 'bg-surface-hover text-text-muted border-border hover:text-text-main hover:border-text-muted/40',
                  )}
                >
                  {Icon && <Icon className="w-3 h-3" />}
                  {opt.label}
                </button>
              );
            })}
          </div>
        </CardHeader>
        <CardContent className="p-0 overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Timestamp</TableHead>
                <TableHead>Admin</TableHead>
                <TableHead>Action</TableHead>
                <TableHead>Resource Type</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 6 }).map((_, i) => (
                  <TableRow key={`audit-skel-${i}`}>
                    {Array.from({ length: 7 }).map((__, j) => (
                      <TableCell key={j}>
                        <div className="h-4 bg-surface-hover rounded animate-pulse" />
                      </TableCell>
                    ))}
                  </TableRow>
                ))
              ) : filteredLogs.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={7}
                    className="text-center text-text-muted py-10"
                  >
                    {logs.length === 0 ? (
                      <div className="flex flex-col items-center gap-2">
                        <FileSearch className="w-8 h-8 text-text-muted/60" />
                        <span>No audit log entries found.</span>
                      </div>
                    ) : (
                      <div className="flex flex-col items-center gap-3">
                        <SearchX className="w-8 h-8 text-text-muted/60" />
                        <span>No entries match your filters.</span>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => {
                            setSearch('');
                            setActionFilter('');
                          }}
                        >
                          Clear filters
                        </Button>
                      </div>
                    )}
                  </TableCell>
                </TableRow>
              ) : (
                filteredLogs.map((log) => {
                  const rowHasDiff = hasDiff(log);
                  return (
                  <TableRow
                    key={log.id}
                    className={rowHasDiff
                      ? 'cursor-pointer hover:bg-surface-hover/60 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60'
                      : undefined}
                    tabIndex={rowHasDiff ? 0 : undefined}
                    onClick={rowHasDiff ? () => setSelectedLog(log) : undefined}
                    onKeyDown={rowHasDiff
                      ? (e) => {
                          if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            setSelectedLog(log);
                          }
                        }
                      : undefined}
                  >
                    {/* Timestamp */}
                    <TableCell className="whitespace-nowrap text-sm text-text-muted">
                      {formatTimestamp(log.timestamp)}
                    </TableCell>

                    {/* Admin */}
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <p className="text-sm text-text-main font-medium">
                          {log.actor_name || <span className="italic text-text-muted">System</span>}
                        </p>
                        {log.actor_id && roleByActorId.get(log.actor_id) && (
                          <Badge variant="default" className="text-[10px] px-1.5 py-0">
                            {roleByActorId.get(log.actor_id)}
                          </Badge>
                        )}
                      </div>
                      {log.actor_id && (
                        <div className="mt-0.5">
                          <EntityId
                            displayId={log.actor_display_id}
                            uuid={log.actor_id}
                            fallbackPrefix="USR"
                          />
                        </div>
                      )}
                    </TableCell>

                    {/* Action */}
                    <TableCell>
                      {(() => {
                        const Icon = actionIcon(log.action);
                        return (
                          <Badge variant={actionVariant(log.action)} className="gap-1">
                            {Icon && <Icon className="w-3 h-3" />}
                            {humanizeAction(log.action)}
                          </Badge>
                        );
                      })()}
                    </TableCell>

                    {/* Resource Type */}
                    <TableCell className="text-sm text-text-main capitalize whitespace-nowrap">
                      {humanizeResourceType(log.resource_type)}
                    </TableCell>

                    {/* Actions */}
                    <TableCell className="text-right">
                      {rowHasDiff ? (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedLog(log);
                          }}
                          title="View diff"
                        >
                          <Eye className="w-4 h-4 mr-1" />
                          View Diff
                        </Button>
                      ) : null}
                    </TableCell>
                  </TableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Diff modal */}
      <DiffModal
        open={!!selectedLog}
        log={selectedLog}
        onClose={() => setSelectedLog(null)}
      />
    </div>
  );
}
