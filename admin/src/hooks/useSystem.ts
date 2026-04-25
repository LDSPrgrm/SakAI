// React Query hooks for system services, feature flags, integrations, notification templates.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { systemApi, type FeatureFlag } from '@/api/super-admin/system';
import { api, type HealthResponse } from '@/lib/api';
import { FLAG_KEYS } from '@/constants/featureFlags';

// Backend seeds one flag per cashless method. The admin UI collapses these
// into a single "Cashless Payments" row; toggling it fans out to all three.
const CASHLESS_PROVIDER_KEYS = ['gcash_payments', 'paymaya_payments', 'card_payments'];
const CASHLESS_PROVIDER_SET = new Set(CASHLESS_PROVIDER_KEYS);

export function compressCashlessFlags(flags: FeatureFlag[]): FeatureFlag[] {
  const cashless = flags.filter((f) => f.key && CASHLESS_PROVIDER_SET.has(f.key));
  const rest = flags.filter((f) => !f.key || !CASHLESS_PROVIDER_SET.has(f.key));
  if (cashless.length === 0) return rest;
  const synthetic: FeatureFlag = {
    key: FLAG_KEYS.CASHLESS_PAYMENTS,
    label: 'Cashless Payments',
    description: 'Accept GCash, PayMaya, and card payments. When off, only Cash is accepted app-wide.',
    enabled: cashless.every((f) => f.enabled ?? false),
  };
  return [...rest, synthetic];
}

const SYSTEM_KEY = ['admin', 'system'] as const;
const INTEGRATIONS_KEY = [...SYSTEM_KEY, 'integrations'] as const;
const TEMPLATES_KEY = [...SYSTEM_KEY, 'notification-templates'] as const;
const FLAGS_KEY = [...SYSTEM_KEY, 'feature-flags'] as const;
const SERVICES_KEY = [...SYSTEM_KEY, 'services'] as const;

export function useHealth() {
  return useQuery<HealthResponse>({
    queryKey: ['system', 'health'],
    queryFn: () => api.health.check(),
    refetchInterval: 30_000,
    retry: false,
  });
}

export function useIntegrations() {
  return useQuery({
    queryKey: INTEGRATIONS_KEY,
    queryFn: () => systemApi.getIntegrations(),
  });
}

export function useNotificationTemplates() {
  return useQuery({
    queryKey: TEMPLATES_KEY,
    queryFn: () => systemApi.getNotificationTemplates(),
  });
}

export function useFeatureFlags() {
  return useQuery({
    queryKey: FLAGS_KEY,
    queryFn: () => systemApi.getFeatureFlags(),
    select: compressCashlessFlags,
  });
}

// Defaults to true so cashless UI isn't prematurely gated while the flag
// query is loading or in the failure state — the backend is still the
// authority at ride/payment creation time.
export function useIsCashlessEnabled(): boolean {
  const { data } = useFeatureFlags();
  const flag = data?.find((f) => f.key === FLAG_KEYS.CASHLESS_PAYMENTS);
  return flag ? flag.enabled : true;
}

export function useSystemServices(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: SERVICES_KEY,
    queryFn: () => systemApi.getServices(),
    refetchInterval: options?.refetchInterval,
  });
}

export function useInfraMetrics(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: [...SYSTEM_KEY, 'infra-metrics'] as const,
    queryFn: () => systemApi.getInfraMetrics(),
    refetchInterval: options?.refetchInterval,
  });
}

export function useUpdateIntegration() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ service, data }: { service: string; data: Record<string, string> }) =>
      systemApi.updateIntegration(service, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: INTEGRATIONS_KEY }),
  });
}

export function useTestIntegration() {
  return useMutation({
    mutationFn: (service: string) => systemApi.testIntegration(service),
  });
}

export function useUpdateTemplate() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ event, body }: { event: string; body: string }) =>
      systemApi.updateTemplate(event, body),
    onSuccess: () => qc.invalidateQueries({ queryKey: TEMPLATES_KEY }),
  });
}

export function useToggleFlag() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ key, enabled }: { key: string; enabled: boolean }) => {
      if (key === FLAG_KEYS.CASHLESS_PAYMENTS) {
        await Promise.all(
          CASHLESS_PROVIDER_KEYS.map((k) => systemApi.toggleFlag(k, enabled)),
        );
        return;
      }
      await systemApi.toggleFlag(key, enabled);
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: FLAGS_KEY }),
  });
}
