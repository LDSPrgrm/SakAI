import React, { createContext, useContext, useEffect, useState } from 'react';
import { api, tokenStore, UserProfile } from '@/lib/api';
import { AdminRole, Permission, checkPermission } from '@/lib/permissions';

// Admin users have role injected from the JWT or backend profile.
// The mobile UserProfile role is 'passenger' | 'driver', so we extend here.
export interface AdminProfile extends Omit<UserProfile, 'role'> {
  role: AdminRole;
}

interface AuthContextValue {
  user: AdminProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  hasPermission: (permission: Permission) => boolean;
}

const AuthContext = createContext<AuthContextValue | null>(null);

// Derive admin role from backend user profile.
// The mobile API returns role = 'passenger' | 'driver', which means this
// admin panel is accessed by admin users. We default to 'super_admin' for now
// until the backend ships admin-role claims in the JWT.
function deriveAdminRole(user: UserProfile): AdminRole {
  const roleMap: Record<string, AdminRole> = {
    super_admin: 'super_admin',
    operations: 'operations',
    finance: 'finance',
    support: 'support',
  };
  return roleMap[(user as unknown as Record<string, string>).role] ?? 'super_admin';
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AdminProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const token = tokenStore.getAccess();
    if (!token) {
      setIsLoading(false);
      return;
    }
    api.users.me()
      .then((profile) => setUser({ ...profile, role: deriveAdminRole(profile) }))
      .catch(() => tokenStore.clear())
      .finally(() => setIsLoading(false));
  }, []);

  const login = async (email: string, password: string) => {
    const res = await api.auth.login({ email, password });
    tokenStore.set(res.access_token, res.refresh_token);
    setUser({ ...res.user, role: deriveAdminRole(res.user) });
  };

  const logout = async () => {
    const refresh = tokenStore.getRefresh();
    if (refresh) await api.auth.logout(refresh).catch(() => {});
    tokenStore.clear();
    setUser(null);
  };

  const hasPermission = (permission: Permission): boolean => {
    if (!user) return false;
    return checkPermission(user.role, permission);
  };

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, isLoading, login, logout, hasPermission }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
