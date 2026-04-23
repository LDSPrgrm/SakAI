import React, { useEffect, useState } from 'react';
import { Eye, EyeOff, CheckCircle, XCircle, Loader2, Lock } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { AlertRulesTab } from '@/components/super-admin/system/AlertRulesTab';
import { Badge } from '@/components/ui/Badge';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { StatusBadge } from '@/components/shared/StatusBadge';
import {
  useIntegrations, useNotificationTemplates, useFeatureFlags,
  useUpdateIntegration, useTestIntegration, useUpdateTemplate, useToggleFlag,
} from '@/hooks/useSystem';
import type { Integration, IntegrationTestResult } from '@/api/super-admin/system';
import type { FeatureFlag } from '@/types/super-admin';
import { maskApiKey } from '@/utils/maskApiKey';
import { ChangePasswordForm } from '@/components/super-admin/system/ChangePasswordForm';

// ── Local types ───────────────────────────────────────────────────────────────

interface NotificationTemplate {
  event: string;
  channel: string;
  body: string;
}

const SERVICE_LABELS: Record<string, string> = {
  google_maps: 'Google Maps',
  twilio: 'Twilio SMS',
  firebase: 'Firebase FCM',
  background_check: 'Background Check',
  cloud_storage: 'Cloud Storage (S3)',
  stripe: 'Stripe',
  gcash: 'GCash',
  paymaya: 'PayMaya',
  mapbox: 'Mapbox',
};

interface FieldSchema {
  key: string;
  label: string;
  secret?: boolean;
  placeholder?: string;
}

// Per-provider field schema. Falls back to a single `api_key` input for any
// provider not listed here, preserving the pre-2.6 single-key UX for unknown
// services while making the known ones fully configurable.
const INTEGRATION_SCHEMAS: Record<string, FieldSchema[]> = {
  stripe: [
    { key: 'api_key', label: 'API Key', secret: true, placeholder: 'sk_live_…' },
    { key: 'webhook_secret', label: 'Webhook Secret', secret: true, placeholder: 'whsec_…' },
  ],
  gcash: [
    { key: 'merchant_id', label: 'Merchant ID' },
    { key: 'api_key', label: 'API Key', secret: true },
  ],
  paymaya: [
    { key: 'api_key', label: 'API Key', secret: true },
  ],
  twilio: [
    { key: 'account_sid', label: 'Account SID' },
    { key: 'auth_token', label: 'Auth Token', secret: true },
  ],
  mapbox: [
    { key: 'access_token', label: 'Access Token', secret: true },
  ],
  firebase: [
    { key: 'project_id', label: 'Project ID' },
    { key: 'client_email', label: 'Client Email' },
    { key: 'private_key', label: 'Private Key', secret: true, placeholder: '-----BEGIN PRIVATE KEY-----' },
  ],
};

function schemaForService(service: string): FieldSchema[] {
  return INTEGRATION_SCHEMAS[service] ?? [{ key: 'api_key', label: 'API Key', secret: true }];
}

// Backend masks secrets as `****…abcd`. Treat any value starting with '****'
// as unchanged on save so we don't overwrite real credentials with the mask.
function isMaskedValue(v: string | undefined | null): boolean {
  return typeof v === 'string' && v.startsWith('****');
}

function labelForService(service: string | undefined): string {
  if (!service) return '—';
  if (SERVICE_LABELS[service]) return SERVICE_LABELS[service];
  return service
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function formatDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('en-PH', {
    dateStyle: 'medium',
    timeStyle: 'short',
  });
}

function extractVariables(template: string): string[] {
  const matches = template.match(/\{(\w+)\}/g) ?? [];
  return [...new Set(matches)];
}

function humanizeEvent(event: string | null | undefined): string {
  if (!event) return '—';
  return event
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

// ── Sub-components ────────────────────────────────────────────────────────────

interface IntegrationCardProps {
  integration: Integration;
  onSave: (service: string, configFields: Record<string, string>) => Promise<void> | void;
  onTest: (service: string) => Promise<IntegrationTestResult>;
}

function IntegrationCard({ integration, onSave, onTest }: IntegrationCardProps) {
  const service = integration.service ?? '';
  const schema = schemaForService(service);
  const stored = integration.config ?? {};

  const [values, setValues] = useState<Record<string, string>>({});
  const [revealed, setRevealed] = useState<Record<string, boolean>>({});
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [pendingPatch, setPendingPatch] = useState<Record<string, string>>({});
  const [testing, setTesting] = useState(false);
  const [saving, setSaving] = useState(false);
  const [testResult, setTestResult] = useState<IntegrationTestResult | null>(null);

  // Seed form from backend (masked secrets) exactly once per integration row.
  useEffect(() => {
    const seed: Record<string, string> = {};
    for (const f of schema) {
      seed[f.key] = stored[f.key] ?? '';
    }
    setValues(seed);
    setRevealed({});
  // Keying on integration.service + its config keys is intentional: we reset
  // when the integration row changes or is refreshed, but not on every render.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [service, JSON.stringify(stored)]);

  const updateField = (key: string, value: string) => {
    setValues((prev) => ({ ...prev, [key]: value }));
  };
  const toggleReveal = (key: string) => {
    setRevealed((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const hasChanges = schema.some((f) => (values[f.key] ?? '') !== (stored[f.key] ?? ''));

  const handleSaveClick = () => {
    if (!hasChanges) return;
    // Drop untouched masked secrets so we don't overwrite real values with '****abcd'.
    const patch: Record<string, string> = {};
    for (const f of schema) {
      const v = values[f.key] ?? '';
      if (f.secret && isMaskedValue(v) && v === (stored[f.key] ?? '')) continue;
      patch[f.key] = v;
    }
    setPendingPatch(patch);
    setConfirmOpen(true);
  };

  const handleConfirm = async () => {
    setSaving(true);
    try {
      await onSave(service, pendingPatch);
    } finally {
      setSaving(false);
      setConfirmOpen(false);
      setPendingPatch({});
    }
  };

  const handleTest = async () => {
    setTesting(true);
    setTestResult(null);
    try {
      const r = await onTest(service);
      setTestResult(r);
    } finally {
      setTesting(false);
    }
  };

  return (
    <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-3">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-2">
        <span className="font-medium text-text-main">{labelForService(integration.service)}</span>
        <div className="flex items-center gap-2">
          <StatusBadge status={integration.status ?? 'unknown'} />
          <Button variant="ghost" size="sm" disabled={testing} onClick={handleTest}>
            {testing && <Loader2 className="w-3 h-3 animate-spin mr-1.5" />}
            Test Connection
          </Button>
        </div>
      </div>

      {/* Test result */}
      {testResult && (
        <div
          className={`flex items-center gap-1.5 text-xs px-2 py-1.5 rounded-md ${
            testResult.status === 'ok' ? 'bg-success/10 text-success' : 'bg-danger/10 text-danger'
          }`}
        >
          {testResult.status === 'ok'
            ? <CheckCircle className="w-3.5 h-3.5 flex-shrink-0" />
            : <XCircle className="w-3.5 h-3.5 flex-shrink-0" />}
          <span>
            {testResult.status === 'ok' ? 'Connected' : 'Failed'}
            {testResult.latency_ms != null ? ` · ${testResult.latency_ms}ms` : ''}
            {testResult.message ? ` · ${testResult.message}` : ''}
          </span>
        </div>
      )}

      {/* Schema-driven fields */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {schema.map((f) => {
          const v = values[f.key] ?? '';
          const visible = !f.secret || revealed[f.key];
          return (
            <div key={f.key}>
              <p className="text-xs text-text-muted mb-1 flex items-center gap-1.5">
                {f.secret && <Lock className="w-3 h-3" />}
                {f.label}
              </p>
              <div className="flex items-center gap-2">
                <Input
                  type={visible ? 'text' : 'password'}
                  placeholder={f.placeholder ?? (f.secret ? '•••••• (unchanged)' : '')}
                  value={v}
                  onChange={(e) => updateField(f.key, e.target.value)}
                  className="flex-1 font-mono"
                />
                {f.secret && (
                  <button
                    onClick={() => toggleReveal(f.key)}
                    className="text-text-muted hover:text-text-main transition-colors"
                    aria-label={visible ? `Hide ${f.label}` : `Reveal ${f.label}`}
                    type="button"
                  >
                    {visible ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                )}
              </div>
            </div>
          );
        })}
        <div>
          <p className="text-xs text-text-muted mb-1">Last Tested</p>
          <p className="text-sm text-text-muted">{formatDate(integration.last_sync)}</p>
        </div>
      </div>

      <div className="flex justify-end">
        <Button size="sm" onClick={handleSaveClick} disabled={!hasChanges || saving}>
          {saving ? 'Saving…' : 'Save'}
        </Button>
      </div>

      <ConfirmModal
        open={confirmOpen}
        title="Update Live Credentials"
        message={`This will replace live ${labelForService(service)} credentials. Continue?`}
        confirmLabel="Update"
        onConfirm={handleConfirm}
        onClose={() => setConfirmOpen(false)}
      />
    </div>
  );
}

interface TemplateEditorProps {
  template: NotificationTemplate;
  onSave: (event: string, body: string) => void;
}

function TemplateEditor({ template, onSave }: TemplateEditorProps) {
  const [body, setBody] = useState(template.body);
  const variables = extractVariables(body);

  return (
    <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <span className="font-medium text-text-main">{humanizeEvent(template.event)}</span>
        <Badge variant="default">{template.channel}</Badge>
      </div>

      <textarea
        value={body}
        onChange={(e) => setBody(e.target.value)}
        className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary resize-none h-20"
        aria-label={`Template body for ${template.event}`}
      />

      {variables.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          <span className="text-xs text-text-muted">Variables:</span>
          {variables.map((v) => (
            <code
              key={v}
              className="text-xs bg-primary/10 text-primary border border-primary/20 rounded px-1.5 py-0.5"
            >
              {v}
            </code>
          ))}
        </div>
      )}

      <div className="flex justify-end">
        <Button size="sm" onClick={() => onSave(template.event, body)}>
          Save Template
        </Button>
      </div>
    </div>
  );
}

interface FeatureFlagRowProps {
  flag: FeatureFlag;
  onToggle: (key: string, next: boolean) => void;
}

function FeatureFlagRow({ flag, onToggle }: FeatureFlagRowProps) {
  const [confirmOpen, setConfirmOpen] = useState(false);
  const isDestructive = flag.key === 'maintenance_mode';

  const handleClick = () => {
    if (isDestructive && !flag.enabled) {
      setConfirmOpen(true);
    } else {
      onToggle(flag.key, !flag.enabled);
    }
  };

  return (
    <div className="flex items-center justify-between p-4 bg-surface-hover rounded-lg border border-border">
      <div className="flex-1 min-w-0 pr-4">
        <p className="font-medium text-text-main">{flag.label}</p>
        <p className="text-sm text-text-muted">{flag.description}</p>
      </div>

      <button
        role="switch"
        aria-checked={flag.enabled}
        aria-label={`${flag.enabled ? 'Disable' : 'Enable'} ${flag.label}`}
        onClick={handleClick}
        className={`w-11 h-6 rounded-full transition-colors relative flex-shrink-0 ${flag.enabled ? 'bg-primary' : 'bg-border'
          }`}
      >
        <div
          className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-transform ${flag.enabled ? 'translate-x-6' : 'translate-x-1'
            }`}
        />
      </button>

      <ConfirmModal
        open={confirmOpen}
        title="Enable Maintenance Mode"
        message="This will disable ride booking for all users and show a maintenance message. Are you sure you want to enable Maintenance Mode?"
        confirmLabel="Enable"
        variant="danger"
        onConfirm={() => {
          onToggle(flag.key, true);
          setConfirmOpen(false);
        }}
        onClose={() => setConfirmOpen(false)}
      />
    </div>
  );
}

// ── Main component ────────────────────────────────────────────────────────────

export function SASystemConfig() {
  const integrationsQuery = useIntegrations();
  const templatesQuery = useNotificationTemplates();
  const flagsQuery = useFeatureFlags();
  const updateIntegrationMut = useUpdateIntegration();
  const testIntegrationMut = useTestIntegration();
  const updateTemplateMut = useUpdateTemplate();
  const toggleFlagMut = useToggleFlag();

  const integrations = (integrationsQuery.data ?? []) as Integration[];
  const templates = (templatesQuery.data ?? []) as NotificationTemplate[];
  const featureFlags = (flagsQuery.data ?? []) as unknown as FeatureFlag[];

  const [saveBannerVisible, setSaveBannerVisible] = useState(false);

  const showSaveBanner = () => {
    setSaveBannerVisible(true);
    setTimeout(() => setSaveBannerVisible(false), 3000);
  };

  const handleUpdateIntegration = async (service: string, configFields: Record<string, string>) => {
    await updateIntegrationMut.mutateAsync({ service, data: configFields });
    showSaveBanner();
  };

  const handleTestIntegration = (service: string) =>
    testIntegrationMut.mutateAsync(service);

  const handleUpdateTemplate = async (event: string, body: string) => {
    await updateTemplateMut.mutateAsync({ event, body });
    showSaveBanner();
  };

  const handleToggleFlag = async (key: string, next: boolean) => {
    await toggleFlagMut.mutateAsync({ key, enabled: next });
    showSaveBanner();
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">System Configuration</h1>
        <SaveBanner visible={saveBannerVisible} />
      </div>

      <Card>
        <CardContent className="pt-6">
          <Tabs defaultValue="integrations">
            <TabsList className="mb-6">
              <TabsTrigger value="integrations">Integrations</TabsTrigger>
              <TabsTrigger value="templates">Notification Templates</TabsTrigger>
              <TabsTrigger value="flags">Feature Flags</TabsTrigger>
              <TabsTrigger value="alerts">Alerts</TabsTrigger>
              <TabsTrigger value="account">Account</TabsTrigger>
            </TabsList>

            {/* Tab 1 — Integrations */}
            <TabsContent value="integrations">
              <div className="space-y-4">
                {integrations.map((integration, idx) => (
                  <IntegrationCard
                    key={integration.service ?? idx}
                    integration={integration}
                    onSave={handleUpdateIntegration}
                    onTest={handleTestIntegration}
                  />
                ))}
                {integrations.length === 0 && (
                  <p className="text-sm text-text-muted text-center py-8">
                    Loading integrations…
                  </p>
                )}
              </div>
            </TabsContent>

            {/* Tab 2 — Notification Templates */}
            <TabsContent value="templates">
              <div className="space-y-4">
                {templates.map((template) => (
                  <TemplateEditor
                    key={template.event}
                    template={template}
                    onSave={handleUpdateTemplate}
                  />
                ))}
                {templates.length === 0 && (
                  <p className="text-sm text-text-muted text-center py-8">
                    Loading templates…
                  </p>
                )}
              </div>
            </TabsContent>

            {/* Tab 3 — Feature Flags */}
            <TabsContent value="flags">
              <div className="space-y-3">
                {featureFlags.map((flag) => (
                  <FeatureFlagRow
                    key={flag.key}
                    flag={flag}
                    onToggle={handleToggleFlag}
                  />
                ))}
                {featureFlags.length === 0 && (
                  <p className="text-sm text-text-muted text-center py-8">
                    Loading feature flags…
                  </p>
                )}
              </div>
            </TabsContent>

            {/* Tab 4 — Alerts */}
            <TabsContent value="alerts">
              <AlertRulesTab />
            </TabsContent>

            {/* Tab 5 — Account / Change Password */}
            <TabsContent value="account">
              <ChangePasswordForm />
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}
