// React Query hooks for incidents, KYC queue, LTFRB compliance.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { safetyApi, type KycBatchRequest } from '@/api/super-admin/safety';

const SAFETY_KEY = ['admin', 'safety'] as const;
const INCIDENTS_KEY = [...SAFETY_KEY, 'incidents'] as const;
const KYC_KEY = [...SAFETY_KEY, 'kyc'] as const;
const LTFRB_KEY = [...SAFETY_KEY, 'ltfrb'] as const;

export function useIncidents() {
  return useQuery({
    queryKey: INCIDENTS_KEY,
    queryFn: () => safetyApi.getIncidents(),
  });
}

export function useKycQueue() {
  return useQuery({
    queryKey: KYC_KEY,
    queryFn: () => safetyApi.getKycQueue(),
  });
}

export function useLtfrbCompliance() {
  return useQuery({
    queryKey: LTFRB_KEY,
    queryFn: () => safetyApi.getLtfrbCompliance(),
  });
}

export function useResolveIncident() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, notes }: { id: string; notes: string }) =>
      safetyApi.resolveIncident(id, notes),
    onSuccess: () => qc.invalidateQueries({ queryKey: INCIDENTS_KEY }),
  });
}

export function useUpdateKyc() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: 'approved' | 'rejected' }) =>
      safetyApi.updateKyc(id, status),
    onSuccess: () => qc.invalidateQueries({ queryKey: KYC_KEY }),
  });
}

export function useBatchKyc() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload: KycBatchRequest) => safetyApi.batchKyc(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: KYC_KEY }),
  });
}
