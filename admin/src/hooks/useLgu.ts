import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  lguApi,
  serviceAreaApi,
  type LGUPartnershipInput,
  type ServiceAreaInput,
} from '@/api/super-admin/lgu';

const LGU_KEY = ['admin', 'lgu-partnerships'] as const;
const SA_KEY = ['admin', 'service-areas'] as const;

export function useLguPartnerships() {
  return useQuery({
    queryKey: LGU_KEY,
    queryFn: () => lguApi.list(),
  });
}

export function useServiceAreas() {
  return useQuery({
    queryKey: SA_KEY,
    queryFn: () => serviceAreaApi.list(),
  });
}

export function useCreateLgu() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: LGUPartnershipInput) => lguApi.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: LGU_KEY }),
  });
}

export function useUpdateLgu() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: LGUPartnershipInput }) =>
      lguApi.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: LGU_KEY }),
  });
}

export function useDeleteLgu() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => lguApi.remove(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: LGU_KEY }),
  });
}

export function useCreateServiceArea() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: ServiceAreaInput) => serviceAreaApi.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: SA_KEY }),
  });
}

export function useUpdateServiceArea() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: ServiceAreaInput }) =>
      serviceAreaApi.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: SA_KEY }),
  });
}

export function useDeleteServiceArea() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => serviceAreaApi.remove(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: SA_KEY }),
  });
}
