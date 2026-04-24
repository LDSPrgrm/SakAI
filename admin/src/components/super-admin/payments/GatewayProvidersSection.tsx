import React, { useEffect, useState } from 'react';
import { AlertCircle, Eye, EyeOff, Lock } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import type { PaymentGatewayConfig } from '@/api/super-admin/payments';
import { useIsCashlessEnabled } from '@/hooks/useSystem';
import { cn } from '@/lib/utils';

const CASHLESS_PROVIDERS = new Set(['gcash', 'paymaya', 'card']);

// Per-provider field schemas. Mirrors the INTEGRATION_SCHEMAS pattern in
// SASystemConfig — secret fields are masked on read by the backend, so we
// preserve the "****" placeholder unless the user types a fresh value.
interface FieldSchema {
  key: string;
  label: string;
  secret?: boolean;
}

const PROVIDER_SCHEMAS: Record<string, FieldSchema[]> = {
  gcash:   [
    { key: 'merchant_id',     label: 'Merchant ID' },
    { key: 'api_key',         label: 'API Key',         secret: true },
    { key: 'webhook_secret',  label: 'Webhook Secret',  secret: true },
  ],
  paymaya: [
    { key: 'public_key',      label: 'Public Key' },
    { key: 'secret_key',      label: 'Secret Key',      secret: true },
    { key: 'webhook_secret',  label: 'Webhook Secret',  secret: true },
  ],
  card:    [
    { key: 'publishable_key', label: 'Publishable Key' },
    { key: 'secret_key',      label: 'Secret Key',      secret: true },
    { key: 'webhook_secret',  label: 'Webhook Secret',  secret: true },
  ],
  cash:    [],
};

const PROVIDER_LABELS: Record<string, string> = {
  gcash: 'GCash',
  paymaya: 'PayMaya',
  card: 'Card (Stripe)',
  cash: 'Cash',
};

export interface GatewayProvidersSectionProps {
  configs: PaymentGatewayConfig[];
  onSave: (provider: string, payload: { config_fields: Record<string, string>; is_active: boolean }) => Promise<void>;
}

export function GatewayProvidersSection({ configs, onSave }: GatewayProvidersSectionProps) {
  const [draft, setDraft] = useState<Record<string, Record<string, string>>>({});
  const [active, setActive] = useState<Record<string, boolean>>({});
  const [revealed, setRevealed] = useState<Record<string, boolean>>({});
  const [savingProvider, setSavingProvider] = useState<string | null>(null);
  const cashlessEnabled = useIsCashlessEnabled();

  // Sync local draft when server data arrives or refreshes.
  useEffect(() => {
    const nextDraft: Record<string, Record<string, string>> = {};
    const nextActive: Record<string, boolean> = {};
    for (const c of configs) {
      if (!c.provider) continue;
      nextDraft[c.provider] = { ...(c.config_fields ?? {}) };
      nextActive[c.provider] = c.is_active ?? false;
    }
    setDraft(nextDraft);
    setActive(nextActive);
  }, [configs]);

  function setField(provider: string, key: string, value: string) {
    setDraft((d) => ({ ...d, [provider]: { ...(d[provider] ?? {}), [key]: value } }));
  }

  function toggleReveal(provider: string, key: string) {
    const tag = `${provider}:${key}`;
    setRevealed((r) => ({ ...r, [tag]: !r[tag] }));
  }

  async function handleSave(provider: string) {
    setSavingProvider(provider);
    try {
      const config_fields: Record<string, string> = {};
      for (const [k, v] of Object.entries(draft[provider] ?? {})) {
        // Drop unchanged masked secrets — the backend keeps the existing value
        // when a key is absent from the JSONB merge.
        if (v.startsWith('****')) continue;
        config_fields[k] = v;
      }
      await onSave(provider, {
        config_fields,
        is_active: active[provider] ?? false,
      });
    } finally {
      setSavingProvider(null);
    }
  }

  const allProviders: string[] = configs
    .map((c) => c.provider)
    .filter((p): p is NonNullable<typeof p> => Boolean(p));

  return (
    <Card>
      <CardHeader>
        <CardTitle>Payment Gateway Configuration</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-start gap-2 p-3 bg-warning/10 border border-warning/20 rounded-lg">
          <AlertCircle className="w-4 h-4 text-warning flex-shrink-0 mt-0.5" />
          <p className="text-sm text-warning">
            API keys and webhook secrets are masked. Type a new value to overwrite; leave the masked
            placeholder to keep the stored secret.
          </p>
        </div>

        {!cashlessEnabled && (
          <div
            role="status"
            className="flex items-start gap-2 p-3 bg-danger/10 border border-danger/20 rounded-lg"
          >
            <Lock className="w-4 h-4 text-danger flex-shrink-0 mt-0.5" />
            <p className="text-sm text-danger">
              Cashless payments are disabled via the <strong>cashless_payments</strong> feature flag.
              GCash, PayMaya, and Card providers are locked. Re-enable in System Config &rarr; Feature Flags.
            </p>
          </div>
        )}

        {allProviders.length === 0 && (
          <p className="text-sm text-text-muted text-center py-6">
            No payment gateways configured. Run the gateway seed migration or add a provider via SQL.
          </p>
        )}

        {allProviders.map((provider) => {
          const schema = PROVIDER_SCHEMAS[provider] ?? [];
          const label = PROVIDER_LABELS[provider] ?? provider;
          const fields = draft[provider] ?? {};
          const isCashless = CASHLESS_PROVIDERS.has(provider);
          const locked = isCashless && !cashlessEnabled;
          const shownActive = locked ? false : (active[provider] ?? false);
          return (
            <div
              key={provider}
              aria-disabled={locked || undefined}
              className={cn(
                'p-4 bg-surface-hover rounded-lg border border-border space-y-3',
                locked && 'opacity-60',
              )}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <h4 className="text-sm font-semibold text-text-main flex items-center gap-1.5">
                    {locked && <Lock className="w-3.5 h-3.5 text-text-muted" />}
                    {label}
                  </h4>
                  <Badge variant={shownActive ? 'success' : 'default'}>
                    {shownActive ? 'Active' : locked ? 'Locked' : 'Inactive'}
                  </Badge>
                </div>
                <label className={cn(
                  'text-xs text-text-muted flex items-center gap-2',
                  locked ? 'cursor-not-allowed' : 'cursor-pointer',
                )}>
                  <input
                    type="checkbox"
                    className="w-4 h-4 accent-primary disabled:cursor-not-allowed"
                    checked={shownActive}
                    disabled={locked}
                    onChange={(e) => setActive((a) => ({ ...a, [provider]: e.target.checked }))}
                  />
                  Enabled
                </label>
              </div>

              {schema.length === 0 ? (
                <p className="text-xs text-text-muted">No credentials required.</p>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {schema.map((f) => {
                    const tag = `${provider}:${f.key}`;
                    const isRevealed = revealed[tag] ?? false;
                    return (
                      <div key={f.key}>
                        <label className="block text-xs text-text-muted mb-1">{f.label}</label>
                        <div className="flex gap-1">
                          <Input
                            type={f.secret && !isRevealed ? 'password' : 'text'}
                            value={fields[f.key] ?? ''}
                            onChange={(e) => setField(provider, f.key, e.target.value)}
                          />
                          {f.secret && (
                            <Button
                              type="button"
                              variant="outline"
                              size="sm"
                              onClick={() => toggleReveal(provider, f.key)}
                              aria-label={isRevealed ? 'Hide' : 'Reveal'}
                            >
                              {isRevealed ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                            </Button>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}

              <div className="flex justify-end">
                <Button
                  variant="primary"
                  size="sm"
                  onClick={() => handleSave(provider)}
                  disabled={savingProvider === provider || locked}
                >
                  {savingProvider === provider ? 'Saving…' : 'Save'}
                </Button>
              </div>
            </div>
          );
        })}
      </CardContent>
    </Card>
  );
}
