// React Query hooks for transactions, payouts, summaries, and gateway/commission configs.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  paymentsApi,
  type CommissionConfig,
  type UpdatePaymentConfigRequest,
} from '@/api/super-admin/payments';

const PAYMENTS_KEY = ['admin', 'payments'] as const;

export function useTransactions() {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'transactions'] as const,
    queryFn: () => paymentsApi.getTransactions(),
  });
}

export function usePayouts() {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'payouts'] as const,
    queryFn: () => paymentsApi.getPayouts(),
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

export function useGatewayConfigs() {
  return useQuery({
    queryKey: [...PAYMENTS_KEY, 'gateway-configs'] as const,
    queryFn: () => paymentsApi.getGatewayConfigs(),
  });
}

export function useApprovePayout() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => paymentsApi.approvePayout(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: [...PAYMENTS_KEY, 'payouts'] }),
  });
}

export function useBatchApprovePayouts() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (ids: string[]) => paymentsApi.batchApprovePayouts(ids),
    onSuccess: () => qc.invalidateQueries({ queryKey: [...PAYMENTS_KEY, 'payouts'] }),
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
