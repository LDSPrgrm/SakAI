import { useAuth } from '@/contexts/AuthContext';
import { Permission } from '@/lib/permissions';

export function usePermission(permission: Permission): boolean {
  const { hasPermission } = useAuth();
  return hasPermission(permission);
}
