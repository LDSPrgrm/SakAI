import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { alertsApi, type AlertRuleInput } from '@/api/super-admin/alerts';

const RULES_KEY = ['admin', 'alerts', 'rules'] as const;
const EVENTS_KEY = ['admin', 'alerts', 'events'] as const;

export function useAlertRules() {
  return useQuery({ queryKey: RULES_KEY, queryFn: () => alertsApi.listRules() });
}

export function useAlertEvents(limit = 100) {
  return useQuery({
    queryKey: [...EVENTS_KEY, limit],
    queryFn: () => alertsApi.listEvents(limit),
  });
}

export function useCreateAlertRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: AlertRuleInput) => alertsApi.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: RULES_KEY }),
  });
}

export function useUpdateAlertRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: AlertRuleInput }) =>
      alertsApi.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: RULES_KEY }),
  });
}

export function useDeleteAlertRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => alertsApi.remove(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: RULES_KEY }),
  });
}
