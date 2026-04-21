// React Query hooks for admin user CRUD (super-admin only).

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminsApi, type CreateAdminPayload, type UpdateAdminPayload } from '@/api/super-admin/admins';

const ADMINS_KEY = ['admin', 'admins'] as const;

export function useAdmins() {
  return useQuery({
    queryKey: ADMINS_KEY,
    queryFn: () => adminsApi.list(),
  });
}

export function useCreateAdmin() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateAdminPayload) => adminsApi.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ADMINS_KEY }),
  });
}

export function useUpdateAdmin() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateAdminPayload }) =>
      adminsApi.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ADMINS_KEY }),
  });
}

export function useDeactivateAdmin() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminsApi.deactivate(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ADMINS_KEY }),
  });
}

export function useResetAdminPassword() {
  return useMutation({
    mutationFn: ({ id, password }: { id: string; password: string }) =>
      adminsApi.resetPassword(id, password),
  });
}
