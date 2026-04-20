import React, { useState } from 'react';
import { AlertCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { maskApiKey } from '@/utils/maskApiKey';

export interface GatewayProvider {
  id: string;
  label: string;
  type: 'ewallet' | 'card';
  apiKey?: string;
  secret?: string;
  merchantId?: string;
  webhookUrl?: string;
  publishableKey?: string;
  secretKey?: string;
  webhookSecret?: string;
}

export interface GatewayProvidersSectionProps {
  providers: GatewayProvider[];
  onChange: (providers: GatewayProvider[]) => void;
  onSave: (provider: GatewayProvider) => Promise<void>;
}

export function GatewayProvidersSection({ providers, onChange, onSave }: GatewayProvidersSectionProps) {
  const [savingProvider, setSavingProvider] = useState<string | null>(null);

  const updateField = (
    id: string,
    field: keyof Omit<GatewayProvider, 'id' | 'label'>,
    value: string,
  ) => {
    onChange(providers.map((p) => (p.id === id ? { ...p, [field]: value } : p)));
  };

  async function handleSave(id: string) {
    const provider = providers.find((p) => p.id === id);
    if (!provider) return;
    setSavingProvider(id);
    try {
      await onSave(provider);
    } finally {
      setSavingProvider(null);
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Payment Gateway Configuration</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-start gap-2 p-3 bg-warning/10 border border-warning/20 rounded-lg">
          <AlertCircle className="w-4 h-4 text-warning flex-shrink-0 mt-0.5" />
          <p className="text-sm text-warning">
            API keys are masked for security. Only the last 4 characters are visible.
          </p>
        </div>

        <div className="space-y-4">
          {providers.length === 0 && (
            <p className="text-sm text-text-muted text-center py-6">
              No payment gateways configured. Configure via Settings → System Config.
            </p>
          )}
          {providers.map((provider) => (
            <div key={provider.id} className="p-4 bg-surface-hover rounded-lg border border-border">
              <h4 className="text-sm font-semibold text-text-main mb-3">{provider.label}</h4>

              {provider.type === 'ewallet' ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs text-text-muted mb-1">API Key</label>
                    <Input value={maskApiKey(provider.apiKey ?? '')} onChange={(e) => updateField(provider.id, 'apiKey', e.target.value)} />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Secret</label>
                    <Input value={maskApiKey(provider.secret ?? '')} type="password" onChange={(e) => updateField(provider.id, 'secret', e.target.value)} />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Merchant ID</label>
                    <Input value={provider.merchantId ?? ''} onChange={(e) => updateField(provider.id, 'merchantId', e.target.value)} />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Webhook URL</label>
                    <Input value={provider.webhookUrl ?? ''} onChange={(e) => updateField(provider.id, 'webhookUrl', e.target.value)} />
                  </div>
                </div>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div className="sm:col-span-2">
                    <label className="block text-xs text-text-muted mb-1">Publishable Key</label>
                    <Input value={maskApiKey(provider.publishableKey ?? '')} onChange={(e) => updateField(provider.id, 'publishableKey', e.target.value)} />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Secret Key</label>
                    <Input value={maskApiKey(provider.secretKey ?? '')} type="password" onChange={(e) => updateField(provider.id, 'secretKey', e.target.value)} />
                  </div>
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Webhook Secret</label>
                    <Input value={maskApiKey(provider.webhookSecret ?? '')} type="password" onChange={(e) => updateField(provider.id, 'webhookSecret', e.target.value)} />
                  </div>
                </div>
              )}

              <div className="mt-3 flex justify-end">
                <Button
                  variant="primary"
                  size="sm"
                  onClick={() => handleSave(provider.id)}
                  disabled={savingProvider === provider.id}
                >
                  {savingProvider === provider.id ? 'Saving...' : 'Save'}
                </Button>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
