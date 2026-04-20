// React Query hook for admin-side ride browsing.

import { useQuery } from '@tanstack/react-query';
import { ridesApi, type AdminListParams } from '@/api/admin/rides';

const RIDES_KEY = ['admin', 'rides'] as const;

export function useRides(params: AdminListParams = {}) {
  return useQuery({
    queryKey: [...RIDES_KEY, params] as const,
    queryFn: () => ridesApi.list(params),
  });
}
