import React, { useState } from 'react';
import { Bell, Plus, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/Table';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import {
  useAlertRules, useAlertEvents,
  useCreateAlertRule, useUpdateAlertRule, useDeleteAlertRule,
} from '@/hooks/useAlerts';
import type { AlertRule, AlertRuleType } from '@/api/super-admin/alerts';
import { formatDate } from '@/utils/formatDate';

const TYPES: { value: AlertRuleType; label: string; defaults: Record<string, unknown> }[] = [
  { value: 'low_rating',        label: 'Low Rating',        defaults: { threshold: 3.0, window_days: 7 } },
  { value: 'high_cancellation', label: 'High Cancellation', defaults: { threshold_pct: 20, window_days: 7 } },
  { value: 'fraud_velocity',    label: 'Fraud Velocity',    defaults: { rides_per_hour: 10, window_hours: 1 } },
  { value: 'kyc_expiry',        label: 'KYC Expiry',        defaults: { days_before_expiry: 30 } },
];

function defaultsFor(type: AlertRuleType): Record<string, unknown> {
  return TYPES.find((t) => t.value === type)?.defaults ?? {};
}

export function AlertRulesTab() {
  const rulesQuery = useAlertRules();
  const eventsQuery = useAlertEvents(50);
  const createMut = useCreateAlertRule();
  const updateMut = useUpdateAlertRule();
  const deleteMut = useDeleteAlertRule();

  const rules = rulesQuery.data ?? [];
  const events = eventsQuery.data ?? [];

  const [editing, setEditing] = useState<AlertRule | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  function openNew() {
    setEditing({
      id: '',
      name: '',
      type: 'low_rating',
      enabled: true,
      config: defaultsFor('low_rating'),
    });
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Bell className="w-5 h-5 text-warning" />
          <h3 className="text-lg font-semibold text-text-main">Alert Rules</h3>
          <span className="text-sm text-text-muted">({rules.length})</span>
        </div>
        <Button size="sm" onClick={openNew}>
          <Plus className="w-4 h-4 mr-1" /> New Rule
        </Button>
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>Type</TableHead>
            <TableHead>Config</TableHead>
            <TableHead>Enabled</TableHead>
            <TableHead className="text-right">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rules.length === 0 ? (
            <TableRow>
              <TableCell colSpan={5} className="py-8 text-center text-text-muted">
                No alert rules configured.
              </TableCell>
            </TableRow>
          ) : (
            rules.map((r) => (
              <TableRow
                key={r.id}
                className="cursor-pointer hover:bg-surface-hover/80"
                onClick={() => setEditing(r)}
              >
                <TableCell className="font-medium text-text-main">{r.name}</TableCell>
                <TableCell>
                  <Badge variant="default">
                    {TYPES.find((t) => t.value === r.type)?.label ?? r.type}
                  </Badge>
                </TableCell>
                <TableCell className="text-xs text-text-muted font-mono">
                  {JSON.stringify(r.config)}
                </TableCell>
                <TableCell>
                  <Badge variant={r.enabled ? 'success' : 'default'}>
                    {r.enabled ? 'Enabled' : 'Paused'}
                  </Badge>
                </TableCell>
                <TableCell className="text-right">
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={(e) => {
                      e.stopPropagation();
                      setDeleteId(r.id);
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

      <div className="pt-4 border-t border-border">
        <h4 className="text-sm font-semibold text-text-main mb-2">Recent Events</h4>
        {events.length === 0 ? (
          <p className="text-xs text-text-muted">No alert events yet.</p>
        ) : (
          <ul className="space-y-1.5 text-xs">
            {events.map((ev) => (
              <li key={ev.id} className="text-text-muted">
                <span className="text-text-main">{formatDate(ev.fired_at)}</span>
                {' · '}
                {ev.subject_type || 'subject'}
                {ev.subject_id ? ` ${ev.subject_id.slice(0, 8)}` : ''}
                {' · '}
                <code className="font-mono">{JSON.stringify(ev.payload)}</code>
              </li>
            ))}
          </ul>
        )}
      </div>

      {editing && (
        <RuleModal
          value={editing}
          saving={createMut.isPending || updateMut.isPending}
          onClose={() => setEditing(null)}
          onSave={async (data) => {
            if (editing.id) {
              await updateMut.mutateAsync({ id: editing.id, data });
            } else {
              await createMut.mutateAsync(data);
            }
            setEditing(null);
          }}
        />
      )}

      <ConfirmationModal
        open={!!deleteId}
        title="Delete Alert Rule"
        description="This stops evaluation for this rule. Historical events are retained."
        variant="danger"
        confirmLabel="Delete"
        onConfirm={() => deleteId && deleteMut.mutateAsync(deleteId).then(() => setDeleteId(null))}
        onCancel={() => setDeleteId(null)}
      />
    </div>
  );
}

interface RuleModalProps {
  value: AlertRule;
  saving: boolean;
  onClose: () => void;
  onSave: (data: {
    name: string;
    type: AlertRuleType;
    enabled: boolean;
    config: Record<string, unknown>;
  }) => void;
}

function RuleModal({ value, saving, onClose, onSave }: RuleModalProps) {
  const [name, setName] = useState(value.name);
  const [type, setType] = useState<AlertRuleType>(value.type);
  const [enabled, setEnabled] = useState(value.enabled);
  const [configText, setConfigText] = useState(JSON.stringify(value.config, null, 2));
  const [error, setError] = useState('');

  function handleTypeChange(t: AlertRuleType) {
    setType(t);
    setConfigText(JSON.stringify(defaultsFor(t), null, 2));
  }

  function handleSave() {
    setError('');
    let parsed: Record<string, unknown>;
    try {
      parsed = JSON.parse(configText);
    } catch {
      setError('Config must be valid JSON.');
      return;
    }
    if (!name.trim()) {
      setError('Name is required.');
      return;
    }
    onSave({ name, type, enabled, config: parsed });
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-lg p-6 space-y-4 max-h-[90vh] overflow-y-auto">
        <h3 className="text-lg font-semibold text-text-main">
          {value.id ? 'Edit Alert Rule' : 'New Alert Rule'}
        </h3>
        <div className="space-y-3 text-sm">
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Name</label>
            <Input value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Type</label>
            <select
              value={type}
              onChange={(e) => handleTypeChange(e.target.value as AlertRuleType)}
              className="w-full h-10 rounded-lg border border-border bg-background px-3"
            >
              {TYPES.map((t) => (
                <option key={t.value} value={t.value}>{t.label}</option>
              ))}
            </select>
          </div>
          <label className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={enabled}
              onChange={(e) => setEnabled(e.target.checked)}
              className="w-4 h-4 accent-primary"
            />
            <span>Enabled — evaluator runs this rule every ~5 min</span>
          </label>
          <div>
            <label className="block text-xs uppercase tracking-wide text-text-muted mb-1">Config (JSON)</label>
            <textarea
              value={configText}
              onChange={(e) => setConfigText(e.target.value)}
              rows={6}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-xs font-mono"
            />
          </div>
          {error && <p className="text-xs text-danger">{error}</p>}
        </div>
        <div className="flex justify-end gap-2">
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button disabled={saving} onClick={handleSave}>
            {saving ? 'Saving…' : 'Save'}
          </Button>
        </div>
      </div>
    </div>
  );
}
