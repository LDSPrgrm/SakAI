// React Query hooks for transactions, payouts, summaries, and gateway/commission configs.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  paymentsApi,
  type CommissionConfig,
  type DriverPayout,
  type UpdatePaymentConfigRequest,
} from '@/api/super-admin/payments';

const PAYMENTS_KEY = ['admin', 'payments'] as const;

export function useTransactions(filters: import('@/api/super-admin/payments').TransactionFilters = {}) {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'transactions', filters] as const,
    queryFn: () => paymentsApi.getTransactions(filters),
  });
}

export function usePayouts(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'payouts'] as const,
    queryFn: () => paymentsApi.getPayouts(),
    refetchInterval: options?.refetchInterval,
  });
}

export function usePaymentSummary() {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'summary'] as const,
    queryFn: () => paymentsApi.getSummary(),
  });
}

export function useCommissionConfig() {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'commission-config'] as const,
    queryFn: () => paymentsApi.getCommissionConfig(),
  });
}

export function useGatewayConfigs(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'gateway-configs'] as const,
    queryFn: () => paymentsApi.getGatewayConfigs(),
    refetchInterval: options?.refetchInterval,
  });
}

const PAYOUTS_KEY = [...PAYMENTS_KEY, 'payouts'] as const;

type PayoutsSnapshot = { prev: DriverPayout[] | undefined };

export function useApprovePayout() {
  const qc = useQueryClient();
  return useMutation<void, Error, string, PayoutsSnapshot>({
    mutationFn: (id) => paymentsApi.approvePayout(id),
    onMutate: async (id) => {
      await qc.cancelQueries({ queryKey: PAYOUTS_KEY });
      const prev = qc.getQueryData<DriverPayout[]>(PAYOUTS_KEY);
      qc.setQueryData<DriverPayout[]>(PAYOUTS_KEY, (current) =>
        (current ?? []).map((p) => (p.id === id ? { ...p, status: 'approved' } : p)),
      );
      return { prev };
    },
    onError: (_err, _vars, ctx) => {
      if (ctx?.prev !== undefined) qc.setQueryData(PAYOUTS_KEY, ctx.prev);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: PAYOUTS_KEY }),
  });
}

export function useBatchApprovePayouts() {
  const qc = useQueryClient();
  return useMutation<{ approved: number }, Error, string[], PayoutsSnapshot>({
    mutationFn: (ids) => paymentsApi.batchApprovePayouts(ids),
    onMutate: async (ids) => {
      await qc.cancelQueries({ queryKey: PAYOUTS_KEY });
      const prev = qc.getQueryData<DriverPayout[]>(PAYOUTS_KEY);
      const idSet = new Set(ids);
      qc.setQueryData<DriverPayout[]>(PAYOUTS_KEY, (current) =>
        (current ?? []).map((p) => (idSet.has(p.id) ? { ...p, status: 'approved' } : p)),
      );
      return { prev };
    },
    onError: (_err, _vars, ctx) => {
      if (ctx?.prev !== undefined) qc.setQueryData(PAYOUTS_KEY, ctx.prev);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: PAYOUTS_KEY }),
  });
}

export function useUpdatePaymentConfig() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ provider, payload }: { provider: string; payload: UpdatePaymentConfigRequest }) =>
      paymentsApi.updateConfig(provider, payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: [...PAYMENTS_KEY, 'gateway-configs'] }),
  });
}

export function useUpdateCommissionConfig() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CommissionConfig) => paymentsApi.updateCommissionConfig(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: [...PAYMENTS_KEY, 'commission-config'] }),
  });
}
