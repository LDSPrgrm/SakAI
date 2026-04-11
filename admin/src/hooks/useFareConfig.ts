// React Query hooks for base fare + surge configuration.
// Spec: superadmin.md §4.4 (Fare Configuration)

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { faresApi, type FareConfig, type SurgeConfig } from '@/api/super-admin/fares';

const FARES_KEY = ['admin', 'fares'] as const;
const SURGE_KEY = ['admin', 'surge'] as const;

export function useFareConfigs() {
  return useQuery({
    queryKey: FARES_KEY,
    queryFn: () => faresApi.getConfigs(),
  });
}

export function useSurgeConfig() {
  return useQuery({
    queryKey: SURGE_KEY,
    queryFn: () => faresApi.getSurge(),
  });
}

export function useUpdateFareConfig() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<FareConfig>[]) => faresApi.updateConfigs(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: FARES_KEY }),
  });
}

export function useUpdateSurgeConfig() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<SurgeConfig>) => faresApi.updateSurge(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: SURGE_KEY }),
  });
}

export function useSimulateFare() {
  return useMutation({
    mutationFn: ({ vehicle, origin, destination }: {
      vehicle: string;
      origin: { lat: number; lng: number };
      destination: { lat: number; lng: number };
    }) => faresApi.simulate(vehicle, origin, destination),
  });
}
