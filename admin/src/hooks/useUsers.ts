// React Query hooks for passenger + driver user lists.
// Spec: CLAUDE.md rule #5 — server state via React Query.

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { usersApi, type UserListParams } from '@/api/admin/users';
import type { AdminStatus } from '@/types/super-admin';

const USERS_KEY = ['admin', 'users'] as const;

export function usePassengers(params: UserListParams = {}) {
  return useQuery({
    queryKey: [...USERS_KEY, 'passengers', params] as const,
    queryFn: () => usersApi.getPassengers(params),
  });
}

export function useDrivers(params: UserListParams = {}) {
  return useQuery({
    queryKey: [...USERS_KEY, 'drivers', params] as const,
    queryFn: () => usersApi.getDrivers(params),
  });
}

export function useUpdateUserStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: AdminStatus }) =>
      usersApi.updateStatus(id, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: USERS_KEY }),
  });
}
