// React Query hooks for CRUD on admin roles + permission sets.
// Spec: superadmin.md §4.3 (Role Management)

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { rolesApi, type Role, type RolePermission } from '@/api/super-admin/roles';

const ROLES_KEY = ['admin', 'roles'] as const;

export function useRoles() {
  return useQuery({
    queryKey: ROLES_KEY,
    queryFn: () => rolesApi.list(),
  });
}

export function useCreateRole() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { name: string; description: string; permissions: RolePermission[] }) =>
      rolesApi.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ROLES_KEY }),
  });
}

export function useUpdateRole() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: {
      id: string;
      data: { name: string; description: string; permissions: RolePermission[] };
    }) => rolesApi.update(id, data),
    onSuccess: (updated) => {
      qc.setQueryData<Role[]>(ROLES_KEY as unknown as readonly unknown[], (old) =>
        old ? old.map((r) => (r.id === updated.id ? updated : r)) : old,
      );
      return qc.invalidateQueries({ queryKey: ROLES_KEY });
    },
  });
}

export function useDeleteRole() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => rolesApi.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ROLES_KEY }),
  });
}

export function useDuplicateRole() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => rolesApi.duplicate(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ROLES_KEY }),
  });
}

export type { Role, RolePermission };
