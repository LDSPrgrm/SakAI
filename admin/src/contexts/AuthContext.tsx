import React, { createContext, useContext, useEffect, useState } from 'react';
import { api, tokenStore, UserProfile } from '@/lib/api';
import { AdminRole } from '@/lib/permissions';
import { usePermissionsStore } from '@/hooks/usePermissions';

// Admin users have role + role_id injected from the backend JWT payload.
export interface AdminProfile extends Omit<UserProfile, 'role'> {
  role: AdminRole;
  role_id?: string;
}

interface AuthContextValue {
  user: AdminProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function applyAdminProfile(raw: UserProfile): AdminProfile {
  const r = raw as unknown as Record<string, string>;
  const role = ((r['role'] as AdminRole) ?? 'support') as AdminRole;
  const role_id = r['role_id'];
  return { ...raw, role, role_id };
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AdminProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const afterAuth = (profile: AdminProfile) => {
    setUser(profile);
    // Self-scoped fetch — backend resolves role from the JWT. Users with no
    // role_id get an empty permissions array, so no client-side guard needed.
    void usePermissionsStore.getState().loadPermissions();
  };

  useEffect(() => {
    const token = tokenStore.getAccess();
    if (!token) {
      setIsLoading(false);
      return;
    }
    api.users.me()
      .then((profile) => afterAuth(applyAdminProfile(profile)))
      .catch(() => tokenStore.clear())
      .finally(() => setIsLoading(false));
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const login = async (email: string, password: string) => {
    const res = await api.auth.login({ email, password });
    tokenStore.set(res.access_token, res.refresh_token);
    afterAuth(applyAdminProfile(res.user));
  };

  const logout = async () => {
    const refresh = tokenStore.getRefresh();
    if (refresh) await api.auth.logout(refresh).catch(() => { });
    tokenStore.clear();
    usePermissionsStore.getState().clear();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
