// React Query hooks for incidents, KYC queue, LTFRB compliance.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { safetyApi, type KycBatchRequest } from '@/api/super-admin/safety';

const SAFETY_KEY = ['admin', 'safety'] as const;
const INCIDENTS_KEY = [...SAFETY_KEY, 'incidents'] as const;
const KYC_KEY = [...SAFETY_KEY, 'kyc'] as const;
const LTFRB_KEY = [...SAFETY_KEY, 'ltfrb'] as const;

export function useIncidents(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: INCIDENTS_KEY,
    queryFn: () => safetyApi.getIncidents(),
    refetchInterval: options?.refetchInterval,
  });
}

export function useKycQueue(options?: { refetchInterval?: number }) {
  return useQuery({
    queryKey: KYC_KEY,
    queryFn: () => safetyApi.getKycQueue(),
    refetchInterval: options?.refetchInterval,
  });
}

export function useLtfrbCompliance() {
  return useQuery({
    queryKey: LTFRB_KEY,
    queryFn: () => safetyApi.getLtfrbCompliance(),
  });
}

export function useIncident(id: string | null) {
  return useQuery({
    queryKey: [...INCIDENTS_KEY, id],
    queryFn: () => safetyApi.getIncident(id as string),
    enabled: !!id,
  });
}

export function useResolveIncident() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, notes }: { id: string; notes: string }) =>
      safetyApi.resolveIncident(id, notes),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: INCIDENTS_KEY });
      qc.invalidateQueries({ queryKey: [...INCIDENTS_KEY, vars.id] });
    },
  });
}

export function useAssigneeCandidates() {
  return useQuery({
    queryKey: [...SAFETY_KEY, 'assignees'],
    queryFn: () => safetyApi.getAssigneeCandidates(),
  });
}

export function useAssignIncident() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, assigneeId }: { id: string; assigneeId: string | null }) =>
      safetyApi.assignIncident(id, assigneeId),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: INCIDENTS_KEY });
      qc.invalidateQueries({ queryKey: [...INCIDENTS_KEY, vars.id] });
    },
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
