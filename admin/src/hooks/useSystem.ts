// React Query hooks for system services, feature flags, integrations, notification templates.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { systemApi } from '@/api/super-admin/system';

const SYSTEM_KEY = ['admin', 'system'] as const;
const INTEGRATIONS_KEY = [...SYSTEM_KEY, 'integrations'] as const;
const TEMPLATES_KEY = [...SYSTEM_KEY, 'notification-templates'] as const;
const FLAGS_KEY = [...SYSTEM_KEY, 'feature-flags'] as const;
const SERVICES_KEY = [...SYSTEM_KEY, 'services'] as const;

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
  });
}

export function useSystemServices(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: SERVICES_KEY,
    queryFn: () => systemApi.getServices(),
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
    mutationFn: ({ key, enabled }: { key: string; enabled: boolean }) =>
      systemApi.toggleFlag(key, enabled),
    onSuccess: () => qc.invalidateQueries({ queryKey: FLAGS_KEY }),
  });
}
