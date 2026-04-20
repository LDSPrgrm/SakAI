import React from 'react';
import { Navigate } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { usePermissions, type PermissionScope } from '@/hooks/usePermissions';
import type { PermissionKey } from '@/utils/permissions';

interface Props {
  permission: PermissionKey;
  scope?: PermissionScope;
  children: React.ReactNode;
}

export function RequirePermission({ permission, scope = 'read', children }: Props) {
  const { user, isAuthenticated, isLoading: authLoading } = useAuth();
  const { can, loading: permsLoading } = usePermissions();

  if (authLoading || permsLoading) {
    return (
      <div className="flex-1 flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin text-primary" />
      </div>
    );
  }
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (can(permission, scope)) return <>{children}</>;

  const fallback = user?.role === 'superadmin' ? '/super-admin/dashboard' : '/admin/dashboard';
  return <Navigate to={fallback} replace />;
}
