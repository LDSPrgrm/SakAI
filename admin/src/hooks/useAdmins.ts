// React Query hooks for admin user CRUD (super-admin only).

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminsApi, type CreateAdminPayload, type UpdateAdminPayload } from '@/api/super-admin/admins';

const ADMINS_KEY = ['admin', 'admins'] as const;
const ROLES_KEY = ['admin', 'roles'] as const;

export function useAdmins() {
  return useQuery({
    queryKey: ADMINS_KEY,
    queryFn: () => adminsApi.list(),
  });
}

function invalidateAdminsAndRoles(qc: ReturnType<typeof useQueryClient>) {
  qc.invalidateQueries({ queryKey: ADMINS_KEY });
  qc.invalidateQueries({ queryKey: ROLES_KEY });
}

export function useCreateAdmin() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateAdminPayload) => adminsApi.create(data),
    onSuccess: () => invalidateAdminsAndRoles(qc),
  });
}

export function useUpdateAdmin() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateAdminPayload }) =>
      adminsApi.update(id, data),
    onSuccess: () => invalidateAdminsAndRoles(qc),
  });
}

export function useDeactivateAdmin() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminsApi.deactivate(id),
    onSuccess: () => invalidateAdminsAndRoles(qc),
  });
}

export function useResetAdminPassword() {
  return useMutation({
    mutationFn: ({ id, password }: { id: string; password: string }) =>
      adminsApi.resetPassword(id, password),
  });
}
