import React, { useState } from 'react';
import { ToggleLeft, ToggleRight } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { useGatewayConfigs, useUpdatePaymentConfig } from '@/hooks/usePayments';

interface GatewayConfig {
  id: string;
  provider: string;
  is_active: boolean;
  config_fields: Record<string, string>;
}

export function SystemConfigTab() {
  const gatewaysQuery = useGatewayConfigs();
  const updatePaymentConfig = useUpdatePaymentConfig();
  const gateways = (gatewaysQuery.data ?? []) as unknown as GatewayConfig[];
  const [saved, setSaved] = useState(false);

  // Only providers with an entry here get persisted — prevents blanking keys admin didn't touch.
  const [editedKeys, setEditedKeys] = useState<Record<string, { field: string; value: string }>>({});

  const onKeyChange = (provider: string, field: string, value: string) => {
    setEditedKeys(prev => ({ ...prev, [provider]: { field, value } }));
  };

  const onToggle = (idx: number) => {
    const gw = gateways[idx];
    updatePaymentConfig.mutate({ provider: gw.provider, payload: { is_active: !gw.is_active } });
  };

  const onSave = async () => {
    const entries = Object.entries(editedKeys);
    await Promise.all(
      entries.map(([provider, { field, value }]) =>
        updatePaymentConfig.mutateAsync({ provider, payload: { config_fields: { [field]: value } } }).catch(() => {}),
      ),
    );
    setEditedKeys({});
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-medium">System Configuration</h3>
        <SaveBanner visible={saved} />
      </div>

      <div className="space-y-6 max-w-2xl">
        <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
          <h4 className="font-medium">Payment Gateways</h4>
          {gatewaysQuery.isPending ? (
            <p className="text-sm text-text-muted">Loading...</p>
          ) : gateways.length > 0 ? (
            <div className="space-y-3">
              {gateways.map((gw, idx) => {
                const entries = Object.entries(gw.config_fields ?? {});
                const [firstField, firstValue] = entries[0] ?? ['api_key', ''];
                const edited = editedKeys[gw.provider];
                const inputValue = edited?.field === firstField ? edited.value : firstValue;
                return (
                  <div key={gw.id ?? gw.provider} className="flex items-center justify-between gap-4">
                    <div className="flex-1 space-y-1">
                      <label className="text-sm text-text-muted capitalize">{gw.provider} API Key</label>
                      <Input
                        type="password"
                        value={inputValue}
                        placeholder="Enter API key"
                        onChange={(e) => onKeyChange(gw.provider, firstField, e.target.value)}
                      />
                    </div>
                    <button
                      aria-label={`${gw.is_active ? 'Disable' : 'Enable'} ${gw.provider}`}
                      onClick={() => onToggle(idx)}
                      className="flex-shrink-0"
                    >
                      {gw.is_active
                        ? <ToggleRight className="w-8 h-8 text-success" />
                        : <ToggleLeft className="w-8 h-8 text-text-muted" />
                      }
                    </button>
                  </div>
                );
              })}
            </div>
          ) : (
            <p className="text-sm text-text-muted">
              No payment gateways configured. Gateways are provisioned by the platform team.
            </p>
          )}
        </div>

        <Button onClick={onSave}>Save Configuration</Button>
      </div>
    </div>
  );
}
