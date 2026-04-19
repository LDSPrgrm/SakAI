import React, { useEffect, useState } from 'react';
import { Eye, EyeOff, CheckCircle, XCircle, Loader2, Lock } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Badge } from '@/components/ui/Badge';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { systemApi } from '@/api/super-admin/system';
import { authApi } from '@/api/super-admin/auth';
import type { IntegrationTestResult } from '@/api/super-admin/system';
import type { FeatureFlag } from '@/types/super-admin';

// ── Local types ───────────────────────────────────────────────────────────────

interface Integration {
  service: string;
  label: string;
  api_key: string;
  status: string;
  last_used: string;
}

interface NotificationTemplate {
  event: string;
  channel: string;
  body: string;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function maskedKey(key: string | null | undefined): string {
  if (!key) return '—';
  const last4 = key.slice(-4);
  return `••••••••${last4}`;
}

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
  onSave: (service: string, newKey: string) => void;
  onTest: (service: string) => Promise<IntegrationTestResult>;
}

function IntegrationCard({ integration, onSave, onTest }: IntegrationCardProps) {
  const [revealed, setRevealed] = useState(false);
  const [newKey, setNewKey] = useState('');
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [testing, setTesting] = useState(false);
  const [testResult, setTestResult] = useState<IntegrationTestResult | null>(null);

  const handleSaveClick = () => {
    if (!newKey.trim()) return;
    setConfirmOpen(true);
  };

  const handleConfirm = () => {
    onSave(integration.service, newKey.trim());
    setNewKey('');
    setConfirmOpen(false);
  };

  const handleTest = async () => {
    setTesting(true);
    setTestResult(null);
    try {
      const r = await onTest(integration.service);
      setTestResult(r);
    } finally {
      setTesting(false);
    }
  };

  return (
    <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-3">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-2">
        <span className="font-medium text-text-main">{integration.label}</span>
        <div className="flex items-center gap-2">
          <StatusBadge status={integration.status} />
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

      {/* Key info */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <p className="text-xs text-text-muted mb-1">API Key</p>
          <div className="flex items-center gap-2">
            <code className="text-sm text-text-main font-mono">
              {revealed ? integration.api_key : maskedKey(integration.api_key)}
            </code>
            <button
              onClick={() => setRevealed((r) => !r)}
              className="text-text-muted hover:text-text-main transition-colors"
              aria-label={revealed ? 'Hide API key' : 'Reveal API key'}
            >
              {revealed ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>
        </div>
        <div>
          <p className="text-xs text-text-muted mb-1">Last Used</p>
          <p className="text-sm text-text-muted">{formatDate(integration.last_used)}</p>
        </div>
      </div>

      {/* Update form */}
      <div className="flex gap-2 items-center">
        <Input
          placeholder="Enter new API key…"
          value={newKey}
          onChange={(e) => setNewKey(e.target.value)}
          className="flex-1"
        />
        <Button size="sm" onClick={handleSaveClick} disabled={!newKey.trim()}>
          Save
        </Button>
      </div>

      <ConfirmModal
        open={confirmOpen}
        title="Update Live Credentials"
        message="This will update live credentials. Are you sure?"
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
  const [integrations, setIntegrations] = useState<Integration[]>([]);
  const [templates, setTemplates] = useState<NotificationTemplate[]>([]);
  const [featureFlags, setFeatureFlags] = useState<FeatureFlag[]>([]);
  const [saveBannerVisible, setSaveBannerVisible] = useState(false);

  // Change password state
  const [cpOldPassword, setCpOldPassword] = useState('');
  const [cpNewPassword, setCpNewPassword] = useState('');
  const [cpConfirmPassword, setCpConfirmPassword] = useState('');
  const [cpLoading, setCpLoading] = useState(false);
  const [cpError, setCpError] = useState('');
  const [cpSuccess, setCpSuccess] = useState(false);

  useEffect(() => {
    systemApi.getIntegrations().then((data) =>
      setIntegrations(data as Integration[])
    );
    systemApi.getNotificationTemplates().then((data) =>
      setTemplates(data as NotificationTemplate[])
    );
    systemApi.getFeatureFlags().then(f => setFeatureFlags(f as unknown as FeatureFlag[]));
  }, []);

  const showSaveBanner = () => {
    setSaveBannerVisible(true);
    setTimeout(() => setSaveBannerVisible(false), 3000);
  };

  const handleUpdateIntegration = async (service: string, newKey: string) => {
    await systemApi.updateIntegration(service, { api_key: newKey });
    setIntegrations((prev) =>
      prev.map((i) => (i.service === service ? { ...i, api_key: newKey } : i))
    );
    showSaveBanner();
  };

  const handleTestIntegration = (service: string) =>
    systemApi.testIntegration(service);

  const handleUpdateTemplate = async (event: string, body: string) => {
    await systemApi.updateTemplate(event, body);
    setTemplates((prev) =>
      prev.map((t) => (t.event === event ? { ...t, body } : t))
    );
    showSaveBanner();
  };

  const handleToggleFlag = async (key: string, next: boolean) => {
    const updated = await systemApi.toggleFlag(key, next) as unknown as FeatureFlag;
    setFeatureFlags((prev) =>
      prev.map((f) => (f.key === key ? { ...f, enabled: updated.enabled } : f))
    );
    showSaveBanner();
  };

  async function handleChangePassword() {
    if (cpNewPassword !== cpConfirmPassword) {
      setCpError('New passwords do not match.');
      return;
    }
    if (cpNewPassword.length < 8) {
      setCpError('Password must be at least 8 characters.');
      return;
    }
    setCpLoading(true);
    setCpError('');
    setCpSuccess(false);
    try {
      await authApi.changePassword({ old_password: cpOldPassword, new_password: cpNewPassword });
      setCpSuccess(true);
      setCpOldPassword('');
      setCpNewPassword('');
      setCpConfirmPassword('');
    } catch {
      setCpError('Failed to change password. Check your current password and try again.');
    } finally {
      setCpLoading(false);
    }
  }

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
              <TabsTrigger value="account">Account</TabsTrigger>
            </TabsList>

            {/* Tab 1 — Integrations */}
            <TabsContent value="integrations">
              <div className="space-y-4">
                {integrations.map((integration) => (
                  <IntegrationCard
                    key={integration.service}
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

            {/* Tab 4 — Account / Change Password */}
            <TabsContent value="account">
              <div className="max-w-md space-y-4">
                <div className="flex items-center gap-2 mb-2">
                  <Lock className="w-4 h-4 text-text-muted" />
                  <h3 className="font-semibold text-text-main">Change Password</h3>
                </div>
                <div className="space-y-3">
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Current Password</label>
                    <Input
                      type="password"
                      placeholder="Enter current password"
                      value={cpOldPassword}
                      onChange={(e) => {
                        setCpOldPassword(e.target.value);
                        setCpError('');
                        setCpSuccess(false);
                      }}
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">New Password</label>
                    <Input
                      type="password"
                      placeholder="Min. 8 characters"
                      value={cpNewPassword}
                      onChange={(e) => {
                        setCpNewPassword(e.target.value);
                        setCpError('');
                        setCpSuccess(false);
                      }}
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Confirm New Password</label>
                    <Input
                      type="password"
                      placeholder="Repeat new password"
                      value={cpConfirmPassword}
                      onChange={(e) => {
                        setCpConfirmPassword(e.target.value);
                        setCpError('');
                        setCpSuccess(false);
                      }}
                    />
                  </div>
                </div>
                {cpError && (
                  <p className="text-sm text-danger">{cpError}</p>
                )}
                {cpSuccess && (
                  <p className="text-sm text-success">Password changed successfully.</p>
                )}
                <Button
                  onClick={handleChangePassword}
                  disabled={cpLoading || !cpOldPassword || !cpNewPassword || !cpConfirmPassword}
                >
                  {cpLoading ? 'Saving…' : 'Change Password'}
                </Button>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}
